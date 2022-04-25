\ Darian Marvel
\ 4/25/2022
\ Writing collcount word for Assignment 7

: collcount { n -- c }
  0 { c }

  begin
    n 1 > while
    n collatz-step to n
    c 1 + to c
  repeat
  c
;


\ From Glenn G. Chappell's "word.fs"
\ https://github.com/ggchappell/cs331-2022-01/blob/main/word.fs
: collatz-step  { n -- number_after_n_in_Collatz_sequence }
  n 2 mod 0 = if  \ Is n even?
    n 2 /
  else
    n 3 * 1 +
  endif
;
