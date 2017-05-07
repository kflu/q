#lang typed/racket/base

(require racket/string racket/list racket/match racket/system racket/port racket/function)
(provide execute)

(: execute (-> String (Listof String) (Pairof String String)))
(define (execute cmd . args)
  (define cmdln 
    (string-join 
      (cast (flatten `(,cmd ,args)) (Listof String))))

  (displayln (format "running ~a" cmdln))
  (match (process cmdln)
    [(list out in pid err f)

     (define cust (make-custodian))
     (dynamic-wind
      (thunk #f)
      
      (thunk 
       (parameterize ([current-custodian cust])
         (define buf_stdout (open-output-string))
         (define buf_stderr (open-output-string))
       
         (thread (λ () (copy-port out buf_stdout (current-output-port))))
         (thread (λ () (copy-port err buf_stderr (current-error-port))))

         (displayln (f 'status))
         (f 'wait)
       
         (cons (get-output-string buf_stdout) (get-output-string buf_stderr))))
      
      (thunk (custodian-shutdown-all cust)))
     ]))
