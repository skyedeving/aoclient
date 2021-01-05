(in-package #:cl-user)
(defpackage #:aoclient.gui.character-label
  (:use #:cl+qt)
  (:import-from #:aoclient.aochar
                #:load-character)
  (:import-from #:aoclient.utilities
                #:character-path
                #:misc-path))
(in-package #:aoclient.gui.character-label)

(in-readtable :qtools)

(define-widget character-label (QLabel) ())

(define-initializer (character-label settings)
  (q+:set-scaled-contents character-label t)
  (q+:set-fixed-width character-label 512)
  (q+:set-fixed-height character-label 384))

(define-subwidget (character-label image) (q+:make-qmovie))

(define-signal (character-label idle) (string string))
(define-signal (character-label talking) (string string))
(define-signal (character-label prenanim) (string string))

(defmethod load-animation  ((this character-label) (name string) (emote string))
  (with-slots-bound (this character-label) 
    (q+:stop image)
    (if (cl-fad:file-exists-p (character-path name emote))
        (progn (format t "Animation Valid(~a): ~a~%" emote (q+:is-valid image))
               (q+:set-file-name image (character-path name emote)))
        (progn (format t "Animation Valid(~a): ~a~%" emote nil)
               (q+:set-file-name image (misc-path "placeholder.gif")))) 
    (q+:set-movie this image)
    (q+:start image)))

(define-slot (character-label idle) ((name string) (emote string))
  (declare (connected character-label (idle string string)))
  (load-animation character-label name (concatenate 'string "(a)" emote ".gif")))

(define-slot (character-label talking) ((name string) (emote string))
  (declare (connected character-label (talking string string)))
  (load-animation character-label name (concatenate 'string "(b)" emote ".gif")))

(define-slot (character-label preanim) ((name string) (emote string))
  (declare (connected character-label (preanim string string)))
  (load-animation character-label name (concatenate 'string emote ".gif")))
