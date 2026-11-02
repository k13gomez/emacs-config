;;; init-files.el --- File tree on the right (neo-tree) -*- lexical-binding: t; -*-

(use-package treemacs
  :defer t
  :config
  ;; No saved state: nothing visits the persist file, so `:qa' never asks about it, and sessions don't share it.
  (advice-add 'treemacs--persist :override #'ignore)
  (advice-add 'treemacs--restore :override #'ignore)
  ;; An empty workspace would ask for a project root; take the project of the window treemacs opened from.
  (advice-add 'treemacs--read-first-project-path :override #'my/treemacs-first-project)
  (setq treemacs-position 'right
        treemacs-width 40
        treemacs-show-hidden-files nil
        ;; The first project is expanded when it's added; this would toggle it closed again.
        treemacs-expand-after-init nil)
  (treemacs-follow-mode 1)
  ;; The root follows the current buffer's project. neo-tree's root stays at the cwd; this differs on purpose.
  (treemacs-project-follow-mode 1)
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'simple)
  ;; neo-tree hides gitignored files (_build, deps, target, ...) as well as dotfiles.
  (treemacs-hide-gitignored-files-mode 1))

(defun my/treemacs-first-project ()
  (with-current-buffer (window-buffer (get-mru-window nil nil t))
    (file-truename (or (treemacs--find-current-user-project) default-directory))))

(defun my/treemacs-open-in-tab ()
  "Open the file at point in a new tab."
  (interactive)
  (let ((path (when-let* ((btn (treemacs-current-button))) (treemacs-button-get btn :path))))
    (unless (and (stringp path) (file-regular-p path))
      (user-error "Not a file"))
    (find-file-other-tab path)))

(use-package treemacs-evil
  :after (treemacs evil)
  :config
  ;; As in nvim's tree. This replaces treemacs-evil's `t' prefix of toggles (th, tf, ...),
  ;; and its `H' (collapse parent) with neo-tree's hidden-file toggle.
  (define-key evil-treemacs-state-map (kbd "t") #'my/treemacs-open-in-tab)
  (define-key evil-treemacs-state-map (kbd "H") #'treemacs-toggle-show-dotfiles))

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

(provide 'init-files)
;;; init-files.el ends here
