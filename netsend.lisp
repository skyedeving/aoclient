(in-package #:cl-user)
(defpackage #:aoclient.netsend
  (:use #:cl)
  (:import-from #:aoclient.connection
                #:*stream*)
  (:import-from #:aoclient.encryption
                #:encode-command
                #:decode-command))
(in-package #:aoclient.netsend)

(defun message (cmd params &optional encrypt-p)
  (format nil "~a#~{~a~^#~}#%"
          (if encrypt-p
              (encode-command cmd)
              cmd)
          (if (listp params)
              params
              (list params))))

(defun send (message)
  (write-string message *stream*)
  (force-output *stream*))

(defun music (title)
  (message "MC" title))

(defun talk (preanimation character animation message side sfx talk-mode cid? sound-timing press-mode evidence cid flash color)
  (format nil "MS#chat#~a#~a#~a#~a#~a#~a#~a#~a#~a#~a#~a#~a#~a#~a#%"
          preanimation character animation message side
          sfx talk-mode cid? sound-timing press-mode evidence cid flash color))

(defun talk-occ (name message)
  (message "CT" (list name message)))

(defun hi (client-name)
  "Send server a what's up!  Send: HI # HDID #%  Receive AID and server version.  Receive: ID# AID # Server Version #% Receive population and capacity.  Receive:  PN # Population # Capacity #%"
  (message "HI" client-name))

(defun loading-list ()
  "Send: askchaa #% Asks the server what we have to load.  Receive: SI # Characters # Evidence  # Music #%"
  (send "askchaa#%"))

(defun choose-character (cid)
  "Send: CC # AID? # Character ID (CID) # HDID #% Choose our character."
  (format *stream* "CC#14#~a#aoclient#%" cid)
  (force-output *stream*))

