(in-package #:cl-user)
(defpackage #:aoclient.gui.volume-controls
  (:use #:cl+qt)
  (:import-from #:aoclient.gui.jukebox
                #:*jukebox*
                #:master-volume
                #:music-volume
                #:sfx-volume))
(in-package #:aoclient.gui.volume-controls)

(in-readtable :qtools)

(define-widget volume-controls (QVBoxLayout) ())

(define-subwidget (volume-controls master-volume-slider) (q+:make-qslider (q+:qt.horizontal)) 
  (q+:set-minimum master-volume-slider 0)
  (q+:set-maximum master-volume-slider 100)
  (q+:set-value master-volume-slider (round (* 100 (master-volume *jukebox*))))
  (q+:add-widget volume-controls master-volume-slider))

(define-subwidget (volume-controls music-volume-slider) (q+:make-qslider (q+:qt.horizontal)) 
  (q+:set-minimum music-volume-slider 0)
  (q+:set-maximum music-volume-slider 100)
  (q+:set-value music-volume-slider (round (* 100 (music-volume *jukebox*))))
  (q+:add-widget volume-controls music-volume-slider))

(define-subwidget (volume-controls sfx-volume-slider) (q+:make-qslider (q+:qt.horizontal)) 
  (q+:set-minimum sfx-volume-slider 0)
  (q+:set-maximum sfx-volume-slider 100)
  (q+:set-value sfx-volume-slider (round (* 100 (sfx-volume *jukebox*))))
  (q+:add-widget volume-controls sfx-volume-slider))

(define-slot (volume-controls master-volume-slider-changed) ((new-value int))
  (declare (connected master-volume-slider (value-changed int))) 
  (setf (master-volume *jukebox*) (float (/ new-value 100)))
  (format t "Master Volume: ~a~%" (master-volume *jukebox*)))

(define-slot (volume-controls music-volume-slider-changed) ((new-value int))
  (declare (connected music-volume-slider (value-changed int))) 
  (setf (music-volume *jukebox*) (float (/ new-value 100))) 
  (format t "Music Volume: ~a~%" (music-volume *jukebox*)))

(define-slot (volume-controls sfx-volume-slider-changed) ((new-value int))
  (declare (connected sfx-volume-slider (value-changed int))) 
  (setf (sfx-volume *jukebox*) (float (/ new-value 100)))
  (format t "SFX Volume: ~a~%" (sfx-volume *jukebox*)))
