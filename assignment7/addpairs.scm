; Darian Marvel
; 4/25/2022
; Writing a procedure in Scheme for Assignment 7

(define (addpairs . args)
  (cond
    ((null? args) ())
    ((= 1 (length args)) args)
    (else (append (list (+ (car args) (cadr args))) (apply addpairs (cdr (cdr args)))))
  )
)
