(in-package #:cl-user)
(defpackage #:aoclient.gui.jukebox
  (:use #:cl+qt) 
  (:import-from #:bass
                #:channel-play
                #:channel-bytes-2-seconds
                #:channel-get-length
                #:channel-set-attribute
                #:init
                #:free
                #:stream-create-file
                #:stream-free)
  (:import-from #:aoclient.utilities
                #:character-path
                #:music-path
                #:sfx-path)
  (:export #:*jukebox*))
(in-package #:aoclient.gui.jukebox)

(in-readtable :qtools)

(defvar *jukebox*)

(define-widget jukebox (QObject)
  ((master-volume :reader master-volume :initarg :master-volume :initform 1.0)
   (music-stream :accessor music-stream :initarg :music-stream :initform 0)
   (music-volume :reader music-volume :initarg :music-volume :initform 0.2)
   (sfx-volume :accessor sfx-volume :initarg :sfx-volume :initform 0.2)))

(define-initializer (jukebox bass-init)
  (init -1 44100 0 (cffi:null-pointer) (cffi:null-pointer))
  (setf *jukebox* jukebox))

(define-finalizer (jukebox bass-free) 
  (free)
  (setf *jukebox* nil))

(defmethod (setf music-volume) (new-volume (this jukebox))
  (setf (slot-value this 'music-volume) new-volume) 
  (channel-set-attribute (music-stream this) 2 (* (master-volume this)
                                                  (music-volume this))))

(defmethod (setf master-volume) (new-volume (this jukebox))
  (setf (slot-value this 'master-volume) new-volume) 
  (setf (music-volume this) (music-volume this)))

(define-signal (jukebox play-music) (string))
(define-signal (jukebox play-sfx) (string int))
(define-signal (jukebox play-character-sfx) (string string))

(define-slot (jukebox play-music play-music) ((name string))
  (declare (connected jukebox (play-music string)))
  (let ((musicp (music-path name)))
    (stream-free music-stream)
    (format t "Tried to play music: ~a~%" name)
    (when (search ".mp3" musicp :from-end t)
      (setf music-stream (stream-create-file nil musicp 0 0 #x40000))
      (channel-set-attribute music-stream 2 (* master-volume music-volume))
      (channel-play music-stream nil))))

(define-slot (jukebox play-sfx play-sfx) ((name string) (delay int))
  (declare (connected jukebox (play-sfx string int))) 
  (let ((sfx (sfx-path (concatenate 'string name ".wav"))))
    (format t "Tried to play effect: ~a~%" name)
    (when (cl-fad:file-exists-p (pathname (sfx-path sfx)))
      (let ((stream (stream-create-file nil sfx 0 0 #x40000)))
        (channel-set-attribute stream 2 (* master-volume sfx-volume))
        (if (< delay 1)
            (channel-play stream nil)
            (bt:make-thread #'(lambda ()
                                (sleep (/ delay 1000))
                                (channel-play stream nil))))))))

(define-slot (jukebox play-character-sfx) ((character-name string) (sfx-name string))
  (declare (connected jukebox (play-character-sfx string string)))
  (let ((sfx (character-path character-name (concatenate 'string sfx-name ".wav"))))
    (format t "Tried to play ~a for ~a.wav~%" character-name sfx-name)
    (when (cl-fad:file-exists-p sfx)
      (let ((stream (stream-create-file nil sfx 0 0 #x40000)))
        (channel-set-attribute stream 2 (* master-volume sfx-volume))
        (channel-play stream nil)))))
