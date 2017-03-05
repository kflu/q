# q

post message to slack

```
q [ <option> ... ] [<msg>] ...
 where <option> is one of
  -c <ch>, --channel <ch> : slack channel to post (default: use .qrc setting or default)
  -v, --verbose : verbose mode
  -x, --execute : execute command
  --help, -h : Show this help
  -- : Do not treat any remaining argument as a switch (at this level)
 Multiple single-letter switches can be combined after one `-'; for
  example: `-h-' is the same as `-h --'
 
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
```
