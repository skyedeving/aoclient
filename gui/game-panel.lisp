(in-package #:cl-user)
(defpackage #:aoclient.gui.game-panel
  (:use #:cl+qt)
  (:import-from #:alexandria
                #:switch)
  (:import-from #:aoclient.gui.character-label
                #:character-label)
  (:import-from #:aoclient.gui.fx-label
                #:fx-label)
  (:import-from #:aoclient.gui.dialogue-box
                #:dialogue-box)
  (:import-from #:aoclient.utilities
                #:misc-path
                #:character-path
                #:background-path))
(in-package #:aoclient.gui.game-panel)

(in-readtable :qtools)

(define-widget game-panel (QWidget)
  ((theme :accessor theme :initform "default")))

(define-widget image-view (Qlabel) ())

(define-subwidget (game-panel aa-font) (q+:make-qfont)
  (let* ((id (q+:qfontdatabase-add-application-font (misc-path "aaf.ttf")))
         (fam (q+:qfontdatabase-application-font-families id) 0))
    (q+:set-family aa-font (car fam))))

(define-subwidget (image-view image) (q+:make-qpixmap))

(defgeneric load-image (view file-name)
  (:method ((view image-view) file-name)
    (with-slots (image) view
      (format t "Image Valid(~a): ~a~%" file-name (not (q+:is-null image)))
      (q+:load image file-name)
      (q+:set-pixmap view image)
      (q+:set-scaled-contents view t)
      (q+:set-fixed-width view (* 2 (q+:width image)))
      (q+:set-fixed-height view (* 2 (q+:height image)))
      (q+:show view))))

(defmethod initialize-instance :after ((this image-view) &key file-name)
  (load-image this file-name))

(define-subwidget (game-panel bg) (make-instance 'image-view
                                                 :file-name (background-path "default" "defenseempty.png")))
(define-subwidget (game-panel character) (make-instance 'character-label)
  (signal! character (preanim string string) "EmaSkye" "drop"))
(define-subwidget (game-panel fore) (make-instance 'image-view
                                                   :file-name  (background-path "default" "bancodefensa.gif")))
(define-subwidget (game-panel fx) (make-instance 'fx-label))

(define-subwidget (game-panel icc-textbox) (make-instance 'dialogue-box))

(define-subwidget (game-panel overlap-layout) (q+:make-qgridlayout game-panel)
  (q+:add-widget overlap-layout bg 0 0)
  (q+:add-widget overlap-layout character 0 0)
  (q+:add-widget overlap-layout fore 0 0 (q+:qt.align-bottom))
  (q+:add-widget overlap-layout fx 0 0)
  (q+:add-widget overlap-layout icc-textbox 0 0 (q+:qt.align-bottom)))

(define-signal (game-panel change-sides) (string))

(define-slot (game-panel change-sides change-sides) ((side string))
  (declare (connected game-panel (change-sides string)))
  (switch (side :test equal)
    ("pro" (load-image bg (background-path theme "prosecutorempty.png"))
           (load-image fore (background-path theme "bancoacusacion.png")))
    ("def" (load-image bg (background-path theme "defenseempty.png"))
           (load-image fore (background-path theme "bancodefensa.png"))) 
    ("wit" (load-image bg (background-path theme "witnessempty.png"))
           (load-image fore (background-path theme "estrado.png")))
    ("jud" (load-image bg (background-path theme "judgestand.png"))
           (q+:clear fore))
    ("hld" (load-image bg (background-path theme "helperstand.png"))
           (q+:clear fore))
    ("hlp" (load-image bg (background-path theme "prohelperstand.png"))
           (q+:clear fore))))
