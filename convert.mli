(**Renvoie la somme des codes ASCI des caractères contenus dans la chaine passée
en entrée. *)
val to_asci : string -> int

(**Convertis un terme de type [Ast.Term.t] en un terme de type [Term.t] en
utilisant une table de hachage en s'assurant que les variables restent cohérentes
dans les sous-termes.*)
val convert_term_with_hash :
  string Ast.Term.t -> (string, Term.var) Hashtbl.t -> Term.t

(**Transforme une liste de termes de type [Ast.Term.t] en liste de termes de
type [Term.t]. La table de hachage est nécessaire pour garantir que les variables
restent cohérentes dans les sous termes.*)
val convert_term_list :
  string Ast.Term.t list -> (string, Term.var) Hashtbl.t -> Term.t list

(**Transforme un terme de type [Ast.Term.t] en terme de type [Term.t]*)
val convert_term_t : string Ast.Term.t -> Term.t


(**Transforme un atome de type [Ast.Atom] en une requête issue du constructeur
[Query.Atom]. *)
val convert_ast_to_query_atom : string Ast.Atom.t -> Query.t

exception Not_matching_rule


(** Cette fonction prend un atome et une règle, et renvoie une conjonction
  d'égalités entre les termes de l'atome et de la règle. *)
val convert_result : Query.t -> Query.t -> Query.t

(** Cette fonction prend en argument une liste d'hypothèses pour appliquer une
  règle, et renvoie une conjonction de ces atomes. *)
val convert_hyp : Query.t list -> Query.t


(** Cette fonction prend en argument une règle et un Query.atome, et renvoie une
  conjonctions d'égalités sur les termes de l'atome et les termes des règles. *)
val convert_1_rule :
  Query.t -> string Ast.Atom.t * string Ast.Atom.t list -> Query.t

(** Conversion des règles parsées en un [atom_to_query_t] utilisable
par [Query.search] pour résoudre des requêtes en intégrant les
règles d'inférence données. *)
val rules : (string Ast.Atom.t * string Ast.Atom.t list) list -> Query.atom_to_query_t

(** Conversion d'une liste d'atomes parsés en une requête conjonctive.
  La fonction renvoyée peut être appelée quand une solution aura été
  trouvée: elle affiche l'état des variables à ce moment là. *)
val query : string Ast.Atom.t list -> Query.t * (unit -> unit)