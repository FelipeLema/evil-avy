;;; evil-avy.el --- set-based completion -*- lexical-binding: t -*-

;; Copyright (C) 2015  Free Software Foundation, Inc.

;; Author: Yufan Lou <loganlyf@gmail.com>
;; Maintainer: Felipe Lema <felipelema@mortemale.org>
;; URL: https://github.com/FelipeLema/evil-avy
;; Version: 0.1.1
;; Package-Requires: ((emacs "24.1") (cl-lib "0.5") (avy "0.5.0") (evil "1.13.0"))
;; Keywords: point, location, evil, vim

;; This file is part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This package provides keybindings of avy in evil (vim) format.

;;; Code:
(require 'avy)
(require 'evil)

(defcustom evil-avy-move-to-begin-or-end-of-window
  t
  "Simulate hop.nvim's behaviour and move to begin/end of window.

Instead of listing candidates until begin/end of line, list them up to begin/end
of window")

(defun avy-forward-char-in-line (char &optional back)
  "Jump forward to the currently visible CHAR in the current line.
If BACK is t, jump backward."
  (interactive (list (read-char "char: " t)))

  (let ((avy-all-windows nil))
    (avy-with avy-forward-char-in-line
      (avy-process
       (save-restriction
         (if (null back)
             (narrow-to-region (+ 1 (point))
                               (line-end-position))
           (narrow-to-region (line-beginning-position)
                             (point)))
         (avy--regex-candidates (regexp-quote (string char))))
       (avy--style-fn avy-style)))
    nil))

(defun avy-forward-char-in-window (char &optional back)
  "Jump forward to the currently visible CHAR up to window end.
If BACK is t, jump backward."
  (interactive (list (read-char "char: " t)))

  (let ((avy-all-windows nil))
    (avy-with avy-forward-char-in-window
      (avy-process
       (save-restriction
         (if (null back)
             (narrow-to-region (+ 1 (point))
                               (window-end))
           (narrow-to-region (window-start)
                             (point)))
         (avy--regex-candidates (regexp-quote (string char))))
       (avy--style-fn avy-style)))
    nil))

;;; evil motions
;;;; in line
(evil-define-motion evil-avy-find-char-in-line (count char)
  "Use avy to move forward to char in line."
  :jump t
  :type inclusive
  (interactive "<c><C>")
  (if (null count) (avy-forward-char-in-line char)
    (evil-find-char count char)))

(evil-define-motion evil-avy-find-char-in-line-to (count char)
  "Use avy to move till char in line"
  :jump t
  :type inclusive
  (interactive "<c><C>")
  (if (null count)
      (progn
        (avy-forward-char-in-line char)
        (backward-char))
    (evil-find-char-to count char)))

(evil-define-motion evil-avy-find-char-in-line-backward (count char)
  "Use avy to move backward to char in line."
  :jump t
  :type exclusive
  (interactive "<c><C>")
  (if (null count)
      (avy-forward-char-in-line char t)
    (evil-find-char-backward count char)))

(evil-define-motion evil-avy-find-char-in-line-to-backward (count char)
  "Use avy to move backward till char in line."
  :jump t
  :type exclusive
  (interactive "<c><C>")
  (if (null count)
      (progn
        (avy-forward-char-in-line char t)
        (forward-char))
    (evil-find-char-to-backward count char)))

;;;; in window
(evil-define-motion evil-avy-find-char-in-window (count char)
  "Use avy to move forward to char in window."
  :jump t
  :type inclusive
  (interactive "<c><C>")
  (if (null count) (avy-forward-char-in-window char)
    (evil-find-char count char)))

(evil-define-motion evil-avy-find-char-in-window-to (count char)
  "Use avy to move till char in line"
  :jump t
  :type inclusive
  (interactive "<c><C>")
  (if (null count)
      (progn
        (avy-forward-char-in-window char)
        (backward-char))
    (evil-find-char-to count char)))

(evil-define-motion evil-avy-find-char-in-window-backward (count char)
  "Use avy to move backward to char in line."
  :jump t
  :type exclusive
  (interactive "<c><C>")
  (if (null count)
      (avy-forward-char-in-window char t)
    (evil-find-char-backward count char)))

(evil-define-motion evil-avy-find-char-in-window-to-backward (count char)
  "Use avy to move backward till char in line."
  :jump t
  :type exclusive
  (interactive "<c><C>")
  (if (null count)
      (progn
        (avy-forward-char-in-window char t)
        (forward-char))
    (evil-find-char-to-backward count char)))

;;; minor mode
;;;###autoload
(define-minor-mode evil-avy-mode
  "Toggle evil-avy-mode.

Interactively with no argument, this command toggles the mode. A
positive prefix argument enables the mode, any other prefix
argument disables it.  From Lisp, argument omitted or nil enables
the mode,`toggle' toggles the state.

When evil-avy-mode is active, it replaces some the normal, visual, operator
and motion state keybindings to invoke avy commands."
  :lighter nil
  :keymap (make-sparse-keymap)
  :global t
  :group 'avy
  (evil-define-key 'motion evil-avy-mode-map
    "f" (when evil-avy-mode
          (if evil-avy-move-to-begin-or-end-of-window
              #'evil-avy-find-char-in-window
            #'evil-avy-find-char-in-line))
    "F" (when evil-avy-mode
          (if evil-avy-move-to-begin-or-end-of-window
              #'evil-avy-find-char-in-window-backward
            #'evil-avy-find-char-in-line-backward))
    "t" (when evil-avy-mode
          (if evil-avy-move-to-begin-or-end-of-window
              #'evil-avy-find-char-in-window-to
            #'evil-avy-find-char-in-line-to))
    "T" (when evil-avy-mode
          (if evil-avy-move-to-begin-or-end-of-window
              #'evil-avy-find-char-in-window-to-backward
            #'evil-avy-find-char-in-line-to-backward))))

(provide 'evil-avy)
;;; evil-avy.el ends here
