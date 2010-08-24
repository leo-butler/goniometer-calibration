;; -*- mode: emacs-lisp -*-
(defcustom emacs-latex-make-binary "make"
  "Name of MAKE binary."
  :type 'string
  :group 'emacs-latex)
(defcustom emacs-latex-shell-output-buffer ""
  "Name of output buffer for `shell-command'."
  :type 'string
  :group 'emacs-latex)

(setq TeX-region (substring (buffer-name) 0 -4))

(defmacro emacs-latex-make (target)
  (let ((fn (intern (concat "emacs-latex-make-" target))))
    `(defun ,fn (&optional arg)
       ""
       (interactive "P")
       (let* ((target (if (null arg)
			  ,target
			(concat (read-from-minibuffer "Make command options? ") " " ,target)))
	      (output-buffer (if (and emacs-latex-shell-output-buffer
				      (not (string= "" emacs-latex-shell-output-buffer)))
				 emacs-latex-shell-output-buffer
			       (concat "*" (substring (buffer-name) 0 -4) "-output*")))
	      (error-buffer (concat (substring output-buffer 0 -1) "-errors*"))
	      (SRC (concat " SRC=" (substring (buffer-name) 0 -4)))
	      (shell-cmd (concat emacs-latex-make-binary SRC " " target)))
	 (message shell-cmd)
	 (shell-command shell-cmd output-buffer error-buffer)
	 (message (concat shell-cmd "  -> Done."))
	 ))))

(defvar emacs-goniometer-calibration-shell "*goniometer-calibration*")
(defun emacs-goniometer-calibration-shell ()
  (interactive)
  (shell emacs-goniometer-calibration-shell))
(fset 'emacs-goniometer-calibration-widen
   "\C-u1000\C-xf")
(fset 'emacs-goniometer-calibration-narrow
   "\C-u70\C-xf")

(emacs-latex-make "bbl")
(emacs-latex-make "dvi")
(emacs-latex-make "pdf")
(emacs-latex-make "clean")
(defcustom goniometer-calibration-minor-mode nil
  ""
  :type 'boolean
  :group 'emacs-latex)
(define-minor-mode goniometer-calibration-minor-mode
  "Minor mode primarily to make key-bindings buffer local."
  ;; start mode
  :init-value t
  ;; mode line indicator
  :lighter " GC"
  ;; global ?
  :global nil
  ;; keybindings
  :keymap
  '(("\C-cb" . emacs-latex-make-bbl)
    ("\C-cd" . emacs-latex-make-dvi)
    ("\C-cp" . emacs-latex-make-pdf)
    ("\C-cc" . emacs-latex-make-clean)
    ("\C-cs" . emacs-goniometer-calibration-shell)
    ("\C-cn" . emacs-goniometer-calibration-narrow)
    ("\C-cw" . emacs-goniometer-calibration-widen)))
  

(define-abbrev-table 'latex-mode-abbrev-table '(
    ("aa" "\\alpha" nil 0)
    ("bb" "\\beta" nil 0)
    ("cc" "\\gamma" nil 0)
    ("dd" "\\delta" nil 0)
    ("eps" "\\epsilon" nil 0)
    ("ph" "\\phi" nil 0)
    ("io" "\\iota" nil 0)
    ("vph" "\\varphi" nil 0)
    ("ka" "\\kappa" nil 0)
    ("lm" "\\lambda" nil 0)
    ("ps" "\\psi" nil 0)
    ("th" "\\theta" nil 0)
    ("rh" "\\rho" nil 0)
    ("ss" "\\sigma" nil 0)
    ("ta" "\\tau" nil 0)
    ("zz" "\\zeta" nil 0)
    ("om" "\\omega" nil 0)
    ("hra" "\\hookrightarrow" nil 0)
    ("lra" "\\leftrightarrow" nil 0)
    ("lr" "\\left  \\right" nil 0)
    ("1o2" "\\frac{1}{2}" nil 0)
    ("na" "\\nabla" nil 0)
    ("ii" "\\item" nil 0)
    ("pa" "\\partial" nil 0)
    ("ija" "\\ar@{^{(}->}[r]^{}" nil 0)
    ("sja" "\\ar@{->>}[r]^{}" nil 0)
    ("bf" "\\mathbf{" nil 0)
    ))

;; end of customisation.el
