;;; early-init.el --- Runs before the package system and the first frame -*- lexical-binding: t; -*-

;; A high GC threshold makes startup faster. init.el sets a normal value at the end.
(setq gc-cons-threshold most-positive-fixnum)

;; init.el starts package.el itself, after it sets the archives.
(setq package-enable-at-startup nil)

(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;;; early-init.el ends here
