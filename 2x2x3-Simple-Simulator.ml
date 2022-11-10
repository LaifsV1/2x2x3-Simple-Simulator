(* author: Yu-Yang Lin
 * This file simulates turning on a 2x2x3, which acts as a bandaged 2x2x2
 * The 2x2x3 is encoded as 2 tuples (top and bottom face)
 * Top face: 1 to 4 clockwise, Bottom face: 5 to 8 clockwise
 * The following operations are available:
 * - t  : 90 degrees clockwise top turn
 * - b  : 90 degrees clockwise bottom turn
 * - x' : inverse operation
 * - r  : right-side 180 degree turn
 * - f  : front-side 180 degree turn
 * - m  : complex operation r t' r
 * - (>=) : sequences operations and prints each step.
 *          e.g. start_conf >= t >= b >= r >= t
 * The file provides a way to search for algorithms (i.e. sequences of operations):
 * - start_conf : the starting configuration
 * - goal_conf  : the desired configuration to be reached
 * - bfs : BFS search
 * - dfs : DFS search
 * - timed_solve <bfs/dfs> : outputs all algorithms found
 * Search uses explore-set memoisation to prune alternative commutative routes
 *)

(* configurations *)
type ring = (int * int * int * int)
type conf = ring * ring
let print_conf ((a,b,c,d),(a',b',c',d')) =
  print_endline "conf=";
  Printf.printf "%d %d %d %d\n" a b a' b';
  Printf.printf "%d %d %d %d\n" d c d' c'

let start_conf = (1,2,3,4),(5,6,7,8)
let goal_conf  = (1,2,4,3),(5,6,7,8)

(* operations *)
let t  ((a,b,c,d),(a',b',c',d')) = (d,a,b,c),(a',b',c',d')
let t' ((a,b,c,d),(a',b',c',d')) = (b,c,d,a),(a',b',c',d')

let m  ((a,b,c,d),(a',b',c',d')) = (d,b,c,c'),(a',a,b',d')
let r  ((a,b,c,d),(a',b',c',d')) = (a,b',c',d),(a',b,c,d')
let f  ((a,b,c,d),(a',b',c',d')) = (a,b,a',b'),(c,d,c',d')

let b  ((a,b,c,d),(a',b',c',d')) = (a,b,c,d),(d',a',b',c')
let b' ((a,b,c,d),(a',b',c',d')) = (a,b,c,d),(b',c',d',a')

let p f conf =
  let conf' = f conf in
  print_conf conf';
  conf'

let (>=) c f = p f c

(* memoisation *)
let memo_size = 100000
let memo = ref (Hashtbl.create memo_size)        (* memoisation hashtable *)
let conf_count = ref 0                           (* configuration count *)

let check_sol conf =
  if Hashtbl.mem !memo conf then true
  else (Hashtbl.add !memo conf (); false)

(* search *)
type search_conf = {c : conf ; s : string}
let start_search_conf = {c=start_conf;s=""}

let search goal frontier =
  let aux acc {c;s} =
    if c = goal then (print_endline s; acc)
    else if check_sol c then (acc) else
      (* commented out; bottom face uneeded to swap adjascent edges *)
      (*{c=b  c;s=s ^ "b " }:: 
        {c=b' c;s=s ^ "b'"}::*)
          {c=f  c;s=s ^ "f " }::
            {c=t  c;s=s ^ "t " }::
              {c=r  c;s=s ^ "r " }::
                {c=t' c;s=s ^ "t'"}::
                  acc
  in
  List.fold_left aux [] frontier

let rec bfs goal = function
  | [] -> ()
  | frontier -> bfs goal (List.rev (search goal frontier))
let rec dfs goal = function
  | [] -> ()
  | frontier -> dfs goal (search goal frontier)
  
(* top-level function *)
let timed_solve f =
  memo := (Hashtbl.create memo_size);
  conf_count := 0;
  let t = Sys.time() in
  let res = f goal_conf [start_search_conf] in
  Printf.printf "Execution time: %fs\n" (Sys.time() -. t);
  res
