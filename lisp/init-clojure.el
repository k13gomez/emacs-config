;;; init-clojure.el --- Clojure: CIDER (Conjure), parinfer -*- lexical-binding: t; -*-

;; CIDER requires clojure-mode, but files open in clojure-ts-mode for tree-sitter, as in nvim.
(use-package clojure-mode
  :defer t
  :mode "\\.clje\\'")

(use-package clojure-ts-mode
  :defer t
  :init
  (dolist (remap '((clojure-mode . clojure-ts-mode)
                   (clojurescript-mode . clojure-ts-clojurescript-mode)
                   (clojurec-mode . clojure-ts-clojurec-mode)))
    (add-to-list 'major-mode-remap-alist remap)))

(use-package cider
  :defer t
  :config
  ;; Conjure does not open the REPL buffer on connect. CIDER must not either.
  (setq cider-repl-pop-to-buffer-on-connect nil
        cider-show-error-buffer 'only-in-repl
        cider-auto-select-error-buffer nil))

;; One switch for all buffers, as nvim's global g:parinfer_enabled.
(defvar my/parinfer-enabled t)
(defconst my/parinfer-modes '(clojure-mode clojure-ts-mode emacs-lisp-mode))

(defun my/parinfer-maybe-enable ()
  (when my/parinfer-enabled (parinfer-rust-mode 1)))

(defun my/parinfer-toggle ()
  "Turn parinfer on or off in every Lisp buffer."
  (interactive)
  (setq my/parinfer-enabled (not my/parinfer-enabled))
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (apply #'derived-mode-p my/parinfer-modes)
        (parinfer-rust-mode (if my/parinfer-enabled 1 -1)))))
  (message "Parinfer %s" (if my/parinfer-enabled "on" "off")))

(use-package parinfer-rust-mode
  :defer t
  :init
  (setq parinfer-rust-auto-download t)
  (dolist (mode my/parinfer-modes)
    (add-hook (intern (format "%s-hook" mode)) #'my/parinfer-maybe-enable)))

;; Conjure's ,ece and ,e! act on the form around the cursor; CIDER's commands take the sexp before
;; point. Move just past the current form first.
(defun my/goto-current-form-end ()
  (goto-char (or (nth 8 (syntax-ppss)) (point)))
  (if (eq (char-syntax (or (char-after) ?\s)) ?\()
      (forward-sexp)
    (condition-case nil
        (up-list)
      (scan-error (forward-sexp)))))

(defun my/cider-call-on-current-form (command)
  ;; evil-collection's advice would step one more character past point in normal state.
  (let ((evil-move-beyond-eol t))
    (save-excursion
      (my/goto-current-form-end)
      (call-interactively command))))

(defun my/cider-eval-form-to-comment ()
  (interactive)
  (my/cider-call-on-current-form #'cider-pprint-eval-last-sexp-to-comment))

(defun my/cider-eval-and-replace-form ()
  (interactive)
  (my/cider-call-on-current-form #'cider-eval-last-sexp-and-replace))

;; `(' and `)' jump to the enclosing bracket, as in lua/plugins/sexp.lua. They also leave a string first.
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

;; The Clojure and Portal helpers from lua/helpers/clojure.lua. Each sends the same form that nvim
;; sends through ConjureEval, evaluated in the buffer's namespace.
(defun my/clj-symbol ()
  (or (cider-symbol-at-point) (user-error "No symbol at point")))

(defmacro my/clj-command (name doc &rest parts)
  "Define command NAME that evaluates the concatenation of PARTS in the REPL."
  `(defun ,name ()
     ,doc
     (interactive)
     (cider-interactive-eval (concat ,@parts))))

(my/clj-command my/clj-find-library-versions "Show the latest 10 versions of the library at point."
  "(do (require '[clojure.edn] '[clojure.tools.deps] '[clojure.tools.deps.extensions] '[clojure.tools.deps.util.maven]) (let [mvn-repos (->> (slurp \"deps.edn\") clojure.edn/read-string :mvn/repos (merge clojure.tools.deps.util.maven/standard-repos)) types (distinct (into [:mvn :git] (clojure.tools.deps.extensions/procurer-types))) lib '"
  (my/clj-symbol)
  " procurer {:mvn/repos mvn-repos}] (->> (some #(clojure.tools.deps.extensions/find-versions lib nil % procurer) types) (reverse) (take 10) (vec))))")
(my/clj-command my/clj-portal-add-lib "Add Portal to the running REPL."
  "(do (require 'clojure.repl.deps) (clojure.repl.deps/add-lib 'djblue/portal))")
(my/clj-command my/clj-portal-taps-on "Open Portal and send tap> to it and to println."
  "(do (require 'portal.api) (portal.api/open) (add-tap #'portal.api/submit) (add-tap #'println))")
(my/clj-command my/clj-tap-symbol "tap> the symbol at point."
  "(tap> " (my/clj-symbol) ")")
(my/clj-command my/clj-portal-taps-off "Stop sending tap> to Portal and println."
  "(do (require 'portal.api) (portal.api/open) (remove-tap #'portal.api/submit) (remove-tap #'println))")
(my/clj-command my/clj-portal-selected "Return the value selected in Portal."
  "(do (require 'portal.api) (portal.api/selected))")
(my/clj-command my/clj-pid "Show the REPL JVM's process id."
  "(.. (java.lang.ProcessHandle/current) (pid))")
(my/clj-command my/clj-warn-on-reflection "Turn on *warn-on-reflection*."
  "(alter-var-root #'*warn-on-reflection* (constantly true))")
(my/clj-command my/clj-eval-fn "Call the function at point with no arguments."
  "(" (my/clj-symbol) ")")
(my/clj-command my/clj-run-test "Run the test var at point."
  "(do (require '[clojure.test]) (clojure.test/test-var #'" (my/clj-symbol) "))")
(my/clj-command my/clj-run-tests "Run the tests in the current namespace."
  "(do (require '[clojure.test]) (clojure.test/run-tests))")
(my/clj-command my/clj-reload-ns "Reload the current namespace."
  "(require (ns-name *ns*) :reload)")
(my/clj-command my/clj-reset-rules "Reset the clara rules and loader."
  "(do (rules.core/reset-rules!) (rules.core/reset-loader!))")

(with-eval-after-load 'general
  (general-define-key
   :states 'motion
   :keymaps '(clojure-mode-map clojure-ts-mode-map emacs-lisp-mode-map)
   "(" #'init-clojure-backward-up-list
   ")" #'init-clojure-up-list)
  ;; The keys follow the Conjure defaults.
  (general-define-key
   :states 'visual
   :keymaps '(clojure-mode-map clojure-ts-mode-map)
   :prefix ","
   "E" '(cider-eval-region :which-key "eval selection"))
  (general-define-key
   :states '(normal visual)
   :keymaps '(clojure-mode-map clojure-ts-mode-map)
   :prefix ","
   "repl" '(cider-connect-clj :which-key "connect REPL")
   "cf" '(cider-connect-clj :which-key "connect REPL")
   "cd" '(cider-quit :which-key "disconnect")
   "cv" '(my/clj-find-library-versions :which-key "find library versions")
   "cp" '(my/clj-portal-add-lib :which-key "Portal: add lib")
   "ct" '(my/clj-portal-taps-on :which-key "Portal: taps on")
   "cT" '(my/clj-tap-symbol :which-key "tap> word at cursor")
   "cu" '(my/clj-portal-taps-off :which-key "Portal: taps off")
   "cg" '(my/clj-portal-selected :which-key "Portal: get selected")
   "cj" '(my/clj-pid :which-key "JVM PID")
   "cw" '(my/clj-warn-on-reflection :which-key "*warn-on-reflection* on")
   "ce" '(:ignore t :which-key "eval")
   "cef" '(my/clj-eval-fn :which-key "eval fn at cursor")
   "cr" '(:ignore t :which-key "clojure: run / reload / reset")
   "cro" '(my/clj-run-test :which-key "run one test")
   "crt" '(my/clj-run-tests :which-key "run all tests")
   "crn" '(my/clj-reload-ns :which-key "reload current ns")
   "crr" '(my/clj-reset-rules :which-key "reset clara rules")
   "ee" '(cider-eval-list-at-point :which-key "eval current form")
   "er" '(cider-eval-defun-at-point :which-key "eval root form")
   "ew" '(cider-eval-sexp-at-point :which-key "eval word")
   "ece" '(my/cider-eval-form-to-comment :which-key "eval form to comment")
   "ecr" '(cider-eval-defun-to-comment :which-key "eval root form to comment")
   "e!" '(my/cider-eval-and-replace-form :which-key "eval and replace form")
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
