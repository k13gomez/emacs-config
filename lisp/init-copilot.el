;;; init-copilot.el --- GitHub Copilot (copilot.vim) -*- lexical-binding: t; -*-

;; Run M-x copilot-install-server and M-x copilot-login once.
(use-package copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("TAB" . copilot-accept-completion)
              ("<tab>" . copilot-accept-completion)))

(provide 'init-copilot)
;;; init-copilot.el ends here
