#lang racket
(require srfi/13)
(require (planet endobson/smk/target))
(provide main clean)

(define (build-llvm-racket)
 (define program "/usr/bin/env")
 (define flags1 (list "g++" "-dynamiclib" "-m32" "-o" "llvm-racket.dylib"))
 (define flags2 
  (regexp-split " "
   (let-values (((process out in err) (subprocess #f #f #f "/usr/bin/env" "llvm-config" "--cxxflags")))
    (begin0
     (string-trim-both (port->string out))
     (close-output-port in)
     (close-input-port err)
     (close-input-port out)
     (subprocess-wait process)
     (unless (= (subprocess-status process) 0) (error 'llvm-config "Returned non zero exit code"))))))
 (define flags3 
  (regexp-split " "
   (let-values (((process out in err) (subprocess #f #f #f "/usr/bin/env" "llvm-config" "--ldflags")))
    (begin0
     (string-trim-both (port->string out))
     (close-output-port in)
     (close-input-port err)
     (close-input-port out)
     (subprocess-wait process)
     (unless (= (subprocess-status process) 0) (error 'llvm-config "Returned non zero exit code"))))))
 (define flags4 
  (filter (lambda (flag) (equal? (substring flag 0 2) "-l"))
   (regexp-split " "
    (let-values (((process out in err) (subprocess #f #f #f "/usr/bin/env" "llvm-config" "--libs")))
     (begin0
      (string-trim-both (port->string out))
      (close-output-port in)
      (close-input-port err)
      (close-input-port out)
      (subprocess-wait process)
      (unless (= (subprocess-status process) 0) (error 'llvm-config "Returned non zero exit code")))))))
 (define flags5 (list "llvm-racket.cpp"))
 (let-values (((process out in err)
               (apply subprocess #f #f (current-error-port) program (append flags1 flags2 flags3 flags4 flags5))))
  (close-output-port in)
  (close-input-port out)
  (subprocess-wait process)
  (unless (= (subprocess-status process) 0) (error 'g++ "Returned non zero exit code"))
  empty))

(define (c++-clean)
 (void))
 


;rsync -r . ~/proj/racket/planet/llvm/1.0



(define clean (new target% (build c++-clean)))
(define main (new target% (build build-llvm-racket)))
