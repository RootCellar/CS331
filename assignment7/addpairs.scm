(define (addpair p)
  (list (+ (car p) (car (cadr p)) ) )
)

(define (addpairs (list l))
  (car (addpair l))
)
