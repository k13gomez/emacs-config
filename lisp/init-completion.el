;;; init-completion.el --- Finder (telescope) and completion (nvim-cmp) -*- lexical-binding: t; -*-

(use-package vertico
  :config
  (vertico-mode 1)
  (define-key vertico-map (kbd "C-t") #'my/vertico-exit-to-tab)
  (define-key vertico-map (kbd "M-t") #'my/vertico-exit-to-tab))

(defun my/vertico-exit-to-tab ()
  "Accept the current candidate and show its buffer in a new tab, as Telescope's C-t does."
  (interactive)
  ;; The override only applies once the minibuffer has closed, so it works for any picker.
  (other-tab-prefix)
  (vertico-exit))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :config
  (marginalia-mode 1))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode 1)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package consult
  :config
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

;; Keys match the nvim-cmp mappings: C-SPC opens, C-b/C-f scroll the docs, C-e aborts, and RET
;; confirms only an item you selected, else inserts a newline (evil-collection's magic-return, set in init-evil.el).
(use-package corfu
  :config
  (setq corfu-auto t
        corfu-auto-prefix 1
        corfu-auto-delay 0.2
        corfu-cycle t
        corfu-preselect 'prompt
        corfu-popupinfo-delay 0.5)
  (global-corfu-mode 1)
  (corfu-popupinfo-mode 1)
  (define-key corfu-map (kbd "C-b") #'corfu-popupinfo-scroll-down)
  (define-key corfu-map (kbd "C-f") #'corfu-popupinfo-scroll-up)
  (define-key corfu-map (kbd "C-e") #'corfu-quit)
  (with-eval-after-load 'evil
    (evil-define-key 'insert 'global (kbd "C-SPC") #'completion-at-point)))

(use-package cape
  :config
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90))

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(provide 'init-completion)
;;; init-completion.el ends here
