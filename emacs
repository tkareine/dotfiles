;; Syntax higlighting where applicable
(global-font-lock-mode 1)

;; Highlight current line
(global-hl-line-mode 1)

;; Standard selection-highlighting behavior of other edit
(transient-mark-mode 1)

;; See matching pairs of parentheses and other characters
(show-paren-mode 1)

;; Show current line and column in the mode line
(line-number-mode 1)
(column-number-mode 1)

;; Font
(set-default-font "Inconsolata-14")

;; Frame width and height
(if (window-system) (set-frame-size (selected-frame) 140 60))

;; Prevent extraneous tabs
(setq-default indent-tabs-mode nil)

;; Default indentation
(setq standard-indent 2)

;; Language specific settings
(setq js-indent-level 2)

;; Enable backup files
(setq make-backup-files t)

;; Safer backup for symlinks
(setq backup-by-copying t)

;; Enable version control for backups
(setq version-control t)

;; Save all backup files in this directory.
(setq backup-directory-alist `((".*" . "~/.emacs_backups/")))

;; OS X: allow entering special chars via Option key
(setq mac-option-modifier nil)

;; OS X: use Command as meta key
(setq mac-command-modifier 'meta)

;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))

;; require or autoload paredit-mode
;(defun lisp-enable-paredit-hook () (paredit-mode 1))
;(add-hook 'clojure-mode-hook 'lisp-enable-paredit-hook)
