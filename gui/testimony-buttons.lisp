(in-package #:cl-user)
(defpackage #:aoclient.gui.testimony-buttons
  (:use #:cl+qt)
  (:import-from #:aoclient.utilities
                #:misc-path)
  (:import-from #:aoclient.netsend
                #:send))
(in-package #:aoclient.gui.testimony-buttons)

(in-readtable :qtools)

(define-widget witness-button (QPushbutton) ())
(define-widget crossex-button (QPushbutton) ())

(define-subwidget (witness-button icon) (q+:make-qicon (misc-path "testimony.png")))
(define-subwidget (crossex-button icon) (q+:make-qicon (misc-path "crossex.png")))

(define-initializer (witness-button setup) 
  (with-finalizing ((size (q+:make-qsize 91 56)))
    (q+:set-auto-fill-background witness-button t)
    (q+:set-flat witness-button t)
    (q+:set-icon-size witness-button size)
    (q+:set-icon witness-button icon)))

(define-initializer (crossex-button setup) 
  (with-finalizing ((size (q+:make-qsize 91 56)))
    (q+:set-auto-fill-background crossex-button t)
    (q+:set-flat crossex-button t)
    (q+:set-icon-size crossex-button size)
    (q+:set-icon crossex-button icon)))

(define-slot (witness-button send-witness) ()
  (declare (connected witness-button (pressed)))
  (send "#5289#testimony1#%"))

(define-slot (crossex-button send-crossex) ()
  (declare (connected crossex-button (pressed)))
  (send "#5289#testimony2#%"))

