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
  (evil-define-key '(normal visual) 'global "gc" #'my/evil-comment)
  ;; Remapped rather than bound to DEL, so modes with their own Backspace (vterm) keep it.
  (define-key evil-insert-state-map [remap delete-backward-char] #'my/evil-delete-backward-softtab)
  (define-key evil-insert-state-map [remap backward-delete-char-untabify] #'my/evil-delete-backward-softtab))

(defun my/evil-delete-backward-softtab ()
  "Delete spaces back to the previous indent stop, as nvim's 'softtabstop'.
The stop is `evil-shift-width', which the mode hooks set per language."
  (interactive)
  (let* ((col (current-column))
         (spaces (- col (save-excursion
                          (skip-chars-backward " " (line-beginning-position))
                          (current-column))))
         (n (min spaces (- col (* (/ (max 0 (1- col)) evil-shift-width) evil-shift-width)))))
    (if (and (> n 1) (not (use-region-p)))
        (delete-char (- n))
      (call-interactively #'evil-delete-backward-char-and-join))))

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
  ;; The docstring warns that 0 can cause issues (emacs-which-key#134). 0.01 looks the same.
  (setq which-key-idle-delay 0.01)
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
