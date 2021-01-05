(in-package #:cl-user)
(defpackage #:aoclient.netreceive
  (:use #:cl) 
  (:import-from #:aoclient.connection
                #:*stream*)
  (:import-from #:alexandria
                #:switch))
(in-package #:aoclient.netreceive)

(defun receive ()
  (when (listen *stream*)
    (coerce (loop for char = (read-char *stream*)
                  while (char/= #\% char)
                  collect char)
            'string)))

(defun receive-command ()
  (coerce (loop for char = (read-char *stream*)
                while (char/= #\% char)
                collect char)
          'string))

(defun handle-response (response)
  (let ((command (subseq response 0 2)))
    (switch (command :test equal)
      (t (print response)))))

(defun network-listener ()
  (loop while (listen *stream*)
        do (handle-response (receive))))
