; Darian Marvel
; 4/25/2022
; Writing a procedure in Scheme for Assignment 7

(define (addpair . p)
  (+ (car p) (cadr p))
)

(define (addpairs . args)
(cond
  ((null? args) 0)
  ((not (pair? args)) (error "add: args do not form a list"))
  (else (cons (addpair (car args) (cadr args)) (apply addpairs (cdr (cdr args)))))
  )
)
