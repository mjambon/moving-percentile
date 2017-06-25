type state = {
  avg: Moving_average.state;
  var: Moving_average.state;

  (* Values from the states above, updated simultaneously,
     relatively cheap to update, provided for convenience. *)

  mutable stdev: float;
    (* square root of the estimated variance *)
  mutable normalized: float;
    (* (signal - mean) / stdev *)
}

let init ?(r_avg = 0.05) ?(r_var = 0.05) () =
  {
    avg = Moving_average.init ~r:r_avg ();
    var = Moving_average.init ~r:r_var ();
    stdev = nan;
    normalized = nan;
  }

let update state x =
  if x <> x then
    invalid_arg "Moving_variance.update: not a number";
  let avg = state.avg in
  let var = state.var in
  if avg.Moving_average.age > 0 then
    Moving_average.update var ((x -. avg.Moving_average.m) ** 2.);
  Moving_average.update avg x;

  let mean = Moving_average.get avg in
  let variance = Moving_average.get var in
  let stdev = sqrt variance in
  state.stdev <- stdev;
  state.normalized <- (x -. mean) /. stdev

let get_variance state = Moving_average.get state.var
let get_average state = Moving_average.get state.avg
let get_stdev state = state.stdev
let get_normalized state = state.normalized

let get_count state =
  state.avg.Moving_average.age
