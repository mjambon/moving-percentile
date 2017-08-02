type delta_param = [
  | `Dynamic of float
      (* Factor r by which to multiply the estimated standard deviation.
         r is roughly equivalent to 1/w if we were to extract
         the exact percentile from the last w observations.
      *)
  | `Constant of float
      (* Constant value of delta *)
]

type param = private {
  p : float;
    (* Percentile rank (within 0 .. 1) *)
  delta_param : delta_param;
  q : float;
    (* 1 - p *)
}

type delta_state

type state = private {
  param : param;

  mutable m : float;
    (* Estimated percentile value, i.e. ideally m is such that
       p is the fraction of recent observations less then m. *)

  delta_state: delta_state;
    (* Smaller values of delta increase precision while greater values
       increase reactivity and give more weight to recent observations.
    *)

  mutable delta: float;
    (* delta is the parameter determining by how much to adjust
       the estimated percentile value at each iteration.
       Changes only if delta_param is set to Dynamic. *)

  mutable age: int;
    (* Number of observations so far *)
}

val update : state -> float -> unit

val default_delta_param : delta_param

val init :
  ?delta_param:delta_param ->
  p:float ->
  unit -> state

val get : state -> float
