;; Disable backup files
(setq make-backup-files nil)

;; Disable lock files (this might be a bad idea)
(setq create-lockfiles nil)

;; Configure package for Nix
(require 'package)
;; (setq package-achives nil)
(setq package-enable-at-startup nil)
;; (package-initialize)

;; Customize the GUI
;; (load-theme 'tango-dark)
(load-theme 'tango)
(column-number-mode)
(menu-bar-mode 0)
(tool-bar-mode 0)
(setq default-frame-alist '((vertical-scroll-bars . nil)))
(setq column-number-indicator-zero-based nil)

;; Enable system monitor
;; (require 'symon)
;; (symon-mode)

;; Enable interactive completion
(ido-mode 1)
;; (fido-mode 1)
;; (ivy-mode 1)

;; Enable hungry deletion (removes blocks of whitespace)
(require 'hungry-delete)
(global-hungry-delete-mode)

;; Bind ace-window
(global-set-key (kbd "M-o") 'ace-window)

;; Always move the focus to the newly-shown help buffer
(setq help-window-select t)

;; Key-mappings
(global-set-key (kbd "C-S-s") 'isearch-forward-symbol-at-point)

;; Show whitespace
(require 'whitespace)
(setq-default indicate-buffer-boundaries 'left)
(setq whitespace-style '(face
                         trailing
                         ;; lines-tail
                         empty
                         tab-mark
                         space-mark
                         spaces
                         tabs))
(global-whitespace-mode)
(setq whitespace-global-modes '(not magit-status-mode))

(defun abc/style-whitespace()
  (interactive)
  (set-face-attribute 'whitespace-space nil :foreground "#9999AA" :background nil)
  (set-face-attribute 'whitespace-tab nil :foreground "#9999AA" :background nil))
(abc/style-whitespace)

;; Spell checking
(add-hook 'text-mode-hook #'flyspell-mode)
(add-hook 'git-commit-mode-hook #'flyspell-mode)

;; Keep backups and autosaves in separate directory
(make-directory "~/.emacs.d/auto-saves" t)
(make-directory "~/.emacs.d/backups" t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-saves" t)))
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

;; (defun abc/project-find-alt-root (dir)
;;   (let ((override (locate-dominating-file dir ".project.el")))
;;     (if override
;;         (cons 'vc override)
;;         nil)))

(require 'project)
(setq project-vc-extra-root-markers '(".project.el" ".projectile" ))
;; (add-hook 'project-find-functions #'abc/project-find-alt-root)

;; Support for ebooks
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

;; Configure Nix support
;; (load-file "~/.emacs.d/nix-shell.el")

;; Fix the search paths when running on MacOS
(when (memq window-system '(ns))
  ;; (exec-path-from-shell-initialize))
  (setenv "PATH" (concat
                  "/Users/user/.local/bin:"
                  "/Users/user/.nix-profile/bin:"
                  "/nix/var/nix/profiles/default/bin:"
                  (getenv "PATH")))
  (setq exec-path (append '("/Users/user/.local/bin"
                            "/Users/user/.nix-profile/bin"
                            "/nix/var/nix/profiles/default/bin")
                          exec-path))
)

;; Use spaces for indentation
(defun abc/disable-indent-tabs-mode ()
  (indent-tabs-mode 0))
;; (setq-default indent-tabs-mode nil)

;; Enable reading remote .dir-locals.el for configuring eglot
;; TODO: move that configuration here using classes?
(setq enable-remote-dir-locals t)

;; Use the PATH from the remote machine
(require 'tramp)
(add-to-list 'tramp-remote-path 'tramp-own-remote-path)

;; Configure C support
;; (add-to-list 'c-default-style '(c-mode . "linux"))
(require 'cc-vars)
(defun abc/set-c-style ()
  (setq c-basic-offset 4)
  (c-set-offset 'arglist-cont-nonempty '+)
  (c-set-style "linux"))
(add-hook 'c-mode-hook #'abc/set-c-style)

;; Configure eglot
(require 'eglot)
(defun abc/configure-eglot-keymap ()
  (keymap-set eglot-mode-map "C-c e a" 'eglot-code-actions)
  (keymap-set eglot-mode-map "C-c e r" 'eglot-rename)
  (keymap-set eglot-mode-map "C-c e f" 'eglot-format-buffer)
  (keymap-set eglot-mode-map "C-c f n" 'flymake-goto-next-error)
  (keymap-set eglot-mode-map "C-c f p" 'flymake-goto-prev-error))
(add-hook 'eglot-mode-hook #'abc/configure-eglot-keymap)

;; Configure Rust support
(require 'rust-mode)
(setq eglot-stay-out-of '(eldoc))
;; (setq compilation-scroll-output t)
(add-to-list 'eglot-server-programs '(rust-mode . ("rust-analyzer")))
(defun abc/configure-for-rust ()
  (setq indent-tabs-mode nil)
  (setq whitespace-line-column 100)
  (set-fill-column 100)
  (whitespace-mode)
  (global-set-key "\C-c\C-c\C-n" 'flymake-goto-next-error)
  (global-set-key "\C-c\C-c\C-p" 'flymake-goto-prev-error)
  (global-set-key "\C-c\C-c\C-f" 'eglot-format)
  (eglot-ensure)
  (company-mode))
(add-hook 'rust-mode-hook #'abc/configure-for-rust)
(add-hook 'c++-mode-hook #'abc/configure-for-rust)
(add-hook 'rust-mode-hook #'abc/disable-indent-tabs-mode)

;; Configure Clojure
(defun abc/configure-for-clojure ()
  (eglot-ensure))
(add-hook 'clojure-mode-hook #'abc/configure-for-clojure)

;; Configure JavaScript
(add-hook 'javascript-mode-hook #'abc/disable-indent-tabs-mode)

;; Configure TypeScript
(add-hook 'typescript-mode-hook #'abc/disable-indent-tabs-mode)

(defun abc/disable-whitespace-mode ()
  "Disables whitespace mode"
  (whitespace-mode 0))

;; Configure Go support
(add-hook 'go-mode-hook #'eglot-ensure)
(add-hook 'go-mode-hook #'abc/disable-whitespace-mode)

;; Configure Markdown support
(defun abc/set-markdown-style ()
  (set-fill-column 80)
  (setq whitespace-line-column 80))
(add-hook 'markdown-mode-hook #'abc/set-markdown-style)
(add-hook 'markdown-mode-hook #'abc/disable-indent-tabs-mode)

;; Configure eshell
(defvar-local abc/command-timer-print-threshold 10)
(defvar-local abc/command-start-time nil)
(defun abc/start-command-timer ()
  (setq abc/command-start-time (current-time)))
(defun abc/stop-command-timer ()
  (when abc/command-start-time
    (let ((duration (time-convert (time-subtract (current-time)
                                                 abc/command-start-time)
                                  'integer)))
      (when (> duration abc/command-timer-print-threshold)
        (eshell-interactive-print
         (format "Elapsed: %s\n" (format-seconds "%H, %M, %z%S" duration)))))
    (setq abc/command-start-time nil)))
;; (add-to-list 'eshell-expand-input-functions 'eshell-expand-history-references)
(defun abc/configure-eshell ()
  (interactive)
  (add-hook 'eshell-pre-command-hook #'abc/start-command-timer nil t)
  (add-hook 'eshell-post-command-hook #'abc/stop-command-timer nil t)
  compilation-shell-minor-mode
  ;; this seems to help reduce the latency when using eshell over TRAMP
  ;; https://www.gnu.org/software/tramp/#Using-ssh-connection-sharing-1
  (setq tramp-use-connection-share nil)
  ;; https://www.gnu.org/software/tramp/#Configure-direct-copying-between-two-remote-servers
  (setq tramp-use-scp-direct-remote-copying t))
(defun abc/rename-eshell-buffer (&optional prefix)
  "Rename the eshell buffer with the given prefix"
  (interactive)
  (let* ((prefix (or prefix (read-string "Prefix: ")))
         (new-name (concat prefix "-eshell")))
    (rename-buffer new-name)))
(add-hook 'eshell-mode-hook #'abc/configure-eshell)
(global-set-key "\C-xxc" 'abc/rename-eshell-buffer)

;; Helper functions
(defun abc/dev-eshell (&rest args)
  "Create a new eshell in the dev VM"
  (interactive)
  (let ((default-directory "/ssh:dev:/home/user"))
    (eshell args)))

;; RUSTC_WRAPPER=sccache
;; PAGER=cat

;; Make it easier to kill runaway processes
;; Found here: https://stackoverflow.com/a/18034042
;; Licensed by João Távora under the CC BY-SA 3.0
;; Modifications were made to the function name
(define-key process-menu-mode-map (kbd "C-k") 'delete-process-at-point)
(defun abc/delete-process-at-point ()
  (interactive)
  (let ((process (get-text-property (point) 'tabulated-list-id)))
    (cond ((and process
                (processp process))
           (delete-process process)
           (revert-buffer))
          (t
           (error "no process at point!")))))

;; Automatically change the theme to match the system
(defun abc/system-dark-theme-p ()
  "Check if the system is using the dark theme"
  (let* ((command (if (memq window-system '(ns))
                      "defaults read -globalDomain AppleInterfaceStyle"
                    "gsettings get org.gnome.desktop.interface color-scheme"))
         (default-directory "/")
         (output (shell-command-to-string command)))
    (if (or (string= "'prefer-dark'\n" output)
            (string= "Dark\n" output))
        t)))

(defvar abc/current-theme-dark nil
  "Whether the current theme is the dark one")

(defun abc/update-theme ()
  "Update the theme to match the system"
  (interactive)
  (if (abc/system-dark-theme-p)
      (if (not abc/current-theme-dark)
          (progn
            (load-theme 'tango-dark)
            (abc/style-whitespace)
            (setq abc/current-theme-dark t)))
    (if abc/current-theme-dark
        (progn
          (load-theme 'tango)
          (abc/style-whitespace)
          (setq abc/current-theme-dark nil)))))

(run-with-timer 30 30 'abc/update-theme)

;; Helper function for resolving IP addresses
(defun abc/ssh-ip (alias)
  "Resolve the IP address of the SSH host alias"
  (let ((default-directory "/"))
    (shell-command-to-string
     (concat "ssh -TG " alias " | awk '$1 == \"hostname\" { printf \"%s\", $2 }'" ))))

;; Helper for decoding and printing base64+json payloads
(defun abc/decode-and-pretty-print (beg end)
  "Base64-decode and pretty print the inner JSON"
  (interactive "r")
  (let* ((payload (buffer-substring beg end))
        (decoded (base64-decode-string payload)))
    (deactivate-mark)
    (delete-region beg end)
    (insert decoded)
    (json-pretty-print beg (+ beg (length decoded)))))
;; (keymap-global-set "C-c C-b" 'abc/decode-and-pretty-print)
(global-set-key (kbd "C-c C-b") 'abc/decode-and-pretty-print)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auth-source-save-behavior nil)
 '(eldoc-echo-area-use-multiline-p 2))
 ;; '(package-selected-packages '(nix-mode rust-mode))
