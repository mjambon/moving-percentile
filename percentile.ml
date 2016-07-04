type state = {
  p: float;
  max_window_length: int;
  mutable m: float * float;
  mutable values: float list;
}

let init ?(max_window_length = max_int) p =
  if not (p >= 0. && p <= 1.) then
    invalid_arg "Percentile.init";
  {
    p;
    max_window_length;
    m = (nan, nan);
    values = [];
  }

let compute_percentile p l =
  assert (l <> []);
  let a = Array.of_list l in
  Array.sort compare a;
  let n = Array.length a in
  let k = p *. float (n - 1) in
  let i = floor k in
  let j = ceil k in
  a.(truncate i), a.(truncate j)

let rec head_n n l =
  if n > 0 then
    match l with
    | [] -> []
    | x :: tail -> x :: head_n (n-1) tail
  else
    []

let truncate_window state =
  let n = List.length state.values in
  if n > state.max_window_length then
    state.values <- head_n state.max_window_length state.values

let update state x =
  let values = x :: state.values in
  state.values <- values;
  truncate_window state;
  let m = compute_percentile state.p values in
  state.m <- m

let get state = state.m
