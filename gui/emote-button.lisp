(in-package #:cl-user)
(defpackage #:aoclient.gui.emote-button
  (:use #:cl+qt)
  (:import-from #:aoclient.utilities
                #:button-path
                #:misc-path)
  (:import-from #:aoclient.aochar
                #:load-character
                #:emotions
                #:id))
(in-package #:aoclient.gui.emote-button)

(in-readtable :qtools)

(define-widget emote-button (QPushButton)
  ((character-name :initform "" :initarg :character-name)
   (id :initform 0 :initarg :id)))

(define-subwidget (emote-button icon-size) (q+:make-qsize 40 40))

(define-subwidget (emote-button icon) (q+:make-qicon))

(define-initializer (emote-button setup-button) 
  (let ((on (if (button-path character-name id t)
                (namestring (button-path character-name id t))
                (misc-path "placeholder.png")))
        (off (if (button-path character-name id nil)
                 (namestring (button-path character-name id nil))
                 (misc-path "placeholder.png"))))
    (q+:add-file icon on icon-size (q+:qicon.normal) (q+:qicon.on))
    (q+:add-file icon off icon-size (q+:qicon.normal) (q+:qicon.off))
    (q+:set-icon emote-button icon)
    (q+:set-icon-size emote-button icon-size))
  (q+:resize emote-button icon-size)
  (q+:set-flat emote-button t)
  (q+:set-auto-fill-background emote-button t)
  (q+:set-checkable emote-button t))
