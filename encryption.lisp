(in-package #:cl-user)
(defpackage #:aoclient.encryption
  (:use #:cl)
  (:export #:decode-command
           #:encode-command))
(in-package #:aoclient.encryption)

; 322 is another magic number
(defvar *key* 5)

(defconstant +cipher1+ 53761)
(defconstant +cipher2+ 32618)

(defun string-to-hex (str)
  (with-output-to-string (s)
    (loop for c across str
          do (format s "~2,x" (char-code c)))))

(defun hex-to-string (hex)
  (if (> (length hex) 1)
      (loop with str = (make-string (/ (length hex) 2))
            for index upto (1- (length hex)) by 2
            do (setf (char str (/ index 2))
                     (code-char (parse-integer (subseq hex index (+ index 2)) :radix 16)))
            finally (return str))
      hex))

(defun cipher-char (char key)
  (code-char (logxor (char-code char) (ash key (- 8)))))

(defun next-key (key char)
  (mod (+ (* (+ (char-code char) key) +cipher1+) +cipher2+)
       65536))

(defun cipher-string (str key &optional backwards-p)
  (map 'string
       #'(lambda (c)
           (let ((ciphered-char (cipher-char c key)))
             (setf key (next-key key (if backwards-p
                                         c
                                         ciphered-char)))
             ciphered-char))
       str))

(defun encrypt-string (str key)
  (cipher-string str key))

(defun decrypt-string (str key)
  (cipher-string str key t))

(defun encode-command (cmd)
  (string-to-hex (encrypt-string cmd *key*)))

(defun decode-command (cmd)
  (decrypt-string (hex-to-string cmd) *key*))
