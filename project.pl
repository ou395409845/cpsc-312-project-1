%list L contains element E
contains(L,E) :- member(E, L).

% prereq(C, S) : S is a string describing the prerequisite of course C.
prereq('CPSC 101', '').
prereq('CPSC 110', '').
prereq('CPSC 112', 'Prerequisite: CPSC 110').
prereq('CPSC 114', 'Prerequisite: CPSC 110 and CPSC 110').
prereq('CPSC 116', 'Prerequisite: all of CPSC 110, CPSC 114, CPSC 101').
prereq('CPSC 118', 'Prerequisite: one of CPSC 110, CPSC 116').
prereq('CPSC 120', 'Prerequisite: either (a) one of CPSC 110, CPSC 118 or (b) all of CPSC 116, CPSC 112').

% all elements of T are courses:
are_courses(T) :- contains_each(['CPSC 101', 'CPSC 110','CPSC 112', 'CPSC 114', 'CPSC 116', 'CPSC 118', 'CPSC 120'],T).

% true if the string S starts with the string C
string_starts_with(S,C) :- string_concat(C,_,S).
string_ends_with(S,C) :- string_concat(_,C,S).

% true if the string S starts with C or D or S is empty
string_starts_with_either_or_empty(S,_,_) :- string_length(S,0).
string_starts_with_either_or_empty(S,C,_) :- string_starts_with(S,C).
string_starts_with_either_or_empty(S,_,C) :- string_starts_with(S,C).

% splits the given string by spaces and lets commas be separate elements
split_string_commas(A,[]):- string_length(A,0).
split_string_commas(' ',[]).
split_string_commas(',',[',']).
split_string_commas(S, [',' | L]) :- string_concat(',',R, S), split_string_commas(R, L).
split_string_commas(S, L) :- string_concat(' ',R,S), split_string_commas(R, L).
split_string_commas(S, [F | L]) :- string_concat(F,R,S), string_starts_with_either_or_empty(R, ' ',','), \+ string_length(F,0), \+ sub_string(F, _, _, _, ' '), \+ sub_string(F, _, _, _, ','), split_string_commas(R,L).

% the entries of A separated by S form L.
separate(L, S, A) :- ([], S, []).
separate([O, S | L], S, [[O] | A]) :- separate(L, S, A).

% contains_each(A, B) :- the list A contains all the entries of B
contains_each(_, []).
contains_each(A, [X | R]) :- contains(A, X), contains_each(A, R).

% contains_any(A, B) :- the intersection of A and B is non-empty
contains_any(A, [X | B]) :- contains(A, X).
contains_any(A, [X | B]) :- contains_any(A,B).

% list of courses (starter function)
can_register(C,T) :- prereq(C, S), split_string_commas(S, L), can_register2(T,L).

% empty string special case
can_register(C,_) :- prereq(C, '').

% helper function: given taken courses T, does the space-split list of strings L representing a
% description of the prerequisites required for a given course permit registration?

% L is just a single course:
can_register2(T, L) :- contains(T, E), atomic_list_concat(L, ' ', E).

% L is of the form 'A and B':
can_register2(T, L) :- L is [A | ['and'| B]], can_register2(T, A), can_register2(T, B).

% L is of the form 'all of course 1, course 2, course 3...'
can_register2(T, L) :- L is ['all','of' | R], separate(R, ',', X), contains_each(T, X).

% L is of the form 'all of course 1, course 2, course 3...'
can_register2(T, L) :- L is ['one','of' | R], separate(R, ',', X), contains_any(T, X).

% L is of the form 'either (a) X or (b) Y'
can_register2(T, L) :- L is ['either','(a)' | X], append(A,['or','(b)'| B],X), can_register(A), can_register(B).