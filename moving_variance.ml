type state = {
  avg: Moving_average.state;
  var: Moving_average.state;
}

let init ?(r_avg = 0.1) ?(r_var = 0.08) ~avg ~var () =
  {
    avg = Moving_average.init ~r:r_avg ~m:avg ();
    var = Moving_average.init ~r:r_var ~m:var ();
  }

let update state x =
  let avg = state.avg in
  let var = state.var in
  Moving_average.update avg x;
  Moving_average.update var ((x -. avg.Moving_average.m) ** 2.)

let get state = Moving_average.get state.var
let get_average state = Moving_average.get state.avg
