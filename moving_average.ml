
type state = {
  r: float;
  age_min: int;
  mutable m: float;
  mutable age: int;
}

let init ?(r = 0.1) () =
  if not (r >= 0. && r <= 1.) then
    invalid_arg "Moving_average.init";
  let age_min = truncate (ceil (1. /. r)) in
  {
    r;
    age_min;
    m = nan;
    age = 0
  }

let update_age state =
  let age = state.age in
  if age >= 0 then
    state.age <- age + 1

let update state x =
  if x <> x then
    invalid_arg "Moving_average.update: not a number";
  update_age state;
  let r =
    if state.age > state.age_min then
      state.r
    else (
      if state.age = 1 then
        (* replace nan to avoid contamination when it's multiplied by 0 *)
        state.m <- 0.;
      (* arithmetic mean until we reach 1/r observations *)
      1. /. float state.age
    )
  in
  state.m <- (1. -. r) *. state.m +. r *. x

let get state = state.m
