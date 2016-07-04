open Printf

let print_csv_header () =
  printf "i,m1,m2,m,x\n"

let print_csv_state i naive_state state x =
  let open Moving_percentile in
  let m1, m2 = Percentile.get naive_state in
  printf "%i,%g,%g,%g,%g\n"
    i m1 m2 state.m x

let process_sample i naive_state state =
  try
    let x = float_of_string (input_line stdin) in
    Moving_percentile.update state x;
    Percentile.update naive_state x;
    print_csv_state i naive_state state x;
    Some ()
  with End_of_file ->
    None

let loop () =
  let p = 0.9 in
  let naive_state =
    Percentile.init
      ~max_window_length:100
      p
  in
  let state =
    Moving_percentile.init
      ~p
      ~delta:0.001
      ()
  in
  let stream = Stream.from (fun i -> process_sample i naive_state state) in
  print_csv_header ();
  Stream.iter (fun () -> ()) stream

let main () =
  loop ()

let () = main ()
