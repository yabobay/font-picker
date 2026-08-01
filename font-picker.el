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
;;     (`M-x font-picker-choose-font') with the fonts included in the
;;     `font-picker-font-rotation' variable.

;;; Code:

(provide 'font-picker)

(defvar font-picker-current-font nil)

;;;###autoload
(defun font-picker-choose-font ()
  "Interactively choose a font for the current session."
  (interactive)
  (if (zerop (length font-picker-font-rotation))
      (message "You don't have any fonts selected in `font-picker-font-rotation'!")
    (let (;(ivy-wrap t)
          (font-before font-picker-current-font))
      (ivy-read "choose font:" font-picker-font-rotation
                :preselect font-before
                :update-fn (lambda ()
                             (let ((font (ivy-state-current ivy-last)))
                               (font-picker-enable-font font)))
                :action (lambda (font)
                          (set 'font-picker-current-font font)
                          (font-picker-reload-font))
                :unwind (lambda ()
                          (font-picker-enable-font font-before))))))

;;;###autoload
(defun font-picker-enable-font (font)
  "Set a font for the current session."
  (when font
    (modify-all-frames-parameters
     (cons `(font . ,font)
           (assq-delete-all 'font default-frame-alist)))))

(defun font-picker-reload-font ()
  (font-picker-enable-font (or font-picker-current-font
                               font-picker-default-font)))

(defgroup font-picker nil
  "Customization group for font-picker."
  :prefix "font-picker"
  :group 'emacs)

(defcustom font-picker-default-font nil
  "Font to load at startup."
  :type 'string)

(defcustom font-picker-font-rotation nil
  "Set of fonts to choose from."
  :type '(repeat string))

(advice-add 'enable-theme :after
            (lambda (&rest r)
              (font-picker-reload-font)))

(add-hook 'emacs-startup-hook 'font-picker-reload-font)

;;; font-picker.el ends here
