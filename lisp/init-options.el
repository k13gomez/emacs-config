;;; init-options.el --- Editor options (mirrors config/options.lua) -*- lexical-binding: t; -*-

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 120)

(global-display-line-numbers-mode 1)
(global-display-fill-column-indicator-mode 1)
(global-hl-line-mode 1)
(show-paren-mode 1)
(column-number-mode 1)

;; The nvim 'list' option: show tabs and trailing spaces.
(setq whitespace-style '(face tabs trailing))
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'whitespace-mode))

(setq scroll-margin 4
      scroll-conservatively 101)

(setq select-enable-clipboard t)

;; As nvim: no backup copies, and a warning when the file is already open in another Emacs
;; (nvim's swap file). Lock files go to the cache, not next to the file.
(let ((autosaves (expand-file-name "~/.cache/emacs-swapfiles/"))
      (locks (expand-file-name "~/.cache/emacs-lockfiles/")))
  (make-directory autosaves t)
  (make-directory locks t)
  (setq make-backup-files nil
        auto-save-file-name-transforms `((".*" ,autosaves t))
        lock-file-name-transforms `((".*" ,locks t))))

(setq ring-bell-function #'ignore
      use-short-answers t)

;; A subdirectory with one of these files is its own project, so the LSP server gets the right root.
(setq project-vc-extra-root-markers '("mix.exs" "deps.edn" "project.clj"))

(recentf-mode 1)
(savehist-mode 1)
(global-auto-revert-mode 1)
(repeat-mode 1)

;; Terminal support: mouse, and the macOS clipboard through pbcopy and pbpaste.
(unless (display-graphic-p)
  (xterm-mouse-mode 1)
  ;; xterm-mouse emits wheel-up/wheel-down, which only mwheel binds, and it isn't preloaded in a tty session.
  (mouse-wheel-mode 1))

(use-package xclip
  :config
  (setq xclip-method 'pbpaste)
  (xclip-mode 1))

;; Terminal buffers stand in for tmux, so children must not think they're inside it:
;; byobu-launch in .zshrc would nest a session, and the zsh tmux hooks would rename
;; the window hosting Emacs.
(setenv "TMUX")
(setenv "TMUX_PANE")
(setenv "BYOBU_DISABLE" "1")

(provide 'init-options)
;;; init-options.el ends here
