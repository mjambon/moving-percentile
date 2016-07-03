open Printf

let print_csv_header () =
  printf "m,delta,x\n"

let print_csv_state state x =
  let open Moving_percentile in
  printf "%g,%g,%g\n"
    state.m state.delta x

let process_sample state =
  try
    let x = float_of_string (input_line stdin) in
    Moving_percentile.update state x;
    print_csv_state state x;
    Some ()
  with End_of_file ->
    None

let loop () =
  let state =
    Moving_percentile.init
      ~p:0.9
      ~lambda:0.01
      ~delta:0.01
      ()
  in
  let stream = Stream.from (fun i -> process_sample state) in
  print_csv_header ();
  Stream.iter (fun () -> ()) stream

let main () =
  loop ()

let () = main ()
