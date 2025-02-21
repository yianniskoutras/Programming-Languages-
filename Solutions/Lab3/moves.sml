(* Utility functions to handle file reading and string splitting *)
fun explode (s: string) : char list = String.explode s
fun implode (cs: char list) : string = String.implode cs

(* Read file and return list of strings *)
fun readFile fileName = let
    val ins = TextIO.openIn fileName
    fun readLines ins = case TextIO.inputLine ins of
          NONE => []
        | SOME line => line :: readLines ins
    val lines = readLines ins
    val _ = TextIO.closeIn ins
  in
    lines
  end

(* Split a string by a delimiter *)
fun splitBy s delimiter = let
    fun split' [] acc = [acc]
      | split' (c::cs) acc = if c = delimiter then acc :: split' cs [] else split' cs (acc @ [c])
  in
    List.map implode (split' (explode s) [])
  end

(* Convert a list of strings to a list of integers *)
fun stringsToInts strs = List.map (fn s => valOf (Int.fromString s)) strs

(* Read grid from file *)
fun readGrid fileName = let
    val lines = readFile fileName
    val n = valOf (Int.fromString (hd lines))
    val grid = List.map (fn line => stringsToInts (splitBy line #" ")) (tl lines)
  in
    grid
  end

(* Move directions *)
datatype direction = N | S | E | W | NE | NW | SE | SW

(* Valid moves with directions *)
val directions = [(1, 0, S), (~1, 0, N), (0, 1, E), (0, ~1, W), (1, 1, SE), (1, ~1, SW), (~1, 1, NE), (~1, ~1, NW)]

(* Check if a move is within bounds and valid *)
fun validMove grid (x, y) (nx, ny) = 
    let 
        val n = length grid
    in
        0 <= nx andalso nx < n andalso 0 <= ny andalso ny < n andalso
        0 <= x andalso x < n andalso 0 <= y andalso y < n andalso
        List.nth (List.nth (grid, x), y) > List.nth (List.nth (grid, nx), ny)
    end

(* Priority queue implementation using lists *)
fun insertPQ (x, []) = [x]
  | insertPQ ((costX, elemX), (costY, elemY) :: rest) = 
    if costX <= costY then (costX, elemX) :: (costY, elemY) :: rest else (costY, elemY) :: insertPQ ((costX, elemX), rest)

fun extractMinPQ [] = raise Fail "Priority queue underflow"
  | extractMinPQ (x::xs) = (x, xs)

(* Dijkstra's algorithm to find path with minimum steps *)
fun dijkstra grid = 
    let
        val n = length grid
        val n1 = n - 1
        fun aux [] visited path = NONE
          | aux ((cost, (x, y, revPath))::rest) visited path = 
              if x = n1 andalso y = n1 then SOME (List.rev ((x, y)::revPath))
              else
                let 
                    val neighbors = List.filter (fn (dx, dy, _) => validMove grid (x, y) (x + dx, y + dy)) directions
                    val newNodes = List.map (fn (dx, dy, dir) => (cost + 1, (x + dx, y + dy, (x, y)::revPath))) neighbors
                    val newRest = List.foldl (fn (node, acc) => insertPQ (node, acc)) rest newNodes
                in
                    aux newRest ((x, y)::visited) path
                end
    in
        aux [(0, (0, 0, []))] [(0, 0)] []
    end

(* Convert points to directions *)
fun pointsToDirections [] = []
  | pointsToDirections [_] = []
  | pointsToDirections ((x1, y1)::(x2, y2)::rest) = 
      let
          val dx = x2 - x1
          val dy = y2 - y1
          val dir = case (dx, dy) of
                      (1, 0) => S
                    | (~1, 0) => N
                    | (0, 1) => E
                    | (0, ~1) => W
                    | (1, 1) => SE
                    | (1, ~1) => SW
                    | (~1, 1) => NE
                    | (~1, ~1) => NW
                    | _ => raise Fail "Invalid direction"
      in
          dir :: pointsToDirections ((x2, y2)::rest)
      end

(* Utility function to convert directions to string *)
fun directionToString N = "N"
  | directionToString S = "S"
  | directionToString E = "E"
  | directionToString W = "W"
  | directionToString NE = "NE"
  | directionToString NW = "NW"
  | directionToString SE = "SE"
  | directionToString SW = "SW"

(* Convert list of directions to string *)
fun directionsToString dirs = "[" ^ String.concatWith "," (List.map directionToString dirs) ^ "]"

(* Main function to read grid, find path and convert to directions *)
fun moves fileName = 
    let 
        val grid = readGrid fileName
    in
        case dijkstra grid of
            NONE => print "IMPOSSIBLE\n"
          | SOME path => print (directionsToString (pointsToDirections path) ^ "\n")
    end handle _ => ()