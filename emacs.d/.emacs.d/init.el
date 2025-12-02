;;; init.el --- Emacs configuration with Evil mode and academic/programming support

;;; Commentary:
;;; A comprehensive Emacs configuration with Evil mode, org-mode for academics,
;;; programming language support, and various quality-of-life improvements.

;;; Code:

;; Package system setup
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Install use-package if not already installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

;; General settings
(load-theme 'modus-vivendi)
(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(set-fringe-mode 10)
(column-number-mode)
(global-display-line-numbers-mode t)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)


;; Disable line numbers for certain modes
(dolist (mode '(org-mode-hook
                markdown-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                vterm-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Which-key configuration
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; General for keybindings
(use-package general
  :config
  (general-create-definer leader-def
    :states '(normal visual insert emacs)
    :prefix "SPC"
    :non-normal-prefix "M-SPC")
  
  (general-create-definer local-leader-def
    :states '(normal visual insert emacs)
    :prefix "SPC m"
    :non-normal-prefix "M-SPC m"))

;; Evil mode and related packages
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
  
  ;; Make sure evil works everywhere
  (setq evil-emacs-state-modes nil)
  (setq evil-insert-state-modes nil)
  (setq evil-motion-state-modes nil)
  
  ;; Make escape quit everything
  (define-key evil-normal-state-map [escape] 'keyboard-escape-quit)
  (define-key evil-visual-state-map [escape] 'keyboard-escape-quit)
  
  ;; Set initial states for specific modes
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

;; Evil Collection for evil mode everywhere
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Evil commentary for commenting code
(use-package evil-commentary
  :after evil
  :diminish
  :config (evil-commentary-mode))

;; Evil surround for parentheses, quotes, etc.
(use-package evil-surround
  :after evil
  :config (global-evil-surround-mode 1))

;; Evil matchit for improved % matching
(use-package evil-matchit
  :after evil
  :config (global-evil-matchit-mode 1))

;; Evil visualstar for * on visual selections
(use-package evil-visualstar
  :after evil
  :config (global-evil-visualstar-mode))

;; Evil numbers for incrementing/decrementing
(use-package evil-numbers
  :after evil
  :config
  (define-key evil-normal-state-map (kbd "C-a") 'evil-numbers/inc-at-pt)
  (define-key evil-normal-state-map (kbd "C-x") 'evil-numbers/dec-at-pt))

;; Evil-org for org-mode integration
(use-package evil-org
  :after (evil org)
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;; Markdown mode + pandoc export
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\" . markdown-mode)
  :init
  ;; Associate additional extensions
  (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
  :config
  ;; Use pandoc for HTML export
  (setq markdown-command "pandoc -f gfm -t html5"))

;; Evil-markdown
(use-package evil-markdown
  :after (evil markdown-mode)
  :ensure t
  :hook (markdown-mode . evil-markdown-mode))

;; Evil-lion for alignment
(use-package evil-lion
  :after evil
  :config (evil-lion-mode))

;; Evil-exchange for swapping text
(use-package evil-exchange
  :after evil
  :config (evil-exchange-install))

;; Evil-args for argument text objects
(use-package evil-args
  :after evil
  :config
  (define-key evil-inner-text-objects-map "a" 'evil-inner-arg)
  (define-key evil-outer-text-objects-map "a" 'evil-outer-arg))

;; Evil-indent-plus for indent text objects
(use-package evil-indent-plus
  :after evil
  :config (evil-indent-plus-default-bindings))

;; Evil-textobj-anyblock for any block text objects
(use-package evil-textobj-anyblock
  :after evil
  :config
  (define-key evil-inner-text-objects-map "b" 'evil-textobj-anyblock-inner-block)
  (define-key evil-outer-text-objects-map "b" 'evil-textobj-anyblock-a-block))

;; Evil-snipe for improved f/t
(use-package evil-snipe
  :after evil
  :diminish evil-snipe-mode
  :diminish evil-snipe-local-mode
  :config
  (evil-snipe-mode 1)
  (evil-snipe-override-mode 1))

;; Evil-easymotion for quick navigation
(use-package evil-easymotion
  :after evil
  :config
  (evilem-default-keybindings "gs"))

;; Improved Info mode evil integration
(evil-collection-define-key 'normal 'Info-mode-map
  "g?" 'Info-summary
  "gd" 'Info-goto-node
  "gm" 'Info-menu
  "gt" 'Info-top-node
  "gu" 'Info-up
  "gG" 'Info-goto-node)

;; Org-mode configuration
(use-package org
  :hook (org-mode . (lambda ()
                      (org-indent-mode)
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
        org-cycle-separator-lines 2)

  ;; Academic workflow settings
  (setq org-latex-pdf-process
        '("pdflatex -interaction nonstopmode -output-directory %o %f"
          "bibtex %b"
          "pdflatex -interaction nonstopmode -output-directory %o %f"
          "pdflatex -interaction nonstopmode -output-directory %o %f"))
  
  ;; Better citation support
  (setq org-latex-prefer-user-labels t))

;; Org-ref for academic citations
(use-package org-ref
  :after org
  :config
  (setq reftex-default-bibliography '("~/bibliography/references.bib")
        org-ref-default-bibliography '("~/bibliography/references.bib")
        org-ref-pdf-directory "~/bibliography/bibtex-pdfs/"))

;; Org-roam for note-taking
(use-package org-roam
  :after org
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/org-roam")
  :config
  (org-roam-setup)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)))

;; REPL support for Julia
(use-package julia-mode)

(use-package julia-repl
  :hook (julia-mode . julia-repl-mode)
  :config
  (julia-repl-set-terminal-backend 'vterm))

;; Programming language support
;; C
(defconst my-c-style
  '((c-tab-always-indent        . t)
    (c-basic-offset             . 0)
    (c-comment-only-line-offset . 2)

    ;; Brace rules
    (c-hanging-braces-alist     . ((defun-open after)
                                   (defun-close before after)
                                   (substatement-open)
                                   (brace-list-open)))

    (c-cleanup-list             . (scope-operator
                                   empty-defun-braces
                                   defun-close-semi))
    (c-offsets-alist
     (substatement-open . -2)
     (block-open        . -2)
     (case-label        . 2)
     (arglist-close     . c-lineup-arglist)))

  "My custom C style: GNU-ish defuns with K&R-ish control braces.")

(use-package cc-mode
    :ensure nil
    :config
    (c-add-style "user" my-c-style)
    :hook
    (c-mode . (lambda ()
            (setq c-default-style "user"
				    indent-tabs-mode nil
                    tab-width 4))))

;; Perl
(use-package cperl-mode
  :ensure nil
  :mode ("\\.\\([pP][Llm]\\|al\\)\\'" . cperl-mode)
  :interpreter (("perl" . cperl-mode)
                ("perl5" . cperl-mode))
  :config
  (setq cperl-indent-level 4))

;; Python
(use-package python
  :ensure nil
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python" . python-mode))

(use-package elpy
  :init
  (elpy-enable))

;; Go
(use-package go-mode
  :mode "\\.go\\'")

(use-package company-go
  :after go-mode)

;; LSP support for better code intelligence
(use-package lsp-mode
  :commands lsp
  :hook ((c-mode . lsp)
         (c++-mode . lsp)
         (elisp-mode . lsp)
         (python-mode . lsp)
         (go-mode . lsp)
         (julia-mode . lsp))
  :config
  (setq lsp-headerline-breadcrumb-enable nil))

(use-package lsp-ui
  :commands lsp-ui-mode)

;; Company for code completion
(use-package company
  :diminish
  :hook (prog-mode . company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.1))

;; Yasnippet
(use-package yasnippet
  :ensure t
  :hook ((prog-mode . yas-minor-mode)
         (text-mode . yas-minor-mode))
  :config
  (yas-reload-all))

;; Yasnippet-snippets
(use-package yasnippet-snippets :ensure t after yasnippet)

;; Magit for Git
(use-package magit
  :config
  ;; Set evil bindings for magit
  (evil-set-initial-state 'magit-mode 'normal)
  (evil-set-initial-state 'magit-status-mode 'normal)
  (evil-set-initial-state 'magit-diff-mode 'normal)
  (evil-set-initial-state 'magit-log-mode 'normal))

;; Dired configuration
(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches "-alh --group-directories-first")
  (define-key dired-mode-map (kbd "C-c C-e") 'wdired-change-to-wdired-mode))

(use-package dired-open
  :after dired
  :config
  (setq dired-open-extensions '(("png" . "feh")
                               ("jpg" . "feh")
                               ("pdf" . "zathura"))))

;; Projectile for project management
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :init
  (setq projectile-project-search-path '("~/projects/"))
  (setq projectile-switch-project-action #'projectile-dired))

;; Ivy for completion
(use-package ivy
  :diminish
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :after ivy
  :config
  (counsel-mode 1))

;; Helpful for better help pages
(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; Eshell
(use-package eshell
  :ensure nil
  :config
  ;; .aliases
  (let ((aliases '(("c" "clear")
                   ("x" "exit")
                   ("la" "ls -a")
                   ("gs" "git status")
                   (".." "cd .."))))
    (dolist (alias aliases)
      (add-to-list 'eshell-command-aliases-list alias t))))

;; Better man page support
(use-package man
  :ensure nil
  :config
  (setq Man-notify-method 'pushy))

;; Woman for viewing man pages without external man program
(use-package woman
  :ensure nil
  :commands woman)

;; DevDocs integration
(use-package devdocs
  :commands devdocs-lookup
  :config
  (add-hook 'python-mode-hook
            (lambda () (setq-local devdocs-current-docs '("python~3.9"))))
  (add-hook 'c-mode-hook
            (lambda () (setq-local devdocs-current-docs '("c"))))
  (add-hook 'go-mode-hook
            (lambda () (setq-local devdocs-current-docs '("go"))))
  (add-hook 'julia-mode-hook
            (lambda () (setq-local devdocs-current-docs '("julia~1")))))

;; Dash docset integration
(use-package dash-docs
  :config
  (setq dash-docs-docsets-path (expand-file-name "~/.docsets"))
  (setq dash-docs-browser-func 'eww))

(use-package counsel-dash
  :after dash-docs
  :config
  (add-hook 'python-mode-hook (lambda () (setq-local counsel-dash-docsets '("Python 3"))))
  (add-hook 'c-mode-hook (lambda () (setq-local counsel-dash-docsets '("C"))))
  (add-hook 'go-mode-hook (lambda () (setq-local counsel-dash-docsets '("Go"))))
  (add-hook 'julia-mode-hook (lambda () (setq-local counsel-dash-docsets '("Julia"))))
  (add-hook 'perl-mode-hook (lambda () (setq-local counsel-dash-docsets '("Perl"))))
  (add-hook 'cperl-mode-hook (lambda () (setq-local counsel-dash-docsets '("Perl")))))

;; Info mode enhancements
(use-package info-colors
  :hook (Info-selection . info-colors-fontify-node))

;; Enhanced EWW for web browsing
(use-package eww
  :ensure nil
  :commands (eww)
  :config
  ;; Make URLs clickable
  (define-key eww-mode-map (kbd "f") 'eww-lnum-follow)
  (define-key eww-mode-map (kbd "F") 'eww-lnum-universal)
  
  ;; Better readability
  (setq shr-use-fonts nil)
  (setq shr-use-colors nil)
  (setq shr-indentation 2)
  (setq shr-width 70)
  (setq eww-search-prefix "https://duckduckgo.com/html?q="))

;; EWW-lnum for link navigation with numbers
(use-package eww-lnum
  :after eww
  :commands (eww-lnum-follow eww-lnum-universal))

;; Ace-link for quick link selection in various modes
(use-package ace-link
  :config
  (ace-link-setup-default)
  (define-key Info-mode-map "f" 'ace-link-info)
  (define-key help-mode-map "f" 'ace-link-help))

;; Language-specific documentation
(defun open-python-docs ()
  "Open Python documentation in EWW."
  (interactive)
  (eww "https://docs.python.org/3/"))

(defun open-julia-docs ()
  "Open Julia documentation in EWW."
  (interactive)
  (eww "https://docs.julialang.org/en/v1/"))

(defun open-go-docs ()
  "Open Go documentation in EWW."
  (interactive)
  (eww "https://golang.org/doc/"))

(defun open-perl-docs ()
  "Open Perl documentation in EWW."
  (interactive)
  (eww "https://perldoc.perl.org/"))

(defun open-c-docs ()
  "Open C documentation in EWW."
  (interactive)
  (eww "https://en.cppreference.com/w/c"))

;; Leader key bindings
(leader-def
  ;; Top level
  "SPC" '(counsel-M-x :which-key "M-x")
  ";" '(eval-expression :which-key "eval expression")
  ":" '(counsel-M-x :which-key "M-x")
  "." '(find-file :which-key "find file")
  
  ;; Files
  "f" '(:ignore t :which-key "files")
  "ff" '(find-file :which-key "find file")
  "fs" '(save-buffer :which-key "save file")
  "fr" '(counsel-recentf :which-key "recent files")
  
  ;; Buffers
  "b" '(:ignore t :which-key "buffers")
  "bb" '(counsel-switch-buffer :which-key "switch buffer")
  "bd" '(kill-current-buffer :which-key "kill buffer")
  "bn" '(next-buffer :which-key "next buffer")
  "bp" '(previous-buffer :which-key "previous buffer")
  "bs" '(save-buffer :which-key "save buffer")
  
  ;; Windows
  "w" '(:ignore t :which-key "windows")
  "wl" '(windmove-right :which-key "move right")
  "wh" '(windmove-left :which-key "move left")
  "wk" '(windmove-up :which-key "move up")
  "wj" '(windmove-down :which-key "move down")
  "w/" '(split-window-right :which-key "split right")
  "w-" '(split-window-below :which-key "split below")
  "wd" '(delete-window :which-key "delete window")
  
  ;; Git
  "g" '(:ignore t :which-key "git")
  "gs" '(magit-status :which-key "git status")
  "gb" '(magit-blame :which-key "git blame")
  "gl" '(magit-log-all :which-key "git log")
  "gc" '(magit-commit :which-key "git commit")
  "gp" '(magit-push :which-key "git push")
  "gf" '(magit-pull :which-key "git pull")
  
  ;; Org
  "o" '(:ignore t :which-key "org")
  "oa" '(org-agenda :which-key "org agenda")
  "oc" '(org-capture :which-key "org capture")
  "ol" '(org-store-link :which-key "org store link")
  "ot" '(org-todo :which-key "org todo")
  "os" '(org-schedule :which-key "org schedule")
  "od" '(org-deadline :which-key "org deadline")
  
  ;; Projects
  "p" '(:ignore t :which-key "projects")
  "pp" '(projectile-switch-project)

  ;; Documentation
  "d" '(:ignore t :which-key "docs")
  "dm" '(man :which-key "man page")
  "dw" '(woman :which-key "woman")
  "di" '(info :which-key "info")
  "dd" '(devdocs-lookup :which-key "devdocs")
  "dh" '(dash-docs-search :which-key "dash docs")
  "dc" '(counsel-dash :which-key "counsel dash")
  
  ;; Web
  "e" '(:ignore t :which-key "web")
  "ee" '(eww :which-key "eww browser")
  "es" '(eww-search-words :which-key "eww search")
  "eb" '(eww-list-bookmarks :which-key "eww bookmarks")
  "ea" '(eww-add-bookmark :which-key "eww add bookmark")
  
  ;; Info navigation
  "i" '(:ignore t :which-key "info")
  "ii" '(info :which-key "open info")
  "id" '(info-display-manual :which-key "display manual"))


;; Add language-specific documentation to leader key
;; (leader-def
;;   "dl" '(:ignore t :which-key "language docs")
;;   "dlp" '(open-python-docs :which-key "python docs")
;;   "dlj" '(open-julia-docs :which-key "julia docs")
;;   "dlg" '(open-go-docs :which-key "go docs")
;;   "dle" '(open-perl-docs :which-key "perl docs")
;;   "dlc" '(open-c-docs :which-key "c docs"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil)
 '(warning-suppress-log-types '((use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
