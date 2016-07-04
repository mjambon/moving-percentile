
type state = {
  r: float;
  mutable m: float;
}

let init ?(r = 0.1) ~m () =
  if not (r >= 0. && r <= 1.) then
    invalid_arg "Moving_average.init";
  { r; m }

let update state x =
  let r = state.r in
  state.m <- (1. -. r) *. state.m +. r *. x

let get state = state.m
