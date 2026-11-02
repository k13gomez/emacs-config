;;; init-ui.el --- Theme, modeline, tab bar and start screen -*- lexical-binding: t; -*-

(defconst my/tokyo-night-variants
  '(tokyo-night tokyo-night-storm tokyo-night-moon tokyo-night-day))

;; *.eld is already gitignored, so the saved choice stays out of the repo.
(defvar my/tokyo-night-file (expand-file-name "tokyo-night.eld" user-emacs-directory))

(defun my/tokyo-night-saved ()
  (let ((theme (ignore-errors
                 (with-temp-buffer
                   (insert-file-contents my/tokyo-night-file)
                   (read (current-buffer))))))
    (if (memq theme my/tokyo-night-variants) theme 'tokyo-night)))

;; Declared special so the let below binds it dynamically, compiled or not.
(defvar consult-themes)

(defun my/tokyo-night-pick ()
  "Pick a Tokyo Night variant with live preview and remember it across restarts."
  (interactive)
  ;; Load consult outside the let, or its defcustom would see only the let binding.
  (require 'consult)
  (let ((consult-themes my/tokyo-night-variants))
    (call-interactively #'consult-theme))
  (let ((theme (car custom-enabled-themes)))
    (when (memq theme my/tokyo-night-variants)
      (with-temp-file my/tokyo-night-file
        (prin1 theme (current-buffer))))))

;; The mode colours of lualine's tokyonight theme. Any other state, including nil in the
;; minibuffer, gets yellow, lualine's command-mode colour.
(defconst my/tokyo-night-state-colors
  '((normal . "tokyo-blue") (motion . "tokyo-blue") (operator . "tokyo-blue")
    (insert . "tokyo-green") (visual . "tokyo-magenta") (replace . "tokyo-red")
    (emacs . "tokyo-teal")))

(defun my/tokyo-night-state-color (state theme)
  (tokyo-night-get-color (alist-get state my/tokyo-night-state-colors "tokyo-yellow") theme))

(defvar my/tokyo-night-tab-state 'unset)

(defun my/tokyo-night-sync-tab ()
  "Fill the active tab with the evil state colour of the selected window, as lualine does."
  (let ((state (bound-and-true-p evil-state))
        (theme (car custom-enabled-themes)))
    (when (and (not (eq state my/tokyo-night-tab-state))
               (memq theme my/tokyo-night-variants))
      (setq my/tokyo-night-tab-state state)
      (set-face-attribute 'tab-bar-tab nil :background (my/tokyo-night-state-color state theme)))))

;; enable-theme rebuilds faces from the theme spec, so this reapplies on every switch,
;; including consult's live preview.
(defun my/tokyo-night-ui-faces (theme)
  "Draw the evil state and the tab bar as the solid blocks of lualine's tokyonight theme."
  (when (memq theme my/tokyo-night-variants)
    (let ((bg-dark (tokyo-night-get-color "tokyo-bg-dark" theme)))
      ;; tokyo-night makes this face inherit mode-line. It comes first in every segment's
      ;; inherit list, so the mode-line background would hide the state colour.
      (set-face-attribute 'doom-modeline nil :inherit 'unspecified)
      (dolist (state '(normal motion operator insert visual replace emacs user))
        (set-face-attribute (intern (format "doom-modeline-evil-%s-state" state)) nil
                            :background (my/tokyo-night-state-color state theme)
                            :foreground bg-dark :weight 'bold))
      (set-face-attribute 'doom-modeline-overwrite nil
                          :background (my/tokyo-night-state-color 'replace theme)
                          :foreground bg-dark :weight 'bold)
      (set-face-attribute 'tab-bar nil
                          :background bg-dark
                          :foreground (tokyo-night-get-color "tokyo-fg-dark" theme))
      (set-face-attribute 'tab-bar-tab nil :foreground bg-dark :weight 'bold :box nil)
      (set-face-attribute 'tab-bar-tab-inactive nil
                          :background bg-dark
                          :foreground (tokyo-night-get-color "tokyo-blue" theme))
      (setq my/tokyo-night-tab-state 'unset)
      (my/tokyo-night-sync-tab))))

(use-package tokyo-night
  :init
  (setq tokyo-night-flat-mode-line t)
  :config
  (load-theme (my/tokyo-night-saved) t))

(use-package nerd-icons)

(use-package doom-modeline
  :init
  (setq doom-modeline-buffer-file-name-style 'truename
        doom-modeline-buffer-encoding t
        doom-modeline-modal t
        ;; Show evil's tag text instead of an icon; the tags below are lualine's mode names.
        doom-modeline-modal-icon nil
        evil-normal-state-tag " NORMAL "
        evil-insert-state-tag " INSERT "
        evil-visual-char-tag " VISUAL "
        evil-visual-line-tag " V-LINE "
        evil-visual-screen-line-tag " V-LINE "
        evil-visual-block-tag " V-BLOCK "
        evil-operator-state-tag " O-PENDING "
        evil-replace-state-tag " REPLACE "
        evil-motion-state-tag " MOTION "
        evil-emacs-state-tag " EMACS ")
  :config
  (doom-modeline-mode 1))

;; The tabline is always shown, with tab numbers for ,1 to ,9.
(use-package tab-bar
  :ensure nil
  :config
  (setq tab-bar-show t
        tab-bar-tab-hints t
        tab-bar-close-button-show nil
        tab-bar-new-button-show nil
        ;; An empty buffer, as :tabnew.
        tab-bar-new-tab-choice (lambda () (generate-new-buffer "untitled")))
  (tab-bar-mode 1))

;; Runs here because the restyle needs the doom-modeline and tab-bar faces defined.
(add-hook 'enable-theme-functions #'my/tokyo-night-ui-faces)
(my/tokyo-night-ui-faces (car custom-enabled-themes))
(add-hook 'post-command-hook #'my/tokyo-night-sync-tab)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(defun my/dashboard-new-buffer ()
  "Open an empty, unnamed buffer, as `e' does on the nvim start screen."
  (interactive)
  (switch-to-buffer (generate-new-buffer "untitled")))

(defun my/dashboard--listed-p (buf)
  "Non-nil if BUF is a user buffer: files, terminals, untitled. Not *special* ones."
  (and (buffer-live-p buf)
       (not (string-match-p "\\`[* ]" (buffer-name buf)))))

(defun my/dashboard-quit ()
  "Leave the dashboard the way `q' leaves the nvim start screen.
Go to the previous user buffer if there is one, else close the window,
then the tab, then Emacs."
  (interactive)
  (let ((alt (other-buffer (current-buffer) t)))
    (cond
     ((my/dashboard--listed-p alt) (switch-to-buffer alt))
     ((when-let* ((buf (seq-find #'my/dashboard--listed-p (buffer-list))))
        (switch-to-buffer buf)))
     ((not (one-window-p)) (delete-window))
     ((> (length (tab-bar-tabs)) 1) (tab-close))
     (t (save-buffers-kill-terminal)))))

;; The dashboard shows emacsium.png as a sixel image in the terminal. The image size comes from the cell size in pixels.
;; Only tmux reports it, so the image needs tmux with sixel support. Other terminals get banner.txt.
(defconst my/banner-png (expand-file-name "emacsium.png" user-emacs-directory))
(defconst my/banner-rows 10)
(defvar my/banner-enabled 'unknown)
(defvar my/banner-cache nil "Alist of (WIDTH HEIGHT BACKGROUND) to sixel data.")
(defvar my/banner-start nil "Marker at the first blank line of the image banner.")
(defvar my/banner-shown nil)
(defvar my/banner-timer nil)

(defun my/banner-tmux (format)
  "Return tmux's value for FORMAT, or nil.
init-options.el clears $TMUX for child processes, so this gives back the original values."
  (let ((process-environment
         (append (seq-filter (lambda (v) (string-match-p "\\`TMUX\\(_PANE\\)?=" v)) initial-environment)
                 process-environment)))
    (with-temp-buffer
      (when (eql 0 (ignore-errors (call-process "tmux" nil t nil "display" "-p" format)))
        (string-trim (buffer-string))))))

(defun my/banner-enabled-p ()
  (when (eq my/banner-enabled 'unknown)
    (setq my/banner-enabled
          (and (not (display-graphic-p))
               (equal (getenv "TERM_PROGRAM") "tmux")
               (executable-find "magick")
               (equal (my/banner-tmux "#{sixel_support}") "1"))))
  my/banner-enabled)

(defun my/dashboard-insert-banner ()
  "Insert blank lines for the sixel image, or else the normal banner."
  (if (not (my/banner-enabled-p))
      (dashboard-insert-banner)
    (goto-char (point-max))
    (insert "\n")
    (setq my/banner-start (point-marker))
    (insert (make-string my/banner-rows ?\n))
    ;; Point in the image rows made hl-line rewrite them. Emacs then scrolled those rows, and tmux removed the image.
    ;; Point may stop only below the image. Sticky ends make the buffer start intangible and the next line tangible.
    (add-text-properties (point-min) (point)
                         '(cursor-intangible t inhibit-isearch t
                           front-sticky (cursor-intangible) rear-nonsticky (cursor-intangible)))))

(defun my/dashboard-skip-banner ()
  "Keep point out of the image rows, and start it below the image."
  (cursor-intangible-mode 1)
  ;; hl-line marks the line before `cursor-intangible-mode' moves point, so mark it again after the move.
  (add-hook 'pre-redisplay-functions #'my/dashboard-rehighlight 90 t)
  (when (and my/banner-start (eq (marker-buffer my/banner-start) (current-buffer)))
    (goto-char (+ my/banner-start my/banner-rows))))

(defun my/dashboard-rehighlight (_window)
  (global-hl-line-highlight))

(defun my/dashboard-initialize-tangible (initialize &rest args)
  "Run INITIALIZE with ARGS while cursor-sensor is off.
It redisplays with point at the buffer start, which is intangible. On a window's first
redisplay that makes `cursor-intangible-mode' signal an error in Emacs 31."
  (let ((cursor-sensor-inhibit t))
    (apply initialize args)))

(defun my/banner-sixel (width height)
  "Return sixel data for the PNG at WIDTH x HEIGHT pixels.
The PNG is flattened onto the theme background, so a style switch with ,fs still matches."
  (let* ((bg (apply #'format "#%02x%02x%02x"
                    (mapcar (lambda (c) (/ c 256)) (color-values (face-background 'default nil t)))))
         (key (list width height bg)))
    (or (alist-get key my/banner-cache nil nil #'equal)
        (setf (alist-get key my/banner-cache nil nil #'equal)
              (with-temp-buffer
                (set-buffer-multibyte nil)
                (let ((coding-system-for-read 'binary))
                  (call-process "magick" nil t nil my/banner-png "-background" bg "-flatten"
                                "-resize" (format "%dx%d" width height) "sixel:-"))
                (buffer-string))))))

(defun my/banner-draw ()
  "Draw the image over the blank banner lines, centered in the dashboard window."
  (when-let* ((win (get-buffer-window dashboard-buffer-name))
              ((eq (marker-buffer my/banner-start) (window-buffer win)))
              (cell (split-string (or (my/banner-tmux "#{client_cell_width} #{client_cell_height}") "")))
              ((= (length cell) 2))
              (height (* my/banner-rows (string-to-number (cadr cell))))
              (cols (ceiling (* 3 height) (string-to-number (car cell))))
              (posn (progn (redisplay t) (posn-at-point my/banner-start win)))
              (edges (window-inside-edges win)))
    ;; Terminal rows and columns count from 1, Emacs ones from 0.
    (send-string-to-terminal
     (concat "\e7"
             (format "\e[%d;%dH"
                     (+ (nth 1 edges) (cdr (posn-col-row posn)) 1)
                     (+ (nth 0 edges) (max 0 (/ (- (window-body-width win) cols) 2)) 1))
             (my/banner-sixel (* 3 height) height)
             "\e8"))
    (setq my/banner-shown t)))

(defun my/banner-update (&rest _)
  "Clear the old image and draw it again while the dashboard is visible.
`redraw-frame' clears the screen, and tmux drops the image with it."
  (when (and (my/banner-enabled-p)
             (or my/banner-shown (get-buffer-window dashboard-buffer-name)))
    (when my/banner-shown
      (redraw-frame)
      (setq my/banner-shown nil))
    ;; Both window hooks run at startup. Two draws stacked two images, and the image blinked.
    (when (timerp my/banner-timer) (cancel-timer my/banner-timer))
    (setq my/banner-timer (run-at-time 0 nil #'my/banner-draw))))

(use-package dashboard
  :config
  (setq dashboard-items '((recents . 10) (projects . 5))
        dashboard-projects-backend 'project-el
        dashboard-icon-type 'nerd-icons
        dashboard-set-file-icons t
        ;; A GUI frame shows the PNG itself. In a terminal, `my/dashboard-insert-banner' decides.
        dashboard-startup-banner (cons my/banner-png (expand-file-name "banner.txt" user-emacs-directory))
        dashboard-navigator-buttons
        `(((nil "Empty buffer" "" ,(lambda (&rest _) (my/dashboard-new-buffer)) nil "(e) " "   ")
           (nil "Quit" "" ,(lambda (&rest _) (my/dashboard-quit)) nil "(q) " "")))
        ;; Worded and placed as the startify header's load-time line.
        dashboard-init-info
        (lambda ()
          (format "Emacs loaded %d packages in %.2f ms"
                  (length package-activated-list)
                  (* 1000 (float-time (time-subtract after-init-time before-init-time)))))
        dashboard-startupify-list
        '(my/dashboard-insert-banner
          dashboard-insert-newline
          dashboard-insert-init-info
          dashboard-insert-newline
          dashboard-insert-newline
          dashboard-insert-navigator
          dashboard-insert-newline
          dashboard-insert-items))
  ;; Bound in dashboard's own map: evil-collection copies its `e' into the evil map on every redraw.
  (keymap-set dashboard-mode-map "e" #'my/dashboard-new-buffer)
  (evil-define-key 'normal dashboard-mode-map "q" #'my/dashboard-quit)
  ;; `dashboard-initialize' moves point back to the buffer start after the mode hook runs.
  (add-hook 'dashboard-mode-hook #'my/dashboard-skip-banner)
  (add-hook 'dashboard-after-initialize-hook #'my/dashboard-skip-banner)
  (advice-add 'dashboard-initialize :around #'my/dashboard-initialize-tangible)
  (add-hook 'window-buffer-change-functions #'my/banner-update)
  (add-hook 'window-size-change-functions #'my/banner-update)
  (dashboard-setup-startup-hook))

(provide 'init-ui)
;;; init-ui.el ends here
