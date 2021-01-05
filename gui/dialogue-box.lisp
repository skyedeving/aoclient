(in-package #:cl-user)
(defpackage #:aoclient.gui.dialogue-box
  (:use #:cl+qt)
  (:import-from #:aoclient.utilities
                #:misc-path)
  (:import-from #:aoclient.gui.jukebox
                #:*jukebox*
                #:play-sfx)
  (:export #:main))
(in-package #:aoclient.gui.dialogue-box)

(in-readtable :qtools)

(define-widget dialogue-box (QTextEdit)
  ((text :accessor text :initform "")
   (blipfx :initform "sfx-blipmale")
   (blip-loop :initarg :blip-loop :accessor blip-loop :initform 0)
   (jukebox :initform *jukebox*)))

(define-subwidget (dialogue-box aa-font) (q+:make-qfont)
  (let* ((id (q+:qfontdatabase-add-application-font (misc-path "aaf.ttf")))
         (fam (q+:qfontdatabase-application-font-families id) 0))
    (q+:set-family aa-font (car fam))))

(define-subwidget (dialogue-box blip-timer) (q+:make-qtimer dialogue-box)
  (q+:set-single-shot blip-timer nil))

(define-initializer (dialogue-box setup)
  (q+:set-read-only dialogue-box t)
  (q+:set-fixed-height dialogue-box 128)
  (q+:set-font-point-size dialogue-box 24)
  (q+:set-font dialogue-box aa-font)
  (q+:set-style-sheet dialogue-box "* { background-color: rgba(0,0,0,125); border: 2px solid white; border-radius: 10px;}"))

(define-signal (dialogue-box clear) ())
(define-signal (dialogue-box done) ())
(define-signal (dialogue-box talking) ())
(define-signal (dialogue-box start) (string string int))
(define-signal (dialogue-box set-text-color) (int))

(defun color-code (code)
  (nth code '("white" "#00FF00" "#FF0000" "orange" "#00bfff")))

(define-slot (dialogue-box set-text-color set-text-color) ((new-color int))
  (declare (connected dialogue-box (set-text-color)))
  (with-finalizing* ((parsed-color (color-code new-color))
                     (color (q+:make-qcolor parsed-color)))
    (format t "Text Color: ~a~%" parsed-color)
    (q+:set-text-color dialogue-box color)))

(define-slot (dialogue-box clear clear) ()
  (declare (connected dialogue-box (clear)))
  (setf text "")
  (q+:set-text dialogue-box text))

(define-slot (dialogue-box start start) ((name string) (new-text string) (speed int))
  (declare (connected dialogue-box (start string string int)))
  (setf text new-text)
  (setf blip-loop (round (/ (length text) 2)))
  (setf blipfx "sfx-blipfemale")
  (signal! dialogue-box (talking))
  (q+:start blip-timer speed))

(define-slot (dialogue-box blip-play) ()
  (declare (connected blip-timer (timeout))) 
  (q+:set-text dialogue-box
               (if (string= "" text)
                   ""
                   (progn (play-sfx *jukebox* blipfx 0)
                          (subseq text 0 (if (< (- (length text) (* 2 blip-loop)) 1)
                                            0
                                            (- (length text) (* 2 blip-loop)))))))

  (when (< (decf blip-loop) 1)
    (signal! dialogue-box (done))
    (q+:set-text dialogue-box text)
    (q+:stop blip-timer)))
