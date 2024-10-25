(** Le type [t] correspond à la représentation interne des termes.
  * Le type [var] représente les variables, c'est à dire les objets que
  * l'on peut instantier.
  * Le type [obs_t] correspond à un terme superficiellement explicité. *)

type var = int
type obs_t = Fun of string * obs_t list | Var of var (*TODO changer obs_t list en t list*)
type t = obs_t (*TODO trouver une meilleur ipléementation de t*)


(** Modification d'une variable. *)
val bind : var -> t -> unit

(** Observation d'un terme. *)
val observe : t -> obs_t

(** Egalité syntaxique entre termes et variables. *)

val equals : t -> t -> bool
val var_equals : var -> var -> bool

val is_var_in_term : var -> t -> bool


(** Constructeurs de termes. *)

(** Création d'un terme construit à partir d'un symbole
  * de fonction -- ou d'une constante, cas d'arité 0. *)
val make : string -> t list -> t

(** Création d'un terme restreint à une variable. *)
val var : var -> t

(** Création d'une variable fraîche. *)
val fresh : unit -> var

(** Combinaison des deux précédents. *)
val fresh_var : unit -> t

(** Manipulation de l'état: sauvegarde, restauration. *)

type state =(var, t) Hashtbl.t

(** [save ()] renvoie un descripteur de l'état actuel. *)
val save : unit -> state

(** [restore s] restaure les variables dans l'état décrit par [s]. *)
val restore : state -> unit

(** Remise à zéro de l'état interne du module.
    Garantit que les futurs usages seront comme 
    dans un module fraichement initialisé. *)
val reset : unit -> unit

val pp: Format.formatter -> t -> unit

val get_global_state : unit -> state (* TODO regler ce fix pas ouf *)

val print_one_var : var -> t -> unit
val print_vars : unit -> unit