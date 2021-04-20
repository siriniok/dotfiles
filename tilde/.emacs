;; Based on the config provided by https://groups.csail.mit.edu/mac/users/gjs/6.945/dont-panic/

;; Enable MELPA
;; Please, run M-x package-refresh-contents on the first run
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;         MIT-scheme config                        ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This is the place where you have installed scheme. Be sure to set
;; this to an appropriate value!!!
; (setq scheme-root "/usr")
;; Linux
;; (setq scheme-program-name
;;       (concat
;;        scheme-root "/bin/mit-scheme "
;;        "--library " scheme-root "/lib/x86_64-linux-gnu/mit-scheme "
;;        "--band " scheme-root "/lib/x86_64-linux-gnu/mit-scheme/all.com "
;;        "-heap 10000"))

;; macOS
(setq scheme-root "/usr/local/Cellar/mit-scheme/10.1.11")

(setq scheme-program-name
      (concat
        scheme-root "/bin/mit-scheme "
        "--library " scheme-root " "
        "--band " scheme-root "/lib/mit-scheme-x86-64/all.com "
        "-heap 10000"))

;; Use the Edwin-like MIT/Scheme interpreter:
(load "xscheme")

;; enable mouse
(xterm-mouse-mode 1)

;;;; Mouse scrolling in terminal emacs
(unless (display-graphic-p)
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;         General Emacs Apperance                  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(if window-system
    (tool-bar-mode -1))
(if window-system
    (scroll-bar-mode -1))
;; (menu-bar-mode -1)
(column-number-mode 1)
(add-hook 'prog-mode-hook 'linum-mode)
;; (setq inhibit-startup-message 't)

(load-theme 'twilight-bright t)

;;parentheses
(show-paren-mode 1)
(setq show-paren-delay 0)

;;no tabs
(setq-default indent-tabs-mode nil)

;; eldoc mode
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'eldoc-mode)
(add-hook 'ielm-mode-hook 'eldoc-mode)

;;paredit package
(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)

;;auto-complete package
; (ac-config-default)

;; scheme-complete package
(autoload 'scheme-smart-complete "scheme-complete" nil t)

;; Special keys in scheme mode. Use <tab> to indent scheme code to the
;; proper level.
(eval-after-load
 'scheme
 '(define-key scheme-mode-map "\t" 'scheme-complete-or-indent))

(eval-after-load
 'cmuscheme
 '(define-key inferior-scheme-mode-map "\t" 'scheme-complete-or-indent))

(eval-after-load
 'xscheme
 '(define-key scheme-interaction-mode-map "\t" 'scheme-complete-or-indent))

; scheme docs
(autoload 'scheme-get-current-symbol-info "scheme-complete" nil t)
(add-hook 'scheme-mode-hook
  (lambda ()
    (make-local-variable 'eldoc-documentation-function)
    (setq eldoc-documentation-function 'scheme-get-current-symbol-info)
    (eldoc-mode)))
; scheme smart indent
(setq lisp-indent-function 'scheme-smart-indent-function)

;;custom
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (paredit))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;         Miscellaneous Settings                   ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq x-select-enable-clipboard 't)
(setq auto-mode-alist (cons '("README" . text-mode) auto-mode-alist))
;; activate auto-fill-mode for various other modes
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'scheme-mode-hook 'turn-on-auto-fill)
; (defadvice save-buffers-kill-emacs (around no-query-kill-emacs activate)
  ; "Prevent annoying \"Active processes exist\" query when you quit Emacs."
  ; (flet ((process-list ())) ad-do-it))
(setq-default ispell-program-name "aspell")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Patch for xscheme - Fixing evaluate-expression in debugger ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun xscheme-prompt-for-expression-exit ()
  (interactive)
  (let (
	;; In Emacs 21+, during a minibuffer read the minibuffer
	;; contains the prompt as buffer text and that text is
	;; read only.  So we can no longer assume that (point-min)
	;; is where the user-entered text starts and we must avoid
	;; modifying that prompt text.  The value we want instead
	;; of (point-min) is (minibuffer-prompt-end).
	(point-min (if (fboundp 'minibuffer-prompt-end)
		              (minibuffer-prompt-end)
		            (point-min))))
    (if (eq (xscheme-region-expression-p point-min (point-max)) 'one)
        (exit-minibuffer)
      (error "input must be a single, complete expression"))))
