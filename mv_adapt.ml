(*
   Track a signal and estimate a good window length for estimating
   an average.
   - The window should be shorter when the average is changing.
   - The window should be longer when the signal is noisy.
*)

open Printf

type state = {
  alpha_avg: float;
  alpha_missing: float;

  avg: Mv_avg.state;
  missing: Mv_avg.state;

  mutable smoothed: float;
}

let default_alpha_avg = 0.05
let default_alpha_missing = 0.5

let init
  ?(alpha_avg = default_alpha_avg)
  ?(alpha_missing = default_alpha_missing)
  () =

  {
    alpha_avg;
    alpha_missing;
    avg = Mv_avg.init ~alpha:alpha_avg ();
    missing = Mv_avg.init ~alpha:alpha_missing ();
    smoothed = nan;
  }

let update state x =
  assert (x = x);
  let diff =
    let last = Mv_avg.get state.avg in
    if last = last then
      x -. last
    else
      0.
  in
  Mv_avg.update state.avg x;
  Mv_avg.update state.missing diff;
  let avg = Mv_avg.get state.avg in
  let missing = Mv_avg.get state.missing in
  let smoothed = avg +. missing in
  state.smoothed <- smoothed

let get_smoothed state =
  state.smoothed
