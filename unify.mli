(** La fonction unify prend deux termes et effectue des instantiations
  * pour les unifier. Par effet de bord elle rend les termes égaux,
  * si possible; sinon elle lève l'exception Unification_failure.
  * Elle n'effectue jamais plus d'instantiations que nécessaire.
  *
  * On ne demande pas forcément que l'état des variables soit inchangé
  * en cas d'échec. *)

exception Unification_failure

(** La fonction [unify] cherche par des instantiations à rendre les deux termes
passés en paramètre égaux. En cas d'échec, elle lève l'exception 
[Unification_failure], et l'état des variables peut avoir été modifié. En cas de
succès, l'état des variables permet l'égalité des termes.*)
val unify : Term.t -> Term.t -> unit
