(*
   Tests and demo for adaptive smoothing
*)

open Printf

let init_list len f = Array.to_list (Array.init len f)

let low = 0.
let high = 100.

let input_low = init_list 50 (fun i -> low)
let input_high = init_list 50 (fun i -> high)
let input_climb =
  let len = 50 in
  init_list len (fun i -> low +. (float i /. float len) *. (high -. low))

let input_no_noise = input_low @ input_climb @ input_high

let add_noise x = x +. Random.float 4.
let input_with_noise = List.map add_noise input_no_noise

let print_csv_header () =
  printf "i,x,mean_long,mean_short,\
          mv_exp_long,mv_exp_short,mv_exp_best,\
          adapt_avg,gain,loss,alpha\n"

let print_csv_row
    ~i ~x ~mv_mean_long ~mv_mean_short
    ~mv_exp_long ~mv_exp_short ~mv_exp_best
    ~adapt_avg ~gain ~loss ~alpha =
  printf "%i,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n"
    i x mv_mean_long mv_mean_short mv_exp_long mv_exp_short mv_exp_best
    adapt_avg gain loss alpha

let test_series input =
  let state_mean_long = Mv_naive_mean.init ~window_length:30 in
  let state_mean_short = Mv_naive_mean.init ~window_length:3 in
  let state_mv_exp_long = Mv_avg.init ~alpha:Mv_adapt.default_alpha_min () in
  let state_mv_exp_short = Mv_avg.init ~alpha:Mv_adapt.default_alpha_max () in
  let state_mv_exp_best = Mv_avg.init ~alpha:0.3 () in
  let state = Mv_adapt_avg.init () in
  let process_sample i x =
    Mv_naive_mean.update state_mean_long x;
    let mv_mean_long = Mv_naive_mean.get state_mean_long in

    Mv_naive_mean.update state_mean_short x;
    let mv_mean_short = Mv_naive_mean.get state_mean_short in

    Mv_avg.update state_mv_exp_long x;
    let mv_exp_long = Mv_avg.get state_mv_exp_long in

    Mv_avg.update state_mv_exp_short x;
    let mv_exp_short = Mv_avg.get state_mv_exp_short in

    Mv_avg.update state_mv_exp_best x;
    let mv_exp_best = Mv_avg.get state_mv_exp_best in

    let open Mv_adapt_avg in
    update state x;
    let gain = Mv_adapt.get_avg_gain state.alpha_tracker in
    let loss = Mv_adapt.get_avg_loss state.alpha_tracker in
    let alpha = Mv_adapt.get_alpha state.alpha_tracker in
    let adapt_avg = get state in

    print_csv_row
      ~i ~x ~mv_mean_long ~mv_mean_short
      ~mv_exp_long ~mv_exp_short ~mv_exp_best
      ~adapt_avg ~gain ~loss ~alpha
  in
  print_csv_header ();
  Array.iteri process_sample (Array.of_list input)

let main () =
  test_series input_with_noise

let () = main ()
