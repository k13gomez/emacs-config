;;; init-evil.el --- Vim keys, leader and which-key -*- lexical-binding: t; -*-

(use-package evil
  :init
  ;; evil-collection sets the keys for other modes, so evil must not do it too.
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-u-delete t
        evil-want-Y-yank-to-eol t
        evil-undo-system 'undo-redo
        evil-search-module 'evil-search
        evil-ex-search-case 'smart
        evil-vsplit-window-right t
        evil-split-window-below t
        evil-shift-width 4)
  :config
  (evil-mode 1)
  ;; nvim's built-in gc/gcc commenting.
  (evil-define-operator my/evil-comment (beg end)
    "Comment or uncomment the lines from BEG to END."
    (comment-or-uncomment-region beg end))
  (evil-define-key '(normal visual) 'global "gc" #'my/evil-comment))

(use-package evil-collection
  :after evil
  :init
  ;; RET with no candidate selected inserts a newline, as nvim-cmp's confirm({ select = false }).
  (setq evil-collection-corfu-key-themes '(default magic-return))
  :config
  (evil-collection-init))

;; Persistent undo, as 'undofile' in nvim.
(use-package undo-fu-session
  :config
  (undo-fu-session-global-mode 1))

;; Change the cursor shape between normal and insert state in the terminal.
(use-package evil-terminal-cursor-changer
  :unless (display-graphic-p)
  :config
  (evil-terminal-cursor-changer-activate))

(use-package which-key
  :ensure nil
  :config
  (setq which-key-idle-delay 0.3)
  (which-key-mode 1))

(use-package general
  :config
  (general-evil-setup)
  ;; `,` is both leader and localleader, as in nvim.
  ;; treemacs-evil uses its own `treemacs' state, so the leader must cover it too.
  (general-create-definer my/leader
    :states '(normal visual motion treemacs)
    :keymaps 'override
    :prefix ","))

(provide 'init-evil)
;;; init-evil.el ends here
