(in-package #:cl-user)
(defpackage #:aoclient.gui.character-selection
  (:use #:cl+qt)
  (:import-from #:aoclient.utilities
                #:all-characters))
(in-package #:aoclient.gui.character-selection)

(in-readtable :qtools)

(define-widget character-selection (QListWidget) ())

(define-initializer (character-selection add-characters)
  (mapcar #'(lambda (name) (q+:add-item character-selection name)) (all-characters)))
