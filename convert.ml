let to_asci str = 

  let rec loop str somme index = 
    if index = (String.length str) then 
      somme 
    else
      let code = Char.code str.[index] in 
      loop str (somme+code) (index+1)
  in

  loop str 0 0;;

(*pour convertir un atom_t de type App "f" (Var "X") on veut verifier que X n'est pas déjà une variable (un entier)
pour cela on utilise une hashtable qui associe les variables à des entiers 
La hashtable est local car on ne veut pas que les variables soient partagées entre les différents atom_t*)

let tableGLOBAL = Hashtbl.create 10;;

let rec convert_term_with_hash term tbl=  
  match term with
  | Ast.Term.App (str, term_list) -> Term.Fun(str, convert_term_list term_list tbl)

  | Ast.Term.Var v ->
    if Hashtbl.mem tbl v then
      Term.Var (Hashtbl.find tbl v)
      
    else 
      (let x = Term.fresh () in
      Hashtbl.add tbl v x;
      Term.var x)
and convert_term_list term_list tbl = 
  let rec loop term_list l =
    match term_list with
    | [] -> l
    | t::tail_terms -> (convert_term_with_hash t tbl)::(loop tail_terms l)
  in
  
  loop term_list [];;
  

let convert_term_t term = 
  let tbl = Hashtbl.create 10 in 
  convert_term_with_hash term tbl;;


let convert_ast_to_query_atom atom = 
  match atom with
  | Ast.Atom.Atom(s, terms) -> Query.Atom(s, convert_term_list terms tableGLOBAL)



let rec list_ast_to_query liste = match liste with
| [] -> []
| t::q -> (convert_ast_to_query_atom t)::(list_ast_to_query q)

exception Not_matching_rule




let rec convert_result atom rgl = 
  let open Query in 
  match (atom, rgl) with
  | (Query.Atom (s1, []), Query.Atom (s2, [])) -> 
    if s1 = s2 then
      Query.True
    else
      Query.False

  | (Query.Atom(s1, t1::q1), Query.Atom(s2, t2::q2)) when s1 <> s2 -> raise Not_matching_rule

  | (Query.Atom(s1, t1::q1), Query.Atom(s2, t2::q2)) -> 
      Query.And(Query.Equals(t1, t2), convert_result (Query.Atom(s1, q1)) (Query.Atom(s2, q2)))

  | _ -> failwith "Cette requete ne correspond a aucune regle connue\n"


  
let rec convert_hyp hyp_list = 
  match hyp_list with
  | [] -> Query.True
  | [atom] -> atom
  | atom::suite_atomes -> 
    Query.And(atom, convert_hyp suite_atomes)



(* Une première fonction qui prend en entrée une hypothèse et qui renvoie une table de hachage contenant les nouvelles
variables correspondant aux variables de cette hypothèse*)
let rec change_vars_in_terms termes tbl = match termes with
  | [] -> []
  | terme::suite_termes -> let nouveau_terme =  (match terme with
    | Term.Var v ->
        if not (Hashtbl.mem tbl v) then
          let new_var = Term.fresh_var () in
          Hashtbl.add tbl v new_var;
          new_var
        else
          Term.Var v

    | terme -> terme
    )
    in
    nouveau_terme::(change_vars_in_terms suite_termes tbl)

let change_vars tbl hyp =
    match hyp with Query.Atom(s, liste_de_termes) -> Query.Atom(s, change_vars_in_terms liste_de_termes tbl)
    | _ -> failwith "c'est pas une hypothese\n"


let rec change_vars_hyps tbl hyp_list =
  match hyp_list with
  [] -> []
  | hyp::suite_hypotheses -> (change_vars tbl hyp)::(change_vars_hyps tbl suite_hypotheses)



let rename_rule_vars ccl hyp_list =
  let tbl = Hashtbl.create 10 in
  let nouv_hyps = change_vars_hyps tbl hyp_list in
  let nouv_ccl = change_vars tbl ccl in
  (nouv_ccl, nouv_hyps)





  let convert_1_rule atom (conclusion, ast_hyp_list) =
    let hyp_list = list_ast_to_query ast_hyp_list in
    let conclusion2 = convert_ast_to_query_atom conclusion in
    let (conclusion3, hyp_list2) = rename_rule_vars conclusion2 hyp_list in
    match hyp_list2 with
    | [] -> let ccl_query = conclusion3 in (
      match atom, ccl_query with
      | Query.Atom(s1, l1), Query.Atom(s2, l2) -> let compt = ref true in (
        if s1 = s2 then (
          List.iter2 (fun t1 t2 -> compt := !compt && Term.equals t1 t2) l1 l2 ;
          if !compt then
            Query.True
          else
            convert_result atom conclusion3
          )
        else
          Query.False
        )
          
      | _ -> failwith "convert_1_rule : C'est pas des atomes ca frero"
      )

    | _ -> try
        let gauche = convert_result atom (convert_ast_to_query_atom conclusion) in (
        if gauche = Query.False then (*pas d'application possible car la regle ne matche pas*)
          Query.False
        else
          Query.And(gauche, convert_hyp hyp_list))

      with
        Not_matching_rule -> (*la conclusion ne matche même pas*) Query.False
  


let rules regles =
  let rec atom_to_query rem_rules s_atom l_atom = match rem_rules with
  | [] -> Query.False
  | [regle] -> convert_1_rule (Query.Atom(s_atom, l_atom)) regle
  | regle::suite_regles -> 
    let gauche = convert_1_rule (Query.Atom(s_atom, l_atom)) regle in (
    if gauche = Query.False then
      atom_to_query suite_regles s_atom l_atom
    else
      Query.Or(gauche, atom_to_query suite_regles s_atom l_atom))
  in

  atom_to_query regles


let rec query atoms =
  let state_to_print = Term.get_global_state () in
  match atoms with
  |[] -> 
    let print_one_var v t =
      Printf.printf "Var %d = " v;
      Term.pp (Format.std_formatter) t;
      Printf.printf "\n"
    in

    let print_vars () =
      Hashtbl.iter print_one_var state_to_print
    in

    (Query.True), print_vars
  
  |[atom] -> 
    let print_one_var v t =
      Printf.printf "Var %d = " v;
      Term.pp (Format.std_formatter) t;
      Printf.printf "\n"
    in

    let print_vars () =
      if Hashtbl.length state_to_print = 0 then
        print_string "Aucun variable\n"
      else
        print_string "REPONSE : ";
        Hashtbl.iter print_one_var state_to_print;
        print_string "\n"
    in

    (convert_ast_to_query_atom atom), print_vars

  |atom::atoms ->
    match query atoms with
    |q_tail, print_vars -> Query.And(convert_ast_to_query_atom atom, q_tail), print_vars
