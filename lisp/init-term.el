;;; init-term.el --- Terminal buffers that stand in for tmux (mirrors the nvim terminal setup) -*- lexical-binding: t; -*-

(defvar-local my/vterm-title nil
  "Last title the shell set. It is the buffer name unless `my/vterm-name' is set.")

(defvar-local my/vterm-name nil
  "Name given with `my/vterm-rename'. It wins over the shell's title.")

(defun my/vterm--set-title (title)
  "Name the buffer after TITLE, which the zsh title hooks send as \"dir|cmd\"."
  (setq my/vterm-title title)
  (unless (or my/vterm-name (string-empty-p title))
    (rename-buffer title t)))

(defun my/vterm-rename (name)
  "Name this terminal NAME. An empty NAME goes back to the shell's title."
  (interactive
   (progn
     (unless (derived-mode-p 'vterm-mode)
       (user-error "Not a terminal buffer"))
     (list (read-string "Terminal name: " my/vterm-name))))
  (setq my/vterm-name (unless (string-empty-p name) name))
  (rename-buffer (or my/vterm-name my/vterm-title (buffer-name)) t))

(defun my/vterm--root ()
  (if-let* ((project (project-current)))
      (project-root project)
    default-directory))

(defun my/vterm-new ()
  "Open a new terminal in the selected window, at the project root."
  (let ((default-directory (my/vterm--root)))
    (vterm t)))

(defun my/term-tab ()
  "Open a terminal in a new tab."
  (interactive)
  (tab-new)
  (my/vterm-new))

(defun my/term-vsplit ()
  "Open a terminal in a split to the right."
  (interactive)
  (select-window (split-window-right))
  (my/vterm-new))

(defun my/term-split ()
  "Open a terminal in a split below."
  (interactive)
  (select-window (split-window-below))
  (my/vterm-new))

(defun my/vterm-close (&optional buf)
  "Kill terminal BUF and close its windows, and its tab if nothing else is in it."
  (interactive)
  (let ((buf (or buf (current-buffer))))
    (dolist (win (get-buffer-window-list buf nil t))
      (cond ((not (eq win (frame-root-window win)))
             (delete-window win))
            ((cdr (tab-bar-tabs (window-frame win)))
             (with-selected-frame (window-frame win)
               (tab-close)))))
    (kill-buffer buf)))

;; As in nvim: a clean exit closes the terminal, a failed one stays readable with `q' to close.
(defun my/vterm--on-exit (buf event)
  (when buf
    (if (string= event "finished\n")
        (my/vterm-close buf)
      (with-current-buffer buf
        (evil-normal-state)
        (evil-local-set-key 'normal "q" #'my/vterm-close)))))

(defun my/vterm--enter-live-shell (&optional _frame)
  "Resume typing when a live terminal gets the focus, like switching tmux panes."
  (with-current-buffer (window-buffer (selected-window))
    (when (and (derived-mode-p 'vterm-mode)
               (process-live-p vterm--process))
      (evil-insert-state))))

(defun my/vterm-send-next-key ()
  "After C-v, send Esc to the shell. Any other key goes through as C-v and that key."
  (interactive)
  (let ((key (read-key)))
    (if (memq key '(?\e escape))
        (vterm-send-escape)
      (vterm-send-key "v" nil nil t)
      (push key unread-command-events))))

;; Must be on the hook before vterm loads, and runs after evil-collection's own vterm keys.
(add-hook 'evil-collection-setup-hook
          (lambda (mode &rest _)
            (when (eq mode 'vterm)
              (evil-collection-define-key 'insert 'vterm-mode-map
                (kbd "C-w") evil-window-map
                (kbd "C-v") #'my/vterm-send-next-key))))

(use-package vterm
  :defer t
  :init
  (setq vterm-always-compile-module t)
  :config
  ;; Both are handled above: titles by `my/vterm--set-title', exits by `my/vterm--on-exit'.
  (setq vterm-buffer-name-string nil
        vterm-kill-buffer-on-exit nil
        vterm-max-scrollback 10000)
  ;; This vterm has no hook for title changes, only this function.
  (advice-add 'vterm--set-title :override #'my/vterm--set-title)
  (add-hook 'vterm-exit-functions #'my/vterm--on-exit)
  (add-hook 'vterm-mode-hook (lambda () (display-line-numbers-mode -1)))
  (add-hook 'window-selection-change-functions #'my/vterm--enter-live-shell)
  (add-hook 'window-buffer-change-functions #'my/vterm--enter-live-shell))

(provide 'init-term)
;;; init-term.el ends here
