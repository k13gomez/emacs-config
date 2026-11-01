;;; init-ui.el --- Theme, modeline, tab bar and start screen -*- lexical-binding: t; -*-

(defconst my/tokyo-night-variants
  '(tokyo-night tokyo-night-storm tokyo-night-moon tokyo-night-day))

;; *.eld is already gitignored, so the saved choice stays out of the repo.
(defvar my/tokyo-night-file (expand-file-name "tokyo-night.eld" user-emacs-directory))

(defun my/tokyo-night-saved ()
  (let ((theme (ignore-errors
                 (with-temp-buffer
                   (insert-file-contents my/tokyo-night-file)
                   (read (current-buffer))))))
    (if (memq theme my/tokyo-night-variants) theme 'tokyo-night)))

(defun my/tokyo-night-pick ()
  "Pick a Tokyo Night variant with live preview and remember it across restarts."
  (interactive)
  ;; Loading consult first makes `consult-themes' special, so the let binds it dynamically.
  (require 'consult)
  (let ((consult-themes my/tokyo-night-variants))
    (call-interactively #'consult-theme))
  (let ((theme (car custom-enabled-themes)))
    (when (memq theme my/tokyo-night-variants)
      (with-temp-file my/tokyo-night-file
        (prin1 theme (current-buffer))))))

(use-package tokyo-night
  :config
  (load-theme (my/tokyo-night-saved) t))

(use-package nerd-icons)

(use-package doom-modeline
  :init
  (setq doom-modeline-buffer-file-name-style 'truename
        doom-modeline-buffer-encoding t
        doom-modeline-modal t)
  :config
  (doom-modeline-mode 1))

;; The tabline is always shown, with tab numbers for ,1 to ,9.
(use-package tab-bar
  :ensure nil
  :config
  (setq tab-bar-show t
        tab-bar-tab-hints t
        tab-bar-close-button-show nil
        tab-bar-new-button-show nil)
  (tab-bar-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package dashboard
  :config
  (setq dashboard-items '((recents . 10) (projects . 5))
        dashboard-projects-backend 'project-el
        dashboard-icon-type 'nerd-icons
        dashboard-set-file-icons t)
  (dashboard-setup-startup-hook))

(provide 'init-ui)
;;; init-ui.el ends here
