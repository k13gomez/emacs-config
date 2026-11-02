;;; init-copilot.el --- GitHub Copilot (copilot.vim) -*- lexical-binding: t; -*-

;; Run M-x copilot-install-server and M-x copilot-login once.
;; The keys are copilot.vim's defaults.
(use-package copilot
  :hook (prog-mode . copilot-mode)
  :bind ((:map copilot-mode-map
               ("M-\\" . copilot-complete))
         (:map copilot-completion-map
               ("TAB" . copilot-accept-completion)
               ("<tab>" . copilot-accept-completion)
               ("M-]" . copilot-next-completion)
               ("M-[" . copilot-previous-completion)
               ("M-<right>" . copilot-accept-completion-by-word)
               ("C-M-<right>" . copilot-accept-completion-by-line)
               ("C-]" . copilot-clear-overlay))))

(setq copilot-indent-offset-warning-disable t)

(provide 'init-copilot)
;;; init-copilot.el ends here
