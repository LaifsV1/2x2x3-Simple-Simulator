# 2x2x3 Simple Simulator
This repository contains an OCaml file implementing a very simple simulator for a 2x2x3 cube. The purpose of this file was to help me find a simple generic solution for the 2x2x3 cube, specifically a simple _algorithm_ to swap two adjascent pieces on the top face. While the simulator was originally set up for 2x2x3, adding 90° side turns would transform this into a 2x2x2 simulator.

## Solutions Found
### 2x2x3
1. Intuiveily solve one face of the cube--this face is now the *bottom* face
2. Three possible scenarios from here:
	1. the cube is solved
	2. two adjacent pieces are swapped at the top
	3. four adjacent pieces (two pairs) are swapped

Using the simulator, we can search for an algorithm that swaps two adjascent pieces on the top face. I chose as a preference to find solutions that do not use bottom turns (since they are a bit more annoying to remember) and to prefer top and right turns before front turns. The tool finds the following moves:
```
# timed_solve dfs;;
t r t'f t f t'r t f r 
r f t r t'f t r t'r t 
r f t'r t f t'f t r t'
t'r t r t'r f t'f t f 
Execution time: 0.019836s
```
Of these, the easiest for me to remember is `r f t'r t f t'f t r t'` since one can group the moves into `f t'`, `r t`, `f t` and `r t' ` pairs with a setup `r` move at the front.

With this, solving (2.2) and (2.3) simply takes applying `r f t'r t f t'f t r t'` once or twice respectively until the cube becomes trivial to solve.

## Design
The 2x2x3 cube is implented as a pair of tuples: 
```
type ring = (int * int * int * int)
type conf = ring * ring
```
Each `ring` represents a face with pieces encoded clockwise from the top-left corner. A *configuration* (i.e. a *state* the cube can take) is a pair of these rings. The top and bottom faces are encoded as viewed from a vertical 180° rotation of the whole cube.
e.g.
```
Configuration: (a,b,c,d) , (a',b',c',d')

Top face:            Bottom Face
----------           ------------
[ a ][ b ]            [ a'][ b']
[ d ][ c ]            [ d'][ c']
```
If `a` is
```
       Orange
Blue [ Yellow ]
```
then `a'` is
```
       Red
Blue [ White ]
```
such that a right turn `r` swaps `b,c` with `b',c'`.
```
let r ((a,b,c,d),(a',b',c',d')) = (a,b',c',d),(a',b,c,d')
```
Because the middle layer is trivial to solve, it is not encoded. Effectively, the 2x2x3 is implemented as a kind of bandaged 2x2x2 cube that only allowed 180° turns on the left-right and front-back axes.

The following configurations are provided:
- `start_conf` : initial configuration for the search
- `goal_conf` : goal configuration for the search
The existing values provided for the configurations are integers ranging from `1` to `8` in order. The specific integers are not important as long we stay consistent.

A print function is provided. It prints the top and bottom layer side by side.
e.g.
```
# print_conf start_conf;;
conf=
1 2 5 6
4 3 8 7
```
## Search


The following moves are implemented:
- `t` : top face clockwise turn
- `t'` : top face counter-clockwise turn
- `r` : right face turn
- `f` : front face turn
- `b` : bottom face clockwise turn
- `b'` : bottom face counter-clockwise turn
- `m` : complex move `r t r`
Adding 90° side-face turns would make this into a 2x2x2 simulator.

The function `(>=)` is provided to sequence moves and print the configuration at each step.
e.g.
```
# start_conf >= t >= r >= b;;
conf=
4 1 5 6
3 2 8 7
conf=
4 6 5 1
3 7 8 2
conf=
4 6 8 5
3 7 2 1

```
A function `timed_solve` is provided to perform search depending on the function passed to it. 
e.g.
```
# timed_solve dfs;;
t r t'f t f t'r t f r 
r f t r t'f t r t'r t 
r f t'r t f t'f t r t'
t'r t r t'r f t'f t f 
Execution time: 0.019836s
```
`timed_solve` passes the `goal_conf` to the function passed to it, and prints out the time taken. Two search functions are implemented:
- `bfs` : performs breadth-first search when given a `goal`
- `dfs` : performs depth-first search when given a goal
The functions above make use of the `search` function to expand the configurations they hold. One can reorder moves applied to specify a preference for the search; comment out certain moves to restrict the moves available to the cube; or define and add custom moves to the search. To search for 2x2x2 solutions, 90° side-face turns would need to be added here to the `search` function.

To make the search more feasible, memoisation is used. The impact of memoisation is significant on this problem. With a simple explore-set memoisation, time taken decreases from around 15 minutes to list the first solution to 20ms to fully explore the whole statespace. As a bandaged 2x2x2, the total number of configurations possible is a lot under 3.6 million--easily doable with a laptop. However, without memoisation, the number of states is unbounded, such that listing solutions that are 12 moves long would require exploring 13.8 billion states.
