;;; init-treesit.el --- Tree-sitter modes and folding -*- lexical-binding: t; -*-

;; Install a grammar the first time a file needs it, as the nvim treesitter config does.
(use-package treesit-auto
  :config
  (setq treesit-auto-install t
        treesit-auto-langs '(elixir heex lua bash json yaml toml dockerfile))
  (treesit-auto-add-to-auto-mode-alist treesit-auto-langs)
  (global-treesit-auto-mode 1))

;; Folding with the evil z keys. Folds start open.
(add-hook 'prog-mode-hook #'hs-minor-mode)

(provide 'init-treesit)
;;; init-treesit.el ends here
