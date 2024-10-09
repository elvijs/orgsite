;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)
(require 'ox-publish)

;; Define the publishing project
; (setq out-path "./html")
(setq contents-dir (nth 2 argv))  ;; 2nd argv should be the path to org dir
(setq out-path (nth 3 argv))  ;; 3nd argv should be the out-path
;;  use -- -Q to pass in argv into the script; test using the following
;; (print argv)
;; (print (nth 2 argv))
;; (print (nth 3 argv))

;; from my .emacs file
(require 'ox-publish)
(setq org-publish-project-alist
      `(("org-notes"
         :base-directory ,contents-dir
         :base-extension "org"
         :publishing-directory ,out-path
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t
         :auto-sitemap t
         :sitemap-filename "sitemap.org"
         :sitemap-title "Sitemap"
         :sitemap-sort-files anti-chronologically  ;; newest first
         :sitemap-ignore-case t
         :with-images t
         :html-inline-images t
         :with-toc t
         )
        ("org-static"
         :base-directory ,contents-dir
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
         :publishing-directory ,out-path
         :recursive t
         :publishing-function org-publish-attachment)
        ("org"
         :components ("org-notes" "org-static"))))

(setq org-html-head-include-default-style nil  ;; Use our own styles
      org-html-head-include-scripts nil        ;; Use our own scripts
      org-html-inline-images t
      org-html-head "<link rel=\"stylesheet\" href=\"https://gongzhitaao.org/orgcss/org.css\" type=\"text/css\"/>"
      org-html-preamble (concat "<div class='topnav'>
                                 <a href='/sitemap.html'>Home</a> /
                                 <a href='/agenda.html'>Agenda</a> /
                                 <a href='/projects.html'>Projects</a>
                                 </div>")
      )

;; Add an agenda page
(setq org-agenda-custom-commands
      '(("a" "Agenda and TODOs"
         ((agenda "")
          (alltodo "")))))
(defun my-org-publish-agenda ()
  "Generate an agenda HTML file and save it to the publishing directory, including files from subdirectories."
  (let* ((org-agenda-files (directory-files-recursively contents-dir "\\.org$")) ;; Recursively find all .org files
         (agenda-buffer (get-buffer-create "*Org Agenda Export*"))
         (output-file (expand-file-name "agenda.html" out-path)))
    ;; Generate the agenda
    (org-agenda nil "a") ;; Customize the agenda command if needed
    (with-current-buffer "*Org Agenda*"
      ;; Export to HTML
      (org-agenda-write output-file)
      (kill-buffer agenda-buffer))))

(defun my-org-publish-all ()
  "Publish all Org files and the agenda."
  (interactive)
  ;; Publish all Org files
  (org-publish-all t)
  ;; Generate the agenda HTML file
  (my-org-publish-agenda))

;; Generate the site output
(my-org-publish-all)

(message "Build complete!")