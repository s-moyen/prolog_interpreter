type var = int
type obs_t = Fun of string * obs_t list | Var of var (*TODO changer obs_t list en t list*)
type t = obs_t (*TODO trouver une meilleur ipléementation de t*)
type state =(var, t) Hashtbl.t

let variable_cntr = ref 0;;

let global_state = Hashtbl.create 10;;

let bind var t = 
  Hashtbl.add global_state var t;;

let observe t = match t with
  | Fun (str, l)-> t
  | Var x -> match Hashtbl.find_opt global_state x with
      | None -> Var x
      | Some y -> y;;


let rec check l1 l2 f = match l1, l2 with 
  | [], [] -> true
  | x::xs, y::ys -> f x y && check xs ys f
  | _ -> false;;

(*attention ça peut faire bobo !*)
let rec equals t1 t2 = let u1 = observe t1 in let u2 = observe t2 in match u1,u2 with
  | Var v1, Var v2 -> var_equals v1 v2 (*TODO maybe loop*)
  | Fun (f, v1), Fun (g,v2) -> f=g && check v1 v2 equals
  | Var v, Fun (f,w) | Fun (f,w), Var v-> 
        match Hashtbl.find_opt global_state v with
        |None -> false
        |Some t -> equals t (Fun(f, w))
and var_equals x y  = 
  match Hashtbl.find_opt global_state x, Hashtbl.find_opt global_state y with
  | None, None -> false (*UB*)
  | None, _  | _, None -> false
  | Some v1, Some v2 -> equals v1 v2;;


let make str tl = 
    let rec aux str tl obs_list = match tl with
    | [] -> Fun(str, obs_list)
    | t::ts -> (aux str ts (t::obs_list))
in aux str tl [];;

    
(*let var v = let t = Var v in bind v t; t;;*)
let var v = Var v;;

let fresh () = let x = !variable_cntr + 1 in variable_cntr:=x; x;;

let fresh_var () = let v = fresh () in let t = var v in t;;

let save () = Hashtbl.copy global_state;;


let merge_tbl tbl1 tbl2 = Hashtbl.iter (fun k1 v1 -> Hashtbl.add tbl2 k1 v1) tbl1

let restore state = Hashtbl.clear global_state; merge_tbl state global_state;;


let reset () = variable_cntr := 0; Hashtbl.clear global_state;;


let rec afficher_terme t = match t with 
  | Var v -> Printf.printf "Var %d" v
  | Fun(str, ol) -> Printf.printf "%s(" str; afficher_ol_list ol; Printf.printf ");"
and afficher_ol_list ol = match ol with 
    | [] -> ()
    | o::os -> afficher_terme o; afficher_ol_list os;;


Printf.printf "test\n";;