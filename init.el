;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs startup optimizations (KEEP AT TOP OF INIT.EL)
;;
;; Prevent GC from running hundreds of times on startup. After initialization,
;; will be set to the original parameters and likely incur GC sweeps. Use idle
;; timer instead of after-init-hook so these sweeps happen when we aren't 
;; actively using emacs. 
;;
;; Source: https://www.reddit.com/r/emacs/comments/3kqt6e/2_easy_little_known_steps_to_speed_up_emacs_start/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq gc-cons-threshold-original gc-cons-threshold)
(setq gc-cons-threshold (* 1024 1024 100))
(setq file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)

(run-with-idle-timer
 5 nil
 (lambda ()
   (setq gc-cons-threshold gc-cons-threshold-original)
   (setq file-name-handler-alist file-name-handler-alist-original)
   (makunbound 'gc-cons-threshold-original)
   (makunbound 'file-name-handler-alist-original)
   (message "gc-cons-threshold and file-name-handler-alist restored")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package manager setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add emacs package managers MELPA & ELPA
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(package-initialize)

;; Binds to make updating packages a bit easier
;; s new --> list what packages are newly available
;; a --> put packages marked for upgrade into a buffer to browse
;; Only in Emacs 25.1+
(defun package-menu-find-marks ()
  "Find packages marked for action in *Packages*."
  (interactive)
  (occur "^[A-Z]"))

(defun package-menu-filter-by-status (status)
  "Filter the *Packages* buffer by status."
  (interactive
   (list (completing-read
          "Status: " '("new" "installed" "dependency" "obsolete"))))
  (package-menu-filter (concat "status:" status)))

(define-key package-menu-mode-map "s" #'package-menu-filter-by-status)
(define-key package-menu-mode-map "a" #'package-menu-find-marks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Extra plugins and config files are stored here
(add-to-list 'load-path (expand-file-name "~/.emacs.d/plugins"))

;; store all backup and autosave files in /tmp 
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Emacs Themes
;;
;; Set spolsky-theme from sublime-themes package for GUI
;; Set monokai-pro from monokai-pro-theme package for terminal
;;
;; Spolsky is preferred due to higher contrast and coloring the variable name for declarations
;; However its color scheme does not render properly in a terminal
;; Monokai pro is a suitable substitute
(if (display-graphic-p)
    (use-package sublime-themes
      :ensure t
      :config
      (load-theme 'spolsky t))
  (use-package monokai-pro-theme
    :ensure t
    :config
    (load-theme 'monokai-pro t)) )
  
;; turn on line and column numbers
(setq line-number-mode t)
(setq column-number-mode t)

;; use the tab key to make 4 spaces
(setq tab-width 4)
(setq indent-tabs-mode nil)

;; turn on highlight matching brackets when cursor is on one
(show-paren-mode t)

;; Disable the toolbar at the top since it's useless
(if (functionp 'tool-bar-mode) (tool-bar-mode -1))

;; Make block cursor as wide as underlying glyph
(setq x-stretch-cursor t)

;; no start up message
(setq inhibit-startup-message t)
(setq initial-scratch-message "")

;; no audible or visual bell when emacs is mad
(setq ring-bell-function 'ignore)

;; Overwrite region selected
(delete-selection-mode t)

;; Case insesitive searches with match highlights
(setq-default case-fold-search t 
              search-highlight t)

;; allow upcase (C-x C-u) and downcase (C-x C-l) region
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Configure ispell
(setq ispell-program-name "/usr/bin/aspell")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Programming settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Highlight some keywords in prog-mode
;; Taken from https://gist.github.com/nilsdeppe/7645c096d93b005458d97d6874a91ea9
(add-hook 'prog-mode-hook
          (lambda ()
            ;; Highlighting in cmake-mode this way interferes with
            ;; cmake-font-lock, which is something I don't yet understand.
            (when (not (derived-mode-p 'cmake-mode))
              (font-lock-add-keywords
               nil
               '(("\\<\\(FIXME\\|TODO\\|BUG\\|DONE\\)"
                  1 font-lock-warning-face t))))
            )
          )

;; Untabify bufer on save, except for makefiles
;; That way we can still have smart tab alignment but spaces only output
;; Taken from Nathan @ https://www.emacswiki.org/emacs/UntabifyUponSave
(defvar untabify-this-buffer)
 (defun untabify-all ()
   "Untabify the current buffer, unless `untabify-this-buffer' is nil."
   (and untabify-this-buffer (untabify (point-min) (point-max))))
 (define-minor-mode untabify-mode
   "Untabify buffer on save." nil " untab" nil
   (make-variable-buffer-local 'untabify-this-buffer)
   (setq untabify-this-buffer (not (derived-mode-p 'makefile-mode)))
   (add-hook 'before-save-hook #'untabify-all))
 (add-hook 'prog-mode-hook 'untabify-mode)

;; Create clang-format file using google style
;; clang-format -style=google -dump-config > .clang-format
(use-package clang-format
  :ensure t
  :bind (("C-c C-f" . clang-format-region))
  )

;; Modern C++ code highlighting
(use-package modern-cpp-font-lock
  :ensure t
  :init
  (eval-when-compile
      ;; Silence missing function warnings
    (declare-function modern-c++-font-lock-global-mode
                      "modern-cpp-font-lock.el"))
  :config
  (modern-c++-font-lock-global-mode t)
  )

;; Use Google C++ style
(use-package cc-mode
  :ensure t
  :init
  (add-to-list 'auto-mode-alist '("\\.tpp\\'" . c++-mode))
  :config
  (use-package google-c-style
    :ensure t
    :config
    ;; This prevents the extra two spaces in a namespace that Emacs
    ;; otherwise wants to put... Gawd!
    (add-hook 'c-mode-common-hook 'google-set-c-style)
    ;; Autoindent using google style guide
    (add-hook 'c-mode-common-hook 'google-make-newline-indent)
    )
  )

;; Set the number of spaces that the tab key inserts (usually 2 or 4)
(setq c-basic-offset 4)

;; We want to be able to see if there is a tab character vs a space.
;; global-whitespace-mode allows us to do just that.
;; Set whitespace mode to only show tabs, not newlines/spaces.
(use-package whitespace
  :ensure t
  :init
  (eval-when-compile
      ;; Silence missing function warnings
      (declare-function global-whitespace-mode "whitespace.el"))
  :config
  (setq whitespace-style '(tabs tab-mark))
  ;; Turn on whitespace mode globally.
  (global-whitespace-mode t)
  )

;; Enable hide/show of code blocks
(add-hook 'c-mode-common-hook 'hs-minor-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure other installed packages 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Enable smart-tab package from MELPA
(require 'smart-tab)
(global-smart-tab-mode 1)
