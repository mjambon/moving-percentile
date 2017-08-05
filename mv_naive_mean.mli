(*
   Naive, inefficient tracking of an arithmetic mean over a window.
   This is for comparison in qualitative benchmarks only.
*)

type state

val init : window_length:int -> state
val update : state -> float -> unit
val get : state -> float
