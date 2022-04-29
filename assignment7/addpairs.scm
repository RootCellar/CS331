#lang scheme

; Darian Marvel
; 4/25/2022
; Writing a procedure in Scheme for Assignment 7

(define (addpairs . args)
  (cond
    ; handle case with no arguments (usually when even number of arguments are given)
    ((null? args) ())

    ; handle odd number of arguments
    ((= (length args) 1) args)

    ; otherwise recursively append results to a list
    (else (append (list (+ (car args) (cadr args))) (apply addpairs (cdr (cdr args)))))
  )
)
