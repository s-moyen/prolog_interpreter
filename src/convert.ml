

(*pour convertir un atom_t de type App "f" (Var "X") on veut verifier que X n'est pas déjà une variable (un entier)
pour cela on utilise une hashtable qui associe les variables à des entiers 
La hashtable est local car on ne veut pas que les variables soient partagées entre les différents atom_t*)

let rec convert_atom_t t = 
  let tbl = Hashtbl.create 10 in  
  match t with
  | App (str, tl) -> Term.Fun(str, convert_atom_t tl)
  | Var v -> 
    if Hashtbl.mem tbl v then Term.Var (Hashtbl.find tbl v)
    else 
      let x = Term.fresh () in
      Hashtbl.add tbl v x;
      Term.var x


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
