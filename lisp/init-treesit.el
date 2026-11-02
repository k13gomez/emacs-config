;;; init-treesit.el --- Tree-sitter modes and folding -*- lexical-binding: t; -*-

;; Install a grammar the first time a file needs it, as the nvim treesitter config does, but only
;; for these languages; the rest (Clojure, Terraform, ...) keep their regular major modes.
(use-package treesit-auto
  :config
  (setq treesit-auto-install t
        treesit-auto-langs '(elixir heex lua bash json yaml toml dockerfile))
  (treesit-auto-add-to-auto-mode-alist treesit-auto-langs)
  (global-treesit-auto-mode 1))

;; >> and << move by 2 in YAML, as nvim's yaml ftplugin (shiftwidth=2).
(add-hook 'yaml-ts-mode-hook (lambda () (setq-local evil-shift-width 2)))

;; JSON indents by 2 in both editors. js-json-mode is the fallback when the grammar isn't installed.
(add-hook 'json-ts-mode-hook (lambda () (setq-local evil-shift-width 2)))
(add-hook 'js-json-mode-hook (lambda () (setq-local evil-shift-width 2 js-indent-level 2)))

;; Folding with the evil z keys. Folds start open.
(add-hook 'prog-mode-hook #'hs-minor-mode)

(provide 'init-treesit)
;;; init-treesit.el ends here
