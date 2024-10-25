

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
      Hashtbl.add tbl v x; (* on ajoute cette variable pour subrequete à la hashtlb local*)
      let t = Term.var x in 
      (*Term.bind x t;*) 
      t
and convert_term_list tl tbl = let rec aux tl l = match tl with
      | [] -> l
      | t::ts -> (convert_term_with_hash t tbl )::(aux ts l)
    in aux tl [];;
  

let convert_term_t t = let sv = Term.save () in
   let tbl = Hashtbl.create 10 in let x = convert_term_with_hash t tbl
  in Term.restore sv; x;;


let convert_ast_to_query_atom atom = let tbl = Hashtbl.create 10 in
  match atom with
  | Ast.Atom.Atom(s, terms) -> Query.Atom(s, convert_term_list terms tbl)


exception Not_matching_rule



let rec convert_result atom rgl = let open Query in match (atom, rgl) with
  (* Cette fonction prend un atome et une règle, et renvoie une conjonction d'égalités entre les termes de l'atome et de la règle *)
  | (Query.Atom (s1, []), Query.Atom (s2, [])) -> if s1 = s2 then Query.True else Query.False
  | (Query.Atom(s1, t1::q1), Query.Atom(s2, t2::q2)) when s1 <> s2 -> raise Not_matching_rule
  | (Query.Atom(s1, t1::q1), Query.Atom(s2, t2::q2)) -> Query.And( Query.Equals(t1, t2 ), convert_result (Query.Atom(s1, q1)) (Query.Atom(s2, q2)))
  | _ -> failwith "Cette requete ne correspond a aucune regle connue\n"

let rec convert_hyp hyp_l = match hyp_l with
(* cette fonction prend en argument une liste d'hypothèses pour appliquer une règle, et renvoie une conjonction de ces atomes *)
  | [] -> Query.True
  | [atom] -> convert_ast_to_query_atom atom
  | atom::suite_atomes -> Query.And((convert_ast_to_query_atom atom), convert_hyp suite_atomes)




let convert_1_rule atom (ccl, hyp_l) = match hyp_l with
(* cette fonction prend en argument une règle et un Query.atome, et renvoie une conjonctions d'égalités sur les termes de l'atome
  et les termes des règles*)
  | [] -> let ccl_query = convert_ast_to_query_atom ccl in
    (match atom, ccl_query with
      | Query.Atom(s1, l1), Query.Atom(s2, l2) -> let compt = ref (s1 = s2) in
        List.iter2 (fun t1 t2 -> compt := !compt && Term.equals t1 t2) l1 l2 ;
        if !compt then
          Query.True
        else
          convert_result atom (convert_ast_to_query_atom ccl)
        
      | _ -> failwith "convert_1_rule : C'est pas des atomes ca frero"
    )
  | _ -> let gauche = convert_result atom (convert_ast_to_query_atom ccl) in
          (if gauche = Query.False then (*pas d'application possible car la regle ne matche pas*)
            Query.False
          else
            Query.And(gauche, convert_hyp hyp_l))


let rules regles =
  (* Cette fonction prend en argument une liste de regles et renvoie une fonction qui prend en argument un atome
    et construit une requête correspondant à l'atome *)
  let rec aux rem_rules s_atom l_atom = match rem_rules with
  | [] -> Query.False
  | [regle] -> convert_1_rule (Query.Atom(s_atom, l_atom)) regle
  | regle::suite_regles -> let gauche = convert_1_rule (Query.Atom(s_atom, l_atom)) regle in
    (if gauche = Query.False then
      aux suite_regles s_atom l_atom
    else
      Query.Or(gauche, aux suite_regles s_atom l_atom))
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
