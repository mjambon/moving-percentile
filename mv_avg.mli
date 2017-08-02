type state = private {
  mutable alpha: float;
    (* weight of the latest observation *)

  age_min: int;
    (* age beyond which we use r as is, derived from r. *)

  mutable m: float;
    (* current estimate of the average, initially nan. *)

  mutable age: int;
    (* number of observations *)
}

val init : ?alpha:float -> unit -> state

val update : state -> float -> unit

val get : state -> float

val set_alpha : state -> float -> unit
  (* Change the alpha parameter. *)
