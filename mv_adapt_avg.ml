(*
   Exponential moving average with alpha parameter that
   adjusts depending on the signal's stability.

   It's meant to be used as smoothing technique rather than
   a proper statistically-relevant average.
*)

open Printf

type state = {
  alpha_tracker: Mv_adapt.state;
  avg_tracker: Mv_avg.state;

  var_tracker: Mv_avg.state option;
    (* optional variance tracker *)

  mutable stdev: float;
  mutable normalized: float;
    (* `stdev` and `normalized` are available only if
       we're tracking the variance. *)
}

let init
    ?alpha_gain
    ?alpha_min
    ?(alpha_max = Mv_adapt.default_alpha_max)
    ?(track_variance = false)
    () =
  let alpha_tracker =
    Mv_adapt.init
      ?alpha_gain
      ?alpha_min
      ~alpha_max
      ()
  in
  let alpha = alpha_max in
  let avg_tracker =
    Mv_avg.init ~alpha ()
  in
  let var_tracker =
    if track_variance then
      Some (Mv_avg.init ~alpha ())
    else
      None
  in
  {
    alpha_tracker;
    avg_tracker;
    var_tracker;
    stdev = nan;
    normalized = nan;
  }

let get x =
  Mv_avg.get x.avg_tracker

let get_age x =
  Mv_avg.get_age x.avg_tracker

let get_stdev x = x.stdev

let get_normalized x = x.normalized

let get_alpha_tracker x = x.alpha_tracker

let update_variance ~state ~alpha x =
  match state.var_tracker with
  | None -> ()
  | Some var_tracker ->
      Mv_avg.set_alpha var_tracker alpha;
      let mean = get state in
      Mv_avg.update var_tracker ((x -. mean) ** 2.);
      let variance = Mv_avg.get var_tracker in
      let stdev = sqrt variance in
      state.stdev <- stdev;
      if stdev = 0. then
        state.normalized <- 0.
      else
        state.normalized <- (x -. mean) /. stdev

let update state x =
  let alpha_tracker = state.alpha_tracker in
  let avg_tracker = state.avg_tracker in
  Mv_adapt.update alpha_tracker x;
  let alpha = Mv_adapt.get_alpha alpha_tracker in
  Mv_avg.set_alpha avg_tracker alpha;
  Mv_avg.update avg_tracker x;
  update_variance ~state ~alpha x
