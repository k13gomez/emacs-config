;;; init-lsp.el --- LSP, diagnostics and formatting -*- lexical-binding: t; -*-

(use-package eglot
  :ensure nil
  :hook ((clojure-mode clojurescript-mode clojurec-mode
          elixir-ts-mode heex-ts-mode lua-ts-mode)
         . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs '((elixir-ts-mode heex-ts-mode) . ("elixir-ls")))
  (setq-default eglot-workspace-configuration
                '(:elixirLS (:dialyzerEnabled t :fetchDeps t)))
  (setq eglot-autoshutdown t))

(use-package terraform-mode)

;; Format on save for the same file types and formatters as conform in the nvim config.
(use-package apheleia
  :hook ((elixir-ts-mode heex-ts-mode terraform-mode) . apheleia-mode)
  :config
  (add-to-list 'apheleia-mode-alist '(lua-ts-mode . stylua))
  ;; apheleia's defaults are `opentofu' for terraform and prettier (as HTML) for heex.
  (setf (alist-get 'terraform-mode apheleia-mode-alist) 'terraform
        (alist-get 'heex-ts-mode apheleia-mode-alist) 'mix-format))

(with-eval-after-load 'general
  (general-define-key
   :states 'normal
   :keymaps 'eglot-mode-map
   "gd" #'xref-find-definitions
   "K" #'eldoc-doc-buffer)
  (general-define-key
   :states '(normal visual)
   :keymaps 'eglot-mode-map
   :prefix ","
   "dd" '(eglot-find-declaration :which-key "goto declaration")
   "dt" '(eglot-find-typeDefinition :which-key "goto type definition")
   "ds" '(eldoc :which-key "signature help")
   "dn" '(eglot-rename :which-key "rename symbol")
   "de" '(display-local-help :which-key "show diagnostic")
   "dq" '(flymake-show-buffer-diagnostics :which-key "buffer diagnostics")
   "dj" '(flymake-goto-next-error :which-key "next diagnostic")
   "dk" '(flymake-goto-prev-error :which-key "previous diagnostic")
   "da" '(eglot-code-actions :which-key "code action")
   "dw" '(flymake-show-project-diagnostics :which-key "workspace diagnostics")
   "dr" '(xref-find-references :which-key "references")
   "di" '(eglot-find-implementation :which-key "implementations")))

(provide 'init-lsp)
;;; init-lsp.el ends here
