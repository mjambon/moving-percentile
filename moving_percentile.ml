type param = {
  p: float;
    (* percentile rank (within 0 .. 1) *)
  lambda: float;
    (* constant determining by how much delta grows or shrink. *)

  (* derived constants *)
  q: float;
  delta_dilation_factor: float;
  delta_shrinking_factor: float;
}

type side = Below | Above
  (* indicates whether the last observation not equal to m
     was lower than m or greater than m (at that time). *)

type state = {
  param: param;

  mutable m: float;
    (* estimated percentile value, i.e. ideally m is such that
       p is the fraction of recent observations less then m. *)
  mutable delta: float;
    (* amount by which m is adjusted each time an observation
       falls below or above m. It grows when two successive observations
       fall on the same side of m and shrinks when two successive observations
       fall on each side of m. Observations that fall on m exactly are ignored
       for this purpose.
    *)
  mutable previous_side: side;
    (* whether the previous observation fell below or above m.
       This is used to determine whether to grow or shrink delta. *)
}

let update state x =
  let { p; q; lambda;
        delta_dilation_factor;
        delta_shrinking_factor } = state.param in
  let { m; delta; previous_side } = state in
  if x = m then
    ()
  else
    let side =
      if x < m then Below
      else Above
    in
    let delta_factor =
      if side = previous_side then
        delta_dilation_factor
      else
        delta_shrinking_factor
    in
    let m_term =
      match side with
      | Below -> -. delta /. p
      | Above -> delta /. q
    in
    state.m <- m +. m_term;
    state.delta <- delta_factor *. delta;
    state.previous_side <- side

let init_param ~p ~lambda =
  if not (p > 0. && p < 1.) then
    invalid_arg "Moving_percentile.init: p";
  if not (lambda > 0.) then
    invalid_arg "Moving_percentile.init: lambda";
  let q = 1. -. p in
  assert (q > 0.);
  assert (q < 1.);
  let delta_dilation_factor =
    2. ** (lambda /. (p**2. +. q**2.))
  in
  let delta_shrinking_factor =
    2. ** (-. lambda /. (2. *. p *. q))
  in
  assert (delta_dilation_factor > 1.);
  assert (delta_shrinking_factor < 1.);
  assert (delta_shrinking_factor > 0.);
  {
    p; q;
    lambda;
    delta_dilation_factor;
    delta_shrinking_factor;
  }

let init ?(m = 0.) ?(delta = 1.) ~p ~lambda () =
  let param = init_param ~p ~lambda in
  let previous_side =
    (* start with the most likely *)
    if p >= 0.5 then Below
    else Above
  in
  {
    param;
    m;
    delta;
    previous_side;
  }
