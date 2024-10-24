let variable_table (*todo utiliser une hashtbl str -> int pour les variables*)


let to_asci str = let rec aux str somme index = if index=(String.length str) then somme else
  let code = Char.code str.[index] in aux str (somme+code) (index+1)
in aux str 0 0;; 


let rec convert_atom_t t = match t with
  | App (str, tl) -> Term.Fun(str, convert_atom_t tl)
  | Var v -> Term.var v
