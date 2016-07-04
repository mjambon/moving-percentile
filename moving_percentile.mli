type param = private {
  p : float;
  delta : float;
  q : float;
}

type state = private {
  param : param;
  mutable m : float;
}

val update : state -> float -> unit

val init :
  ?m:float ->
  p:float ->
  delta:float ->
  unit -> state
