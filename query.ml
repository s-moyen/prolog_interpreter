type t =
  | Atom of string * Term.t list
  | Equals of Term.t * Term.t
  | And of t * t
  | Or of t * t
  | False
  | True




(* Term.pp terme*)

let rec pp f obj = match obj with
  | False -> print_string "⊥"
  | True -> print_string "T"
  | Equals (t1, t2) -> (
    Term.pp (Format.std_formatter) t1;
    print_string " = ";
    Term.pp (Format.std_formatter) t2)
  | And (t1, t2) ->
    (pp f t1;
    print_string " ∧ ";
    pp f t2)
  | Or (t1, t2) ->
      (pp f t1;
      print_string " V ";
      pp f t2)
  | Atom(s, l) -> (
      print_string s;
      print_string "(";
      List.iter (Term.pp (Format.std_formatter)) l;
      print_string ")")


(* atom to query : transforme en disjonction de toutes les règles applicables *)
type atom_to_query_t = string -> Term.t list -> t

(* f ~x:6 5 *)

let get_atom_to_query atom_to_query = 
  match atom_to_query with
  | Some x -> x
  | None -> (fun (s : string) (terms : Term.t list) -> False)


let rec search ?atom_to_query process_result q = match q with
  | True | False -> if q = True then process_result ()
  | And(t1, t2) -> search ~atom_to_query:(get_atom_to_query atom_to_query) (fun () -> search ~atom_to_query:(get_atom_to_query atom_to_query) process_result t2) t1
  | Or (t1, t2) ->
    let s = Term.save () in (
      search ~atom_to_query:(get_atom_to_query atom_to_query) process_result t1;
      Term.restore s;

      search ~atom_to_query:(get_atom_to_query atom_to_query) process_result t2;
      Term.restore s;
    )
  | Equals(t1, t2) ->
    let s = Term.save () in (
      try
        let _ = Unify.unify t1 t2 in
        process_result ();
      with
        Unify.Unification_failure  -> Term.restore s
    )
  | Atom(s, l) -> search ~atom_to_query:(get_atom_to_query atom_to_query) process_result ((get_atom_to_query atom_to_query) s l)




let has_solution ?atom_to_query q =
  let solution = ref false
  in
    search ~atom_to_query:(get_atom_to_query atom_to_query) (fun () -> solution := true) q;
    !solution

    