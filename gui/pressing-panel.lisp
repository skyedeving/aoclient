(in-package #:cl-user)
(defpackage #:aoclient.gui.pressing-panel
  (:use #:cl+qt)
  (:import-from #:aoclient.utilities
                #:misc-path))
(in-package #:aoclient.gui.pressing-panel)

(in-readtable :qtools)

(define-widget pressing-panel (QWidget)
  ((previous-button :initform -1 :accessor previous-button)))

(define-subwidget (pressing-panel pressing-buttons-group) (q+:make-qbuttongroup)
  (q+:set-exclusive pressing-buttons-group t))

(define-widget pressing-button (QPushButton)
  ((on-name :initarg :on-name)
   (off-name :initarg :off-name)
   (id :initarg :id :accessor id)))

(define-subwidget (pressing-button icon-size) (q+:make-qsize 76 28))

(define-subwidget (pressing-button icon) (q+:make-qicon))

(define-initializer (pressing-button setup-button) 
  (let ((on (misc-path on-name))
        (off (misc-path off-name)))
    (q+:add-file icon on icon-size (q+:qicon.normal) (q+:qicon.on))
    (q+:add-file icon off icon-size (q+:qicon.normal) (q+:qicon.off))
    (q+:set-icon pressing-button icon)
    (q+:set-icon-size pressing-button icon-size)
    (q+:set-flat pressing-button t)
    (q+:set-auto-fill-background pressing-button t)
    (q+:set-checkable pressing-button t)))

(define-subwidget (pressing-panel holdit-button) (make-instance 'pressing-button
                                                                :on-name "button_holdit.png"
                                                                :off-name "button_holdit_off.png"
                                                                :id 1))
(define-subwidget (pressing-panel objection-button) (make-instance 'pressing-button
                                                                   :on-name "OBJ!.png"
                                                                   :off-name "OBJ!off.png"
                                                                   :id 2))
(define-subwidget (pressing-panel takethat-button) (make-instance 'pressing-button
                                                                  :on-name "button_takethat.png"
                                                                  :off-name "button_takethat_off.png"
                                                                  :id 3))
(define-subwidget (pressing-panel flash-button) (make-instance 'pressing-button
                                                               :on-name "1.png"
                                                               :off-name "1_pressed.png"))

(define-subwidget (pressing-panel color-selection) (q+:make-qcombobox)
  (q+:add-item color-selection "normal")
  (q+:add-item color-selection "green")
  (q+:add-item color-selection "red")
  (q+:add-item color-selection "orange")
  (q+:add-item color-selection "blue"))

(define-subwidget (pressing-panel button-layout) (q+:make-qhboxlayout pressing-panel)
  (q+:add-widget button-layout holdit-button)
  (q+:add-widget button-layout objection-button)
  (q+:add-widget button-layout takethat-button)
  (q+:add-widget button-layout flash-button)
  (q+:add-widget button-layout color-selection)
  (q+:add-button pressing-buttons-group holdit-button 1)
  (q+:add-button pressing-buttons-group objection-button 2)
  (q+:add-button pressing-buttons-group takethat-button 3))

(define-slot (pressing-panel allow-checkable-buttons) ((button "QAbstractButton*"))
  (declare (connected pressing-buttons-group (button-clicked "QAbstractButton*"))) 
  (if (eq previous-button (id button))
      (progn (q+:set-exclusive pressing-buttons-group nil)
             (q+:set-checked button nil)
             (q+:set-exclusive pressing-buttons-group t)
             (setf previous-button nil))
        (setf previous-button (id button))))
