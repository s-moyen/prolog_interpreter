type var = String
type obs_t = Fun of string * obs_t list | Var of var (*TODO changer obs_t list en t list*)
type t = obs_t (*TODO trouver une meilleur ipléementation de t*)


let tbl = Hashtbl.create 10;;

let bind var t = 
  Hashtbl.add tbl var t;;

let observe t = match t with
  | Fun (str, l)-> t
  | Var x -> match Hashtbl.find_opt tbl x with
      | None -> Var x
      | Some y -> y;;


let rec check l1 l2 f = match l1, l2 with 
  | [], [] -> true
  | x::xs, y::ys -> f x y && check xs ys
  | _ -> false;;

(*attention ça peut faire bobo !*)
let rec equals t1 t2 = match t1,t2 with
  | Var v1, Var v2 -> var_equals v1 v2 (*TODO maybe loop*)
  | Fun (f, v1), Fun (g,v2) -> f=g && check v1 v2 equals
  | Var v, Fun (f,w) | Fun (f,w), Var v-> observe 
and var_equals x y  = 
  match Hashtbl.find_opt tlb x, Hashtbl.find_opt tbl y with
  | None, None -> false (*UB*)
  | None, _  | _, None -> false
  | Some v1, Some v2 -> equals v1 v2;;