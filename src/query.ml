(* afficher_terme terme*)

let rec pp f obj = match obj with
  | False -> print_string "⊥"
  | True -> print_string "T"
  | Equals (t1, t2) ->
    Term.afficher_terme t1;
    print_string " = ";
    afficher_terme t2;
  | And (t1, t2) ->
    pp t1;
    print_string " ∧ ";
    pp t2;
  | Or (t1, t2) ->
      pp t1;
      print_string " V ";
      pp t2;
  | Atom(s, l) ->
      print_string s;
      print_string "(";
      List.iter afficher_terme l;
      print_string ")";


(* atom to query : transforme en disjonction de toutes les règles applicables *)

(* f ~x:6 5 *)

let has_solution ?atom_to_query q = match q with
  | True -> true
  | False -> false
  | And(t1, t2) -> (has_solution t1) && (has_solution t2)
  | Or(t1, t2) -> (has_solution t1) || (has_solution t2)
  | Equals(t1,t2) ->
    try
      let _ = unify t1 t2 in
      true
    with
      ->