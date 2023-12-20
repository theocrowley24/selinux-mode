(defconst selinux-font-lock-keywords '("allow") "Wibble")

(defvar selinux-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?# "<\n" table)
    (modify-syntax-entry ?\n ">#" table)
    table)
  "Syntax table used while in `selinux-mode'.")

(define-derived-mode selinux-mode prog-mode "selinux"
  "A major mode for editing SELinux policies"
  (setq-local font-lock-defaults '(selinux-font-lock-keywords))
  (setq-local comment-start "#"))

(add-to-list 'auto-mode-alist '("\\.te" . selinux-mode))
