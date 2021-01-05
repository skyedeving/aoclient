(in-package #:cl-user)
(defpackage #:aoclient.gui.main
  (:use #:cl+qt)
  (:import-from #:aoclient.gui.testimony-buttons
                #:crossex-button
                #:witness-button)
  (:import-from #:aoclient.gui.game-panel
                #:game-panel
                #:theme
                #:character
                #:fore
                #:fx
                #:icc-textbox
                #:change-sides)
  (:import-from #:aoclient.gui.volume-controls
                #:volume-controls)
  (:import-from #:aoclient.gui.hp-bars
                #:hp-bars
                #:set-hp
                #:red-bar
                #:blue-bar)
  (:import-from #:aoclient.gui.dialogue-box
                #:start
                #:clear
                #:set-text-color)
  (:import-from #:aoclient.gui.pressing-panel
                #:previous-button
                #:flash-button
                #:color-selection
                #:pressing-panel
                #:pressing-buttons-group)
  (:import-from #:aoclient.gui.character-selection
                #:character-selection)
  (:import-from #:aoclient.gui.music-selection
                #:music-selection)
  (:import-from #:aoclient.utilities
                #:character-path
                #:background-path
                #:sfx-path
                #:music-path
                #:misc-path)
  (:import-from #:aoclient.gui.emotes-panel
                #:emote-buttons-group
                #:emotes-panel)
  (:import-from #:aoclient.aochar
                #:load-character
                #:emotions
                #:preanimations
                #:preanimation
                #:animation
                #:mode
                #:sfx
                #:sfx-timing)
  (:import-from #:aoclient.connection
                #:*stream*
                #:with-connection)
  (:import-from #:split-sequence
                #:split-sequence)
  (:import-from #:alexandria
                #:switch)
  (:import-from #:aoclient.netsend
                #:talk-occ
                #:choose-character
                #:hi
                #:send
                #:music
                #:talk) 
  (:import-from #:aoclient.netreceive
                #:network-listener
                #:receive)
  (:import-from #:bass 
                #:stream-free
                #:stream-create-file
                #:channel-play
                #:channel-bytes-2-seconds
                #:channel-get-length)
  (:import-from #:aoclient.gui.jukebox
                #:jukebox
                #:*jukebox*
                #:play-sfx)
  (:export #:main))
(in-package #:aoclient.gui.main)

(in-readtable :qtools)

(define-widget main-window (QWidget)
  ((previous-emotion :initform 0) 
   (msg :initarg :msg :accessor msg :initform "")
   (netmsg :initarg netmsg :accessor netmsg :initform "")))

(define-subwidget (main-window jukebox) (make-instance 'jukebox))

(define-subwidget (main-window volume-controls) (make-instance 'volume-controls))

(define-subwidget (main-window game-panel) (make-instance 'game-panel)
  (connect! (slot-value game-panel 'fx) (done) main-window (fx-done))
  (connect! (slot-value game-panel 'icc-textbox) (done) main-window (text-done))
  (connect! (slot-value game-panel 'icc-textbox) (talking) main-window (talking)))

(define-subwidget (main-window icc-input) (q+:make-qlineedit))
(define-subwidget (main-window occ-input) (q+:make-qlineedit))

(define-subwidget (main-window icc-log) (q+:make-qtextedit)
  (q+:set-read-only icc-log t))
(define-subwidget (main-window occ-log) (q+:make-qtextedit)
  (q+:set-read-only occ-log t))

(define-subwidget (main-window emotes-panel) (make-instance 'emotes-panel))
(define-subwidget (main-window pressing-panel) (make-instance 'pressing-panel))

(define-subwidget (main-window hp-bars) (make-instance 'hp-bars))

(define-subwidget (main-window character-selection) (make-instance 'character-selection))
(define-subwidget (main-window music-selection) (make-instance 'music-selection))

(define-subwidget (main-window witness-button) (make-instance 'witness-button))
(define-subwidget (main-window crossex-button) (make-instance 'crossex-button))

(define-subwidget (main-window icc-layout) (q+:make-qvboxlayout)
  (q+:add-widget icc-layout game-panel)
  (q+:add-widget icc-layout icc-input)
  (q+:add-widget icc-layout emotes-panel)
  (q+:add-widget icc-layout pressing-panel))

(define-subwidget (main-window occ-layout) (q+:make-qvboxlayout)
  (q+:add-widget occ-layout occ-log)
  (q+:add-widget occ-layout occ-input)
  (q+:add-layout occ-layout volume-controls)
  (q+:add-widget occ-layout witness-button)
  (q+:add-widget occ-layout crossex-button)
  (q+:add-widget occ-layout hp-bars))

(define-subwidget (main-window main-layout) (q+:make-qhboxlayout main-window)
  (q+:add-layout main-layout icc-layout)
  (q+:add-widget main-layout icc-log) 
  (q+:add-layout main-layout occ-layout)
  (q+:add-widget main-layout character-selection)
  (q+:add-widget main-layout music-selection))

(define-subwidget (main-window network-timer) (q+:make-qtimer main-window)
  (q+:set-single-shot network-timer nil)
  (q+:start network-timer 1))

(define-subwidget (main-window preanim-timer) (q+:make-qtimer main-window)
  (q+:set-single-shot preanim-timer nil))

(define-subwidget (main-window sfx-timer2) (q+:make-qtimer main-window)
  (q+:set-single-shot sfx-timer2 nil))

(define-subwidget (main-window sfx-timer) (q+:make-qtimer main-window)
  (q+:set-single-shot sfx-timer nil))

(define-subwidget (main-window gc-timer) (q+:make-qtimer main-window)
  (q+:set-single-shot sfx-timer nil)
  (q+:start gc-timer (* 60 1000)))

(define-slot (main-window run-gc) ()
  (declare (connected gc-timer (timeout)))
  (tg:gc :full t))

(define-slot (main-window fx-done) ()
  (declare (connected (slot-value game-panel 'fx) (done))) 
  (signal! (slot-value game-panel 'character)
           (preanim string string)
           (nth 3 (split-sequence #\# netmsg))
           (nth 2 (split-sequence #\# netmsg))) 
  (q+:start sfx-timer (round (* 62.5 (read-from-string (nth 12 (split-sequence #\# netmsg))))))
  (q+:start preanim-timer (preanimation-timing (nth 3 (split-sequence #\# netmsg))
                                               (nth 2 (split-sequence #\# netmsg)))))

(define-slot (main-window character-selected) ((item "QListWidgetItem*"))
  (declare (connected character-selection (item-double-clicked "QListWidgetItem*")))
  (signal! emotes-panel (clear-buttons))
  (signal! emotes-panel (load-buttons string) (q+:text item))
  (format t "Character Selected: ~a~%" (q+:text item)))

(define-slot (main-window keep-icc-focus) ()
  (declare (connected (slot-value emotes-panel 'emote-buttons-group) (button-clicked integer)))
  (q+:set-focus icc-input))

(defun random-side ()
  (nth (random 6) '("pro" "def" "jud" "wit" "hld" "hlp")))

(define-slot (main-window icc-input-done) ()
  (declare (connected icc-input (return-pressed)))
  (when (string/= msg (q+:text icc-input))
    (let* ((character (q+:text (q+:current-item character-selection)))
           (emotion (nth (1- (q+:checked-id (slot-value emotes-panel 'emote-buttons-group)))
                         (emotions (load-character character))))
           (pressing (q+:checked-id (slot-value pressing-panel 'pressing-buttons-group)))) 
      (send (talk (preanimation emotion)
                  character
                  (animation emotion)
                  (q+:text icc-input)
                  (random-side)
                  (sfx emotion)
                  (if (> pressing 0)
                      (if (= (mode emotion) 5)
                          5
                          2)
                      (if (and (eq previous-emotion (q+:checked-id (slot-value emotes-panel 'emote-buttons-group)))
                               (eq 1 (mode emotion)))
                          0
                          (mode emotion)))
                  (random 100)
                  (sfx-timing emotion)
                  (if (> pressing 0)
                      pressing
                      0)
                  0
                  1
                  (if (q+:is-checked (slot-value pressing-panel 'flash-button))
                      1
                      0)
                  (q+:current-index (slot-value pressing-panel 'color-selection))))
      (q+:set-checked (slot-value pressing-panel 'flash-button) nil)
      (when (> pressing 0)
        (let* ((pressing-buttons-group (slot-value pressing-panel 'pressing-buttons-group))
               (button (q+:checked-button pressing-buttons-group)))
          (q+:set-exclusive pressing-buttons-group nil)
          (q+:set-checked button nil)
          (q+:set-exclusive pressing-buttons-group t)
          (setf (previous-button pressing-panel) nil))))
    (q+:set-text icc-input "")
    (setf previous-emotion (q+:checked-id (slot-value emotes-panel 'emote-buttons-group)))))
;(send "HP#1#0#%")
;(send "HP#2#0#%")
;(send "ZZ#someone#%")
;(send "MS#chat#coffee#EmaSkye#coffee#etc.#hld#1#0#62#1#0#0#99#0#0#")
(define-slot (main-window occ-input-done) ()
  (declare (connected occ-input (return-pressed)))
  (send (talk-occ "New Client" (q+:text occ-input))) 
  (q+:set-text occ-input ""))

(define-slot (main-window text-done) ()
  (signal! (slot-value game-panel 'character)
           (idle string string)
           (nth 3 (split-sequence #\# netmsg))
           (nth 4 (split-sequence #\# netmsg))))

(define-slot (main-window talking) ()
  (signal! (slot-value game-panel 'character)
           (talking string string)
           (nth 3 (split-sequence #\# netmsg))
           (nth 4 (split-sequence #\# netmsg))))

(define-slot (main-window regular-mode regular-mode) ()
  (declare (connected main-window (regular-mode)))
  (when (= (read-from-string (nth 14 (split-sequence #\# netmsg))) 1) 
    (signal! (slot-value game-panel 'fx) (flash))
    (signal! jukebox (play-sfx string int) "sfx-realization" 0))
  (start (slot-value game-panel 'icc-textbox)
         (nth 3 (split-sequence #\# netmsg))
         (nth 5 (split-sequence #\# netmsg))
         (if (or (search "?!" (nth 5 (split-sequence #\# netmsg)) :from-end t)
                 (search "!!" (nth 5 (split-sequence #\# netmsg)) :from-end t))
             55
             (if (search "..." (nth 5 (split-sequence #\# netmsg)) :from-end t)
                 165
                 110))))

(define-slot (main-window preanimation preanimation) ()
  (declare (connected preanim-timer (timeout)))
  (q+:stop preanim-timer)
  (regular-mode main-window) 
  (signal! (slot-value game-panel 'character)
             (talking string string)
             (nth 3 (split-sequence #\# netmsg))
             (nth 4 (split-sequence #\# netmsg))))

(define-slot (main-window sfx-timer2) ()
  (declare (connected sfx-timer2 (timeout)))
  (q+:stop sfx-timer2)
  (let ((mode (read-from-string (nth 8 (split-sequence #\# netmsg)))))
    (when (and (/= mode 2) (/= mode 1)) 
      (when (= (read-from-string (nth 14 (split-sequence #\# netmsg))) 1)
        (signal! (slot-value game-panel 'fx) (flash))
        (signal! jukebox (play-sfx string int) "sfx-realization" 0))
        (start (slot-value game-panel 'icc-textbox)
           (nth 3 (split-sequence #\# netmsg))
           (nth 5 (split-sequence #\# netmsg))
           110))))

(define-slot (main-window sfx-timer) ()
  (declare (connected sfx-timer (timeout)))
  (let ((sfx (concatenate 'string (nth 7 (split-sequence #\# netmsg)) ".wav")))
    (if (cl-fad:file-exists-p(pathname (sfx-path sfx)))
        (progn (signal! jukebox (play-sfx string int) (nth 7 (split-sequence #\# netmsg)) 0)
               (q+:start sfx-timer2 (round (* 62.5 (read-from-string (nth 10 (split-sequence #\# netmsg)))))))
        (q+:start sfx-timer2 1)))
  (q+:stop sfx-timer))


(define-subwidget (main-window timer1) (q+:make-qtimer))
(define-subwidget (main-window timer2) (q+:make-qtimer))
(define-subwidget (main-window timer3) (q+:make-qtimer))

(define-slot (main-window timer1 timer1) ()
  (declare (connected timer1 (timeout)))
  (if flashp
      (q+:start timer2 100)
      (timer2 main-window)))
(define-slot (main-window timer2 timer2) ()
  (declare (connected timer2 (timeout)))
  (if preanim
      (q+:start timer3 100)
      (timer3 main-window)))
(define-slot (main-window timer3 timer3) ()
  (declare (connected timer3 (timeout)))
  (start (slot-value game-panel 'icc-textbox)
         (nth 3 (split-sequence #\# netmsg))
         (nth 5 (split-sequence #\# netmsg))
         110))

(defun color-code (code)
  (nth code '("white" "#00FF00" "#FF0000" "orange" "#00bfff")))

(defun press-mode (code)
  (nth code '("" "holdit" "objection" "takethat")))

(defun preanimation-timing (character name)
  (if (cl-fad:directory-exists-p (character-path character))
      (round (* 60 (read-from-string
                    (if (cdr (assoc name (preanimations (load-character character)) :test #'equal))
                        (cdr (assoc name (preanimations (load-character character)) :test #'equal))
                        "0"))))
      1))

(define-slot (main-window netread) ()
  (declare (connected network-timer (timeout)))
  (let ((resp (when (listen *stream*) (receive))))
    (when resp
      (format t "Server Response: ~a~%" resp)
      (let ((command (subseq resp 0 2)))
        (switch (command :test equal)
          ("HP" (let ((bar (read-from-string (nth 1 (split-sequence #\# resp))))
                      (hp (read-from-string (nth 2 (split-sequence #\# resp))))) 
                  (case bar
                    (1 (set-hp (slot-value hp-bars 'blue-bar) hp))
                    (2 (set-hp (slot-value hp-bars 'red-bar) hp)))))
          ("RT" (switch ((nth 1 (split-sequence #\# resp)) :test 'equal)
                  ("testimony1" (signal! (slot-value game-panel 'fx) (wit))
                                (play-sfx *jukebox* "sfx-testimony2" 0))
                  ("testimony2" (signal! (slot-value game-panel 'fx) (ce))
                                (play-sfx *jukebox* "sfx-testimony" 0))))
          ("BN" (setf (theme game-panel) (nth 1 (split-sequence #\# resp))))
          ("MC" (q+:append icc-log (format nil "~a changed music to ~a"
                                           (nth 2 (split-sequence #\# resp))
                                           (nth 1 (split-sequence #\# resp)))) 
                (signal! jukebox (play-music string) (nth 1 (split-sequence #\# resp))))
          ("MS" (change-sides game-panel (nth 6 (split-sequence #\# resp)))
                (q+:append icc-log (format nil "~a: ~a"
                                           (nth 3 (split-sequence #\# resp))
                                           (nth 5 (split-sequence #\# resp))))
                (clear (slot-value game-panel 'icc-textbox))
                (set-text-color (slot-value game-panel 'icc-textbox)
                                (read-from-string (nth 15 (split-sequence #\# resp))))

                (setf msg (nth 5 (split-sequence #\# resp)))
                (setf netmsg resp)                
                           
                (let ((mode (read-from-string (nth 8 (split-sequence #\# resp))))
                      (sfx-timing (read-from-string (nth 12 (split-sequence #\# resp)))))
                  (when (= sfx-timing 0)
                    (setf sfx-timing (/ 1 62.5)))
                  (case mode
                    (0 (regular-mode main-window)
                     (play-sfx *jukebox* (nth 7 (split-sequence #\# netmsg))
                               (round (* 62.5 (read-from-string (nth 12 (split-sequence #\# netmsg)))))))
                    (1 (signal! (slot-value game-panel 'character)
                                (preanim string string)
                                (nth 3 (split-sequence #\# netmsg))
                                (nth 2 (split-sequence #\# netmsg))) 
                     (q+:start sfx-timer (round (* 62.5 sfx-timing)))
                     (q+:start preanim-timer (preanimation-timing (nth 3 (split-sequence #\# resp))
                                                                  (nth 2 (split-sequence #\# resp))))
                     
                     (write-line "Sup it's mode 1 for preanims!"))
                    (2 (write-line "Should be an objection here!")
                     (signal! jukebox
                              (play-character-sfx string string)
                              (nth 3 (split-sequence #\# netmsg))
                              (press-mode (read-from-string (nth 11 (split-sequence #\# netmsg)))))
                     (signal! (slot-value game-panel 'fx) 
                              (pressing string)
                              (press-mode (read-from-string (nth 11 (split-sequence #\# netmsg))))))
                    (5 (write-line "Sup it's mode 5 for zooming!")
                     (signal! (slot-value game-panel 'character)
                              (talking string string)
                              (nth 3 (split-sequence #\# netmsg))
                              (nth 4 (split-sequence #\# netmsg))) 
                     (q+:clear (slot-value game-panel 'fore))
                     (q+:start sfx-timer (round (* 62.5 sfx-timing)))))))
          ("CT" (q+:append occ-log (format nil "~a: ~a"
                                           (nth 1 (split-sequence #\# resp))
                                           (nth 2 (split-sequence #\# resp))))))))))

;; localhost 27016
;; 51.255.160.217 50000

(defun main () 
  (with-connection "localhost" 27016 ;"51.255.160.217" 50000
    (with-main-window (window (make-instance 'main-window) :main-thread nil)
      (q+:set-window-title window "AOClient") 
      (format t "~a~%" (receive))
      (send (hi "aoclient"))
      (format t "~a~%" (receive))
      (choose-character 1)
      (format t "~a~%" (receive))))
  (tg:gc :full t))
