% Predicate to check if a file exists
exists_file(File) :-
    catch((open(File, read, _Stream), close(_Stream)),
          error(existence_error(_, _), _),
          fail).

% Predicate to read grid from the file
read_grid(File, Grid) :-
    (   exists_file(File) ->
        open(File, read, Stream),
        read_line(Stream, Line1),
        atom_number(Line1, N),
        read_lines(Stream, N, Grid),
        close(Stream)
    ;   write('File not found.'), nl,
        fail % fail if file doesn't exist
    ).

% Read N lines of the grid
read_lines(Stream, 0, []) :- !.  % Cut to prevent backtracking
read_lines(Stream, N, [Row|Grid]) :-
    N > 0,
    read_line(Stream, Line),
    split_line(Line, Row),
    N1 is N - 1,
    read_lines(Stream, N1, Grid),
    !.  % Cut to prevent backtracking

% Read a line of characters from the stream
read_line(Stream, Line) :-
    read_line(Stream, [], Line).

read_line(Stream, Acc, Line) :-
    get_char(Stream, Char),
    ( Char == '\n' ->
        reverse(Acc, LineChars),
        atom_chars(Line, LineChars)
    ;
        Char == end_of_file ->
        reverse(Acc, LineChars),
        atom_chars(Line, LineChars)
    ;
        read_line(Stream, [Char|Acc], Line)
    ).

% Split a line into a list of integers
split_line(Line, Numbers) :-
    split_atom(Line, ' ', AtomList),
    maplist(atom_number, AtomList, Numbers).

% Split an atom into a list of atoms based on a separator
split_atom(Atom, Sep, List) :-
    atom_codes(Atom, Codes),
    atom_codes(Sep, [SepCode]),
    split_codes(Codes, SepCode, AtomCodesList),
    maplist(codes_to_atom, AtomCodesList, List).

% Helper to split a list of character codes
split_codes([], _, [[]]).
split_codes([Code|Codes], Sep, [[]|Rest]) :-
    Code =:= Sep,
    split_codes(Codes, Sep, Rest).
split_codes([Code|Codes], Sep, [[Code|First]|Rest]) :-
    Code =\= Sep,
    split_codes(Codes, Sep, [First|Rest]).

% Convert a list of character codes to an atom
codes_to_atom(Codes, Atom) :-
    atom_codes(Atom, Codes).

% Convert an atom to a number
atom_number(Atom, Number) :-
    atom_codes(Atom, Codes),
    number_codes(Number, Codes).

% Predicate to convert points to directions
points_to_directions([], []).
points_to_directions([_], []).
points_to_directions([(X1, Y1), (X2, Y2)], [Direction]) :-
    DX is X2 - X1,
    DY is Y2 - Y1,
    move(DX, DY, Direction).
points_to_directions([(X1, Y1), (X2, Y2)|Rest], [Direction|Directions]) :-
    DX is X2 - X1,
    DY is Y2 - Y1,
    move(DX, DY, Direction),
    points_to_directions([(X2, Y2)|Rest], Directions).

% Define possible moves (dx, dy, direction_name)
move(1, 0, 's').    % move down
move(-1, 0, 'n').   % move up
move(0, 1, 'e').    % move right
move(0, -1, 'w').   % move left
move(1, 1, 'se').   % move southeast
move(1, -1, 'sw').  % move southwest
move(-1, 1, 'ne').  % move northeast
move(-1, -1, 'nw'). % move northwest

% Check if a move is within bounds and valid
valid_move(X, Y, NX, NY, Grid) :-
    length(Grid, N),
    NX >= 0, NX < N,
    NY >= 0, NY < N,
    nth0(X, Grid, Row),
    nth0(NX, Grid, NewRow),
    nth0(Y, Row, Val),
    nth0(NY, NewRow, NewVal),
    NewVal < Val.

% Priority queue implementation (not used directly here)
insert_pq(X, [], [X]).
insert_pq((CostX, ElemX), [(CostY, ElemY)|Rest], [(CostX, ElemX), (CostY, ElemY)|Rest]) :- CostX =< CostY.
insert_pq((CostX, ElemX), [(CostY, ElemY)|Rest], [(CostY, ElemY)|Rest1]) :- CostX > CostY, insert_pq((CostX, ElemX), Rest, Rest1).

extract_min_pq([Min|Rest], Min, Rest).

% Dijkstra's algorithm to find path with minimum steps
dijkstra(Grid, Path, MinCost) :-
    length(Grid, N),
    N1 is N - 1,
    dijkstra(Grid, [(0, (0, 0, []))], [(0, 0)], Path, N1, N1, MinCost).

dijkstra(_, [(_, (DestX, DestY, RevPath))|_], _, Path, DestX, DestY, MinCost) :-
    reverse([(DestX, DestY)|RevPath], Path),
    length(Path, MinCost).

dijkstra(Grid, [(Cost, (X, Y, RevPath))|Rest], Visited, Path, DestX, DestY, MinCost) :-
    findall((NewCost, (NX, NY, [(X, Y)|RevPath])),
        (move(DX, DY, _MoveName),
         NX is X + DX,
         NY is Y + DY,
         valid_move(X, Y, NX, NY, Grid),
         \+ member((NX, NY), Visited),
         NewCost is Cost + 1),
        Neighbors),
    append(Rest, Neighbors, NewRest),
    sort(NewRest, SortedNewRest),
    dijkstra(Grid, SortedNewRest, [(X, Y)|Visited], Path, DestX, DestY, MinCost).

% Predicate to get the path with minimum steps
find_min_path(Grid, MinPath, MinCost) :-
    dijkstra(Grid, MinPath, MinCost).

% Predicate to get directions for the minimum path
moves(Filename, Directions) :-
    read_grid(Filename, Grid),
    (   find_min_path(Grid, Path, _)
    ->  filter_redundant_points(Path, FilteredPath),
        points_to_directions(FilteredPath, Directions)
    ;   false % Return false if no path is found
    ),
    !.

% Filter redundant points in the path
filter_redundant_points([], []).
filter_redundant_points([Point], [Point]).
filter_redundant_points([P1, P2 | Rest], [P1 | FilteredRest]) :-
    P1 \= P2,
    filter_redundant_points([P2 | Rest], FilteredRest).
filter_redundant_points([P, P | Rest], FilteredRest) :-
    filter_redundant_points([P | Rest], FilteredRest).
