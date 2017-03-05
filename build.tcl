set raco {c:\racket\raco.exe}

puts "creating executable"
exec $raco exe q.rkt

puts "creating distribution: q"
exec $raco distribute q q.exe
