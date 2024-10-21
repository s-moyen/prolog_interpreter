let _ =
  assert (not (Term.(var_equals (fresh ()) (fresh ()))));

  assert (not (Term.(equals (var (fresh ())) (var (fresh ())))));

  Term.reset () ;
  let v = Term.fresh () in
  let t = Term.make "c" [] in
  Term.bind v t ;
  assert Term.(equals (var v) t) ;

  Term.reset () ;
  let v = Term.fresh () in
  let t = Term.make "c" [] in
  let s = Term.save () in
  assert (not Term.(equals (var v) t)) ;
  Term.bind v t ;
  assert Term.(equals (var v) t) ;
  Term.restore s ;
  assert (not Term.(equals (var v) t));

  Term.reset () ;
  Term.bind (Term.fresh ()) (Term.make "c" []) ;
  let v = Term.fresh () in
  let t = Term.make "c" [] in
  let s = Term.save () in
  Term.bind v t ;
  Term.restore s ;
  assert (not Term.(equals (var v) t)) 


let _ = 
  let open Term in
  reset () ;
  let x = var (fresh ()) in
  let a = make "a" [] in
  let u = make "f" [x;a] in
  let v = make "f" [a;x] in
  assert (not (equals u v)) ;
  Unify.unify u v ;
  assert (equals u v)