;;; init.el --- Evil + academic/programming config (offline-friendly) -*- lexical-binding: t; -*-

;;; Commentary:
;; This configuration intentionally does NOT auto-install packages and does NOT
;; refresh package archives. You manage package downloads manually.
;;
;; If you open Emacs on a new machine and something is missing, install it first,
;; then restart.

;;; Code:

;;;; ------------------------------------------------------------
;;;; Package system (NO network activity)
;;;; ------------------------------------------------------------

(require 'package)

;; Keep your archives listed (useful for manual installs), but do not refresh here.
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org"   . "https://orgmode.org/elpa/")
                         ("gnu"   . "https://elpa.gnu.org/packages/")))

;; Prevent package.el from automatically enabling packages twice.
(setq package-enable-at-startup nil)
(package-initialize)

<<<<<<< HEAD
;; Absolutely do NOT auto-install anything.
(setq use-package-always-ensure nil)
=======
;; Install use-package if not already installed
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
>>>>>>> 789707a (update init.el)

;; Load use-package if present; otherwise continue with core Emacs.
(unless (require 'use-package nil 'noerror)
  (message "NOTE: use-package not found. Install it manually, then restart Emacs."))

;;;; ------------------------------------------------------------
;;;; Helpers
;;;; ------------------------------------------------------------

(defun eax/disable-line-numbers ()
  "Disable display line numbers in the current buffer."
  (display-line-numbers-mode 0))

(defun eax/safe-set-key (keymap key fn)
  "Bind KEY to FN in KEYMAP if KEYMAP is bound."
  (when (boundp keymap)
    (define-key (symbol-value keymap) (kbd key) fn)))

(defun eax/ensure-package (pkg)
  "Ensure PKG is installed. If not, refresh archives and install it.
This may use the network, but only when called."
  (unless (package-installed-p pkg)
    (when (null package-archive-contents)
      (package-refresh-contents))
    (package-install pkg)))

(defvar eax/vterm-buffer-name "*vterm*"
  "Name of the buffer for `eax/open-vterm-bottom`.")

(defun eax/open-vterm-bottom ()
  "Open vterm in a bottom window. Installs vterm if missing."
  (interactive)
  (eax/ensure-package 'vterm)
  (require 'vterm)
  (let* ((buf (get-buffer eax/vterm-buffer-name))
         (buf (or buf (vterm eax/vterm-buffer-name))))
    (pop-to-buffer buf)))

(add-to-list 'display-buffer-alist
             '("\\*vterm\\*"
               (display-buffer-reuse-window display-buffer-at-bottom)
               (window-height . 0.30)))

;;;; ------------------------------------------------------------
;;;; Core UI / behavior
;;;; ------------------------------------------------------------

(setq inhibit-startup-message t
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      indent-tabs-mode nil
      tab-width 4)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(electric-pair-mode 1)
(set-fringe-mode 10)
<<<<<<< HEAD
(column-number-mode 1)
(global-display-line-numbers-mode 1)
=======
(column-number-mode)
(global-display-line-numbers-mode t)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)
(setq fontaine-latest-state-file
      (locate-user-emacs-file "fontaine-latest-state.eld"))

;; <https://github.com/protesilaos/aporetic>.
(setq fontaine-presets
      '((regular
         :default-family "Aporetic Serif Mono"
         :default-height 100
         :variable-pitch-family "Aporetic Sans")
        (medium
         :default-weight semilight
         :default-height 115
         :bold-weight extrabold)
        (large
         :inherit medium
         :default-height 150)
        (presentation
         :default-height 180)
        (t
         ;; <https://protesilaos.com/emacs/fontaine>.
         :default-family "Aporetic Sans Mono"
         :default-weight regular
         :default-height 100

         :fixed-pitch-family nil 
         :fixed-pitch-weight nil
         :fixed-pitch-height 1.0

         :fixed-pitch-serif-family nil
         :fixed-pitch-serif-weight nil
         :fixed-pitch-serif-height 1.0

         :variable-pitch-family "Aporetic Serif"
         :variable-pitch-weight nil
         :variable-pitch-height 1.0

         :mode-line-active-family nil
         :mode-line-active-weight nil
         :mode-line-active-height 0.9

         :mode-line-inactive-family nil
         :mode-line-inactive-weight nil
         :mode-line-inactive-height 0.9

         :header-line-family nil
         :header-line-weight nil
         :header-line-height 0.9

         :line-number-family nil
         :line-number-weight nil
         :line-number-height 0.9

         :tab-bar-family nil
         :tab-bar-weight nil
         :tab-bar-height 1.0

         :tab-line-family nil
         :tab-line-weight nil
         :tab-line-height 1.0

         :bold-family nil
         :bold-weight bold

         :italic-family nil
         :italic-slant italic

         :line-spacing nil)))

(fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular))

(fontaine-mode 1)
>>>>>>> 789707a (update init.el)

;; Theme
(load-theme 'modus-vivendi t)

;; Disable line numbers in specific modes
(dolist (hook '(org-mode-hook
                markdown-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                vterm-mode-hook))
  (add-hook hook #'eax/disable-line-numbers))

;;;; ------------------------------------------------------------
;;;; which-key
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package which-key
    :init (which-key-mode 1)
    :diminish which-key-mode
    :custom (which-key-idle-delay 0.3)))

;;;; ------------------------------------------------------------
;;;; general + leader keys
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package general
    :config
    (general-create-definer leader-def
      :states '(normal visual insert emacs)
      :prefix "SPC"
      :non-normal-prefix "M-SPC")

    (general-create-definer local-leader-def
      :states '(normal visual insert emacs)
      :prefix "SPC m"
      :non-normal-prefix "M-SPC m")))

;;;; ------------------------------------------------------------
;;;; Evil stack
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package evil
    :init
    (setq evil-want-integration t
          evil-want-keybinding nil
          evil-want-C-u-scroll t
          evil-want-C-i-jump nil
          evil-respect-visual-line-mode t
          evil-undo-system 'undo-redo)
    :config
    (evil-mode 1)

    ;; Make escape quit everything
    (define-key evil-normal-state-map [escape] #'keyboard-escape-quit)
    (define-key evil-visual-state-map [escape] #'keyboard-escape-quit)

    ;; Initial states (only if those modes exist)
    (with-eval-after-load 'messages
      (evil-set-initial-state 'messages-buffer-mode 'normal)))

  (use-package evil-collection
    :after evil
    :config (evil-collection-init))

<<<<<<< HEAD
  (use-package evil-escape
    :after evil
    :init
    (setq evil-escape-key-sequence "jk"
          evil-escape-delay 0.15)
    :config (evil-escape-mode 1))
=======
;; Markdown mode + pandoc export
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . markdown-mode)
  :init
  ;; Associate additional extensions
  (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
  :config
  ;; Use pandoc for HTML export
  (setq markdown-command "pandoc -f gfm -t html5"))
>>>>>>> 789707a (update init.el)

  (use-package evil-commentary
    :after evil
    :diminish
    :config (evil-commentary-mode 1))

  (use-package evil-surround
    :after evil
    :config (global-evil-surround-mode 1))

  (use-package evil-matchit
    :after evil
    :config (global-evil-matchit-mode 1))

  (use-package evil-visualstar
    :after evil
    :config (global-evil-visualstar-mode 1))

  (use-package evil-numbers
    :after evil
    :config
    (define-key evil-normal-state-map (kbd "C-a") #'evil-numbers/inc-at-pt)
    (define-key evil-normal-state-map (kbd "C-x") #'evil-numbers/dec-at-pt))

  (use-package evil-lion
    :after evil
    :config (evil-lion-mode 1))

  (use-package evil-exchange
    :after evil
    :config (evil-exchange-install))

  (use-package evil-args
    :after evil
    :config
    (define-key evil-inner-text-objects-map "a" #'evil-inner-arg)
    (define-key evil-outer-text-objects-map "a" #'evil-outer-arg))

  (use-package evil-indent-plus
    :after evil
    :config (evil-indent-plus-default-bindings))

  (use-package evil-textobj-anyblock
    :after evil
    :config
    (define-key evil-inner-text-objects-map "b" #'evil-textobj-anyblock-inner-block)
    (define-key evil-outer-text-objects-map "b" #'evil-textobj-anyblock-a-block))

  (use-package evil-snipe
    :after evil
    :diminish evil-snipe-mode
    :diminish evil-snipe-local-mode
    :config
    (evil-snipe-mode 1)
    (evil-snipe-override-mode 1))

  (use-package evil-easymotion
    :after evil
    :config (evilem-default-keybindings "gs"))

  ;; Org + Evil
  (use-package evil-org
    :after (evil org)
    :hook (org-mode . evil-org-mode)
    :config
    (require 'evil-org-agenda)
    (evil-org-agenda-set-keys)))

;;;; ------------------------------------------------------------
;;;; Markdown
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package markdown-mode
    :mode (("\\.md\\'" . markdown-mode)
           ("\\.markdown\\'" . markdown-mode))
    :custom (markdown-command "pandoc -f gfm -t html5"))

  (use-package evil-markdown
    :after (evil markdown-mode)
    :hook (markdown-mode . evil-markdown-mode)))

;;;; ------------------------------------------------------------
;;;; Org (built-in) + academic bits
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package org
    :ensure nil
    :hook (org-mode . (lambda ()
                        (org-indent-mode 1)
                        (variable-pitch-mode 1)
                        (visual-line-mode 1)))
    :config
    (setq org-ellipsis " ▾"
          org-hide-emphasis-markers t
          org-src-fontify-natively t
          org-src-tab-acts-natively t
          org-edit-src-content-indentation 0
          org-hide-block-startup nil
          org-src-preserve-indentation nil
          org-startup-folded 'content
          org-cycle-separator-lines 2
          org-latex-prefer-user-labels t
          org-latex-pdf-process
          '("pdflatex -interaction nonstopmode -output-directory %o %f"
            "bibtex %b"
            "pdflatex -interaction nonstopmode -output-directory %o %f"
            "pdflatex -interaction nonstopmode -output-directory %o %f")))

  ;; Optional: org-ref (only works if installed)
  (use-package org-ref
    :after org
    :commands (org-ref-insert-link)
    :config
    (setq reftex-default-bibliography '("~/bibliography/references.bib")
          org-ref-default-bibliography '("~/bibliography/references.bib")
          org-ref-pdf-directory "~/bibliography/bibtex-pdfs/"))

  ;; Optional: org-roam
  (use-package org-roam
    :after org
    :init (setq org-roam-v2-ack t)
    :custom (org-roam-directory (expand-file-name "~/org-roam"))
    :commands (org-roam-node-find org-roam-node-insert org-roam-buffer-toggle)
    :config (org-roam-setup)
    :bind (("C-c n l" . org-roam-buffer-toggle)
           ("C-c n f" . org-roam-node-find)
           ("C-c n i" . org-roam-node-insert))))

;;;; ------------------------------------------------------------
;;;; Emacs Lisp + ielm
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package emacs-lisp-mode
    :ensure nil
    :hook ((emacs-lisp-mode . eldoc-mode)
           (emacs-lisp-mode . company-mode))
    :bind (("C-c C-b" . eval-buffer)
           ("C-c C-r" . eval-region)
           ("C-c C-z" . ielm)))

  (use-package ielm
    :ensure nil
    :commands (ielm)
    :hook (ielm-mode . eldoc-mode)))

;;;; ------------------------------------------------------------
;;;; Languages
;;;; ------------------------------------------------------------

;; C / C++
(add-to-list 'load-path (expand-file-name "~/.emacs.d/personal"))

(when (featurep 'use-package)
  (use-package cc-mode
    :ensure nil
    :init
    ;; Your NetBSD style file must be in ~/.emacs.d/personal and provide 'netbsd
    (load "netbsd.el" nil 'noerror)
    :mode (("\\.c\\'" . c-mode)
           ("\\.h\\'" . c-mode)
           ("\\.cc\\'" . c++-mode)
           ("\\.cpp\\'" . c++-mode)
           ("\\.hpp\\'" . c++-mode))
    :hook ((c-mode . netbsd-knf-c-mode-hook)
           (c++-mode . netbsd-knf-c-mode-hook)
           (c-mode-common . company-mode))))

;; Perl (use cperl-mode for everything)
(defalias 'perl-mode 'cperl-mode)

(defun my-cperl-setup ()
  "Local defaults for cperl."
  (when buffer-file-name
    (setq-local compile-command
                (format "perl %s" (shell-quote-argument buffer-file-name))))
  (local-set-key (kbd "C-c h") #'cperl-perldoc)
  (setq-local cperl-indent-level 4))

(when (featurep 'use-package)
  (use-package cperl-mode
    :ensure nil
    :mode ("\\.[pP][Llm]\\'" . cperl-mode)
    :interpreter (("perl" . cperl-mode)
                  ("perl5" . cperl-mode))
    :hook (cperl-mode . my-cperl-setup)))

<<<<<<< HEAD
;; Python (built-in)
(when (featurep 'use-package)
  (use-package python
    :ensure nil
    :mode ("\\.py\\'" . python-mode)
    :interpreter ("python" . python-mode))

  ;; Optional: elpy
  (use-package elpy
    :commands (elpy-enable)
    :init (elpy-enable)))
=======
;; Lua
(use-package lua-mode
  :ensure t
  :mode "\\.lua\\'"
  :interpreter "luajit"
  :config
  (progn
    (setq lua-indent-level 2)
    ))

(use-package elpy
  :init
  (elpy-enable))
>>>>>>> 789707a (update init.el)

;; Go
(when (featurep 'use-package)
  (use-package go-mode
    :mode ("\\.go\\'" . go-mode)))

;; Julia
(when (featurep 'use-package)
  (use-package julia-mode
    :mode ("\\.jl\\'" . julia-mode))

<<<<<<< HEAD
  (use-package julia-repl
    :after julia-mode
    :hook (julia-mode . julia-repl-mode)
    :config
    (when (fboundp 'julia-repl-set-terminal-backend)
      (julia-repl-set-terminal-backend 'vterm))))
=======
;; LSP support for better code intelligence
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((c-mode        . lsp-deferred)
         (c++-mode      . lsp-deferred)
         (elisp-mode    . lsp-deferred)
         (lua-mode      . lsp-deferred)
         (python-mode   . lsp-deferred)
         (go-mode       . lsp-deferred)
         (julia-mode    . lsp-deferred))
  :init
  ;; keep cc-mode's indentation and your custom C
  ;; style. clangd still provides xref/hover/completion
  (setq lsp-enable-indentation nil
        lsp-enable-on-type-formatting nil)
  :config
  (setq lsp-headerline-breadcrumb-enable nil))
>>>>>>> 789707a (update init.el)

;;;; ------------------------------------------------------------
;;;; Completion / snippets
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package company
    :diminish
    :hook (prog-mode . company-mode)
    :custom
    (company-minimum-prefix-length 1)
    (company-idle-delay 0.1))

  (use-package yasnippet
    :hook ((prog-mode . yas-minor-mode)
           (text-mode . yas-minor-mode))
    :config (yas-reload-all))

  (use-package yasnippet-snippets
    :after yasnippet
    :if (locate-library "yasnippet-snippets")))

;;;; ------------------------------------------------------------
;;;; LSP
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package lsp-mode
    :commands (lsp lsp-deferred)
    :hook ((c-mode      . lsp-deferred)
           (c++-mode    . lsp-deferred)
           (python-mode . lsp-deferred)
           (go-mode     . lsp-deferred)
           (julia-mode  . lsp-deferred))
    :init
    ;; Keep cc-mode indentation; let clangd provide xref/hover/completion.
    (setq lsp-enable-indentation nil
          lsp-enable-on-type-formatting nil)
    :config
    (setq lsp-headerline-breadcrumb-enable nil))

  (use-package lsp-ui
    :commands lsp-ui-mode))

;;;; ------------------------------------------------------------
;;;; Git
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package magit
    :commands (magit-status)
    :config
    (with-eval-after-load 'evil
      (evil-set-initial-state 'magit-mode 'normal)
      (evil-set-initial-state 'magit-status-mode 'normal)
      (evil-set-initial-state 'magit-diff-mode 'normal)
      (evil-set-initial-state 'magit-log-mode 'normal))))

;;;; ------------------------------------------------------------
;;;; Dired
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package dired
    :ensure nil
    :config
    ;; GNU ls supports --group-directories-first, BSD ls does not.
    ;; Use a conservative default that works broadly.
    (setq dired-listing-switches "-alh")
    (define-key dired-mode-map (kbd "C-c C-e") #'wdired-change-to-wdired-mode))

  (use-package dired-open
    :after dired
    :config
    (setq dired-open-extensions '(("png" . "feh")
                                 ("jpg" . "feh")
                                 ("jpeg" . "feh")
                                 ("pdf" . "zathura")))))

;;;; ------------------------------------------------------------
;;;; Project management
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package projectile
    :diminish projectile-mode
    :init
    (setq projectile-project-search-path (list (expand-file-name "~/repos/"))
          projectile-switch-project-action #'projectile-dired)
    :config (projectile-mode 1)))

;;;; ------------------------------------------------------------
;;;; Ivy / Counsel / Helpful
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package ivy
    :diminish
    :config (ivy-mode 1))

  (use-package ivy-rich
    :after ivy
    :config (ivy-rich-mode 1))

  (use-package counsel
    :after ivy
    :config (counsel-mode 1))

  (use-package helpful
    :custom
    (counsel-describe-function-function #'helpful-callable)
    (counsel-describe-variable-function #'helpful-variable)
    :bind
    ([remap describe-function] . counsel-describe-function)
    ([remap describe-command]  . helpful-command)
    ([remap describe-variable] . counsel-describe-variable)
    ([remap describe-key]      . helpful-key)))

;;;; ------------------------------------------------------------
;;;; Shells / man
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package eshell
    :ensure nil
    :hook
    (eshell-mode . eax/shell-init-aliases)
    :config
    (defun eax/shell-init-aliases ()
      "Define eshell aliases once per Eshell session."
      (eshell/alias "c"  "clear")
      (eshell/alias "x"  "exit")
      (eshell/alias "la" "ls -la")
      (eshell/alias "gs" "git status")
      (eshell/alias ".." "cd ..")))

  (use-package man
    :ensure nil
    :custom (Man-notify-method 'pushy))

  (use-package woman
    :ensure nil
    :commands (woman)))

;;;; ------------------------------------------------------------
;;;; DevDocs / Dash docs (optional)
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package devdocs
    :commands (devdocs-lookup)
    :config
    (add-hook 'python-mode-hook (lambda () (setq-local devdocs-current-docs '("python~3.12"))))
    (add-hook 'c-mode-hook      (lambda () (setq-local devdocs-current-docs '("c"))))
    (add-hook 'go-mode-hook     (lambda () (setq-local devdocs-current-docs '("go"))))
    (add-hook 'julia-mode-hook  (lambda () (setq-local devdocs-current-docs '("julia~1")))))

  (use-package dash-docs
    :commands (dash-docs-search)
    :config
    (setq dash-docs-docsets-path (expand-file-name "~/.docsets")
          dash-docs-browser-func 'eww))

  (use-package counsel-dash
    :after (dash-docs counsel)
    :commands (counsel-dash)
    :config
    (add-hook 'python-mode-hook (lambda () (setq-local counsel-dash-docsets '("Python 3"))))
    (add-hook 'c-mode-hook      (lambda () (setq-local counsel-dash-docsets '("C"))))
    (add-hook 'go-mode-hook     (lambda () (setq-local counsel-dash-docsets '("Go"))))
    (add-hook 'julia-mode-hook  (lambda () (setq-local counsel-dash-docsets '("Julia"))))
    (add-hook 'cperl-mode-hook  (lambda () (setq-local counsel-dash-docsets '("Perl"))))))

;;;; ------------------------------------------------------------
;;;; Info / EWW niceties
;;;; ------------------------------------------------------------

(when (featurep 'use-package)
  (use-package info-colors
    :hook (Info-selection . info-colors-fontify-node))

  (use-package eww
    :ensure nil
    :commands (eww)
    :config
    (setq shr-use-fonts nil
          shr-use-colors nil
          shr-indentation 2
          shr-width 70
          eww-search-prefix "https://duckduckgo.com/html?q="))

  (use-package eww-lnum
    :after eww
    :commands (eww-lnum-follow eww-lnum-universal)
    :config
    (with-eval-after-load 'eww
      (define-key eww-mode-map (kbd "f") #'eww-lnum-follow)
      (define-key eww-mode-map (kbd "F") #'eww-lnum-universal)))

  (use-package ace-link
    :config
    (ace-link-setup-default)
    (with-eval-after-load 'info
      (define-key Info-mode-map (kbd "f") #'ace-link-info))
    (with-eval-after-load 'help-mode
      (define-key help-mode-map (kbd "f") #'ace-link-help))))

;; Better Info navigation keys (only after evil+info are loaded)
(with-eval-after-load 'evil-collection
  (with-eval-after-load 'info
    (evil-collection-define-key 'normal 'Info-mode-map
      "g?" #'Info-summary
      "gd" #'Info-goto-node
      "gm" #'Info-menu
      "gt" #'Info-top-node
      "gu" #'Info-up
      "gG" #'Info-goto-node)))

;;;; ------------------------------------------------------------
;;;; Leader key bindings (only if general is available)
;;;; ------------------------------------------------------------

(when (and (featurep 'use-package) (fboundp 'leader-def))
  (leader-def
    ;; Top level
    "SPC" '(counsel-M-x :which-key "M-x")
    ";"   '(eval-expression :which-key "eval expression")
    ":"   '(counsel-M-x :which-key "M-x")
    "."   '(find-file :which-key "find file")

    ;; Files
    "f"   '(:ignore t :which-key "files")
    "ff"  '(find-file :which-key "find file")
    "fs"  '(save-buffer :which-key "save file")
    "fr"  '(counsel-recentf :which-key "recent files")

    ;; Buffers
    "b"   '(:ignore t :which-key "buffers")
    "bb"  '(counsel-switch-buffer :which-key "switch buffer")
    "bd"  '(kill-current-buffer :which-key "kill buffer")
    "bn"  '(next-buffer :which-key "next buffer")
    "bp"  '(previous-buffer :which-key "previous buffer")
    "bs"  '(save-buffer :which-key "save buffer")

    ;; Windows
    "w"   '(:ignore t :which-key "windows")
    "wl"  '(windmove-right :which-key "move right")
    "wh"  '(windmove-left :which-key "move left")
    "wk"  '(windmove-up :which-key "move up")
    "wj"  '(windmove-down :which-key "move down")
    "w/"  '(split-window-right :which-key "split right")
    "w-"  '(split-window-below :which-key "split below")
    "wd"  '(delete-window :which-key "delete window")

    ;; Git
    "g"   '(:ignore t :which-key "git")
    "gs"  '(magit-status :which-key "git status")

    ;; Org
    "o"   '(:ignore t :which-key "org")
    "oa"  '(org-agenda :which-key "org agenda")
    "oc"  '(org-capture :which-key "org capture")
    "ol"  '(org-store-link :which-key "org store link")
    "ot"  '(org-todo :which-key "org todo")
    "os"  '(org-schedule :which-key "org schedule")
    "od"  '(org-deadline :which-key "org deadline")

    ;; Projects
    "p"   '(:ignore t :which-key "projects")
    "pp"  '(projectile-switch-project :which-key "switch project")

    ;; Documentation
    "d"   '(:ignore t :which-key "docs")
    "dm"  '(man :which-key "man page")
    "dw"  '(woman :which-key "woman")
    "di"  '(info :which-key "info")
    "dd"  '(devdocs-lookup :which-key "devdocs")
    "dh"  '(dash-docs-search :which-key "dash docs")
    "dc"  '(counsel-dash :which-key "counsel dash")

    ;; Web
    "e"   '(:ignore t :which-key "web")
    "ee"  '(eww :which-key "eww browser")

    ;; LSP
    "l"   '(:ignore t :which-key "lsp")
    "ll"  '(lsp :which-key "start lsp")
    "ld"  '(lsp-find-definition :which-key "definition")
    "lr"  '(lsp-rename :which-key "rename symbol")
    "la"  '(lsp-execute-code-action :which-key "code action")
    "lR"  '(lsp-restart-workspace :which-key "restart workspace")

    ;; Tools
    "t"   '(:ignore t :which-key "tools")
    "tt"  '(eax/open-vterm-bottom :which-key "open terminal")
    "tc"  '(compile :which-key "open compilation")))


(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
<<<<<<< HEAD
 '(package-selected-packages
   '(ace-link company-go counsel-dash devdocs dired-open elpy evil-args
	      evil-collection evil-commentary evil-easymotion
	      evil-escape evil-exchange evil-indent-plus evil-lion
	      evil-matchit evil-numbers evil-org evil-snipe
	      evil-surround evil-textobj-anyblock evil-visualstar
	      eww-lnum general helpful info-colors ivy-rich julia-mode
	      julia-repl lsp-ui magit org-ref org-roam projectile
	      vterm)))
=======
 '(custom-safe-themes
   '("f1c8202c772d1de83eda4765fe21429a528a4fb350a28394d3705fe9678ed1f9"
     default))
 '(package-selected-packages nil)
 '(warning-suppress-log-types '((use-package))))
>>>>>>> 789707a (update init.el)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
