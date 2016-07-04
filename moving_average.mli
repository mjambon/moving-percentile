type state = private {
  r: float;
  mutable m: float;
}

val init : ?r:float -> m:float -> unit -> state

val update : state -> float -> unit

val get : state -> float
