(in-package #:cl-user)
(asdf:defsystem aoclient
  :description "It's being made"
  :version "0.1"
  :serial t
  :components ((:file "ini-parser")
               (:file "encryption")
               (:file "connection")
               (:file "netsend")
               (:file "netreceive")
               (:file "utilities")
               (:file "aochar")
               (:file "aoclient")
               (:module "gui"
                :components ((:file "jukebox")
                             (:file "hp-bars")
                             (:file "testimony-buttons")
                             (:file "volume-controls")
                             (:file "character-label")
                             (:file "fx-label")
                             (:file "dialogue-box")
                             (:file "game-panel")
                             (:file "music-selection")
                             (:file "character-selection")
                             (:file "pressing-panel")
                             (:file "emote-button")
                             (:file "emotes-panel")
                             (:file "main")))) 
  :depends-on (:usocket :alexandria :cl-fad :split-sequence :cl-ppcre :anaphora :bass
                        :qtools :qtcore :qtgui)
  :defsystem-depends-on (:qtools)
  :build-operation "qt-program-op"
  :build-pathname "AO"
  :entry-point "aoclient.gui.main:main")
