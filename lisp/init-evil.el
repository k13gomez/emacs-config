;;; init-evil.el --- Vim keys, leader and which-key -*- lexical-binding: t; -*-

(use-package evil
  :init
  ;; evil-collection sets the keys for other modes, so evil must not do it too.
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-undo-system 'undo-redo
        evil-search-module 'evil-search
        evil-ex-search-case 'smart
        evil-vsplit-window-right t
        evil-split-window-below t
        evil-shift-width 4)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
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
