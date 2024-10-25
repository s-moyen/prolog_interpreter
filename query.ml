type t =
  | Atom of string * Term.t list
  | Equals of Term.t * Term.t
  | And of t * t
  | Or of t * t
  | False
  | True




(* Term.pp terme*)

let rec pp formatter query = 
  match query with
  | False -> print_string "⊥"

  | True -> print_string "T"
  
  | Equals (t1, t2) -> (
    Term.pp (Format.std_formatter) t1;
    print_string " = ";
    Term.pp (Format.std_formatter) t2)
  | And (t1, t2) ->
    (print_string "(";
    pp f t1;
    print_string " ∧ ";
    pp f t2;
    print_string ")")
  | Or (t1, t2) ->
      (print_string "(";
      pp f t1;
      print_string " V ";
      pp f t2;
      print_string ")")
  | Atom(s, l) -> Term.pp f (Fun(s, l))


(* atom to query : transforme en disjonction de toutes les règles applicables *)
type atom_to_query_t = string -> Term.t list -> t

(* f ~x:6 5 *)

let get_atom_to_query atom_to_query = 
  match atom_to_query with
  | Some x -> x
  | None -> (fun s terms -> False)


let rec search ?atom_to_query process_result q =
  print_string "Nouvelle requête : " ; pp (Format.std_formatter) q; print_string "\n";
  match q with
  | True | False -> if q = True then process_result ()
  | And(t1, t2) -> search ~atom_to_query:(get_atom_to_query atom_to_query) (fun () -> search ~atom_to_query:(get_atom_to_query atom_to_query) process_result t2) t1
  | Or (t1, t2) ->
    let s = Term.save () in (
      search ~atom_to_query:(get_atom_to_query atom_to_query) process_result t1;
      Term.restore s
  | And(q1, q2) -> 
    let inner_process = (fun () -> search ~atom_to_query:atom_to_query process_result q2) in
    search ~atom_to_query:atom_to_query inner_process q1

  | Or (q1, q2) ->
    let original_state = Term.save () in (
      search ~atom_to_query:atom_to_query process_result q1;
      Term.restore original_state;

      search ~atom_to_query:atom_to_query process_result q2;
      Term.restore original_state;
    )

  | Equals(t1, t2) ->
    let original_state = Term.save () in (
      try
        let _ = Unify.unify t1 t2 in
        process_result ()

      with
        Unify.Unification_failure  -> Term.restore original_state
    )

  | Atom(s, l) ->
    let new_query = (get_atom_to_query atom_to_query) s l in
      search ~atom_to_query:(get_atom_to_query atom_to_query) process_result new_query




let has_solution ?atom_to_query query =
  let solution = ref false in
  let atom_to_query = get_atom_to_query atom_to_query in
  
  search ~atom_to_query:atom_to_query (fun () -> solution := true) query;
  !solution

    