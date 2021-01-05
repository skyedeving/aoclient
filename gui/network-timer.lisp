(in-package #:cl-user)
(defpackage #:aoclient.gui.network-timer
  (:use #:cl+qt)
  (:import-from #:aoclient.netreceive
                #:network-listener))
(in-package #:aoclient.gui.network-timer)

(in-readtable :qtools)
