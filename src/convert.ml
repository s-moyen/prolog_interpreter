

(*pour convertir un atom_t de type App "f" (Var "X") on veut verifier que X n'est pas déjà une variable (un entier)
pour cela on utilise une hashtable qui associe les variables à des entiers 
La hashtable est local car on ne veut pas que les variables soient partagées entre les différents atom_t*)

let rec convert_atom_t t = 
  let tbl = Hashtbl.create 10 in  
  match t with
  | App (str, tl) -> Term.Fun(str, convert_atom_t tl)
  | Var v -> 
    if Hashtbl.mem tbl v then Term.Var (Hashtbl.find tbl v)
    else 
      let x = Term.fresh () in
      Hashtbl.add tbl v x;
      Term.var x
  
