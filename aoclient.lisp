(in-package #:cl-user)
(defpackage #:aoclient
  (:use #:cl)
  (:import-from #:aoclient.netsend
                #:message
                #:send
                #:music
                #:talk
                #:talk-occ
                #:hi
                #:loading-list
                #:choose-character)
  (:import-from #:aoclient.netreceive
                #:network-listener
                #:handle-response
                #:receive)
  (:import-from #:aoclient.connection
                #:*stream*
                #:with-connection)
  (:import-from #:split-sequence
                #:split-sequence)
  (:export #:repl))
(in-package #:aoclient)

(defun repl ()
  (with-connection "localhost" 27016
    (let ((running t))
      (loop while running
            do (progn
                 (format t "REPL> ")
                 (let ((thing (read-line)))
                   (if (string= "quit" thing)
                       (setf running nil)
                       (progn (send (talk "normal" "EmaSkye" "normal" thing "def"
                                          1 0 0 1 0 0 32 0 0))))))))))
