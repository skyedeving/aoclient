(in-package #:cl-user)
(defpackage #:aoclient.gui.hp-bars
  (:use #:cl+qt)
  (:import-from #:aoclient.netsend
                #:send)
  (:import-from #:aoclient.utilities
                #:misc-path))
(in-package #:aoclient.gui.hp-bars)

(in-readtable :qtools)

(define-widget hp-bars (QWidget) ())

(define-widget red-bar (QLabel)
  ((hp :initform 10)))
(define-widget blue-bar (QLabel)
  ((hp :initform 10)))

(define-subwidget (hp-bars red-bar) (make-instance 'red-bar))
(define-subwidget (hp-bars blue-bar) (make-instance 'blue-bar))

(define-subwidget (red-bar empty-bar-image) (q+:make-qimage (misc-path "zdoh.png")))
(define-subwidget (red-bar red-bar-image) (q+:make-qimage (misc-path "procuror.png")))
(define-subwidget (red-bar red-minus-button) (q+:make-qpushbutton))
(define-subwidget (red-bar red-plus-button) (q+:make-qpushbutton))
(define-subwidget (red-bar red-bar-layout) (q+:make-qhboxlayout)
  (q+:add-widget red-bar-layout red-minus-button)
  (q+:add-widget red-bar-layout red-bar)
  (q+:set-minimum-width red-bar 90)
  (q+:set-minimum-height red-bar 20)
  (q+:add-widget red-bar-layout red-plus-button))

(define-subwidget (blue-bar empty-bar-image) (q+:make-qimage (misc-path "zdoh.png")))
(define-subwidget (blue-bar blue-bar-image) (q+:make-qimage (misc-path "advocat.png")))
(define-subwidget (blue-bar blue-minus-button) (q+:make-qpushbutton))
(define-subwidget (blue-bar blue-plus-button) (q+:make-qpushbutton))
(define-subwidget (blue-bar blue-bar-layout) (q+:make-qhboxlayout)
  (q+:add-widget blue-bar-layout blue-minus-button)
  (q+:add-widget blue-bar-layout blue-bar)
  (q+:set-minimum-width blue-bar 90)
  (q+:set-minimum-height blue-bar 20)
  (q+:add-widget blue-bar-layout blue-plus-button))

(define-subwidget (hp-bars layout) (q+:make-qvboxlayout hp-bars) 
  (q+:add-layout layout (slot-value blue-bar 'blue-bar-layout))
  (q+:add-layout layout (slot-value red-bar 'red-bar-layout)))

(define-override (blue-bar paint-event) (event)
  (declare (ignore event))
  (with-finalizing ((painter (q+:make-qpainter blue-bar))
                    (origin (q+:make-qpoint 0 0))
                    (source (q+:make-qrect 0 0 (1+ (round (* 90 (/ hp 10)))) 20)))
    (q+:draw-image painter origin empty-bar-image)
    (q+:draw-image painter origin blue-bar-image source)))

(define-override (red-bar paint-event) (event)
  (declare (ignore event))
  (with-finalizing ((painter (q+:make-qpainter red-bar))
                    (origin (q+:make-qpoint 0 0))
                    (source (q+:make-qrect 0 0 (1+ (round (* 90 (/ hp 10)))) 20)))
    (q+:draw-image painter origin empty-bar-image)
    (q+:draw-image painter origin red-bar-image source)))

(define-signal (red-bar set-hp) (int))
(define-signal (blue-bar set-hp) (int))

(define-slot (blue-bar set-hp set-hp) ((new-hp int))
  (declare (connected blue-bar (set-hp int))) 
  (setf hp new-hp)
  (q+:repaint blue-bar))

(define-slot (blue-bar penalty) ()
  (declare (connected blue-minus-button (pressed)))
  (when (> hp 0)
    (send (format nil "HP#1#~a#%" (1- hp)))
    (q+:repaint blue-bar)))

(define-slot (blue-bar life) ()
  (declare (connected blue-plus-button (pressed)))
  (when (< hp 10)
    (send (format nil "HP#1#~a#%" (1+ hp)))
    (q+:repaint blue-bar)))

(define-slot (red-bar set-hp set-hp) ((new-hp int))
  (declare (connected red-bar (set-hp int)))
  (setf hp new-hp)
  (q+:repaint red-bar))

(define-slot (red-bar penalty) ()
  (declare (connected red-minus-button (pressed)))
  (when (> hp 0)
    (send (format nil "HP#2#~a#%" (1- hp)))
    (q+:repaint red-bar)))

(define-slot (red-bar life) ()
  (declare (connected red-plus-button (pressed)))
  (when (< hp 10)
    (send (format nil "HP#2#~a#%" (1+ hp)))
    (q+:repaint red-bar)))
