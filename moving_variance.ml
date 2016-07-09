type state = {
  avg: Moving_average.state;
  var: Moving_average.state;
}

let init ?(r_avg = 0.05) ?(r_var = 0.05) () =
  {
    avg = Moving_average.init ~r:r_avg ();
    var = Moving_average.init ~r:r_var ();
  }

let update state x =
  if x <> x then
    invalid_arg "Moving_variance.update: not a number";
  let avg = state.avg in
  let var = state.var in
  if avg.Moving_average.age > 0 then
    Moving_average.update var ((x -. avg.Moving_average.m) ** 2.);
  Moving_average.update avg x

let get state = Moving_average.get state.var
let get_average state = Moving_average.get state.avg
