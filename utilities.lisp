(in-package #:cl-user)
(defpackage #:aoclient.utilities
  (:use #:cl #:cl-fad)
  (:export #:sfx-path
           #:music-path))
(in-package #:aoclient.utilities)

(defun base-pathname ()
  (asdf:system-relative-pathname 'aoclient "base/"))

(defun character-path (name &optional (file "" file-p) pathp)
  (let ((path (if file-p
                  (merge-pathnames-as-file (base-pathname)
                                           (concatenate 'string "characters/" name "/") file)
                  (merge-pathnames-as-directory (base-pathname)
                                                (concatenate 'string "characters/" name "/")))))
    (if pathp
        path
        (namestring path))))

(defun all-characters ()
  (mapcar #'(lambda (path) (car (last (pathname-directory path))))
          (fad:list-directory (character-path ""))))

(defun all-music ()
  (mapcar #'(lambda (path) (file-namestring path))
          (fad:list-directory (music-path ""))))

(defun background-path (name &optional (file "" file-p) pathp)
  (let ((path (if file-p
                  (merge-pathnames-as-file (base-pathname)
                                           (concatenate 'string "background/" name "/") file)
                  (merge-pathnames-as-directory (base-pathname)
                                                (concatenate 'string "background/" name "/")))))
    (if pathp
        path
        (namestring path))))

(defun button-path (name id on/off)
  (file-exists-p (character-path name (format nil "emotions/button~a_~:[off~;on~].png" id on/off) t)))

(defun sfx-path (file)
  (namestring (merge-pathnames-as-file (base-pathname) "sounds/general/" file)))

(defun music-path (file)
  (namestring (merge-pathnames-as-file (base-pathname) "sounds/music/" file)))

(defun misc-path (file)
  (namestring (merge-pathnames-as-file (base-pathname) "misc/" file)))
