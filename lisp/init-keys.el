;;; init-keys.el --- Global leader keys (mirrors config/keymaps.lua) -*- lexical-binding: t; -*-

(use-package uuidgen :defer t)
(use-package xml-format :defer t)
(use-package string-inflection :defer t)

(use-package evil-lion
  :after evil
  :config
  (setq evil-lion-left-align-key (kbd "ga")
        evil-lion-right-align-key (kbd "gA"))
  (evil-lion-mode 1))

;; nvim's ,>> ,>>> ,>>>> resize by 5, 10 and 20. Emacs can't bind a key and a longer key starting
;; with it, so ,>> waits up to nvim's 'timeoutlen' (1s) for more presses of the same key, as Vim does.
(defun my/resize-command (key sign horizontal)
  (lambda ()
    (interactive)
    (let ((extra 0) event)
      (while (and (< extra 2)
                  (setq event (read-event nil nil 1.0))
                  (eq event key))
        (setq extra (1+ extra)))
      (when (and event (not (eq event key)))
        (push event unread-command-events))
      (enlarge-window (* sign (nth extra '(5 10 20))) horizontal))))

(defun my/insert-hash ()
  "Insert 32 random hex characters."
  (interactive)
  (insert (mapconcat (lambda (_) (format "%x" (random 16))) (make-list 32 nil) "")))

(defun my/insert-empty-uuid ()
  (interactive)
  (insert "00000000-0000-0000-0000-000000000000"))

(defun my/insert-timestamp ()
  "Insert the ISO 8601 time with milliseconds and offset, as nvim's ,uts."
  (interactive)
  (insert (format-time-string "%FT%T.%3N%z")))

(defun my/retab ()
  "Turn the buffer's tabs into spaces, as :retab does with 'expandtab'."
  (interactive)
  (untabify (point-min) (point-max)))

(defun my/git-blame-line ()
  "Show who last changed the current line, as gitsigns' blame_line."
  (interactive)
  (unless buffer-file-name (user-error "Not a file"))
  (let* ((line (line-number-at-pos))
         (file (file-local-name buffer-file-name))
         (out (with-temp-buffer
                (unless (zerop (call-process "git" nil t nil "blame" "--porcelain"
                                             "-L" (format "%d,%d" line line) "--" file))
                  (user-error "git blame: %s" (string-trim (buffer-string))))
                (buffer-string)))
         (field (lambda (key)
                  (and (string-match (format "^%s \\(.*\\)$" key) out) (match-string 1 out)))))
    (message "%s %s, %s: %s"
             (substring out 0 8)
             (funcall field "author")
             (format-time-string "%F" (string-to-number (funcall field "author-time")))
             (funcall field "summary"))))

(defun my/case-rotate ()
  "Rotate the symbol at point snake -> kebab -> camel -> Pascal -> MACRO, as vim-case-master.
string-inflection's own cycle uses a different order."
  (interactive)
  (require 'string-inflection)
  (let* ((bounds (save-excursion (funcall string-inflection-bounds-function)))
         (word (buffer-substring-no-properties (car bounds) (cdr bounds)))
         (case-fold-search nil))
    (funcall (cond ((string-search "-" word) #'string-inflection-lower-camel-case)
                   ((string-match-p "\\`[A-Z_]*\\'" word) #'string-inflection-snake-case)
                   ((string-search "_" word) #'string-inflection-kebab-case)
                   ((string-match-p "\\`[A-Z]" word) #'string-inflection-upcase)
                   (t #'string-inflection-camel-case)))))

;; `cs' + r/s/k/c/p/m rotates or converts case, as vim-case-master in nvim. `s' is bound in operator
;; state so plain `c' still works; the conversion runs instead of the pending change (the evil-surround trick).
;; These are string-inflection's autoloaded names; its older aliases only exist once it has loaded.
(defconst my/case-commands
  '((?r . my/case-rotate)
    (?s . string-inflection-snake-case)
    (?k . string-inflection-kebab-case)
    (?c . string-inflection-lower-camel-case)
    (?p . string-inflection-camel-case)
    (?m . string-inflection-upcase)))

(evil-define-command my/evil-case-convert ()
  (setq evil-inhibit-operator t)
  (when (eq evil-this-operator #'evil-change)
    (when-let* ((cmd (alist-get (read-char "Case: [r]otate [s]nake [k]ebab [c]amel [p]ascal [m]acro")
                                my/case-commands)))
      (funcall cmd))))
(define-key evil-operator-state-map "s" #'my/evil-case-convert)

(defun my/clear-highlight ()
  "Clear search highlight and redraw, as nvim's default C-l."
  (interactive)
  (evil-ex-nohighlight)
  (redraw-display))
(evil-define-key 'normal 'global (kbd "C-l") #'my/clear-highlight)

(my/leader
  "h" '(dashboard-open :which-key "start screen")

  "n" '(:ignore t :which-key "new")
  "ne" '(tab-new :which-key "empty buffer in new tab")
  "nt" '(my/term-tab :which-key "terminal in new tab")

  "b" '(:ignore t :which-key "buffer")
  "bw" '(save-buffer :which-key "write buffer")
  "bq" '(evil-quit :which-key "quit buffer")
  "bW" '(evil-write-all :which-key "write all buffers")
  "bQ" '(evil-quit-all :which-key "quit all")
  "bx" '(evil-save-and-quit :which-key "write all and quit")
  "bX" '(kill-emacs :which-key "quit all, discard")

  "u" '(:ignore t :which-key "insert / utilities")
  "uh" '(my/insert-hash :which-key "insert random hex hash")
  "uu" '(uuidgen :which-key "insert UUID")
  "ue" '(my/insert-empty-uuid :which-key "insert empty UUID")
  "uts" '(my/insert-timestamp :which-key "insert ISO timestamp")
  "uf" '(:ignore t :which-key "pretty-print")
  "ufx" '(xml-format-buffer :which-key "pretty-print XML")
  "ufj" '(json-pretty-print-buffer :which-key "pretty-print JSON")

  "f" '(:ignore t :which-key "find")
  "ff" '(project-find-file :which-key "find files")
  "fg" '(consult-ripgrep :which-key "grep")
  "fb" '(consult-buffer :which-key "buffers")
  "fh" '(describe-symbol :which-key "help")
  "fs" '(my/tokyo-night-pick :which-key "switch tokyo-night style")

  "t" '(:ignore t :which-key "tabs / toggles")
  "tt" '(treemacs :which-key "toggle file tree")
  "tl" '(display-line-numbers-mode :which-key "toggle line numbers")
  "ti" '(my/parinfer-toggle :which-key "toggle parinfer")
  "`" '(tab-recent :which-key "last tab")
  "0" '(tab-last :which-key "last tab")
  "1" '(tab-bar-select-tab :which-key "tab 1")
  "2" '(tab-bar-select-tab :which-key "tab 2")
  "3" '(tab-bar-select-tab :which-key "tab 3")
  "4" '(tab-bar-select-tab :which-key "tab 4")
  "5" '(tab-bar-select-tab :which-key "tab 5")
  "6" '(tab-bar-select-tab :which-key "tab 6")
  "7" '(tab-bar-select-tab :which-key "tab 7")
  "8" '(tab-bar-select-tab :which-key "tab 8")
  "9" '(tab-bar-select-tab :which-key "tab 9")

  "T" '(:ignore t :which-key "terminal")
  "Tt" '(my/term-tab :which-key "terminal in new tab")
  "Tv" '(my/term-vsplit :which-key "terminal in vertical split")
  "Ts" '(my/term-split :which-key "terminal in horizontal split")
  "Tr" '(my/vterm-rename :which-key "rename terminal (empty = automatic)")

  ">" '(:ignore t :which-key "resize wider")
  ">>" `(,(my/resize-command ?> 1 t) :which-key "wider +5 (>>> +10, >>>> +20)")
  "<" '(:ignore t :which-key "resize narrower")
  "<<" `(,(my/resize-command ?< -1 t) :which-key "narrower -5 (<<< -10, <<<< -20)")
  "," '(:ignore t :which-key "horiz resize")
  ",>>" `(,(my/resize-command ?> 1 nil) :which-key "taller +5 (>>> +10, >>>> +20)")
  ",<<" `(,(my/resize-command ?< -1 nil) :which-key "shorter -5 (<<< -10, <<<< -20)")

  "rt" '(my/retab :which-key "retab")

  "k" '(:ignore t :which-key "case")
  "kr" '(my/case-rotate :which-key "rotate case")
  "ks" '(string-inflection-snake-case :which-key "snake_case")
  "kk" '(string-inflection-kebab-case :which-key "kebab-case")
  "kc" '(string-inflection-lower-camel-case :which-key "camelCase")
  "kp" '(string-inflection-camel-case :which-key "PascalCase")
  "km" '(string-inflection-upcase :which-key "MACRO_CASE")

  "d" '(:ignore t :which-key "lsp / diagnostics")
  "df" '(apheleia-format-buffer :which-key "format buffer")

  "p" '(:ignore t :which-key "packages")
  "pu" '(package-upgrade-all :which-key "upgrade packages")
  "pl" '(list-packages :which-key "list packages")
  "pc" '(package-autoremove :which-key "delete unused packages")

  "G" '(:ignore t :which-key "git")
  "Gt" '(global-diff-hl-mode :which-key "toggle git signs")
  "Gp" '(diff-hl-show-hunk :which-key "preview hunk")
  "Gs" '(diff-hl-stage-current-hunk :which-key "stage hunk")
  "Gr" '(diff-hl-revert-hunk :which-key "reset hunk")
  "Gb" '(my/git-blame-line :which-key "blame line")

  "c" '(:ignore t :which-key "clojure / elixir")
  "e" '(:ignore t :which-key "eval")
  "l" '(:ignore t :which-key "REPL")
  "m" '(:ignore t :which-key "elixir / mix")
  "s" '(:ignore t :which-key "session"))

(general-define-key
 :states '(normal motion)
 :keymaps 'override
 "\\" #'treemacs-find-file
 "]c" #'diff-hl-next-hunk
 "[c" #'diff-hl-previous-hunk)

(provide 'init-keys)
;;; init-keys.el ends here
