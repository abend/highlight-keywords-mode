;;; highlight-keywords-mode.el --- Highlight keywords in buffer text

;; Copyright (C) 2015 Sasha Kovar

;; Version: 0.6
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
;;
;; To enable this minor mode, put something like the following in your
;; init file:
;;
;; For a single mode:
;;      (add-hook 'emacs-lisp-mode-hook 'turn-on-highlight-keywords-mode)
;;
;; For all programming modes:
;;      (add-hook 'prog-mode-hook 'turn-on-highlight-keywords-mode)

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

(defvar highlight-keywords-search-regexp
  (regexp-opt highlight-keywords-words 'words)
  "Regexp constructed from highlight-keywords-words")

(defun highlight-keywords-find-keyword (limit)
  (let ((match-data nil))
    (save-match-data
      (while (and (null match-data)
                  (re-search-forward highlight-keywords-search-regexp limit t))
        (if (and (highlight-keywords-in-valid-context (match-beginning 0))
                 (highlight-keywords-in-valid-context (match-end 0)))
            (setq match-data (match-data)))))
    (when match-data
      (set-match-data match-data)
      (goto-char (match-end 0))
      t)))

;;;###autoload
(define-minor-mode highlight-keywords-mode
  "Highlight keywords like FIXME, TODO, etc. in parts of a buffer."
  :lighter " HK"
  (let ((def '((highlight-keywords-find-keyword (0 'highlight-keywords-face t)))))
    (if highlight-keywords-mode
        (font-lock-add-keywords nil def)
        (font-lock-remove-keywords nil def))))

;;;###autoload
(defun turn-on-highlight-keywords-mode ()
  "Unequivocally turn on highlight keywords mode
(see command `highlight-keywords-mode')."
  (interactive)
  (highlight-keywords-mode 1))

(provide 'highlight-keywords-mode)
;;; highlight-keywords-mode.el ends here
