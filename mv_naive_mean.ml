(*
   Naive implementation of a window-based moving average.
   A proper implementation would use a circular buffer.
*)

type state = {
  max_window_length: int;
  mutable samples: float list;
  mutable mean: float;
}

let init ~window_length =
  {
    max_window_length = window_length;
    samples = [];
    mean = nan;
  }

let rec take n l =
  if n > 0 then
    match l with
    | [] -> []
    | x :: l -> x :: take (n-1) l
  else
    []

let get_mean l =
  List.fold_left (+.) 0. l /. float (List.length l)

let update state x =
  let samples = take state.max_window_length state.samples in
  state.samples <- samples;
  state.mean <- get_mean samples

let get state = state.mean
