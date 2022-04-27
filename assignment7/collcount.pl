% Darian Marvel
% 4/25/2022
% Writing a prolog program for assignment 7

collatziterate(N, C) :-
  N mod 2 is 1,
  C is (3 * N + 1).

collatziterate(N, C) :-
  N mod 2 is 0,
  C is (N / 2).

collcount(N, C) :-
