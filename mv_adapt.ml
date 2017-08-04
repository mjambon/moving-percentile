(*
   Track a signal and estimate a good window length for estimating
   an average.
   - The window should be shorter when the average is changing.
   - The window should be longer when the signal is noisy.
*)

type state = {
  short_window: float;
    (* inverse of alpha_max *)

  long_window: float;
    (* inverse of alpha_min *)

  gain: Mv_avg.state;
  loss: Mv_avg.state;
  mutable last_sample: float;
  mutable alpha: float;
}

let default_alpha_gain = 0.1
let default_alpha_min = 0.01
let default_alpha_max = 0.5

let init
  ?(alpha_gain = default_alpha_gain)
  ?(alpha_min = default_alpha_min)
  ?(alpha_max = default_alpha_max)
  () =

  if not (alpha_min <= alpha_max) then
    invalid_arg "Adapt.init";

  {
    short_window = 1. /. alpha_max;
    long_window = 1. /. alpha_min;
    gain = Mv_avg.init ~alpha:alpha_gain ();
    loss = Mv_avg.init ~alpha:alpha_gain ();
    last_sample = nan;
    alpha = alpha_max;
  }

(*
   Return an estimation of the signal's instability as a number
   within [0, 1].
   - instability is near 0 for an oscillator with a short period
     (e.g. signal values are 0, 1, 0, 1, ...)
   - instability is near 1 for a monotonic signal
     (e.g. signal values are 0, 1, 2, 3, ...)
*)
let get_instability ~avg_gain ~avg_loss =
  let abs_elevation = abs_float (avg_gain +. avg_loss) in
  let distance_traveled = avg_gain -. avg_loss in
  assert (distance_traveled >= 0.);
  assert (abs_elevation <= distance_traveled);
  if distance_traveled = 0. then
    1.
  else
    abs_elevation /. distance_traveled

let update state x =
  assert (x = x);
  let diff =
    let last = state.last_sample in
    if last = last then
      x -. last
    else
      0.
  in
  Mv_avg.update state.gain (max diff 0.);
  Mv_avg.update state.loss (min diff 0.);
  state.last_sample <- x;
  let avg_gain = Mv_avg.get state.gain in
  let avg_loss = Mv_avg.get state.loss in
  let instability = get_instability ~avg_gain ~avg_loss in
  let wshort = state.short_window in
  let wlong = state.long_window in
  let window = wshort +. (wlong -. wshort) *. (1. -. instability) in
  let alpha = 1. /. window in
  state.alpha <- alpha

let get_alpha state =
  state.alpha
