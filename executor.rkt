#lang racket/base

(require racket/string racket/list racket/match racket/system racket/port)
(provide execute)

(define (execute cmd . args)
  (define cmdln (string-join (flatten `(,cmd ,args))))
  (displayln (format "running ~a" cmdln))
  (match (process cmdln)
    [(list out in pid err f)
     (define buf_stdout (open-output-string))
     (define buf_stderr (open-output-string))
     ;(thread (λ () (copy-port (current-input-port) in)))
     (thread (λ () (copy-port out buf_stdout (current-output-port))))
     (thread (λ () (copy-port err buf_stderr (current-error-port))))

     (displayln (f 'status))
     (f 'wait)

     (values
      (get-output-string buf_stdout)
      (get-output-string buf_stderr))
     ]))