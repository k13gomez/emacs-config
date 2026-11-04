;;; init-mouse.el --- Mouse and context menus (mirrors nvim's mouse=a and PopUp menu) -*- lexical-binding: t; -*-

(unless (display-graphic-p)
  (xterm-mouse-mode 1)
  ;; xterm-mouse emits wheel-up/wheel-down, which only mwheel binds, and it isn't preloaded in a tty session.
  (mouse-wheel-mode 1))

(defun my/context-menu-browse-url (menu click)
  "Offer to open the URL under CLICK in the browser, like nvim's PopUp menu."
  (when-let* ((url (thing-at-mouse click 'url)))
    (define-key-after menu [my-browse-url]
      `(menu-item "Open in Web Browser" ,(lambda () (interactive) (browse-url url)))))
  menu)

(add-hook 'context-menu-functions #'my/context-menu-browse-url)
(context-menu-mode 1)

;; TTY menus pick an item on any button release, so the release of the click that opened a menu chose
;; whatever was under the pointer. While a TTY menu is open, Emacs binds `overriding-terminal-local-map'
;; to the menu map and still decodes xterm mouse input in Lisp, so drop the release whose press came
;; before the menu opened, and any middle or right release: only a left click picks, as nvim's PopUp menu.
(defvar my/mouse-down-in-menu nil
  "Whether the last mouse press happened while a TTY menu was open.")

(defun my/xterm-mouse-skip-opening-release (orig &rest args)
  (let* ((in-menu (eq overriding-terminal-local-map tty-menu-navigation-map))
         (queued unread-command-events)
         (keys (apply orig args))
         ;; With `track-mouse' on, as in menus, a drag is queued and a movement event returned instead.
         (pushed (unless (eq unread-command-events queued) (car unread-command-events)))
         (event (or pushed (and (vectorp keys) (> (length keys) 0) (aref keys 0))))
         (mods (and (consp event) (event-modifiers event))))
    (cond ((memq 'down mods)
           (setq my/mouse-down-in-menu in-menu)
           keys)
          ((and in-menu
                (or (memq 'click mods) (memq 'drag mods))
                (pcase (event-basic-type event)
                  ('mouse-1 (not my/mouse-down-in-menu))
                  ((or 'mouse-2 'mouse-3) t)))
           (when pushed (pop unread-command-events))
           (setq my/mouse-down-in-menu t)
           [])
          (t keys))))

(advice-add 'xterm-mouse-translate-1 :around #'my/xterm-mouse-skip-opening-release)

(provide 'init-mouse)
;;; init-mouse.el ends here
