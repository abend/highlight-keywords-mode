;;; highlight-keywords-mode.el --- Highlight keywords in buffer text

;; Copyright (C) 2015 Sasha Kovar

;; Version: 0.5
;; Author: Sasha Kovar <sasha-emacs@arcocene.org>
;; Url: http://github.com/abend/highlight-keywords-mode

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; highlight-keywords-mode is like many other "fixme" style
;; highlighting packages, but can restrict highlighting to within
;; certain contexts, such as comments and doc strings.

;;; Credits:
;; Based on the work of:
;;   Mark Triggs <mst@dishevelled.net> (highlight-fixmes-mode.el)
;;   Trey Jackson <bigfaceworm(at)gmail(dot)com> (fic-mode.el)
;;
;;; Code:

(defcustom highlight-keywords-words
  '("FIXME" "TODO" "BUG" "HACK" "NOTE" "TEST")
  "Words to be highlighted."
  :type '(repeat string)
  :group 'highlight-keywords)

(defcustom highlight-keywords-valid-contexts
  '(font-lock-doc-face font-lock-comment-face)
  "A list of font lock faces.  If a keyword appears within text
that is highlighted in one of these faces, the keyword will be
highlighted.  If nil, all keyword occurrences in the buffer
will be highlighted regardless of context."
  :type '(repeat face)
  :group 'highlight-keywords)

(defcustom highlight-keywords-case-fold nil
  "When non-nil, keyword matching should ignore case."
  :type '(choice (const :tag "Ignore case" t)
                 (const :tag "Respect case" nil))
  :group 'highlight-keywords)

(defun highlight-keywords-in-valid-context (pos)
  "Return true if POS is within a region within which keywords
should be highlighted."
  (memq (get-char-property pos 'face)
	highlight-keywords-valid-contexts))

(defvar highlight-keywords-found-keyword-hook '()
  "Hooks run after a keyword has been highlighted.
Each hook is run with the keyword's overlay as its argument.")

(defface highlight-keywords-face
  '((t (:foreground "black"
        :background "orange")))
  "The face used to show keywords."
  :group 'highlight-keywords)

(defun highlight-keywords-fontify (beg end)
  (highlight-keywords-unfontify beg end)
  (let ((regexp (regexp-opt fixme-words))
        (case-fold-search highlight-keywords-case-fold))
    (save-excursion
      (goto-char beg)
      (while (search-forward-regexp regexp end t)
        (when (highlight-keywords-in-valid-context (match-beginning 0))
          (let ((keyword (make-overlay (match-beginning 0) (match-end 0))))
            (overlay-put keyword 'type 'highlight-keywords)
            (overlay-put keyword 'evaporate t)
            (overlay-put keyword 'face 'highlight-keywords-face)
            (run-hook-with-args 'found-keywords-hook keyword)))))))

(defun highlight-keywords-unfontify (beg end)
  (mapc #'(lambda (o)
            (when (eq (overlay-get o 'type) 'highlight-keywords)
              (delete-overlay o)))
        (overlays-in beg end)))

(define-minor-mode highlight-keywords-mode
  "Highlight keywords like FIXME, TODO, etc. in parts of a buffer."
  :lighter " HK"
  (cond ((not highlight-keywords-mode)
         (jit-lock-unregister 'highlight-keywords-fontify)
         (highlight-keywords-unfontify (point-min) (point-max)))
        (t (highlight-keywords-fontify (point-min) (point-max))
           (jit-lock-register 'highlight-keywords-fontify))))

(provide 'highlight-keywords-mode)
;;; highlight-keywords-mode.el ends here
