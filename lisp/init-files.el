;;; init-files.el --- File tree on the right (neo-tree) -*- lexical-binding: t; -*-

(use-package treemacs
  :config
  (setq treemacs-position 'right
        treemacs-width 40
        treemacs-show-hidden-files nil)
  (treemacs-follow-mode 1)
  ;; Always show the current project, as neo-tree shows the current directory.
  (treemacs-project-follow-mode 1)
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'simple))

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

(provide 'init-files)
;;; init-files.el ends here
