(in-package #:cl-user)
(defpackage ini-parser
  (:use #:cl #:anaphora)
  (:export #:read-config-from-file))
(in-package #:ini-parser)

(defparameter +empty-line+ (format nil "~%"))

(defmacro defmatcher (name regexp &rest fields)
  (let ((result-expr (loop for i in fields collect `(aref data ,i))))
    `(defun ,name (string)
         (let ((scaner (ppcre:create-scanner ,regexp)))
           (multiple-value-bind (matched data) (ppcre:scan-to-strings scaner string)
             (if matched (list ,@result-expr)))))))

(defmacro stream-with-strings (&rest strings-and-streams)
  `(make-concatenated-stream
    ,@(loop for str in strings-and-streams
        collect `(let ((s ,str)) (if (stringp s) (make-string-input-stream s) s)))))

(defun read-config-from-file (file-name)
  (with-open-file (stream file-name
                          :external-format :iso-8859-1)
    (read-config stream)))

(defun trim (string)
  (if string (string-trim '(#\Space #\Tab #\Newline #\Return) string)))

(defun read-config (stream)
  (parse-config (stream-with-strings stream +empty-line+ +empty-line+)
                (make-hash-table :test #'equal)
                "default"
                1))

(defmatcher section-name "^\\s*\\[\\s*([^\\]]+)\\s*\\]\\s*$" 0)
(defmatcher key-value-pair "^\\s*([^=]+)\\s*=\\s*([^=]+)\\s*$" 0 1)
(defmatcher line-continued-p "^(.*)\\\\\\s*$" 0)

(defun parse-config (stream result section line-number)
  (let ((current-line (trim (read-line stream nil))))
    (if current-line
        (acond
          ((line-continued-p current-line)
           (parse-config (stream-with-strings (trim (first it))
                                              (trim (read-line stream))
                                              +empty-line+
                                              stream)
                         result
                         section
                         (1+ line-number)))
          ((equal "" current-line)
            (parse-config stream result section (1+ line-number)))
          ((section-name current-line)
           (parse-config stream result it (1+ line-number)))
          ((key-value-pair current-line)
           (parse-config stream
                         (hash-add-key-subkey-value result
                                                    (string-downcase (car section))
                                                    (trim (first it))
                                                    (trim (second it)))
                         section
                         (1+ line-number)))
          (t (parse-config stream result section (1+ line-number))
             ;(error (format nil "Incorrect config at line ~a: ~a" line-number current-line))
             ))
        result)))

(defun hash-add-key-subkey-value (hash key subkey value)
  (unless (gethash key hash)
    (setf (gethash key hash) (make-hash-table :test #'equal)))
  (setf (gethash subkey (gethash key hash))
        value)
  hash)
