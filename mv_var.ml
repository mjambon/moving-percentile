type state = {
  avg: Mv_avg.state;
  var: Mv_avg.state;

  (* Values from the states above, updated simultaneously,
     relatively cheap to update, provided for convenience. *)

  mutable stdev: float;
    (* square root of the estimated variance *)
  mutable normalized: float;
    (* (signal - mean) / stdev *)
}

let init ?(alpha_avg = 0.05) ?(alpha_var = 0.05) () =
  {
    avg = Mv_avg.init ~alpha:alpha_avg ();
    var = Mv_avg.init ~alpha:alpha_var ();
    stdev = nan;
    normalized = nan;
  }

let update state x =
  if x <> x then
    invalid_arg "Mv_var.update: not a number";
  let avg = state.avg in
  let var = state.var in
  if avg.Mv_avg.age > 0 then
    Mv_avg.update var ((x -. avg.Mv_avg.m) ** 2.);
  Mv_avg.update avg x;

  let mean = Mv_avg.get avg in
  let variance = Mv_avg.get var in
  let stdev = sqrt variance in
  state.stdev <- stdev;
  state.normalized <- (x -. mean) /. stdev

let get_variance state = Mv_avg.get state.var
let get_average state = Mv_avg.get state.avg
let get_stdev state = state.stdev
let get_normalized state = state.normalized

let get_count state =
  state.avg.Mv_avg.age
