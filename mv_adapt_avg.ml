(*
   Exponential moving average with alpha parameter that
   adjusts depending on the signal's stability.

   It's meant to be used as smoothing technique rather than
   a proper statistically-relevant average.
*)

open Printf

type t = {
  alpha_tracker: Mv_adapt.state;
  avg_tracker: Mv_avg.state;
}

let init
    ?alpha_gain
    ?alpha_min
    ?(alpha_max = Mv_adapt.default_alpha_max)
    () =
  let alpha_tracker =
    Mv_adapt.init
      ?alpha_gain
      ?alpha_min
      ~alpha_max
      ()
  in
  let avg_tracker =
    Mv_avg.init ~alpha:alpha_max ()
  in
  {
    alpha_tracker;
    avg_tracker
  }

let update { alpha_tracker; avg_tracker } x =
  Mv_adapt.update alpha_tracker x;
  let alpha = Mv_adapt.get_alpha alpha_tracker in
  Mv_avg.set_alpha avg_tracker alpha;
  Mv_avg.update avg_tracker x

let get x =
  Mv_avg.get x.avg_tracker

let test_series input =
  let state0 = Mv_avg.init ~alpha:0.1 () in
  let state1 = init () in
  let process_sample i x =
    Mv_avg.update state0 x;
    let avg0 = Mv_avg.get state0 in

    update state1 x;
    let avg1 = get state1 in

    printf "[%i] %g  avg0: %g  avg1: %g\n"
      i x avg0 avg1
  in
  Array.iteri process_sample (Array.of_list input)

let test1 () =
  test_series [
    0.; 0.; 0.; 0.; 0.; 0.; 0.; 0.; 0.; 0.;
    0.; 0.; 0.; 0.; 0.; 0.; 0.; 0.; 0.; 0.;
  ]

let test2 () =
  test_series [
    0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.;
    0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.;
    0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.;
    0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.;
    0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.;
    0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.;
    0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.;
    0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.;
    0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.;
    0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.; 0.; 1.;
  ]

let test3 () =
  let input = Array.to_list (Array.init 100 (fun i -> float i)) in
  test_series input
