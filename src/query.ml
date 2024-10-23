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
  | Equals(t1,t2) -> let s = save () in
      try
        let _ = unify t1 t2 in
        true
      with
        Unification_failure  -> restore s ; false
  | Atom (s, l) -> let q' = atom_to_query s l in has_solution ~atom_to_query:atom_to_query q'



let search ?atom_to_query process_result q = match q with
  | True | False -> if has_solution q then process_result ()
  | And(t1, t2) -> search ~atom_to_query:atom_to_query (fun result -> search ~atom_to_query:atom_to_query process_result t2) t1
  | Or (t1, t2) ->
    let s = Term.save () in (
      search ~atom_to_query:atom_to_query process_result t1;
      Term.restore s;
      search ~atom_to_query:atom_to_query process_result t2;
      Term.restore s;
    )
  | Equals(t1, t2) ->
    let s = save () in
    try
      let _ = Unify.unify t1 t2 in
      process_result
    with
      Unification_failure  -> restore s
  | Atom(s, l) -> search ~atom_to_query:atom_to_query process_result (atom_to_query s l)
    
    
    
    
    
    
    
    
    
    
    
    
    (*if has_solution q then process_result ()
  | Or (t1, t2) -> let s = save () in
    if has_solution t1 then (
      process_result () ;
      restore s ;
      (* On sait qu'à t1 ça marche donc peu importe t2, ca marche *)
      (* Ici, il faut afficher plein de solutions en modifiant à chaque fois t2 *)
    );
    if has_solution t2 then (
      process_result () ;
      restore s ;
      (* On sait qu'à t1 ça marche donc peu importe t2, ca marche *)
      (* Ici, il faut afficher plein de solutions en modifiant à chaque fois t2 *)
    )
  | Equals(t1, t2) -> (* ici, peut etre que ça marche grâce à un unify bien choisi *)
    (* et il faut savoir si unify peut faire d'autres affectations qui fonctionnent, pour lui demander de le faire après *)
    
    *)
    