(in-package #:cl-user)
(defpackage #:aoclient.connection
  (:use #:cl) 
  (:import-from #:usocket
                #:socket-stream
                #:socket-connect
                #:socket-close))
(in-package #:aoclient.connection)

(defvar *conn*)
(defvar *stream*)

(defclass client ()
  ((population :accessor population :initarg :current-population)
   (max-capacity :accessor max-capacity :initarg :max-capacity)
   (character-list :accessor character-list :initarg :character-list)
   (music-list :accessor music-list :initarg :music-list)))

(defmacro with-connection (hostname port &body body)
  `(unwind-protect
        (progn (setf *conn* (socket-connect ,hostname ,port :element-type 'extended-char))
               (setf *stream* (socket-stream *conn*))
               ,@body)
     (socket-close *conn*)))
