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
  (let* ([channel (make-parameter "general")]
         [verbose (make-parameter #f)])
    (command-line
     #:program "q"
     #:once-each
     [("-c" "--channel") ch "slack channel to post (default: general)" (channel ch)]
     [("-v" "--verbose") "verbose mode" (verbose #t)]
     #:args (msg)
     (cmdline (channel) msg (verbose)))))

(define cmdline-config (parse-cmdline))
(if (cmdline-verbose cmdline-config) (displayln cmdline-config) (void))


;; Base url of the API
(define BASEURL (string->url "https://slack.com/api/chat.postMessage"))

(struct config (token) #:prefab)

;; Get config object (currently just a token string)
(define (get-config)
  (let* ([homedir (find-system-path 'home-dir)]
         [rc (build-path homedir ".qrc")])
    (call-with-input-file rc read)))

;; Add parameters to the URL
(define (add-params url_ params)
  (let ([existing-params (url-query url_)])
    (struct-copy url url_ [query (append existing-params params)])))

;; Construct API URL
(define (make-url url_ token channel text)
  (add-params url_ `([token . ,token]
                    [channel . ,channel]
                    [text . ,text])))

(let* ([config (get-config)]
       [token (config-token config)]
       [api-url (make-url BASEURL token (cmdline-channel cmdline-config) (cmdline-msg cmdline-config))])
  (http-sendrecv/url api-url))
