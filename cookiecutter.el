;;; cookiecutter.el --- Use the cookiecutter program from emacs -*- lexical-binding: t -*-

;; Copyright © 2019 Jacob Salzberg

;; Author: Jacob Salzberg <jssalzbe@ncsu.edu>
;; URL: https://github.com/jsalzbergedu/cookiecutter-emacs-ui
;; Version: 0.1.0
;; Keywords: cookiecutter user interface

;; This file is not a part of GNU Emacs

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; A _very_ simple interface for cookiecutter.
;; Does not yet handle cases where user variables have colons in them,
;; nor where a cookiecutter could not be found.

;;; Code:
(require 'gv)

(defun cookiecutter-get-cookiecutter-names ()
  (remove ".." (remove "." (directory-files "~/.cookiecutters/"))))

(defun cookiecutter-choose-cookiecutter ()
  (completing-read "Choose or enter URL: "
                   (cookiecutter-get-cookiecutter-names)))

(defun cookiecutter--read-single-char ()
  (if (= (point) (point-max))
      ""
    (let ((out (following-char)))
      (forward-char)
      (string out))))

(defun cookiecutter--buffer-contains-colon ()
  (string-match ":" (buffer-substring-no-properties 1 (point-max))))

(defun cookiecutter-run-cookiecutter (choice)
  (let* ((prompt-string "")
         (filter (lambda (p s)
                   (setf prompt-string (concat prompt-string s))
                   (when (string-match "^.*: " prompt-string)
                     (let* ((user-input (read-string prompt-string)))
                       (process-send-string p user-input)
                       (process-send-string p (string ?\n))))
                   (setf prompt-string ""))))
    (make-process :name "cookiecutter"
                  :buffer nil
                  :command `("cookiecutter" ,choice)
                  :filter filter)))

(defun cookiecutter (choice)
  (interactive (list (cookiecutter-choose-cookiecutter)))
  (cookiecutter-run-cookiecutter choice))

(provide 'cookiecutter)
;;; cookiecutter.el ends here
