(in-package #:cl-user)
(defpackage #:aoclient.gui.fx-label
  (:use #:cl+qt)
  (:import-from #:aoclient.utilities
                #:misc-path))
(in-package #:aoclient.gui.fx-label)

(in-readtable :qtools)

(define-widget fx-label (QLabel) ())

(define-initializer (fx-label settings)
  (q+:set-scaled-contents fx-label t)
  (q+:set-fixed-width fx-label 512)
  (q+:set-fixed-height fx-label 384))

(define-subwidget (fx-label image) (q+:make-qmovie)
  (q+:set-speed image 75))
(define-subwidget (fx-label flash-image) (q+:make-qmovie)
  (q+:set-file-name flash-image (misc-path "whitish.gif"))
  (q+:set-speed flash-image 75))
(define-subwidget (fx-label wit-image) (q+:make-qmovie)
  (q+:set-file-name wit-image (misc-path "witnessTestimony.gif")))
(define-subwidget (fx-label ce-image) (q+:make-qmovie)
  (q+:set-file-name ce-image (misc-path "crossexamination.gif")))

(define-signal (fx-label pressing) (string))
(define-signal (fx-label flash) ())
(define-signal (fx-label wit) ())
(define-signal (fx-label ce) ())
(define-signal (fx-label done) ())

(defmethod load-animation ((this fx-label) (name string))
  (with-slots-bound (this fx-label) 
    (q+:stop image)
    (q+:set-file-name image (misc-path name)) 
    (q+:set-movie this image)
    (q+:start image) 
    (format t "FX Valid(~a): ~a~%" name (q+:is-valid image))))

(define-slot (fx-label wit) ()
  (declare (connected fx-label (wit)))
  (print (q+:is-valid wit-image))
  (q+:set-movie fx-label wit-image)
  (q+:start wit-image))

(define-slot (fx-label ce) ()
  (declare (connected fx-label (ce)))
  (q+:set-movie fx-label ce-image)
  (q+:start ce-image))

(define-slot (fx-label pressing) ((name string))
  (declare (connected fx-label (pressing string)))
  (load-animation fx-label (concatenate 'string name ".gif")))

(define-slot (fx-label flash) ()
  (declare (connected fx-label (flash)))
  (q+:set-movie fx-label flash-image)
  (q+:start flash-image))

(define-slot (fx-label stop-wit) ((frame-number int))
  (declare (connected wit-image (frame-changed int))) 
  (when (= frame-number (- (q+:frame-count wit-image) 1))
    (q+:stop wit-image)))

(define-slot (fx-label stop-ce) ((frame-number int))
  (declare (connected ce-image (frame-changed int))) 
  (when (= frame-number (- (q+:frame-count ce-image) 1))
    (q+:stop ce-image)))

(define-slot (fx-label stop-flash) ((frame-number int))
  (declare (connected flash-image (frame-changed int))) 
  (when (= frame-number (- (q+:frame-count flash-image) 1))
    (q+:stop flash-image)))

(define-slot (fx-label stop-loop) ((frame-number int))
  (declare (connected image (frame-changed int))) 
  (when (= frame-number (- (q+:frame-count image) 1))
    (q+:stop image)
    (signal! fx-label (done))))

