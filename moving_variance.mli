type state = private {
  avg: Moving_average.state;
  var: Moving_average.state;
}

val init :
  ?r_avg:float ->
  ?r_var:float ->
  avg:float ->
  var:float ->
  unit -> state

val update : state -> float -> unit

val get : state -> float
val get_average : state -> float
