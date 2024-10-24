val to_asci : string -> int
val convert_term_with_hash :
  string Ast.Term.t -> (string, Term.var) Hashtbl.t -> Term.t
val convert_term_list :
  string Ast.Term.t list -> (string, Term.var) Hashtbl.t -> Term.t list
val convert_term_t : string Ast.Term.t -> Term.t
val convert_ast_to_query_atom : string Ast.Atom.t -> Query.t
exception Not_matching_rule
val convert_result : Query.t -> Query.t -> Query.t
val convert_hyp : string Ast.Atom.t list -> Query.t
val convert_1_rule :
  Query.t -> string Ast.Atom.t * string Ast.Atom.t list -> Query.t

(** Conversion des règles parsées en un [atom_to_query_t] utilisable
par [Query.search] pour résoudre des requêtes en intégrant les
règles d'inférence données. *)
val rules :
(string Ast.Atom.t * string Ast.Atom.t list) list ->
Query.atom_to_query_t

(** Conversion d'une liste d'atomes parsés en une requête conjonctive.
  La fonction renvoyée peut être appelée quand une solution aura été
  trouvée: elle affiche l'état des variables à ce moment là. *)
val query : string Ast.Atom.t list -> Query.t * (unit -> unit)