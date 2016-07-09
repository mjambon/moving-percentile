type state = private {
  r: float;
    (* weight of the latest observation *)

  age_min: int;
    (* age beyond which we use r as is, derived from r. *)

  mutable m: float;
    (* current estimate of the average, initially nan. *)

  mutable age: int;
    (* number of observations *)
}

val init : ?r:float -> unit -> state

val update : state -> float -> unit

val get : state -> float
