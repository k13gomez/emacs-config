;;; init.el --- Emacs config that mirrors ~/.config/nvim -*- lexical-binding: t; -*-

(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t)

;; Keep the settings that the Customize UI writes out of this file.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'init-options)
(require 'init-evil)
(require 'init-ui)
(require 'init-completion)
(require 'init-treesit)
(require 'init-lsp)
(require 'init-files)
(require 'init-git)
(require 'init-clojure)
(require 'init-elixir)
(require 'init-keys)
(require 'init-copilot)

(setq gc-cons-threshold (* 64 1024 1024))

;;; init.el ends here
