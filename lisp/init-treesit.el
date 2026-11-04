;;; init-treesit.el --- Tree-sitter modes and folding -*- lexical-binding: t; -*-

;; Every language with a ts-mode uses it, and its grammar is built the first time a file needs it,
;; as the nvim treesitter config does. :custom is required: treesit-enabled-modes has a :set
;; function that sets up the mode remaps.
(use-package treesit
  :ensure nil
  :custom
  (treesit-enabled-modes t)
  (treesit-auto-install-grammar 'always)
  ;; Level 4 adds calls, variables, operators and brackets, closer to nvim's highlighting.
  (treesit-font-lock-level 4))

(use-package markdown-ts-mode
  :ensure nil
  :mode "\\.md\\'")

;; erlang-ts asks before building its grammar. Build it on load instead, as for the other modes.
(use-package erlang-ts
  :mode (("\\.erl\\'" . erlang-ts-mode) ("\\.hrl\\'" . erlang-ts-mode))
  :config
  (erlang-ts-install-grammar))

;; >> and << move by 2 in YAML, as nvim's yaml ftplugin (shiftwidth=2).
(add-hook 'yaml-ts-mode-hook (lambda () (setq-local evil-shift-width 2)))

;; JSON indents by 2 in both editors. js-json-mode is the fallback when the grammar isn't installed.
(add-hook 'json-ts-mode-hook (lambda () (setq-local evil-shift-width 2)))
(add-hook 'js-json-mode-hook (lambda () (setq-local evil-shift-width 2 js-indent-level 2)))

;; Folding with the evil z keys. Folds start open.
(add-hook 'prog-mode-hook #'hs-minor-mode)

(provide 'init-treesit)
;;; init-treesit.el ends here
