(*
   Tests and demo for adaptive smoothing
*)

open Printf

let init_list len f = Array.to_list (Array.init len f)

let make_climb ~start_level:start ~end_level:end_ ~length:len =
  init_list len (fun i -> start +. (float i /. float len) *. (end_ -. start))

let level1 = 5.
let level2 = 0.
let level3 = 30.

let segment1 = make_climb ~start_level:level1 ~end_level:level2 ~length:10
let segment2 = init_list 80 (fun i -> level2)
let segment3 = make_climb ~start_level:level2 ~end_level:level3 ~length:30
let segment4 = init_list 80 (fun i -> level3)

let input_no_noise = List.flatten [
    segment1;
    segment2;
    segment3;
    segment4;
  ]

let add_noise x = x +. Random.float 4.
let input_with_noise = List.map add_noise input_no_noise

let print_csv_header () =
  printf "i,x,\
          adapt_avg,\
          mv_exp_best,\
          mv_mean_best,\
          normalized,\
          gain,loss,alpha\n"

let print_csv_row
    ~i ~x
    ~adapt_avg
    ~mv_exp_best
    ~mv_mean_best
    ~normalized
    ~gain ~loss ~alpha =
  printf "%i,%g,%g,%g,%g,%g,%g,%g,%g\n"
    i x
    adapt_avg
    mv_exp_best
    mv_mean_best
    normalized
    gain loss alpha

let test_series input =
  let state = Mv_adapt_avg.init ~track_variance:true () in
  let state_mv_exp_best = Mv_avg.init ~alpha:0.3 () in
  let state_mv_mean_best = Mv_naive_mean.init ~window_length:8 in
  let process_sample i x =
    Mv_naive_mean.update state_mv_mean_best x;
    let mv_mean_best = Mv_naive_mean.get state_mv_mean_best in

    Mv_avg.update state_mv_exp_best x;
    let mv_exp_best = Mv_avg.get state_mv_exp_best in

    let open Mv_adapt_avg in
    update state x;
    let alpha_tracker = Mv_adapt_avg.get_alpha_tracker state in
    let gain = Mv_adapt.get_avg_gain alpha_tracker in
    let loss = Mv_adapt.get_avg_loss alpha_tracker in
    let alpha = Mv_adapt.get_alpha alpha_tracker in
    let adapt_avg = get state in
    let normalized = Mv_adapt_avg.get_normalized state in

    print_csv_row
      ~i ~x
      ~adapt_avg
      ~mv_exp_best
      ~mv_mean_best
      ~normalized
      ~gain ~loss ~alpha
  in
  print_csv_header ();
  Array.iteri process_sample (Array.of_list input)

let main () =
  test_series input_with_noise

let () = main ()
