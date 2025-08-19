;;; font-picker.el --- Interactively choose your font  -*- lexical-binding:t -*-

;; Copyright (C) 2025, yabobay

;; Author: yabobay <yabobay@yahoo.com>
;; Created 16 Aug 2025
;; Version: 1.0.0
;; Package-Requires: ((emacs "24.4") (ivy "0.13.0"))
;; Keywords: convenience, faces
;; Homepage: https://github.com/yabobay/font-picker

;;; Commentary:

;;     This package is for people who always switch between programming
;;     fonts a lot. It gives you an interactive font selection prompt
;;     (`font-picker-choose-font') with the fonts selected in the
;;     `font-picker-font-rotation' variable.  That font gets set to the
;;     `font-picker-chosen-font' variable, which you can save to have the
;;     font load every time you open Emacs.

;;; Code:

(provide 'font-picker)

;;;###autoload
(defun font-picker-choose-font ()
  "Interactively choose a font for the current session."
  (interactive)
  (if (zerop (length font-picker-font-rotation))
     (message "You don't have any fonts selected in `font-picker-font-rotation'!")
    (let ((ivy-wrap t)
          (font-before (cdr (assoc 'font default-frame-alist))))
      (ivy-read "choose font:" font-picker-font-rotation
		:preselect font-before
		:update-fn (lambda ()
                             (let ((font (ivy-state-current ivy-last)))
                               (font-picker-enable-font font)))
		:action (lambda (font)
			  (custom-set-variables (font-picker-chosen-font font)))
		:unwind (lambda ()
                          (font-picker-enable-font font-before))))))

;;;###autoload
(defun font-picker-enable-font (font)
  "Set a font for the current session."
  (modify-all-frames-parameters
   (cons `(font . ,font)
         (assq-delete-all 'font default-frame-alist))))

(defgroup font-picker nil
  "Customization group for font-picker."
  :prefix "font-picker"
  :group 'emacs)

;;;###autoload
(defcustom font-picker-chosen-font nil
  "Font in current use."
  :type 'string
  :set (lambda (option value)
         (set-default-toplevel-value option value)
         (unless (eq nil font-picker-chosen-font)
	   (font-picker-enable-font font-picker-chosen-font))))

(defcustom font-picker-font-rotation nil
  "Set of fonts to choose from."
  :type '(repeat string))

;;; font-picker.el ends here
