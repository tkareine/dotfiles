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

;;; Whitespace highlighting options
(setq whitespace-line-column 140)

;;; Show file size
(size-indication-mode t)

;;; Font
(set-default-font "Inconsolata-14")

;;; Frame width and height
(if (and (boundp 'window-system) window-system) (set-frame-size (selected-frame) 140 60))

;;; Switch buffers and windows interactively
(ido-mode 1)
(setq ido-enable-flex-matching t)

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

;;; Custom key bindings
(global-set-key [kp-delete]    'delete-char)
(global-set-key [M-kp-delete]  'kill-word)
(global-set-key (kbd "C-c w")  'whitespace-mode)
(global-set-key (kbd "M-+")    'dabbrev-expand)
(global-set-key (kbd "M-ö")    'fixup-whitespace)

;;; Prevent extraneous tabs
(setq-default indent-tabs-mode nil)

;;; Default indentation
(setq standard-indent 2)

;;; JavaScript settings
(setq js-indent-level 2)

(let* ((local-site-lisp-dir "~/.emacs.d/site-lisp"))
  ;; Color theme support
  (add-to-list 'load-path (concat local-site-lisp-dir "/color-theme"))
  (add-to-list 'load-path (concat local-site-lisp-dir "/color-theme-solarized"))
  (require 'color-theme)
  (require 'color-theme-solarized)
  (eval-after-load "color-theme"
    '(progn
       (color-theme-initialize)
       (color-theme-solarized-dark)))

  ;; Automatic closing parens
  (add-to-list 'load-path (concat local-site-lisp-dir "/autopair"))
  (require 'autopair)
  (autopair-global-mode)

  ;; Scala language support
  (add-to-list 'load-path (concat local-site-lisp-dir "/scala-mode"))
  (require 'scala-mode-auto)

  ;; Ensime for Scala language
  (add-to-list 'load-path (concat local-site-lisp-dir "/ensime/elisp"))
  (require 'ensime)
  (add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

  ;; Erlang language support
  (let* ((root-dir  (concat local-site-lisp-dir "/erlang-mode"))
         (bin-dir   (concat root-dir "/bin"))
         (elisp-dir (car (file-expand-wildcards (concat root-dir
                                                        "/lib/tools-2.6.*/emacs") t))))
    (setq erlang-root-dir root-dir)
    (add-to-list 'load-path elisp-dir)
    (add-to-list 'exec-path bin-dir))
  (require 'erlang-start)
)
