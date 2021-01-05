(in-package #:cl-user)
(defpackage #:aoclient.gui.music-selection
  (:use #:cl+qt)
  (:import-from #:aoclient.netsend
                #:send)
  (:import-from #:aoclient.utilities
                #:all-music))
(in-package #:aoclient.gui.music-selection)

(in-readtable :qtools)

(define-widget music-selection (QListWidget) ())

(define-initializer (music-selection add-musics)
  (mapcar #'(lambda (name) (q+:add-item music-selection name)) (all-music)))

(define-slot (music-selection music-selected) ((item "QListWidgetItem*"))
  (declare (connected music-selection (item-double-clicked "QListWidgetItem*")))
  (send (format nil "#4D80#~a#1#%" (q+:text item)))
  (format t "Selected Music: ~a~%" (q+:text item)))
