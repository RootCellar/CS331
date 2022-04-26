#lang scheme

; Darian Marvel
; 4/25/2022
; Writing a procedure in Scheme for Assignment 7

(define (addpairs . args)
  (cond
    ((null? args) ())
    ((= (length args) 1) args)
    (else (append (list (+ (car args) (cadr args))) (apply addpairs (cdr (cdr args)))))
  )
)
