type param = private {
  p : float;
  lambda : float;
  q : float;
  delta_dilation_factor : float;
  delta_shrinking_factor : float;
}

type side = Below | Above

type state = private {
  param : param;
  mutable m : float;
  mutable delta : float;
  mutable previous_side : side;
}

val update : state -> float -> unit

val init :
  ?m:float ->
  ?delta:float ->
  p:float ->
  lambda:float ->
  unit -> state
