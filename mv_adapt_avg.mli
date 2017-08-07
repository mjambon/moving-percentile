(*
   Exponential moving average with alpha parameter that
   adjusts depending on the signal's stability.

   It's designed for returning the most desirable value of a signal
   that converges toward some value:
   - before stabilizing, preference is given to the latest value
   - after stabilizing, preference is give to noise removal
*)

type state

val init :
  ?alpha_gain:float ->
  ?alpha_min:float ->
  ?alpha_max:float ->
  ?track_variance:bool ->
  unit -> state
  (* Initialize a tracker.
     `track_variance` must be set to true for tracking variance and
     standard deviation. *)

val get : state -> float
  (* Return the moving average. *)

val get_age : state -> int
  (* Return the number of observations so far. *)

val get_stdev : state -> float
  (* Return the moving standard deviation.
     Requires the `track_variance` option. *)

val get_normalized : state -> float
  (* Return the normalized signal.
     Requires the `track_variance` option. *)

val update : state -> float -> unit
  (* Add an observation to the tracker. *)

(**/**)

val get_alpha_tracker : state -> Mv_adapt.state
