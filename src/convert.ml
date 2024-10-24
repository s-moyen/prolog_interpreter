

let to_asci str = let rec aux str somme index = if index=(String.length str) then somme else
  let code = Char.code str.[index] in aux str (somme+code) (index+1)
in aux str 0 0;;

(*pour convertir un atom_t de type App "f" (Var "X") on veut verifier que X n'est pas déjà une variable (un entier)
pour cela on utilise une hashtable qui associe les variables à des entiers 
La hashtable est local car on ne veut pas que les variables soient partagées entre les différents atom_t*)




let rec convert_atom_with_hash t tbl=   
  match t with
  | Ast.Term.App (str, tl) -> Term.Fun(str, convert_atom_list tl tbl)
  | Ast.Term.Var v -> Printf.printf "Var %s\n" v;
    if Hashtbl.mem tbl v then Term.Var (Hashtbl.find tbl v)
    else 
      let x = Term.fresh () in       Printf.printf "'%s' pas trouve dans la table, on lui associe %d\n" v x;
      Hashtbl.add tbl v x;
      Term.var x
and convert_atom_list tl tbl = let rec aux tl l = match tl with
      | [] -> l
      | t::ts -> (convert_atom_with_hash t tbl)::(aux ts l)
    in aux tl [];;
  

let convert_atom_t t = let tbl = Hashtbl.create 10 in convert_atom_with_hash t tbl;;


exception Not_matching_rule



let rec convert_result atom rgl = let open Query in match (atom, rgl) with
  (* Cette fonction prend un atome et une règle, et renvoie une conjonction d'égalités entre les termes de l'atome et de la règle *)
  | (Atom (_, []), Atom (_, [])) -> True
  | (Atom(s1, t1::q1), Atom(s2, t2::q2)) when s1 <> s2 -> raise Not_matching_rule
  | (Atom(s2, t1::q1), Atom(s2, t2::q2)) -> And( Equal( convert_atom_t t1, convert_atom_t t2 ), convert_result Atom(s, q1) Atom(s2, q12))
  | _ -> failwith "TU Fé Koi"

let rec convert_hyp hyp_l = match hyp_l with
(* cette fonction prend en argument une liste d'hypothèses pour appliquer une règle, et renvoie une conjonction de ces atomes *)
  | [atom] -> convert_atom_t atom
  | atom::suite_atomes -> And((convert_atom_t atom), convert_hyp suite_atomes)
  | _ -> failwith "TU M'AS PAS DONNE UNE LISTE D'ATOMES"




let convert_1_rule atom (rgl, hyp_l) =
(* cette fonction prend en argument une règle et un atome, et renvoie une conjonctions d'égalités sur les termes de l'atome
  et les termes des règles*)
  And(convert_result atom rgl, convert_hyp hyp_l)


let rules regles =
  (* Cette fonction prend en argument une liste de regles et renvoie une fonction qui prend en argument un atome
    et construit une requête correspondant à l'atome *)
  let rec aux atom = match regles with
  | [regle] -> convert_1_rule atom regle
  | regle::suite_regles -> Or(convert_1_rule atom regle, aux suite_regles)
  in
  aux


let rec query atoms =
  match atoms with
  |[Ast.Atom.Atom (s, terms)] -> 
    let state_to_print = ref Term.save Term.global_state in

    let print_one_var v t =
      Printf.printf "Var %d = " v;
      afficher_terme t;
      Printf.printf "\n"
    in

    let print_vars () =
      Hashtbl.iter print_one_var !state_to_print
    in

    Query.Atom(s, terms), print_vars

  |(Ast.Atom.Atom (s, terms))::atoms ->
    match query atoms with
    |q_tail, print_vars -> Query.And(Query.Atom(s, terms), q_tail), print_vars
