;;; flymake-collection-golangci-lint.el --- Golangci-lint diagnostic function -*- lexical-binding: t -*-

;; Copyright (c) 2024 Aleksandr Kurbatov

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:

;; `flymake' syntax checker for Golang using golangci-lint.

;;; Code:

(require 'flymake)
(require 'flymake-collection)

(eval-when-compile
  (require 'flymake-collection-define))

(defcustom flymake-collection-golangci-lint-args nil
  "Command line arguments always passed to `flymake-collection-golangci-lint'."
  :type '(repeat string)
  :group 'flymake-collection)

;;;###autoload (autoload 'flymake-collection-golangci-lint "flymake-collection-golangci-lint")
(flymake-collection-define-enumerate flymake-collection-golangci-lint
  "A Golang syntax and style checker using Golangci-lint.

See URL `https://golangci-lint.run/'."
  :title "golangci-lint"
  :pre-let ((golangci-lint-exec (executable-find "golangci-lint")))
  :pre-check (unless golangci-lint-exec
               (error "Cannot find golangci-lint executable"))
  :write-type 'pipe
  :command `(,golangci-lint-exec
             "run"
             "--out-format" "json"
             "--issues-exit-code" "0"
             ,@flymake-collection-golangci-lint-args)

  :generator
  (alist-get 'Issues
   (car
    (flymake-collection-parse-json
     (buffer-substring-no-properties
      (point-min) (point-max)))))
  :enumerate-parser
  (let-alist it
    (let ((loc (flymake-diag-region flymake-collection-source .Pos.Line .Pos.Column)))
      (list flymake-collection-source
            (car loc)
            (cdr loc)
            (pcase (downcase .Severity)
              ("warning" :warning)
              ("info" :note)
              (_ :error))
            (concat (propertize .FromLinter 'face 'flymake-collection-diag-id) " " .Text)))))

(provide 'flymake-collection-golangci-lint)

;;; flymake-collection-golangci-lint.el ends here
