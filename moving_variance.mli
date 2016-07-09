type state = private {
  avg: Moving_average.state;
  var: Moving_average.state;
}

val init :
  ?r_avg:float ->
  ?r_var:float ->
  unit -> state

val update : state -> float -> unit
  (* Add an observation *)

val get : state -> float
  (* Return the exponential moving variance.
     We need 2 observations before returning a regular float (not a nan) *)

val get_average : state -> float
  (* Return the exponential moving average, which is maintained
     in order to compute the exponential moving variance.
     We need 1 observation before returning a regular float (not a nan) *)
