#lang racket/base

(define (execute cmd . args)
  (let-values ([(in, out, pid, err, f)
                (apply process* cmd args)])
    
    (define buf_stdout (open-output-string))
    (define buf_stderr (open-output-string))
    (thread (λ () (copy-port in (current-input-port))))
    (thread (λ () (copy-port out buf_stdout (current-output-port))))
    (thread (λ () (copy-port err buf_stderr (current-error-port))))
    
    
    )
  
  )