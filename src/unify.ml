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

  |Term.Fun(f, sous_termes), Term.Var v|Term.Var v, Term.Fun(f, sous_termes) ->
    let tbl = Term.get_global_state() in 
    (match Hashtbl.find_opt tbl v with
    |None -> Term.bind v (Term.make f sous_termes)
    |Some t -> unify t (Term.make f sous_termes)            
    )

  |Term.Var v1, Term.Var v2 -> let tbl = Term.save () in
    (match Hashtbl.find_opt tbl v1, Hashtbl.find_opt tbl v2 with
    |None, None -> Term.bind v1 (Term.var v2) 
    |None, Some t -> Term.bind v1 t
    |Some t, None -> Term.bind v2 t
    |Some t1', Some t2' -> unify t1' t2')