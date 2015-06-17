# highlight-keywords-mode

Highlight keywords such as FIXME, TODO, etc. in Emacs buffers, but only
in select contexts, such as comments and doc strings.


To enable this minor mode, put something like the following in your
init file:

For a single mode:

`(add-hook 'emacs-lisp-mode-hook 'turn-on-highlight-keywords-mode)`

For all programming modes:

`(add-hook 'prog-mode-hook 'turn-on-highlight-keywords-mode)`

Based on the work of:
- Mark Triggs <mst@dishevelled.net> (highlight-fixmes-mode.el)
- Trey Jackson <bigfaceworm(at)gmail(dot)com> (fic-mode.el)
