;;; init-ui.el --- Theme, modeline, tab bar and start screen -*- lexical-binding: t; -*-

(defconst my/tokyo-night-variants
  '(tokyo-night tokyo-night-storm tokyo-night-moon tokyo-night-day))

;; Holds one word (night, storm, moon or day). Neovim, tmux (~/.byobu/tokyonight.tmux) and
;; WezTerm read the same file, so a switch in any editor reaches all of them.
(defvar my/tokyo-night-file (expand-file-name "~/.local/state/tokyonight/style"))

(defun my/tokyo-night-read ()
  "The theme named in `my/tokyo-night-file', or nil if it names none."
  (let* ((style (ignore-errors
                  (with-temp-buffer
                    (insert-file-contents my/tokyo-night-file)
                    (string-trim (buffer-string)))))
         (theme (cond ((equal style "night") 'tokyo-night)
                      (style (intern-soft (concat "tokyo-night-" style))))))
    (and (memq theme my/tokyo-night-variants) theme)))

(defun my/tokyo-night-saved ()
  (or (my/tokyo-night-read) 'tokyo-night))

(defun my/tokyo-night-save (theme)
  (make-directory (file-name-directory my/tokyo-night-file) t)
  (with-temp-file my/tokyo-night-file
    (insert (if (eq theme 'tokyo-night)
                "night"
              (substring (symbol-name theme) (length "tokyo-night-")))
            "\n"))
  (when-let* ((tmux (executable-find "tmux")))
    (call-process tmux nil 0 nil "source-file" "-q" (expand-file-name "~/.byobu/tokyonight.tmux"))))

(defun my/tokyo-night-follow ()
  "Switch theme whenever another editor rewrites `my/tokyo-night-file'."
  (unless (file-exists-p my/tokyo-night-file)
    (my/tokyo-night-save (my/tokyo-night-saved)))
  (file-notify-add-watch
   my/tokyo-night-file '(change)
   (lambda (_event)
     ;; A writer truncates before writing, so an event can see an empty file; skip those.
     (let ((theme (my/tokyo-night-read)))
       (when (and theme (not (eq theme (car custom-enabled-themes))))
         (mapc #'disable-theme custom-enabled-themes)
         (load-theme theme t))))))

(declare-function consult--read "consult")

(defun my/tokyo-night-pick ()
  "Pick a Tokyo Night variant with live preview and remember it across restarts."
  (interactive)
  (require 'consult)
  ;; consult-theme always adds a "default" entry (no theme), which also removes the banner.
  ;; So this calls consult--read with only the four themes.
  (let ((saved (car custom-enabled-themes))
        (names (mapcar #'symbol-name my/tokyo-night-variants)))
    (consult--read names
                   :prompt "Theme: "
                   :require-match t
                   :category 'theme
                   ;; Text that matches no theme gives nil, so the preview leaves the theme alone.
                   :lookup (lambda (selected &rest _) (intern-soft (car (member selected names))))
                   :state (lambda (action theme)
                            (with-selected-window (or (active-minibuffer-window) (selected-window))
                              (pcase action
                                ('return (consult-theme (or theme saved)))
                                ((and 'preview (guard theme)) (consult-theme theme)))))
                   :default (and saved (symbol-name saved))))
  (let ((theme (car custom-enabled-themes)))
    (when (memq theme my/tokyo-night-variants)
      (my/tokyo-night-save theme))))

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
  (load-theme (my/tokyo-night-saved) t)
  (my/tokyo-night-follow))

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

(defun my/dashboard-open-tab ()
  "Show the dashboard without replacing the current buffer, as ,w does in nvim.
Go to the window or tab that already shows it, else open it in a new tab."
  (interactive)
  (unless (derived-mode-p 'dashboard-mode)
    (if-let* ((tab (tab-bar-get-buffer-tab dashboard-buffer-name)))
        (progn (tab-bar-select-tab (1+ (alist-get 'index tab)))
               (select-window (get-buffer-window dashboard-buffer-name)))
      ;; t keeps the current buffer, so the new tab does not leave an "untitled" buffer behind.
      (let ((tab-bar-new-tab-choice t)) (tab-new))
      (set-window-parameter nil 'my/dashboard-tab t)
      (dashboard-open))))

(defun my/dashboard-quit ()
  "Leave the dashboard the way `q' leaves the nvim start screen.
In a tab opened by `my/dashboard-open-tab', close the tab. Otherwise go to the
previous user buffer if there is one, else close the window, then the tab, then Emacs."
  (interactive)
  (let ((alt (other-buffer (current-buffer) t)))
    (cond
     ((and (window-parameter nil 'my/dashboard-tab) (one-window-p) (cdr (tab-bar-tabs)))
      (tab-close))
     ((my/dashboard--listed-p alt) (switch-to-buffer alt))
     ((when-let* ((buf (seq-find #'my/dashboard--listed-p (buffer-list))))
        (switch-to-buffer buf)))
     ((not (one-window-p)) (delete-window))
     ((> (length (tab-bar-tabs)) 1) (tab-close))
     (t (save-buffers-kill-terminal)))))

;; The dashboard shows a sixel image in the terminal. sixels/ keeps one file for each theme and cell size.
;; A missing file is rendered with ImageMagick, and later starts use it again. git ignores sixels/.
;; The layout needs the cell size in pixels. Only tmux reports it, so the image needs tmux and a terminal with sixel.
;; Other terminals get banner.txt.
(defconst my/banner-png (expand-file-name "emacsium.png" user-emacs-directory))
;; The image size in pixels. Each file is padded around it to fill whole cells.
(defconst my/banner-width 930)
(defconst my/banner-height 310)
(defvar my/banner-rows nil)
(defvar my/banner-cell-width nil)
(defvar my/banner-cell-height nil)
(defvar my/banner-enabled 'unknown)
(defvar my/banner-cache nil "Alist of sixel file name to sixel data.")
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
  "Non-nil if the terminal can show the image.
sixel_support is true when tmux is built with sixel. client_termfeatures lists sixel only if the terminal has it."
  (when (eq my/banner-enabled 'unknown)
    (setq my/banner-enabled nil)
    (when-let* (((not (display-graphic-p)))
                ((equal (getenv "TERM_PROGRAM") "tmux"))
                (info (split-string
                       (or (my/banner-tmux
                            "#{sixel_support} #{client_termfeatures} #{client_cell_width} #{client_cell_height}")
                           "")))
                ((= (length info) 4))
                ((equal (nth 0 info) "1"))
                ((member "sixel" (split-string (nth 1 info) ","))))
      (setq my/banner-cell-width (string-to-number (nth 2 info))
            my/banner-cell-height (string-to-number (nth 3 info))
            my/banner-rows (ceiling my/banner-height my/banner-cell-height)
            my/banner-enabled (not (string-empty-p (my/banner-sixel))))))
  my/banner-enabled)

(defun my/dashboard-insert-banner ()
  "Insert blank lines for the sixel image, or else the normal banner."
  (if (not (my/banner-enabled-p))
      ;; Dashboard's (image . text) banner fails in a terminal. It swaps in its own PNG and then cannot show it.
      (let ((dashboard-startup-banner (if (display-graphic-p) my/banner-png dashboard-startup-banner)))
        (dashboard-insert-banner))
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

(defun my/banner-read (file)
  "Return the bytes of FILE, or nil if it cannot be read."
  (when (file-readable-p file)
    (with-temp-buffer
      (set-buffer-multibyte nil)
      (insert-file-contents-literally file)
      (buffer-string))))

(defun my/banner-render (file width height)
  "Render the PNG as sixel into FILE, WIDTH x HEIGHT pixels, and return its bytes.
tmux clears the image's cells to the terminal's default background, which is black.
The theme background fills the cells around the image, or a black band shows."
  (when-let* ((bg (face-background 'default nil t))
              ((color-defined-p bg))
              ((executable-find "magick")))
    (make-directory (file-name-directory file) t)
    (when (eql 0 (call-process "magick" nil nil nil my/banner-png
                               "-background" (apply #'format "#%02x%02x%02x"
                                                    (mapcar (lambda (c) (/ c 256)) (color-values bg)))
                               "-flatten" "-resize" (format "%dx%d" my/banner-width my/banner-height)
                               "-gravity" "center" "-extent" (format "%dx%d" width height)
                               (concat "sixel:" file)))
      (my/banner-read file))))

(defun my/banner-sixel ()
  "Return the sixel data for the active theme, or an empty string.
The file name carries the padded size, so a font change gets its own file and old files stay as they are.
A file whose header shows another size, such as an empty one left by a failed render, is rendered again."
  (let ((theme (car custom-enabled-themes)))
    (if (not (and theme my/banner-cell-width))
        ""
      (let* ((width (* (ceiling my/banner-width my/banner-cell-width) my/banner-cell-width))
             (height (* my/banner-rows my/banner-cell-height))
             (file (expand-file-name (format "sixels/%s-%dx%d.sixel" theme width height)
                                     user-emacs-directory)))
        (or (alist-get file my/banner-cache nil nil #'equal)
            (let ((data (my/banner-read file)))
              (unless (and data
                           (string-match "\\`\eP[^q]*q\"1;1;\\([0-9]+\\);\\([0-9]+\\)" data)
                           (= (string-to-number (match-string 1 data)) width)
                           (= (string-to-number (match-string 2 data)) height))
                (setq data (my/banner-render file width height)))
              (setf (alist-get file my/banner-cache nil nil #'equal) (or data ""))))))))

(defun my/banner-draw ()
  "Draw the image over the blank banner lines, centered in the dashboard window."
  (when-let* ((win (get-buffer-window dashboard-buffer-name))
              ((eq (marker-buffer my/banner-start) (window-buffer win)))
              (data (my/banner-sixel))
              ((not (string-empty-p data)))
              (cols (ceiling my/banner-width my/banner-cell-width))
              (posn (progn (redisplay t) (posn-at-point my/banner-start win)))
              (edges (window-inside-edges win)))
    ;; Terminal rows and columns count from 1, Emacs ones from 0.
    (send-string-to-terminal
     (concat "\e7"
             (format "\e[%d;%dH"
                     (+ (nth 1 edges) (cdr (posn-col-row posn)) 1)
                     (+ (nth 0 edges) (max 0 (/ (- (window-body-width win) cols) 2)) 1))
             data
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
  (setq dashboard-buffer-name "*welcome*"
        dashboard-items '((recents . 10) (projects . 5))
        dashboard-projects-backend 'project-el
        dashboard-icon-type 'nerd-icons
        dashboard-set-file-icons t
        dashboard-startup-banner (expand-file-name "banner.txt" user-emacs-directory)
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
  ;; A style switch with ,fs needs the file for the new style.
  (add-hook 'enable-theme-functions #'my/banner-update)
  (add-hook 'window-size-change-functions #'my/banner-update)
  (dashboard-setup-startup-hook))

(provide 'init-ui)
;;; init-ui.el ends here
