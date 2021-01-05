(in-package #:cl-user)
(defpackage #:aoclient.aochar
  (:use #:cl) 
  (:import-from #:ini-parser
                #:read-config-from-file)
  (:import-from #:aoclient.utilities
                #:character-path)
  (:import-from #:split-sequence
                #:split-sequence))
(in-package #:aoclient.aochar)

(defvar *config* nil
  "Special variable to bind in a LET to for use for several of the functions.")

(defun read-config (name)
  (when (cl-fad:file-exists-p (character-path name "char.ini"))
    (setf *config* (read-config-from-file (character-path name "char.ini")))))

(defun get-option (section option)
  (when *config*
    (gethash (string-downcase option) (gethash (string-downcase section) *config*))))

(defun config-emotions ()
  "Uses the special variable *config* for parsing the emotion so bind it with a LET before calling this. We're going to create CLOS objects out of this next."
  (loop with emotion-count = (read-from-string (get-option "Emotions" "number"))
        for n from 1 upto emotion-count
        for emotion-id = (write-to-string n) 
        for soundfx = (get-option "SoundN" emotion-id)
        for soundfx-timing = (get-option "SoundT" emotion-id)
        for emotion-info = (split-sequence #\# (get-option "Emotions" emotion-id))
        for name = (first emotion-info)
        for preanimation = (second emotion-info)
        for animation = (third emotion-info)
        for mode = (read-from-string (fourth emotion-info))
        collect (list :id n
                      :name name :preanimation preanimation :animation animation :mode mode
                      :sfx soundfx :sfx-timing soundfx-timing)))

(defun get-emotions ()
  "Makes a list of all the emotions as CLOS objects for easier programming out of CONFIG-EMOTIONS."
  (mapcar #'(lambda (emo)
              (apply #'make-instance 'emotion emo))
          (config-emotions)))

(defun hash-keys-of (table)
  (loop for key being the hash-keys of table
        collect key))

(defun get-options (section)
  (when *config*
    (hash-keys-of (gethash (string-downcase section) *config*))))

(defun config-option (option)
  "Uses the special variable *config* for parsing the emotion so bind it with a LET before calling this."
  (when (find option (get-options "Options") :test #'equal)
    (get-option "Options" option)))

(defun config-preanimations ()
  "Simply grab all the preanimations as an alist like ((preanimation1 . delay1) (preanimation2 . delay2) ...)"
  (when *config*
    (if (gethash (string-downcase "Time") *config*)
        (loop for value being the hash-values of (gethash (string-downcase "Time") *config*)
                using (hash-key key)
              collect (cons key value))
        nil)))

(defclass emotion ()
  ((id :accessor id :initarg :id)
   (name :accessor name :initarg :name :initform "")
   (prenimation :accessor preanimation :initarg :preanimation :initform "")
   (animation :accessor animation :initarg :animation :initform "")
   (mode :accessor mode :initarg :mode :initform "0")
   (sfx :accessor sfx :initarg :sfx :initform "1")
   (sfx-timing :accessor sfx-timing :initarg :sfx-timing :initform "1"))
  (:documentation "This class represents the emotions of the config, including the SFX and SFX timing."))

(defmethod print-object ((this emotion) out)
  "Changes how the emotion is displayed in the REPL to show the ID and name."
  (print-unreadable-object (this out :type 'emotion)
    (format out "Id:~a Name:~s" (id this) (name this))))

(defclass aochar ()
  ((name :accessor name :initarg :name :initform "")
   (showname :accessor showname :initarg :showname :initform "")
   (blipfx :accessor blipfx :initarg :blipfx :initform "male")
   (side :accessor side :initarg :side :initform "def")
   (preanimations :accessor preanimations :initarg :preanimations)
   (emotions :accessor emotions :initarg :emotions))
  (:documentation "This class represents the character choosen. You should use LOAD-CONFIG to create this."))

(defmethod print-object ((this aochar) out)
  "Changes how the emotion is displayed in the REPL to show the ID and name."
  (print-unreadable-object (this out :type 'emotion)
    (format out "Name:~s" (name this))))

(defun load-character (name)
  "Supply the character's name and we'll get the character as a CLOS object with all the goodies."
  (let ((*config* (read-config name)))
    (make-instance 'aochar :name name
                           :showname (config-option "showname")
                           :blipfx (config-option "gender")
                           :side (config-option "side")
                           :preanimations (config-preanimations)
                           :emotions (get-emotions)))) 

