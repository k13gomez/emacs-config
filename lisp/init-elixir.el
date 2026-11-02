;;; init-elixir.el --- Elixir: tree-sitter modes, inf-elixir, mix -*- lexical-binding: t; -*-

(use-package elixir-ts-mode
  :ensure nil
  :config
  (setq elixir-ts-indent-offset 2))

(use-package inf-elixir)

(use-package mix
  :hook (elixir-ts-mode . mix-minor-mode))

;; >> and << move by the mode's indent, as nvim's per-filetype shiftwidth=2.
(add-hook 'elixir-ts-mode-hook (lambda () (setq-local evil-shift-width elixir-ts-indent-offset)))
(add-hook 'heex-ts-mode-hook (lambda () (setq-local evil-shift-width heex-ts-indent-offset)))

(defun my/mix-test-failed ()
  (interactive)
  (mix--start "test" "test --failed" (mix--project-root)))

(defun my/mix-deps-get ()
  (interactive)
  (mix--start "deps.get" "deps.get" (mix--project-root)))

(with-eval-after-load 'general
  (general-define-key
   :states 'visual
   :keymaps 'elixir-ts-mode-map
   :prefix ","
   "E" '(inf-elixir-send-region :which-key "send selection"))
  (general-define-key
   :states '(normal visual)
   :keymaps 'elixir-ts-mode-map
   :prefix ","
   "cs" '(inf-elixir-project :which-key "start iex -S mix")
   "ee" '(inf-elixir-send-line :which-key "send line")
   "eb" '(inf-elixir-send-buffer :which-key "send buffer")
   "mt" '(mix-test-current-test :which-key "mix: test at point")
   "mf" '(mix-test-current-buffer :which-key "mix: test current file")
   "ma" '(mix-test :which-key "mix: test all")
   "mr" '(my/mix-test-failed :which-key "mix: re-run failed tests")
   "mc" '(mix-compile :which-key "mix: compile")
   "md" '(my/mix-deps-get :which-key "mix: deps.get")))

(provide 'init-elixir)
;;; init-elixir.el ends here
