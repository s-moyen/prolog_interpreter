(** Le type [t] correspond à la représentation interne des termes.
  * Le type [var] représente les variables, c'est à dire les objets que
  * l'on peut instantier.
  * Le type [obs_t] correspond à un terme superficiellement explicité. *)

type var = int
type obs_t = Fun of string * obs_t list | Var of var (*TODO changer obs_t list en t list*)
type t = obs_t (*TODO trouver une meilleur ipléementation de t*)
type state =(var, t) Hashtbl.t

(**Permet aux fonctions extérieures au module [Term] d'avoir accès à l'état des variables.*)
val get_global_state : unit -> state (* TODO regler ce fix pas ouf *)

(** Modification d'une variable. *)
val bind : var -> t -> unit

(** Observation d'un terme. *)
val observe : t -> obs_t

(** Egalité syntaxique entre termes et variables. *)

(** Vérifie que les deux listes passées en paramètre sont de même longueur et que
tous leurs éléments vérifient un prédicat passé en paramètre. *)
val check_predicate2 : t list -> t list -> (t -> t -> bool) -> bool

(** Vérifie l'égalité de deux termes (de type [t]) *)
val equals : t -> t -> bool
(** Vérifie l'égalité de deux variables (de type [var]) *)
val var_equals : var -> var -> bool


(** Vérification en profondeur de la présence d'une variable [v] dans un terme [t].*)
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

(** [save ()] renvoie un descripteur de l'état actuel. *)
val save : unit -> state

(** L'appel [merge_tbl tbl1 tbl2] ajoute toutes les associations de tbl1 à tbl2
en écrasant les éventuels valeurs précédentes de tbl2 en cas de conflit.*)
val merge_tbl : state -> state -> unit

(** [restore s] restaure les variables dans l'état décrit par [s]. *)
val restore : state -> unit

(** Remise à zéro de l'état interne du module.
    Garantit que les futurs usages seront comme 
    dans un module fraichement initialisé. *)
val reset : unit -> unit

(**Le pretty printer des termes.*)
val pp : Format.formatter -> t -> unit

(** Affiche une liste de termes, séparés pas des virgules.*)
val print_term_list : t list -> unit

(**Affichage de la valeur actuelle d'une variable.*)
val print_one_var : var -> t -> unit

(**Affichage des valeures actuelles de toutes les fonctions.*)
val print_vars : unit -> unit