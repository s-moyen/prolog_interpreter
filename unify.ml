exception Unification_failure

let rec unify t1 t2 =
  match t1, t2 with
  |Term.Fun(f, sous_termes1), Term.Fun(g, sous_termes2) ->
    if f=g then
      List.iter2 unify sous_termes1 sous_termes2
    else
      raise Unification_failure
  
  |Term.Var v1, Term.Var v2 -> 
    if v1 <> v2 then
    let tbl = Term.get_global_state () in
    (match Hashtbl.find_opt tbl v1, Hashtbl.find_opt tbl v2 with
    | None, None -> Term.bind v1 (Term.Var v2)
    | None, Some t -> if Term.is_var_in_term v1 t then
        raise Unification_failure
      else
        Term.bind v1 t
    | Some t, None -> if Term.is_var_in_term v2 t then
        raise Unification_failure
      else
        Term.bind v2 t
    | Some t1, Some t2 -> unify t1 t2

    )

  |t, Term.Var v|Term.Var v, t ->
    let tbl = Term.get_global_state() in 
    (match Hashtbl.find_opt tbl v with
    |None -> if Term.is_var_in_term v t then
        raise Unification_failure
    else
      Term.bind v t
    |Some t' -> unify t t'
    )