(* Term.afficher_terme terme*)

let rec pp f obj = match obj with
  | False -> print_string "⊥"
  | True -> print_string "T"
  | Equals (t1, t2) ->
    Term.afficher_terme t1;
    print_string " = ";
    Term.afficher_terme t2;
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
      List.iter Term.afficher_terme l;
      print_string ")";


(* atom to query : transforme en disjonction de toutes les règles applicables *)



let search ?atom_to_query process_result q = match q with
  | True | False -> if has_solution q then process_result ()
  | And(t1, t2) -> search ~atom_to_query:atom_to_query (fun () -> search ~atom_to_query:atom_to_query process_result t2) t1
  | Or (t1, t2) ->
    let s = Term.save () in (
      search ~atom_to_query:atom_to_query process_result t1;
      Term.restore s;
      search ~atom_to_query:atom_to_query process_result t2;
      Term.restore s;
    )
  | Equals(t1, t2) ->
    let s = Term.save () in
    try
      let _ = Unify.unify t1 t2 in
      process_result ();
      Term.restore s;
    with
      Unification_failure  -> Term.restore s
  | Atom(s, l) -> search ~atom_to_query:atom_to_query process_result (atom_to_query s l)





let has_solution ?atom_to_query q =
  let solution = ref false
  in
    search ~atom_to_query:atom_to_query (fun () -> solution := true) q
    in
      !solution