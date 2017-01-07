;;; wikipedia-this.el --- A set of functions and bindings to wikipedia under point.

;; Author: Ryan McCarl (ryan.mccarl@wordbrewery.com), based on code by Artur Malabarba <bruce.connor.am@gmail.com>
;; Inspired by: http://github.com/Malabarba/emacs-google-this
;; Package-Version: 20160107.001
;; Version: 0.01
;; Package-Requires: ((emacs "24.1"))
;; Keywords: convenience hypermedia
;; Prefix: wikipedia-this
;; Separator: -

;;; Commentary:

;; wikipedia-this is a package that provides a set of functions and
;; keybindings for launching wikipedia searches from within Emacs.

;; The main function is `wikipedia-this' (bound to C-c / w). It does a
;; wikipedia search using the currently selected region, or the
;; expression under point. All functions are bound under "C-c /"
;; prefix, in order to comply with Emacs' standards. If that's a
;; problem see `wikipedia-this-keybind'. To view all keybindings type "C-c
;; / C-h".
;;
;; If you don't like this keybind, just reassign the
;; `wikipedia-this-mode-submap' variable.
;; My personal preference is "C-x g":
;;
;;        (global-set-key (kbd "C-x g") 'wikipedia-this-mode-submap)
;;
;; Or, if you don't want wikipedia-this to overwrite the default ("C-c /")
;; key insert the following line BEFORE everything else (even before
;; the `require' command):
;;
;;        (setq wikipedia-this-keybind (kbd "C-x g"))
;;

;; To start a blank search, do `wikipedia-search' (C-c / RET). If you
;; want more control of what "under point" means for the `wikipedia-this'
;; command, there are the `wikipedia-word', `wikipedia-symbol',
;; `wikipedia-line' and `wikipedia-region' functions, bound as w, s, l and space,
;; respectively. They all do a search for what's under point.

;; If the `wikipedia-wrap-in-quotes' variable is t, than searches are
;; enclosed by double quotes (default is NOT). If a prefix argument is
;; given to any of the functions, invert the effect of
;; `wikipedia-wrap-in-quotes'.

;; There is also a `wikipedia-error' (C-c / e) function. It checks the
;; current error in the compilation buffer, tries to do some parsing
;; (to remove file name, line number, etc), and wikipedias it. It's still
;; experimental, and has only really been tested with gcc error
;; reports.

;; Finally there's also a wikipedia-cpp-reference function (C-c / r).

;;; Instructions:

;; INSTALLATION

;;  Make sure "wikipedia-this.el" is in your load path, then place
;;      this code in your .emacs file:
;;		(require 'wikipedia-this)
;;              (wikipedia-this-mode 1)

;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;

;;; Change Log:
;; 1.9   - 2014/09/25 - New Command: wikipedia-this-noconfirm bound to l. Like wikipedia-this but no confirmation.
;; 1.9   - 2014/09/02 - Renamed A LOT of functions to be namespaced correctly.
;; 1.10  - 2014/09/02 - Fix 24.3 compatibility.
;; 1.9   - 2014/06/19 - Customizable URL.
;; 1.8   - 2013/10/31 - Customizable mode-line indicator (credit https://github.com/mgalgs)
;; 1.7.1 - 2013/09/17 - wikipedia-this-parse-and-search-string returns what browse-url returns.
;; 1.7   - 2013/09/08 - Removed some obsolete aliases.
;; 1.7   - 2013/09/08 - Implemented wikipedia-lucky-and-insert-url, with keybinding.
;; 1.7   - 2013/09/08 - Implemented wikipedia-lucky, with keybinding.
;; 1.6   - 2013/08/22 - Activated wikipedia-instant, so you can navigate straight for the keyboard
;; 1.5   - 2013/07/18 - added keybinding for wikipedia region.
;; 1.5   - 2013/07/18 - Fixed cpp-reference.
;; 1.4   - 2013/06/03 - Added parent groups.
;; 1.4   - 2013/06/03 - Renamed some functions and variables. Is backwards incompatible if you were using functions you shouldn't be.
;; 1.4   - 2013/06/03 - Fixed quoting.
;; 1.3   - 2013/05/31 - Merged fix for wikipedia-forecast. Thanks to ptrv.
;; 1.3   - 2013/05/31 - More robust wikipedia-translate command.
;; 1.2.1 - 2013/04/26 - Created an error parser for the wikipedia-error function.
;; pre   - 2013/02/27 - It works with c-like errors and is extendable to other types of errors using the varible `wikipedia-error-regexp'.
;; 1.2.1 - 2013/04/26 - autoloaded any functions that the user might want to call directly.
;; 1.2   - 2013/04/21 - Fixed docs.
;; pre   - 2013/05/04 - Changed the keybinding to be standards compliant.
;; pre   - 2013/03/03 - Fixed problem with backslash.
;; pre   - 2013/02/27 - Added support for wikipedia-translate and wikipedia-maps packages.
;; pre   - 2013/02/27 - And added `wikipedia-forecast' function.
;; pre   - 2013/02/27 - And added `wikipedia-location-suffix' so we're not constrained to wikipedia.com anymore.
;;; Code:

(require 'url)
(eval-when-compile
  (progn
    (require 'compile)
    (require 'simple)))

(defgroup wikipedia-this '()
  "Customization group for `wikipedia-this-mode'."
  :link '(url-link "http://github.com/Malabarba/emacs-wikipedia-this")
  :group 'convenience
  :group 'comm)

(defconst wikipedia-this-version "1.10"
  "Version string of the `wikipedia-this' package.")
(defcustom wikipedia-this-wrap-in-quotes nil
  "If not nil, searches are wrapped in double quotes.

If a prefix argument is given to any of the functions, the
opposite happens."
  :type 'boolean
  :group 'wikipedia-this)

(defcustom wikipedia-this-suspend-after-search nil
  "Whether Emacs should be minimized after a search is launched (calls `suspend-frame')."
  :type 'boolean
  :group 'wikipedia-this)

(defcustom wikipedia-this-browse-url-function 'browse-url
  "Function used to browse urls.
Possible values include: `browse-url', `browse-url-generic',
`browse-url-emacs', `eww-browse-url'."
  :type 'function
  :group 'wikipedia-this)

(defvar wikipedia-this-mode-submap)
(define-prefix-command 'wikipedia-this-mode-submap)
(define-key wikipedia-this-mode-submap [return] #'wikipedia-this-search)
(define-key wikipedia-this-mode-submap " " #'wikipedia-this-region)
(define-key wikipedia-this-mode-submap "t" #'wikipedia-this)
(define-key wikipedia-this-mode-submap "n" #'wikipedia-this-noconfirm)
(define-key wikipedia-this-mode-submap "g" #'wikipedia-this-lucky-search)
(define-key wikipedia-this-mode-submap "i" #'wikipedia-this-lucky-and-insert-url)
(define-key wikipedia-this-mode-submap "w" #'wikipedia-this-word)
(define-key wikipedia-this-mode-submap "s" #'wikipedia-this-symbol)
(define-key wikipedia-this-mode-submap "l" #'wikipedia-this-line)
(define-key wikipedia-this-mode-submap "e" #'wikipedia-this-error)
(define-key wikipedia-this-mode-submap "f" #'wikipedia-this-forecast)
(define-key wikipedia-this-mode-submap "r" #'wikipedia-this-cpp-reference)
(define-key wikipedia-this-mode-submap "m" #'wikipedia-this-maps)
(define-key wikipedia-this-mode-submap "a" #'wikipedia-this-ray)
(define-key wikipedia-this-mode-submap "m" #'wikipedia-maps)
;; "c" is for "convert language" :-P
(define-key wikipedia-this-mode-submap "c" #'wikipedia-this-translate-query-or-region)

(defun wikipedia-this-translate-query-or-region ()
  "If region is active `wikipedia-translate-at-point', otherwise `wikipedia-translate-query-translate'."
  (interactive)
  (unless (require 'wikipedia-translate nil t)
    (error "[wikipedia-this]: This command requires the 'wikipedia-translate' package"))
  (if (region-active-p)
      (if (functionp 'wikipedia-translate-at-point)
          (call-interactively 'wikipedia-translate-at-point)
        (error "[wikipedia-this]: `wikipedia-translate-at-point' function not found in `wikipedia-translate' package"))
    (if (functionp 'wikipedia-translate-query-translate)
        (call-interactively 'wikipedia-translate-query-translate)
      (error "[wikipedia-this]: `wikipedia-translate-query-translate' function not found in `wikipedia-translate' package"))))

(defcustom wikipedia-this-base-url "https://en.wikipedia."
  "The base url to use in wikipedia searches.

This will be appended with `wikipedia-this-location-suffix', so you
shouldn't include the final \"com\" here."
  :type 'string
  :group 'wikipedia-this)

(defcustom wikipedia-this-location-suffix "org"
  "The url suffix associated with your location (com, co.uk, fr, etc)."
  :type 'string
  :group 'wikipedia-this)

(defun wikipedia-this-url ()
  "URL for wikipedia searches."
  (concat wikipedia-this-base-url wikipedia-this-location-suffix "/wiki/%s"))

(defcustom wikipedia-this-error-regexp '(("^[^:]*:[0-9 ]*:\\([0-9 ]*:\\)? *" ""))
  "List of (REGEXP REPLACEMENT) pairs to parse error strings."
  :type '(repeat (list regexp string))
  :group 'wikipedia-this)

(defun wikipedia-this-pick-term (prefix)
  "Decide what \"this\" and return it.
PREFIX determines quoting."
  (let* ((term (if (region-active-p)
                   (buffer-substring-no-properties (region-beginning) (region-end))
                 (or (thing-at-point 'symbol)
                     (thing-at-point 'word)
                     (buffer-substring-no-properties (line-beginning-position)
                                                     (line-end-position)))))
         (term (read-string (concat "Googling [" term "]: ") nil nil term)))
    term))

;;;###autoload
(defun wikipedia-this-search (prefix &optional search-string)
  "Write and do a wikipedia search.
Interactively PREFIX determines quoting.
Non-interactively SEARCH-STRING is the string to search."
  (interactive "P")
  (let* ((term (wikipedia-this-pick-term prefix)))
    (if (stringp term)
        (wikipedia-this-parse-and-search-string term prefix search-string)
      (message "[wikipedia-this-string] Empty query."))))

(defun wikipedia-this-lucky-search-url ()
  "Return the url for a feeling-lucky wikipedia search."
  (format "%s%s/search?q=%%s&btnI" wikipedia-this-base-url wikipedia-this-location-suffix))

(defalias 'wikipedia-this--do-lucky-search
  (with-no-warnings
    (if (version< emacs-version "24")
        (lambda (term callback)
          "Build the URL using TERM, perform the `url-retrieve' and call CALLBACK if we get redirected."
          (url-retrieve (format (wikipedia-this-lucky-search-url) (url-hexify-string term))
                        `(lambda (status)
                           (if status
                               (if (eq :redirect (car status))
                                   (progn (message "Received URL: %s" (cadr status))
                                          (funcall ,callback (cadr status)))
                                 (message "Unkown response: %S" status))
                             (message "Search returned no results.")))
                        nil))
      (lambda (term callback)
        "Build the URL using TERM, perform the `url-retrieve' and call CALLBACK if we get redirected."
        (url-retrieve (format (wikipedia-this-lucky-search-url) (url-hexify-string term))
                      `(lambda (status)
                         (if status
                             (if (eq :redirect (car status))
                                 (progn (message "Received URL: %s" (cadr status))
                                        (funcall ,callback (cadr status)))
                               (message "Unkown response: %S" status))
                           (message "Search returned no results.")))
                      nil t t)))))

(defvar wikipedia-this--last-url nil "Last url that was fetched by `wikipedia-this-lucky-and-insert-url'.")

;;;###autoload
(defun wikipedia-this-lucky-and-insert-url (term &optional insert)
  "Fetch the url that would be visited by `wikipedia-this-lucky'.

If you just want to do an \"I'm feeling lucky search\", use
`wikipedia-this-lucky-search' instead.

Interactively:
* Insert the URL at point,
* Kill the searched term, removing it from the buffer (it is killed, not
  deleted, so it can be easily yanked back if desired).
* Search term defaults to region or line, and always queries for
  confirmation.

Non-Interactively:
* Runs synchronously,
* Search TERM is an argument without confirmation,
* Only insert if INSERT is non-nil, otherwise return."
  (interactive '(needsQuerying t))
  (let ((nint (null (called-interactively-p 'any)))
        (l (if (region-active-p) (region-beginning) (line-beginning-position)))
        (r (if (region-active-p) (region-end) (line-end-position)))
        ;; We get current-buffer and point here, because it's
        ;; conceivable that they could change while waiting for input
        ;; from read-string
        (p (point))
        (b (current-buffer)))
    (when nint (setq wikipedia-this--last-url nil))
    (when (eq term 'needsQuerying)
      (setq term (read-string "Lucky Term: " (buffer-substring-no-properties l r))))
    (unless (stringp term) (error "TERM must be a string!"))
    (wikipedia-this--do-lucky-search
     term
     `(lambda (url)
        (unless url (error "Received nil url"))
        (with-current-buffer ,b
          (save-excursion
            (if ,nint (goto-char ,p)
              (kill-region ,l ,r)
              (goto-char ,l))
            (when ,insert (insert url))))
        (setq wikipedia-this--last-url url)))
    (unless nint (deactivate-mark))
    (when nint
      (while (null wikipedia-this--last-url) (sleep-for 0 10))
      wikipedia-this--last-url)))

;;;###autoload
(defun wikipedia-this-lucky-search (prefix)
  "Exactly like `wikipedia-this-search', but use the \"I'm feeling lucky\" option.
PREFIX determines quoting."
  (interactive "P")
  (wikipedia-this-search prefix (wikipedia-this-lucky-search-url)))

(defun wikipedia-this--maybe-wrap-in-quotes (text flip)
  "Wrap TEXT in quotes.
Depends on the value of FLIP and `wikipedia-this-wrap-in-quotes'."
  (if (if flip (not wikipedia-this-wrap-in-quotes) wikipedia-this-wrap-in-quotes)
      (format "\"%s\"" text)
    text))

(defun wikipedia-this-parse-and-search-string (text prefix &optional search-url)
  "Convert illegal characters in TEXT to their %XX versions, and then wikipedias.
PREFIX determines quoting.
SEARCH-URL is usually either the regular or the lucky wikipedia
search url.

Don't call this function directly, it could change depending on
version. Use `wikipedia-this-string' instead (or any of the other
wikipedia-this-\"something\" functions)."
  (let* (;; Create the url
         (query-string (wikipedia-this--maybe-wrap-in-quotes text prefix))
         ;; Perform the actual search.
         (browse-result (funcall wikipedia-this-browse-url-function
                                 (format (or search-url (wikipedia-this-url))
                                         (url-hexify-string query-string)))))
    ;; Maybe suspend emacs.
    (when wikipedia-this-suspend-after-search (suspend-frame))
    ;; Return what browse-url returned (very usefull for tests).
    browse-result))

;;;###autoload
(defun wikipedia-this-string (prefix &optional text noconfirm)
  "Wikipedia given TEXT, but ask the user first if NOCONFIRM is nil.
PREFIX determines quoting."
  (unless noconfirm
    (setq text (read-string "Look up on Wikipedia: "
                            (if (stringp text) (replace-regexp-in-string "^[[:blank:]]*" "" text)))))
  (if (stringp text)
      (wikipedia-this-parse-and-search-string text prefix)
    (message "[wikipedia-this-string] Empty query.")))

;;;###autoload
(defun wikipedia-this-line (prefix &optional noconfirm)
  "Wikipedia the current line.
PREFIX determines quoting.
NOCONFIRM goes without asking for confirmation."
  (interactive "P")
  (let ((line (buffer-substring (line-beginning-position) (line-end-position))))
    (wikipedia-this-string prefix line noconfirm)))

;;;###autoload
(defun wikipedia-this-ray (prefix &optional noconfirm noregion)
  "Wikipedia text between the point and end of the line.
If there is a selected region, wikipedias the region.
PREFIX determines quoting. Negative arguments invert the line segment.
NOCONFIRM goes without asking for confirmation.
NOREGION ignores the region."
  (interactive "P")
  (if (and (region-active-p) (not noregion))
      (wikipedia-this-region prefix noconfirm)
    (let (beg end pref (arg (prefix-numeric-value prefix)))
      (if (<= arg -1)
          (progn
            (setq beg (line-beginning-position))
            (setq end (point))
            (setq pref (< arg -1)))
        (setq beg (point))
        (setq end (line-end-position))
        (setq pref prefix))
      (wikipedia-this-string pref (buffer-substring beg end) noconfirm))))

;;;###autoload
(defun wikipedia-this-word (prefix)
  "Wikipedia the current word.
PREFIX determines quoting."
  (interactive "P")
  (wikipedia-this-string prefix (thing-at-point 'word) t))

;;;###autoload
(defun wikipedia-this-symbol (prefix)
  "Wikipedia the current symbol.
PREFIX determines quoting."
  (interactive "P")
  (wikipedia-this-string prefix (thing-at-point 'symbol) t))


;;;###autoload
(defun wikipedia-this-region (prefix &optional noconfirm)
  "Wikipedia the current region.
PREFIX determines quoting.
NOCONFIRM goes without asking for confirmation."
  (interactive "P")
  (wikipedia-this-string
   prefix (buffer-substring-no-properties (region-beginning) (region-end))
   noconfirm))

;;;###autoload
(defun wikipedia-this (prefix &optional noconfirm)
  "Decide what the user wants to wikipedia (always something under point).
Unlike `wikipedia-this-search' (which presents an empty prompt with
\"this\" as the default value), this function inserts the query
in the minibuffer to be edited.
PREFIX argument determines quoting.
NOCONFIRM goes without asking for confirmation."
  (interactive "P")
  (cond
   ((region-active-p) (wikipedia-this-region prefix noconfirm))
   ((thing-at-point 'symbol) (wikipedia-this-string prefix (thing-at-point 'symbol) noconfirm))
   ((thing-at-point 'word) (wikipedia-this-string prefix (thing-at-point 'word) noconfirm))
   (t (wikipedia-this-line prefix noconfirm))))

;;;###autoload
(defun wikipedia-this-noconfirm (prefix)
  "Decide what the user wants to wikipedia and go without confirmation.
Exactly like `wikipedia-this' or `wikipedia-this-search', but don't ask
for confirmation.
PREFIX determines quoting."
  (interactive "P")
  (wikipedia-this prefix 'noconfirm))

;;;###autoload
(defun wikipedia-this-error (prefix)
  "Wikipedia the current error in the compilation buffer.
PREFIX determines quoting."
  (interactive "P")
  (unless (boundp 'compilation-mode-map)
    (error "No compilation active"))
  (require 'compile)
  (require 'simple)
  (save-excursion
    (let ((pt (point))
          (buffer-name (next-error-find-buffer)))
      (unless (compilation-buffer-internal-p)
        (set-buffer buffer-name))
      (wikipedia-this-string prefix
                          (wikipedia-this-clean-error-string
                           (buffer-substring (line-beginning-position) (line-end-position)))))))


;;;###autoload
(defun wikipedia-this-clean-error-string (s)
  "Parse error string S and turn it into wikipediaable strings.

Removes unhelpful details like file names and line numbers from
simple error strings (such as c-like erros).

Uses replacements in `wikipedia-this-error-regexp' and stops at the first match."
  (interactive)
  (let (out)
    (catch 'result
      (dolist (cur wikipedia-this-error-regexp out)
        (when (string-match (car cur) s)
          (setq out (replace-regexp-in-string
                     (car cur) (car (cdr cur)) s))
          (throw 'result out))))))

;;;###autoload
(defun wikipedia-this-cpp-reference ()
  "Visit the most probable cppreference.com page for this word."
  (interactive)
  (wikipedia-this-parse-and-search-string
   (concat "site:cppreference.com " (thing-at-point 'symbol))
   nil (wikipedia-this-lucky-search-url)))

;;;###autoload
(defun wikipedia-this-forecast (prefix)
  "Search wikipedia for \"weather\".
With PREFIX, ask for location."
  (interactive "P")
  (if (not prefix) (wikipedia-this-parse-and-search-string "weather" nil)
    (wikipedia-this-parse-and-search-string
     (concat "weather " (read-string "Location: " nil nil "")) nil)))

(defcustom wikipedia-this-keybind (kbd "C-c /")
  "Keybinding under which `wikipedia-this-mode-submap' is assigned.

To change this do something like:
    (setq wikipedia-this-keybind (kbd \"C-x g\"))
BEFORE activating the function `wikipedia-this-mode' and BEFORE `require'ing the
`wikipedia-this' feature."
  :type 'string
  :group 'wikipedia-this
  :package-version '(wikipedia-this . "1.4"))

(defcustom wikipedia-this-modeline-indicator " Wikipedia"
  "String to display in the modeline when command `wikipedia-this-mode' is activated."
  :type 'string
  :group 'wikipedia-this
  :package-version '(wikipedia-this . "1.8"))

;;;###autoload
(define-minor-mode wikipedia-this-mode nil nil wikipedia-this-modeline-indicator
  `((,wikipedia-this-keybind . ,wikipedia-this-mode-submap))
  :global t
  :group 'wikipedia-this)
;; (setq wikipedia-this-keybind (kbd \"C-x g\"))

(provide 'wikipedia-this)

;;; wikipedia-this.el ends here
