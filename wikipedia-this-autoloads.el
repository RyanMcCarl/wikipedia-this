;;; wikipedia-this-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "wikipedia-this" "wikipedia-this.el" (0 0 0 0))
;;; Generated autoloads from wikipedia-this.el

(autoload 'wikipedia-this-search "wikipedia-this" "\
Write and do a wikipedia search.
Interactively PREFIX determines quoting.
Non-interactively SEARCH-STRING is the string to search.

\(fn PREFIX &optional SEARCH-STRING)" t nil)

(autoload 'wikipedia-this-lucky-and-insert-url "wikipedia-this" "\
Fetch the url that would be visited by `wikipedia-this-lucky'.

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
* Only insert if INSERT is non-nil, otherwise return.

\(fn TERM &optional INSERT)" t nil)

(autoload 'wikipedia-this-lucky-search "wikipedia-this" "\
Exactly like `wikipedia-this-search', but use the \"I'm feeling lucky\" option.
PREFIX determines quoting.

\(fn PREFIX)" t nil)

(autoload 'wikipedia-this-string "wikipedia-this" "\
Wikipedia given TEXT, but ask the user first if NOCONFIRM is nil.
PREFIX determines quoting.

\(fn PREFIX &optional TEXT NOCONFIRM)" nil nil)

(autoload 'wikipedia-this-line "wikipedia-this" "\
Wikipedia the current line.
PREFIX determines quoting.
NOCONFIRM goes without asking for confirmation.

\(fn PREFIX &optional NOCONFIRM)" t nil)

(autoload 'wikipedia-this-ray "wikipedia-this" "\
Wikipedia text between the point and end of the line.
If there is a selected region, wikipedias the region.
PREFIX determines quoting. Negative arguments invert the line segment.
NOCONFIRM goes without asking for confirmation.
NOREGION ignores the region.

\(fn PREFIX &optional NOCONFIRM NOREGION)" t nil)

(autoload 'wikipedia-this-word "wikipedia-this" "\
Wikipedia the current word.
PREFIX determines quoting.

\(fn PREFIX)" t nil)

(autoload 'wikipedia-this-symbol "wikipedia-this" "\
Wikipedia the current symbol.
PREFIX determines quoting.

\(fn PREFIX)" t nil)

(autoload 'wikipedia-this-region "wikipedia-this" "\
Wikipedia the current region.
PREFIX determines quoting.
NOCONFIRM goes without asking for confirmation.

\(fn PREFIX &optional NOCONFIRM)" t nil)

(autoload 'wikipedia-this "wikipedia-this" "\
Decide what the user wants to wikipedia (always something under point).
Unlike `wikipedia-this-search' (which presents an empty prompt with
\"this\" as the default value), this function inserts the query
in the minibuffer to be edited.
PREFIX argument determines quoting.
NOCONFIRM goes without asking for confirmation.

\(fn PREFIX &optional NOCONFIRM)" t nil)

(autoload 'wikipedia-this-noconfirm "wikipedia-this" "\
Decide what the user wants to wikipedia and go without confirmation.
Exactly like `wikipedia-this' or `wikipedia-this-search', but don't ask
for confirmation.
PREFIX determines quoting.

\(fn PREFIX)" t nil)

(autoload 'wikipedia-this-error "wikipedia-this" "\
Wikipedia the current error in the compilation buffer.
PREFIX determines quoting.

\(fn PREFIX)" t nil)

(autoload 'wikipedia-this-clean-error-string "wikipedia-this" "\
Parse error string S and turn it into wikipediaable strings.

Removes unhelpful details like file names and line numbers from
simple error strings (such as c-like erros).

Uses replacements in `wikipedia-this-error-regexp' and stops at the first match.

\(fn S)" t nil)

(autoload 'wikipedia-this-cpp-reference "wikipedia-this" "\
Visit the most probable cppreference.com page for this word.

\(fn)" t nil)

(autoload 'wikipedia-this-forecast "wikipedia-this" "\
Search wikipedia for \"weather\".
With PREFIX, ask for location.

\(fn PREFIX)" t nil)

(defvar wikipedia-this-mode nil "\
Non-nil if Wikipedia-This mode is enabled.
See the `wikipedia-this-mode' command
for a description of this minor mode.")

(custom-autoload 'wikipedia-this-mode "wikipedia-this" nil)

(autoload 'wikipedia-this-mode "wikipedia-this" "\
Toggle Wikipedia-This mode on or off.
With a prefix argument ARG, enable Wikipedia-This mode if ARG is
positive, and disable it otherwise.  If called from Lisp, enable
the mode if ARG is omitted or nil, and toggle it if ARG is `toggle'.
\\{wikipedia-this-mode-map}

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "wikipedia-this" '("wikipedia-this-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; wikipedia-this-autoloads.el ends here
