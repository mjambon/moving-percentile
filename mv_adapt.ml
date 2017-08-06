(*
   Track a signal and estimate a good window length for estimating
   an average.
   - The window should be shorter when the average is changing.
   - The window should be longer when the signal is noisy.
*)

open Printf

type state = {
  alpha_avg: float;
  alpha_slope: float;

  alpha_avg_half_weight: float;
  alpha_slope_half_weight: float;

  avg: Mv_avg.state;
  slope: Mv_avg.state;

  mutable last_sample: float;
  mutable smoothed: float;
}

(*
let default_alpha_avg = 0.0561257 (* half-weight = 12 samples *)
let default_alpha_slope = 0.1091013 (* half-weight = 6 samples *)
*)
let default_alpha_avg = 0.10
let default_alpha_slope = 0.05

(*
   Determine number of samples with a weight of half in an exponential
   moving average of parameter alpha.

   alpha = 0.0561257 -> 12 samples
   alpha = 0.1091013 -> 6 samples
*)
let get_half_weight alpha =
  let result = ref 0 in
  let sum = ref 0. in
  try
    for i = 0 to 1000 do
      sum := !sum +. alpha *. (1. -. alpha) ** (float i);
      (* printf "[%i] %g\n" i !sum; *)
      if !sum >= 0.5 then (
        result := i;
        raise Exit
      )
    done;
    assert false
  with Exit ->
    !result + 1

let init
  ?(alpha_avg = default_alpha_avg)
  ?(alpha_slope = default_alpha_slope)
  () =

  {
    alpha_avg;
    alpha_slope;
    alpha_avg_half_weight = float (get_half_weight alpha_avg);
    alpha_slope_half_weight = float (get_half_weight alpha_slope);
    avg = Mv_avg.init ~alpha:alpha_avg ();
    slope = Mv_avg.init ~alpha:alpha_slope ();
    last_sample = nan;
    smoothed = nan;
  }

let update state x =
  assert (x = x);
  let diff =
    let last = state.last_sample in
    if last = last then
      x -. last
    else
      0.
  in
  Mv_avg.update state.slope diff;
  Mv_avg.update state.avg x;
  state.last_sample <- x;
  let avg = Mv_avg.get state.avg in
  let slope = Mv_avg.get state.slope in
  let smoothed = avg +. slope *. state.alpha_avg_half_weight in
  state.smoothed <- smoothed

let get_smoothed state =
  state.smoothed
