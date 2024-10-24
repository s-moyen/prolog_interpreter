

let to_asci str = let rec aux str somme index = if index=(String.length str) then somme else
  let code = Char.code str.[index] in aux str (somme+code) (index+1)
in aux str 0 0;;

(*pour convertir un atom_t de type App "f" (Var "X") on veut verifier que X n'est pas déjà une variable (un entier)
pour cela on utilise une hashtable qui associe les variables à des entiers 
La hashtable est local car on ne veut pas que les variables soient partagées entre les différents atom_t*)




let rec convert_term_with_hash t tbl=  
  match t with
  | Ast.Term.App (str, tl) -> Term.Fun(str, convert_term_list tl tbl)
  | Ast.Term.Var v -> Printf.printf "Var %s\n" v;
    if Hashtbl.mem tbl v then Term.Var (Hashtbl.find tbl v)
    else 
      let x = Term.fresh () in       Printf.printf "'%s' pas trouve dans la table, on lui associe %d\n" v x;
      Hashtbl.add tbl v x;
      Term.var x
and convert_term_list tl tbl = let rec aux tl l = match tl with
      | [] -> l
      | t::ts -> (convert_term_with_hash t tbl)::(aux ts l)
    in aux tl [];;
  

let convert_term_t t = let tbl = Hashtbl.create 10 in convert_term_with_hash t tbl;;


let convert_ast_to_query_atom atom = let tbl = Hashtbl.create 10 in
  match atom with
  | Ast.Atom.Atom(s, terms) -> Query.Atom(s, convert_term_list terms tbl)


exception Not_matching_rule



let rec convert_result atom rgl = let open Query in match (atom, rgl) with
  (* Cette fonction prend un atome et une règle, et renvoie une conjonction d'égalités entre les termes de l'atome et de la règle *)
  | (Query.Atom (_, []), Query.Atom (_, [])) -> Query.True
  | (Query.Atom(s1, t1::q1), Query.Atom(s2, t2::q2)) when s1 <> s2 -> raise Not_matching_rule
  | (Query.Atom(s1, t1::q1), Query.Atom(s2, t2::q2)) -> Query.And( Query.Equals(t1, t2 ), convert_result (Query.Atom(s1, q1)) (Query.Atom(s2, q2)))
  | _ -> failwith "TU Fé Koi"

let rec convert_hyp hyp_l = match hyp_l with
(* cette fonction prend en argument une liste d'hypothèses pour appliquer une règle, et renvoie une conjonction de ces atomes *)
  | [atom] -> convert_ast_to_query_atom atom
  | atom::suite_atomes -> Query.And((convert_ast_to_query_atom atom), convert_hyp suite_atomes)
  | _ -> failwith "TU M'AS PAS DONNE UNE LISTE D'ATOMES"




let convert_1_rule atom (rgl, hyp_l) =
(* cette fonction prend en argument une règle et un Query.atome, et renvoie une conjonctions d'égalités sur les termes de l'atome
  et les termes des règles*)
  Query.And(convert_result atom (convert_ast_to_query_atom rgl), convert_hyp hyp_l)


let rules regles =
  (* Cette fonction prend en argument une liste de regles et renvoie une fonction qui prend en argument un atome
    et construit une requête correspondant à l'atome *)
  let rec aux regles s_atom l_atom = match regles with
  | [] -> Query.False
  | [regle] -> convert_1_rule (Query.Atom(s_atom, l_atom)) regle
  | regle::suite_regles -> Query.Or(convert_1_rule (Query.Atom(s_atom, l_atom)) regle, aux suite_regles s_atom l_atom)
  in
  aux regles


let rec query atoms =
  match atoms with
  |[] -> 
    let state_to_print = ref (Term.save ()) in

    let print_one_var v t =
      Printf.printf "Var %d = " v;
      Term.pp (Format.std_formatter) t;
      Printf.printf "\n"
    in

    let print_vars () =
      Hashtbl.iter print_one_var !state_to_print
    in

    (Query.True), print_vars
  
  |[atom] -> 
    let state_to_print = ref (Term.save ()) in

    let print_one_var v t =
      Printf.printf "Var %d = " v;
      Term.pp (Format.std_formatter) t;
      Printf.printf "\n"
    in

    let print_vars () =
      Hashtbl.iter print_one_var !state_to_print
    in

    (convert_ast_to_query_atom atom), print_vars

  |atom::atoms ->
    match query atoms with
    |q_tail, print_vars -> Query.And(convert_ast_to_query_atom atom, q_tail), print_vars
