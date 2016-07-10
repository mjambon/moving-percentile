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
      if state.age >= 2 then (
        let variance = Moving_variance.get var_state in
        assert (variance = variance);
        let stdev = sqrt variance in
        state.delta <- r *. stdev
      )

let update state x =
  if x <> x then
    invalid_arg "Moving_percentile.update: not a number";
  update_age state;
  update_delta state x;
  let { param; m; delta } = state in
  let { p; q } = param in
  let m =
    if state.age = 1 then
      x
    else if x < m then
      m -. delta /. p
    else if x > m then
      m +. delta /. q
    else
      m
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
        let var_state = Moving_variance.init () in
        `Dynamic (r, var_state)
      in
      delta_state, delta

let default_delta_param = `Dynamic 0.01

let init ?(delta_param = default_delta_param) ~p () =
  let param = init_param ~p ~delta_param in
  let delta_state, delta = init_delta_state delta_param in
  {
    param;
    m = nan;
    delta_state;
    delta;
    age = 0;
  }

let get state = state.m
