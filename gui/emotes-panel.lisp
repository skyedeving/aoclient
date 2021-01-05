(in-package #:cl-user)
(defpackage #:aoclient.gui.emotes-panel
  (:use #:cl+qt) 
  (:import-from #:aoclient.gui.emote-button
                #:emote-button)
  (:import-from #:aoclient.aochar
                #:load-character
                #:emotions
                #:id))
(in-package #:aoclient.gui.emotes-panel)

(in-readtable :qtools)

(define-widget emotes-panel (QWidget)
  ((buttons-list :accessor buttons-list :initform nil :finalized t)))

(define-subwidget (emotes-panel emote-buttons-group) (q+:make-qbuttongroup)
  (q+:set-exclusive emote-buttons-group t))

(define-subwidget (emotes-panel emote-buttons-layout) (q+:make-qgridlayout emotes-panel))

(define-signal (emotes-panel load-buttons) (string))

(define-signal (emotes-panel clear-buttons) ())

(define-slot (emotes-panel load-buttons load-buttons) ((character-name string))
  (declare (connected emotes-panel (load-buttons string)))
  (loop with emotions = (emotions (load-character character-name))
        for emotion in emotions
        for e upto (length emotions)
        for col = (mod e 5)
        for row = (floor (/ e 5))
        for button = (make-instance 'emote-button :character-name character-name :id (id emotion)) 
        do (q+:add-button emote-buttons-group button (id emotion))
        do (q+:add-widget emote-buttons-layout button row col)
        do (push button buttons-list)
        finally (q+:toggle (car (last buttons-list)))))

(define-slot (emotes-panel clear-buttons) () 
  (declare (connected emotes-panel (clear-buttons))) 
  (loop for button in buttons-list
        do (q+:remove-widget emote-buttons-layout button)
        do (q+:remove-button emote-buttons-group button)
        do (q+:delete-later button)
        do (finalize button)
        finally (setf buttons-list nil)))

(define-slot (emotes-panel emote-buttons-group) ((id integer))
  (declare (connected emote-buttons-group (button-clicked integer)))
  (print id))
