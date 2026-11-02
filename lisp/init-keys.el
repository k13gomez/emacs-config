;;; init-keys.el --- Global leader keys (mirrors config/keymaps.lua) -*- lexical-binding: t; -*-

(use-package uuidgen)
(use-package xml-format)
(use-package string-inflection)

(use-package evil-lion
  :after evil
  :config
  (setq evil-lion-left-align-key (kbd "ga")
        evil-lion-right-align-key (kbd "gA"))
  (evil-lion-mode 1))

(my/leader
  "h" '(dashboard-open :which-key "start screen")

  "b" '(:ignore t :which-key "buffer")
  "bw" '(save-buffer :which-key "write buffer")
  "bq" '(evil-quit :which-key "quit buffer")
  "bW" '(evil-write-all :which-key "write all buffers")
  "bQ" '(evil-quit-all :which-key "quit all")
  "bx" '(evil-save-and-quit :which-key "write all and quit")
  "bX" '(kill-emacs :which-key "quit all, discard")

  "u" '(:ignore t :which-key "insert / utilities")
  "uu" '(uuidgen :which-key "insert UUID")
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
  "ti" '(parinfer-rust-mode :which-key "toggle parinfer")
  "to" '(tab-new :which-key "new tab")
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

  ">" '(enlarge-window-horizontally :which-key "wider")
  "<" '(shrink-window-horizontally :which-key "narrower")
  "," '(:ignore t :which-key "height")
  ",>" '(enlarge-window :which-key "taller")
  ",<" '(shrink-window :which-key "shorter")

  "k" '(:ignore t :which-key "case")
  "kr" '(string-inflection-all-cycle :which-key "rotate case")
  "ks" '(string-inflection-underscore :which-key "snake_case")
  "kk" '(string-inflection-kebab-case :which-key "kebab-case")
  "kc" '(string-inflection-lower-camelcase :which-key "camelCase")
  "kp" '(string-inflection-camelcase :which-key "PascalCase")
  "km" '(string-inflection-upcase :which-key "MACRO_CASE")

  "d" '(:ignore t :which-key "lsp / diagnostics")
  "df" '(apheleia-format-buffer :which-key "format buffer")

  "p" '(:ignore t :which-key "packages")
  "pu" '(package-upgrade-all :which-key "upgrade packages")
  "pl" '(list-packages :which-key "list packages")
  "pc" '(package-autoremove :which-key "delete unused packages")

  "G" '(:ignore t :which-key "git")
  "Gt" '(diff-hl-mode :which-key "toggle git signs")
  "Gp" '(diff-hl-show-hunk :which-key "preview hunk")
  "Gs" '(diff-hl-stage-current-hunk :which-key "stage hunk")
  "Gr" '(diff-hl-revert-hunk :which-key "reset hunk")
  "Gb" '(magit-blame-addition :which-key "blame")

  "c" '(:ignore t :which-key "clojure / elixir")
  "e" '(:ignore t :which-key "eval")
  "l" '(:ignore t :which-key "REPL")
  "m" '(:ignore t :which-key "elixir / mix")
  "s" '(:ignore t :which-key "session")
  "w" '(:ignore t :which-key "s-exp"))

(general-define-key
 :states '(normal motion)
 :keymaps 'override
 "\\" #'treemacs-find-file
 "]c" #'diff-hl-next-hunk
 "[c" #'diff-hl-previous-hunk)

(provide 'init-keys)
;;; init-keys.el ends here
