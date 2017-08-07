(* Exponential moving average. See .mli *)

type state = {
  mutable alpha: float;
  age_min: int;
  mutable m: float;
  mutable age: int;
}

let init ?(alpha = 0.1) () =
  if not (alpha >= 0. && alpha <= 1.) then
    invalid_arg "Mv_avg.init";
  let age_min = truncate (ceil (1. /. alpha)) in
  {
    alpha;
    age_min;
    m = nan;
    age = 0
  }

let set_alpha state alpha =
  if not (alpha >= 0. && alpha <= 1.) then
    invalid_arg "Mv_avg.update_alpha";
  state.alpha <- alpha

let update_age state =
  let age = state.age in
  if age >= 0 then
    state.age <- age + 1

let update state x =
  if x <> x then
    invalid_arg "Mv_avg.update: not a number";
  update_age state;
  let alpha =
    if state.age > state.age_min then
      state.alpha
    else (
      if state.age = 1 then
        (* replace nan to avoid contamination when it's multiplied by 0 *)
        state.m <- 0.;
      (* arithmetic mean until we reach 1/r observations *)
      1. /. float state.age
    )
  in
  state.m <- (1. -. alpha) *. state.m +. alpha *. x

let get state = state.m

let get_age state = state.age
