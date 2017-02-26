#| SEND MESSAGE TO SLACK

TODO

* `q config` for a guided process to save a config file
* Read config (token) from other sources
* Read config at system level

|#

#lang racket/base

(require net/url racket/cmdline)

(struct cmdline (channel msg verbose) #:prefab)
(define (parse-cmdline)
  (let* ([channel (make-parameter #f)]
         [verbose (make-parameter #f)])
    (command-line
     #:program "q"
     #:once-each
     [("-c" "--channel") ch "slack channel to post (default: use .qrc setting or default)" (channel ch)]
     [("-v" "--verbose") "verbose mode" (verbose #t)]
     #:args (msg)
     (cmdline (channel) msg (verbose)))))

(define cmdline-config (parse-cmdline))
(if (cmdline-verbose cmdline-config) (displayln cmdline-config) (void))


;; Base url of the API
(define BASEURL (string->url "https://slack.com/api/chat.postMessage"))

;; Get config object (currently just a token string)
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
       [channel (or (cmdline-channel cmdline-config) (get-default-channel config))]
       [botname (get-bot-name config)]
       [api-url (make-url BASEURL token channel botname (cmdline-msg cmdline-config))])
  (if (cmdline-verbose cmdline-config) (displayln config) (void))
  (http-sendrecv/url api-url))
