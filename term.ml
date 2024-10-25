type var = int
type obs_t = Fun of string * obs_t list | Var of var (*TODO changer obs_t list en t list*)
type t = obs_t (*TODO trouver une meilleur implémentation de t*)
type state =(var, t) Hashtbl.t

exception Recursive_bind

let variable_cntr = ref 0;;

let global_state = Hashtbl.create 10;;
let get_global_state () = global_state;;

let bind var t = 
  Hashtbl.add global_state var t;;

let observe t = match t with
  | Fun (str, l)-> t
  | Var x -> match Hashtbl.find_opt global_state x with
      | None -> Var x
      | Some y -> y;;


let rec check_predicate2 l1 l2 pred = match l1, l2 with 
  | [], [] -> true
  | x::xs, y::ys -> pred x y && check_predicate2 xs ys pred
  | _ -> false;;

(*attention ça peut faire bobo !*)
let rec equals t1 t2 = 

  let u1 = observe t1 in 
  let u2 = observe t2 in 
  
  match u1,u2 with
  | Var v1, Var v2 -> var_equals v1 v2 (*TODO maybe loop*)
  | Fun (f, v1), Fun (g,v2) -> f=g && check_predicate2 v1 v2 equals
  | Var v, Fun (f,w) | Fun (f,w), Var v-> 
        match Hashtbl.find_opt global_state v with
        |None -> false
        |Some t -> equals t (Fun(f, w))
and var_equals x y  = 
  if x = y then 
    true
  else
    match Hashtbl.find_opt global_state x, Hashtbl.find_opt global_state y with
    | None, None -> false (*UB*)
    | None, Some t -> equals (Var x) t
    | Some t, None -> equals (Var y) t
    | Some t1, Some t2 -> equals t1 t2;;


let rec is_var_in_term v t =
  match t with
  | Fun(name, sub) -> 
    List.fold_left (fun acc t' -> acc || is_var_in_term v t') false sub
  | Var v' -> match Hashtbl.find_opt global_state v' with
    |None -> v = v'
    |Some t' -> (v = v') || (is_var_in_term v t')



let make fun_name sub_terms = 

  let rec init_sub_terms fun_name terms_to_init terms_ready = 
    match terms_to_init with
    | [] -> Fun(fun_name, terms_ready)
    | t::tail_terms -> (init_sub_terms fun_name tail_terms (t::terms_ready))
  in 
  
  init_sub_terms fun_name sub_terms [];;


let var v = Var v;;

let fresh () =
  let x = !variable_cntr + 1 in
  variable_cntr := x;
  x;;

let fresh_var () = var (fresh ());;

let save () = Hashtbl.copy global_state;;


let merge_tbl tbl1 tbl2 = Hashtbl.iter (fun k1 v1 -> Hashtbl.add tbl2 k1 v1) tbl1

let restore state = 
  Hashtbl.clear global_state;
  merge_tbl state global_state;;


let reset () = variable_cntr := 0; Hashtbl.clear global_state;;


let rec pp formatter term = 
  match term with 
  | Var v -> Printf.printf "Var %d" v
  | Fun(fun_name, sub_terms) -> Printf.printf "%s(" fun_name;
    print_term_list sub_terms;
    Printf.printf ");"
and print_term_list terms = 
  match terms with 
  | [] -> ()
  | [t] -> pp (Format.std_formatter) t
  | t::tail_terms -> pp (Format.std_formatter) t;
    Printf.printf ", ";
    print_term_list tail_terms;;




let print_one_var v t =
  Printf.printf "Var %d = " v;
  pp (Format.std_formatter) t;
  Printf.printf "\n"


let print_vars () =
  Printf.printf "Affichage des variables :\n\n";
  Hashtbl.iter print_one_var global_state


