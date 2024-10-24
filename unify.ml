exception Unification_failure

let rec unify t1 t2 =
  match t1, t2 with
  |Term.Fun(f, sous_termes1), Term.Fun(g, sous_termes2) ->
    if f=g then
      try 
        List.iter2 unify sous_termes1 sous_termes2
      with
        _ -> raise Unification_failure
    else
      raise Unification_failure

  |t, Term.Var v|Term.Var v, t ->
    let tbl = Term.get_global_state() in 
    (match Hashtbl.find_opt tbl v with
    |None -> if Term.is_var_in_term v t then
        raise Unification_failure
    else
      Term.bind v t
    |Some t' -> unify t t'
    )