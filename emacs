;;; ELPA
(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))

;;; Syntax higlighting where applicable
(global-font-lock-mode t)

;;; Highlight current line
(global-hl-line-mode t)

;;; Standard selection-highlighting behavior of other edit
(transient-mark-mode t)

;;; See matching pairs of parentheses and other characters
(show-paren-mode t)

;;; Show current line and column in the mode line
(line-number-mode t)
(column-number-mode t)

;;; No blinking cursor
(blink-cursor-mode 0)

;;; Show file size
(size-indication-mode t)

;;; Font
(set-default-font "Inconsolata-14")

;;; Frame width and height
(if (boundp 'window-system) (set-frame-size (selected-frame) 140 60))

;;; Enable backup files
(setq make-backup-files t)

;;; Safer backup for symlinks
(setq backup-by-copying t)

;;; Enable version control for backups
(setq version-control t)

;;; Save all backup files in this directory
(setq backup-directory-alist `((".*" . "~/.emacs_backups/")))

;;; Silently delete old backup files
(setq delete-old-versions t)

;;; OS X: allow entering special chars via Option key
(setq mac-option-modifier nil)

;;; OS X: use Command as meta key
(setq mac-command-modifier 'meta)

;;; Prevent extraneous tabs
(setq-default indent-tabs-mode nil)

;;; Default indentation
(setq standard-indent 2)

;;; JavaScript settings
(setq js-indent-level 2)

;;; Scala language support
(let* ((root-dir   (car (file-expand-wildcards "/usr/local/Cellar/scala/*" t)))
       (elisp-dir  (concat root-dir "/libexec/misc/scala-tool-support/emacs")))
  (add-to-list 'load-path elisp-dir))
(require 'scala-mode-auto)

;;; Erlang language support
(let* ((root-dir  "/usr/local/lib/erlang")
       (bin-dir   (expand-file-name "bin" root-dir))
       (elisp-dir (car (file-expand-wildcards (concat root-dir
                                                      "/lib/tools-2.6.*/emacs") t))))
  (setq erlang-root-dir root-dir)
  (add-to-list 'load-path elisp-dir)
  (add-to-list 'exec-path bin-dir))
(require 'erlang-start)
