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

;; neo-tree marks files that have LSP diagnostics. treemacs only knows lsp-mode, so feed it what
;; eglot receives. A folder shows the worst mark of anything below it.
(defvar my/treemacs-diagnostics (make-hash-table :test 'equal)
  "Truename of each file with diagnostics -> (WORST-SEVERITY . SERVER).")

(defconst my/treemacs-diagnostic-signs
  '((1 "" error) (2 "" warning) (3 "" success) (4 "" shadow))
  "LSP severity -> sign and face, the same signs as nvim's.")

(defun my/treemacs-worst-diagnostic (path)
  (let ((prefix (file-name-as-directory path))
        worst)
    (maphash (lambda (file entry)
               (when (or (string= file path) (string-prefix-p prefix file))
                 (setq worst (min (car entry) (or worst 4)))))
             my/treemacs-diagnostics)
    worst))

(defun my/treemacs-diagnostics-refresh (file server)
  "Update the marks on FILE and the folders above it, up to SERVER's project root."
  (when (featurep 'treemacs-annotations)
    (let ((root (directory-file-name (file-truename (project-root (eglot--project server)))))
          (path file))
      (while path
        (if-let* ((sign (alist-get (my/treemacs-worst-diagnostic path) my/treemacs-diagnostic-signs)))
            (treemacs-set-annotation-suffix
             path (propertize (concat " " (car sign)) 'face (cadr sign)) "diagnostics")
          (treemacs-remove-annotation-suffix path "diagnostics"))
        ;; Errors when the tree shows another project, which has no node for PATH.
        (ignore-errors (treemacs-apply-single-annotation path))
        (setq path (unless (string= path root)
                     (directory-file-name (file-name-directory path))))
        (when (and path (not (string-prefix-p root path)))
          (setq path nil))))))

(defun my/treemacs-diagnostics-forget-server (server)
  (let (files)
    (maphash (lambda (file entry) (when (eq (cdr entry) server) (push file files)))
             my/treemacs-diagnostics)
    (dolist (file files)
      (remhash file my/treemacs-diagnostics)
      (my/treemacs-diagnostics-refresh file server))))

(with-eval-after-load 'eglot
  ;; :after leaves eglot's own Flymake handling of the notification untouched.
  (cl-defmethod eglot-handle-notification :after
    (server (_method (eql textDocument/publishDiagnostics)) &key uri diagnostics &allow-other-keys)
    (let ((file (file-truename (eglot-uri-to-path uri))))
      (if (seq-empty-p diagnostics)
          (remhash file my/treemacs-diagnostics)
        (puthash file
                 (cons (seq-min (seq-map (lambda (d) (or (plist-get d :severity) 1)) diagnostics))
                       server)
                 my/treemacs-diagnostics))
      (my/treemacs-diagnostics-refresh file server)))
  (advice-add 'eglot--on-shutdown :after #'my/treemacs-diagnostics-forget-server))

;; Diagnostics that arrived before the tree was first opened.
(with-eval-after-load 'treemacs-annotations
  (maphash (lambda (file entry) (my/treemacs-diagnostics-refresh file (cdr entry)))
           my/treemacs-diagnostics))

(defun my/treemacs-reapply-annotation (path)
  (ignore-errors (treemacs-apply-single-annotation path)))

(with-eval-after-load 'treemacs-rendering
  ;; Collapsing a folder leaves its last child's suffix on the folder's line, and a new root node
  ;; is drawn without its annotation. Redraw the node in both cases.
  (dolist (fn '(treemacs--collapse-dir-node treemacs--collapse-root-node))
    (advice-add fn :after (lambda (btn &rest _)
                            (my/treemacs-reapply-annotation (treemacs-button-get btn :path)))))
  (advice-add 'treemacs--add-root-element :after
              (lambda (project) (my/treemacs-reapply-annotation (treemacs-project->path project)))))

(provide 'init-files)
;;; init-files.el ends here
