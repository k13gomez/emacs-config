;;; init-clojure.el --- Clojure: CIDER (Conjure), parinfer -*- lexical-binding: t; -*-

(use-package clojure-mode :defer t)

(use-package cider
  :defer t
  :config
  ;; Conjure does not open the REPL buffer on connect. CIDER must not either.
  (setq cider-repl-pop-to-buffer-on-connect nil
        cider-show-error-buffer 'only-in-repl
        cider-auto-select-error-buffer nil))

(use-package parinfer-rust-mode
  :hook (clojure-mode emacs-lisp-mode)
  :init
  (setq parinfer-rust-auto-download t))

;; `(' and `)' jump to the enclosing bracket, as in vim-sexp. They also leave a string first.
;; At the top level there is no bracket to go to, so they stay in place.
(evil-define-motion init-clojure-backward-up-list (count)
  "Move to the opening bracket COUNT levels up."
  (let ((start (point)))
    (goto-char (save-excursion
                 (goto-char (or (nth 8 (syntax-ppss)) (point)))
                 (condition-case nil
                     (progn (backward-up-list (or count 1)) (point))
                   (scan-error start))))))

(evil-define-motion init-clojure-up-list (count)
  "Move to the closing bracket COUNT levels up."
  (let ((start (point)))
    (goto-char (save-excursion
                 (goto-char (or (nth 8 (syntax-ppss)) (point)))
                 ;; On `(' this enters the list, so `)' finds its partner.
                 ;; On `)' this leaves the list, so a repeat goes one level out.
                 (when (memq (char-syntax (or (char-after) ?\s)) '(?\( ?\)))
                   (forward-char))
                 (condition-case nil
                     (progn (up-list (or count 1)) (1- (point)))
                   (scan-error start))))))

(with-eval-after-load 'general
  (general-define-key
   :states 'motion
   :keymaps '(clojure-mode-map emacs-lisp-mode-map)
   "(" #'init-clojure-backward-up-list
   ")" #'init-clojure-up-list)
  ;; The keys follow the Conjure defaults.
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
   "rr" '(cider-ns-refresh :which-key "refresh changed")))

(provide 'init-clojure)
;;; init-clojure.el ends here
