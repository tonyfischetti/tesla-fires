#!/usr/local/bin/sbcl

(load "pluto.lisp")

(use-package :pluto)

(defvar /reports/ nil)

(setq current nil)

(defun chomp (aline)
  (substr aline 0 -1))

(for-each/line "./data/nhtsa-tesla-fire.txt"
  (setq value! (chomp value!))
  (when (~m value! •^\s*$•) (continue!))
  (push value! current)
  (when (~m value! "^Request Research")
    (push (reverse current) /reports/)
    (setq current nil)))

(setq /reports/ (reverse /reports/))


(defun make-pretty-date (almost)
  (destructuring-bind (year month day) (str-split almost •\-•)
    (setq month (~r month "January" "01"))
    (setq month (~r month "February" "02"))
    (setq month (~r month "March" "03"))
    (setq month (~r month "April" "04"))
    (setq month (~r month "May" "05"))
    (setq month (~r month "June" "06"))
    (setq month (~r month "July" "07"))
    (setq month (~r month "August" "08"))
    (setq month (~r month "September" "09"))
    (setq month (~r month "October" "10"))
    (setq month (~r month "November" "11"))
    (setq month (~r month "December" "12"))
    (when (= (length day) 1) (setq day (fn "0~A" day)))
    (fn "~A-~A-~A" year month day)))


(with-a-file "./output.tsv" :w
  (format stream! 
          (str-join •	• (list "components" "id" "date" "location" "crash" "fire" "injuries" "deaths")))
  (format stream! "~%")

  (for-each/list /reports/
    (unless (= (length value!) 14) (continue!))
    (destructuring-bind (garb1 components id date location garb4 garb2 crash fire injuries deaths note &rest garb) value!

      (setq components (~ra components •^.+?: • ""))
      (setq id (~ra id •^.+?: • ""))
      (setq date (~ra date •Incident Date (\w+) (\d+), (\d+).*• "\\3-\\1-\\2"))
      (setq date (make-pretty-date date))
      (setq location (~ra location •^Consumer Location • ""))
      (setq crash (~ra crash •^.+?: • ""))
      (setq fire (~ra fire •^.+?: • ""))
      (setq injuries (~ra injuries •^.+?: • ""))
      (setq deaths (~ra deaths •^.+?: • ""))


      (format stream!
              (str-join •	• (list components id date location crash fire injuries deaths)))
      (format stream! "~%"))))

