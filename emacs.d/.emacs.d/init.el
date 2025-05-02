;;; init.el --- emacs init file -*- lexical-binding: t; -*-
;;; Commentary:

;;; Code:
;; bootstrap setup
(require 'package)
(when (not (display-graphic-p))
  ;; term tweaks
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (setq inhibit-startup-screen t
	initial-scratch-message nil))

(defvar gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
	("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Get rid of the clutter
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(setq enable-local-variables :all)

;; Evil
(use-package evil
	     :init
	     (setq evil-want-keybinding nil
		   evil-want-C-u-scroll t)
	     :config
	     (evil-mode 1))

(use-package evil-escape
	     :after evil
	     :init
	     (setq evil-escape-key-sequence "jk")
	     :config
	     (evil-escape-mode 1))

(use-package evil-collection
	     :after evil
	     :config
	     (evil-collection-init))

;; Eshell
(use-package bash-completion
  :hook (eshell-mode . (lambda ()
			 (add-hook 'completion-at-point-functions
				   'bash-completion-capf-nonexclusive nil t))))

(use-package pcre2el
	     :after eshell
	     :hook (eshell-mode . pcre-mode)
	     :config
	     (rxt-global-mode 1))
(add-hook 'eshell-mode-hook #'evil-escape-mode)
(declare-function evil-collection-eshell-setup "modes/eshell/evil-collection-eshell.el")
(with-eval-after-load 'evil-collection
		      (evil-collection-eshell-setup))
(declare-function eshell/alias "em-alias.el")
(add-hook 'eshell-mode-hook
	  (lambda ()
	    (eshell/alias "la" "ls -a")
	    (eshell/alias "c" "clear")
	    (eshell/alias "x" "exit")))

(defun eax/popup-shell ()
    "Pop up eshell a la every other IDE in the planet."
    (interactive)
  (let ((buf (get-buffer-create "*eshell-popup*")))
    (unless (comint-check-proc buf)
      (with-current-buffer buf
	(eshell-mode)))
    (display-buffer
     buf
     '((display-buffer-reuse-window display-buffer-in-side-window)
       (side . bottom)
       (slot . 0)
       (window-width . 0.5)
       (window-height . 0.25)))))
(global-set-key (kbd "C-c e") #'eax/popup-shell)

;; Company (aka complete any)
(use-package company
	     :init
	     (global-company-mode)
	     :config
	     (setq company-idle-delay 0.2
		   company-minimum-prefix-length 1))

;; Flycheck
(use-package flycheck
	     :init
	     (global-flycheck-mode))

;; rtags
(use-package rtags
	     :commands rtags-start-process-unless-running
	     :hook ((c-mode c-++-mode) . rtags-start-process-unless-running)
	     :config
	     (setq rtags-autostart-diagnostics t)
	     (rtags-enable-standard-keybindings))

;; Python
(use-package python
  :ensure nil
  :hook (python-mode . (lambda ()
			 (setq python-indent-offset 4)
			 (add-hook 'before-save-hook 'delete-trailing-whitespace)))
  :custom
  (python-shell-interpreter "python3"))

;; Golang
(use-package go-mode
  :mode "\\.go\\'"
  :hook (go-mode . (lambda ()
		     (add-hook 'before-save-hook 'gofmt-before-save nil t)))
  :config
  (setq gofmt-command "goimports"))

;; Dlang
(use-package d-mode
  :mode "\\.d\\'")

;; C
(use-package cc-mode
  :ensure nil
  :hook ((c-mode c++-mode) . (lambda ()
			       (setq c-basic-offset 4
				     indent-tabs-mode nil))))
;;; init.el ends here
