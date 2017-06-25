(*
   State that tracks moving average and moving variance based on that
   moving average, for a given signal.
*)

type state = private {
  avg: Moving_average.state;
  var: Moving_average.state;

  mutable stdev: float;
    (* square root of the estimated variance *)
  mutable normalized: float;
    (* (signal - mean) / stdev *)
}

val init :
  ?r_avg:float ->
  ?r_var:float ->
  unit -> state

val update : state -> float -> unit
  (* Add an observation *)

val get_average : state -> float
  (* Return the exponential moving average, which is maintained
     in order to compute the exponential moving variance.
     We need 1 observation before returning a regular float (not a nan) *)

val get_variance : state -> float
  (* Return the exponential moving variance.
     We need 2 observations before returning a regular float (not a nan) *)

val get_stdev : state -> float
  (* Square root of the estimated variance *)

val get_normalized : state -> float
  (* Normalized signal, defined as (x - mean) / stdev *)

val get_count : state -> int
  (* Return the number of observations so far, i.e. the number of times
     `update` was called successfully. *)
