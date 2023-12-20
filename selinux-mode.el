(eval-when-compile
(require 'rx))

(defun selinux-indent-line ()
  "Indent current line"
  (let (indent
	current-line
	closing-bracket
	(point (point)))
    (save-excursion
      ;; TODO: Decide on a sensible way to indent file context lines      
      
      ;; Go to the beginning of the line
      (beginning-of-line)

      ;; Start by assuming that we are indenting according to the
      ;; number of parentheses we are inside
      (setq indent (car (syntax-ppss)))

      ;; Check if the line we are indenting is closing a
      ;; parentheses. If so we want to indent it one less than the
      ;; body of that block.
      (setq current-line (buffer-substring (line-beginning-position)
					   (line-end-position)))      
      (setq closing-bracket (memq ?' (string-to-list current-line)))      
      (if closing-bracket (setq indent (1- indent)))

      ;; Indent the line 4 spaces
      (indent-line-to (* 4 indent)))))

;; Define the syntax table
(defvar selinux-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?# "<\n" table)
    (modify-syntax-entry ?\n ">#" table)
    (modify-syntax-entry ?{ "(}" table)
    (modify-syntax-entry ?} "){" table)
    table)
  "Syntax table used while in `selinux-mode'.")

(defconst selinux-font-lock-defaults
  (let ((keywords '("allow " "type " "dontaudit " "typealias " "attribute " "typeattribute " "ifdef" "define"))
        (classes '("file " "process " "capability " "unix_stream_socket " "dir "))
	(actions '("sigchld " "sigkill " "signal " "signull " "sigstop " "chown " "dac_override " "fowner " "fsetid " "setgid " "sys_admin " "sys_resource " "sys_tty_config " "execute " "getattr " )))
    `(((,(rx-to-string `(: (or ,@keywords))) 0 font-lock-keyword-face)       
       (,(rx-to-string `(: (or ,@classes))) 0 font-lock-type-face)
       (,(rx-to-string `(: (or ,@actions))) 0 font-lock-constant-face)))))

(define-derived-mode selinux-mode prog-mode "selinux"
  "A major mode for editing SELinux policies"
  (setq font-lock-defaults selinux-font-lock-defaults)
  
  ;; Comments start with #
  (setq-local comment-start "#")

  ;; Use our indentation function
  (setq-local indent-line-function #'selinux-indent-line)

  ;; Use spaces over tabs (this may conflict with distro policies)  
  (setq-local indent-tabs-mode nil))

;; Enable this mode on type enforcement (.te), file context (.fc) and
;; interface (.if) policy files.
(add-to-list 'auto-mode-alist '("\\.te" . selinux-mode))
(add-to-list 'auto-mode-alist '("\\.fc" . selinux-mode))
(add-to-list 'auto-mode-alist '("\\.if" . selinux-mode))

(provide 'selinux-mode)
