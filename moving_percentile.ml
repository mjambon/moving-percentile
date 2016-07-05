type delta_param = [
  | `Dynamic of float
  | `Constant of float
]

type delta_state = [
  | `Dynamic of (float * Moving_variance.state)
  | `Constant
]

type param = {
  p: float;
  delta_param: delta_param;

  (* derived constants *)
  q: float;
}

type state = {
  param: param;
  mutable m: float;
  delta_state: delta_state;
  mutable delta: float;
  mutable age: int;
}

let update_age state =
  let age = state.age in
  if age >= 0 then
    state.age <- age + 1

let update_delta state x =
  match state.delta_state with
  | `Constant -> ()
  | `Dynamic (r, var_state) ->
      Moving_variance.update var_state x;
      (* Avoid catastrophic overestimation of the standard deviation
         due an overestimation of the moving average
         when |average| >> stdev.
         We leave delta set to its initial value (0) until we have
         a more usable standard deviation estimate. *)
      if state.age >= 5 then (
        let variance = Moving_variance.get var_state in
        let stdev = sqrt variance in
        state.delta <- r *. stdev
      )

let update state x =
  update_age state;
  update_delta state x;
  let { param; m; delta } = state in
  let { p; q } = param in
  if x = m then
    ()
  else
    let m =
      if x < m then
        m -. delta /. p
      else
        m +. delta /. q
    in
    state.m <- m

let init_param ~p ~delta_param =
  if not (p > 0. && p < 1.) then
    invalid_arg "Moving_percentile.init: p";
  let q = 1. -. p in
  assert (q > 0.);
  assert (q < 1.);
  {
    p; q;
    delta_param;
  }

let init_delta_state (delta_param : delta_param) : delta_state * float =
  match delta_param with
  | `Constant delta -> `Constant, delta
  | `Dynamic r ->
      let delta = 0. in
      let delta_state =
        let var_state =
          Moving_variance.init
            ~avg:0.
            ~var:0.
            ()
        in
        `Dynamic (r, var_state)
      in
      delta_state, delta

let default_m = 0.
let default_delta_param = `Dynamic 0.01

let init ?(m = default_m) ?(delta_param = default_delta_param) ~p () =
  let param = init_param ~p ~delta_param in
  let delta_state, delta = init_delta_state delta_param in
  {
    param;
    m;
    delta_state;
    delta;
    age = 0;
  }

let get state = state.m
