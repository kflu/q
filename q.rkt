#| SEND MESSAGE TO SLACK

TODO

* `q config` for a guided process to save a config file
* Read config (token) from other sources
* Read config at system level

|#

#lang racket/base
(require errortrace)
(require net/url racket/cmdline racket/format racket/list racket/string "executor.rkt")

(define *channel* (make-parameter #f))
(define *message* (make-parameter #f))
(define *verbose* (make-parameter #f))
(define *exec* (make-parameter #f))

(define *exec-mode-fmt* #<<---EOD---
EXECUTION OF:
~a
STDOUT:
~a
STDERR:
~a
---EOD---
)

(define (parse-cmdline)
    (command-line
     #:program "q"
     #:once-each
     [("-c" "--channel") ch "slack channel to post (default: use .qrc setting or default)" (*channel* ch)]
     [("-v" "--verbose") "verbose mode" (*verbose* #t)]
     [("-x" "--execute") "execute command" (*exec* #t)]
     #:ps #<<---USAGE---

-----
USAGE
-----

Run a command, wait for it to finish, and send a message:
    
    make; q "make is done!"

Run a command, wait for it to finish, and send its stdout and stderr:

    q -x make


------------------
SAMPLE `.qrc` FILE
------------------

#hash(

    ; required: bot token
    (token . "BOT_TOKEN") 

    ; optional: default channel to send, default to #general
    ; can be overriden by cmdline argument
    (default-channel . "@someone")

    ; optional: name of the bot
    (bot-name . "qbot")

)
; vi: set ft=scheme:

---USAGE---
     #:args msg
     (*message* msg)))

(parse-cmdline)
(if (*verbose*) (displayln (list (*channel*) (*verbose*) (*message*))) (void))


;; Base url of the API
(define BASEURL (string->url "https://slack.com/api/chat.postMessage"))

;; Get config object
(define (get-config)
  (let* ([homedir (find-system-path 'home-dir)]
         [rc (build-path homedir ".qrc")])
    (call-with-input-file rc read)))

(define (get-token config) (hash-ref config 'token))
(define (get-default-channel config) (hash-ref config 'default-channel "#general"))
(define (get-bot-name config) (hash-ref config 'bot-name "qbot"))

;; Add parameters to the URL
(define (add-params url_ params)
  (let ([existing-params (url-query url_)])
    (struct-copy url url_ [query (append existing-params params)])))

;; Construct API URL
(define (make-url url_ token channel botname text)
  (add-params url_ `([token . ,token]
                    [channel . ,channel]
                    [username . ,botname]
                    [text . ,text])))

(let* ([config (get-config)]
       [token (get-token config)]
       [channel (or (*channel*) (get-default-channel config))]
       [botname (get-bot-name config)])
  
  (if (*verbose*) (displayln config) (void))
  (define msg 
    (if (*exec*)
        (let-values ([(stdout stderr) (execute (*message*))])
          (format *exec-mode-fmt* (string-join (*message*)) stdout stderr))
        (string-join (*message*))))
  (define api-url (make-url BASEURL token channel botname msg))
  (http-sendrecv/url api-url))
