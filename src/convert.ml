let variable_table (*todo utiliser une hashtbl str -> int pour les variables*)


let to_asci str = let rec aux str somme index = if index=(String.length str) then somme else
  let code = Char.code str.[index] in aux str (somme+code) (index+1)
in aux str 0 0;; 


let rec convert_atom_t t = match t with
  | App (str, tl) -> Term.Fun(str, convert_atom_t tl)
  | Var v -> Term.var v


exception Not_matching_rule

let equality

let rec convert_result atom rgl = match (atom, rgl) with
  (* Cette fonction prend un atome et une règle, et renvoie une conjonction d'égalités entre les termes de l'atome et de la règle *)
  | (Atom (_, []), Atom (_, [])) -> True
  | (Atom(s1, t1::q1), Atom(s2, t2::q2)) when s1 <> s2 -> raise Not_matching_rule
  | (Atom(s2, t1::q1), Atom(s2, t2::q2)) -> And( Equal( convert_atom_t t1, convert_atom_t t2 ), convert_result Atom(s, q1) Atom(s2, q12))


let convert_hyp hyp_l =




let convert_1_rule atom (rgl, hyp_l) =
(* cette fonction prend en argument une règle et un atome, et renvoie une conjonctions d'égalités sur les termes de l'atome
  et les termes des règles*)

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
