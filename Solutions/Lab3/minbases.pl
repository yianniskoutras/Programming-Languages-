process_div(N, B) :-
    process_div(N, B, _).

process_div(N, B, PrevRem) :-
    Quot is N // B,
    Rem is N mod B,
    (   Rem \= PrevRem ->
        false
    ;   Quot = 0, Rem = PrevRem ->
        true
    ;   process_div(Quot, B, Rem)
    ).


find_base(N, Base) :-
    find_base(N, 2, Base).

find_base(N, Base, Base) :-
    process_div(N, Base),
    !.

find_base(N, Base, Result) :-
    NewBase is Base + 1,
    find_base(N, NewBase, Result).


minbases([], []).
minbases([N|Ns], [Base|Bases]) :-
    find_base(N, Base),
    minbases(Ns, Bases).
