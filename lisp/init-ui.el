;;; init-ui.el --- Theme, modeline, tab bar and start screen -*- lexical-binding: t; -*-

(use-package doom-themes
  :config
  (load-theme 'doom-material-dark t))

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
