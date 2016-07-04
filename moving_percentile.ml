type param = {
  p: float;
    (* percentile rank (within 0 .. 1) *)
  delta: float;
    (* constant determining by how much to adjust the estimated percentile
       value at each iteration. Smaller values of delta
       increase precision while greater values increase reactivity
       and give more weight to recent observations.
       For values typically in the range 0..1,
       a suitable value for delta can be 0.001. *)

  (* derived constants *)
  q: float;
}

type state = {
  param: param;

  mutable m: float;
    (* estimated percentile value, i.e. ideally m is such that
       p is the fraction of recent observations less then m. *)
}

let update state x =
  let { param; m } = state in
  let { p; q; delta } = param in
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

let init_param ~p ~delta =
  if not (p > 0. && p < 1.) then
    invalid_arg "Moving_percentile.init: p";
  let q = 1. -. p in
  assert (q > 0.);
  assert (q < 1.);
  {
    p; q;
    delta;
  }

let init ?(m = 0.) ~p ~delta () =
  let param = init_param ~p ~delta in
  {
    param;
    m
  }
