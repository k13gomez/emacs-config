;;; init-elixir.el --- Elixir: tree-sitter modes, inf-elixir, mix -*- lexical-binding: t; -*-

(use-package elixir-ts-mode
  :ensure nil
  :config
  (setq elixir-ts-indent-offset 2))

(use-package inf-elixir)

(use-package mix
  :hook (elixir-ts-mode . mix-minor-mode))

(with-eval-after-load 'general
  (general-define-key
   :states 'visual
   :keymaps 'elixir-ts-mode-map
   "E" #'inf-elixir-send-region)
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
   "mr" '(mix-last-command :which-key "mix: run last command")
   "mc" '(mix-compile :which-key "mix: compile")
   "md" '(mix-execute-task :which-key "mix: run task")))

(provide 'init-elixir)
;;; init-elixir.el ends here
