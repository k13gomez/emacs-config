;;; init-git.el --- magit (fugitive) and diff-hl (gitsigns) -*- lexical-binding: t; -*-

(use-package magit)

(use-package diff-hl
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)
  ;; A terminal frame has no fringe, so draw the signs in the margin.
  (unless (display-graphic-p)
    (diff-hl-margin-mode 1))
  (add-hook 'magit-pre-refresh-hook #'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

(provide 'init-git)
;;; init-git.el ends here
