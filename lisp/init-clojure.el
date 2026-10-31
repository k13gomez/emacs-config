;;; init-clojure.el --- Clojure: CIDER (Conjure), lispyville (vim-sexp), parinfer -*- lexical-binding: t; -*-

(use-package clojure-mode)

(use-package cider
  :config
  ;; Conjure does not open the REPL buffer on connect. CIDER must not either.
  (setq cider-repl-pop-to-buffer-on-connect nil
        cider-show-error-buffer 'only-in-repl
        cider-auto-select-error-buffer nil))

;; lispy needs these, but its MELPA recipe does not list them.
(use-package iedit)
(use-package zoutline)

(use-package lispyville
  :hook (clojure-mode . lispyville-mode)
  :config
  (lispyville-set-key-theme
   '(operators c-w slurp/barf-cp additional additional-movement additional-wrap text-objects)))

(use-package parinfer-rust-mode
  :init
  (setq parinfer-rust-auto-download t))

;; The keys follow the Conjure defaults and plugins/sexp.lua.
(with-eval-after-load 'general
  ;; vim-sexp swaps elements with M-h/M-l. lispyville's own theme uses them for defun motions.
  (general-define-key
   :states '(normal visual)
   :keymaps 'lispyville-mode-map
   "M-h" #'lispyville-drag-backward
   "M-l" #'lispyville-drag-forward)
  (general-define-key
   :states 'visual
   :keymaps 'clojure-mode-map
   "E" #'cider-eval-region)
  (general-define-key
   :states '(normal visual)
   :keymaps 'clojure-mode-map
   :prefix ","
   "repl" '(cider-connect-clj :which-key "connect REPL")
   "cf" '(cider-connect-clj :which-key "connect REPL")
   "cd" '(cider-quit :which-key "disconnect")
   "ee" '(cider-eval-list-at-point :which-key "eval current form")
   "er" '(cider-eval-defun-at-point :which-key "eval root form")
   "ew" '(cider-eval-sexp-at-point :which-key "eval word")
   "ece" '(cider-pprint-eval-last-sexp-to-comment :which-key "eval form to comment")
   "ecr" '(cider-eval-defun-to-comment :which-key "eval root form to comment")
   "e!" '(cider-eval-last-sexp-and-replace :which-key "eval and replace form")
   "eb" '(cider-load-buffer :which-key "eval buffer")
   "ef" '(cider-load-file :which-key "eval file")
   "ei" '(cider-interrupt :which-key "interrupt")
   "ls" '(cider-switch-to-repl-buffer :which-key "REPL buffer")
   "lv" '(cider-switch-to-repl-buffer :which-key "REPL buffer")
   "ll" '(cider-switch-to-repl-buffer :which-key "REPL buffer")
   "lr" '(cider-find-and-clear-repl-output :which-key "clear REPL output")
   "gd" '(cider-find-var :which-key "goto definition")
   "x1" '(cider-macroexpand-1 :which-key "macroexpand-1")
   "xa" '(cider-macroexpand-all :which-key "macroexpand all")
   "sq" '(cider-quit :which-key "close session")
   "sl" '(sesman-browser :which-key "list sessions")
   "ss" '(sesman-link-with-buffer :which-key "select session")
   "ta" '(cider-test-run-project-tests :which-key "run all tests")
   "tn" '(cider-test-run-ns-tests :which-key "run ns tests")
   "tc" '(cider-test-run-test :which-key "run test at point")
   "rr" '(cider-ns-refresh :which-key "refresh changed")
   "w(" '(lispyville-wrap-round :which-key "wrap ( )")
   "w[" '(lispyville-wrap-brackets :which-key "wrap [ ]")
   "w{" '(lispyville-wrap-braces :which-key "wrap { }")
   "ws" '(lispy-splice :which-key "splice list")
   "wv" '(lispy-convolute :which-key "convolute")
   "wc" '(lispy-clone :which-key "clone")
   "wr" '(lispy-raise :which-key "raise")))

(provide 'init-clojure)
;;; init-clojure.el ends here
