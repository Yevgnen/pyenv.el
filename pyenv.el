;; -*- lexical-binding: t; -*-
;;; pyenv.el --- Pyenv for Emacs.
;;
;; Copyright (C) 2017 Yevgnen Koh
;;
;; Author: Yevgnen Koh <wherejoystarts@gmail.com>
;; Version: 1.0.0
;; Keywords: pyenv, python
;; Package-Requires: ((pythonic "0.1.1"))
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; Pyenv for Emacs.
;;
;; See documentation on https://github.com/Yevgnen/pyenv.el.

;;; Code:

(require 'pythonic)

(defcustom pyenv-executable "pyenv"
  "Pyenv executable."
  :type 'string)

(defcustom pyenv-home "~/.pyenv/versions"
  "Pyenv home directory."
  :type 'string)

(defcustom pyenv-show-env-name t
  "Whether to show env name in mode name."
  :type 'boolean)

;;;###autoload
(defun pyenv-versions ()
  (if (executable-find pyenv-executable (pythonic-remote-p))
      (split-string
       (string-trim
        (shell-command-to-string (format "%s version-name" pyenv-executable))) ":")
    (user-error "Pyenv executable [%s] not found." pyenv-executable)))

;;;###autoload
(defun pyenv-version ()
  (car (pyenv-versions)))

;;;###autoload
(defun pyenv-virtualenv-root (&optional virtualenv-name)
  (expand-file-name (or virtualenv-name (pyenv-version))
                    (pythonic-emacs-readable-file-name pyenv-home)))

;;;###autoload
(defun pyenv-virtualenv-bin (&optional virtualenv-root)
  (expand-file-name "bin/" (or virtualenv-root (pyenv-virtualenv-root))))

;;;###autoload
(defun pyenv-virtualenv-command (command &optional virtualenv-root)
  (expand-file-name (concat "bin/" command)
                    (or virtualenv-root (pyenv-virtualenv-root))))

;;;###autoload
(defun pyenv-virtualenv-python (&optional virtualenv-root)
  (expand-file-name "bin/python"
                    (or virtualenv-root (pyenv-virtualenv-root))))

;;;###autoload
(defun pyenv-virtualenv-with-root ()
  (let* ((virtualenv-name (pyenv-version))
         (virtualenv-root (pyenv-virtualenv-root virtualenv-name)))
    (cons virtualenv-name virtualenv-root)))

;;;###autoload
(defun pyenv-activate ()
  (require 'tramp)
  (when-let ((result (pyenv-virtualenv-with-root))
             (virtualenv-name (car result))
             (virtualenv-root (cdr result))
             (virtualenv-bin (pyenv-virtualenv-bin)))
    (pythonic-activate virtualenv-root)
    (setq-local exec-path (cons virtualenv-root (remove virtualenv-bin exec-path))
                tramp-remote-path (cons virtualenv-root (remove virtualenv-bin tramp-remote-path)))
    (setq mode-name (concat mode-name (format "[%s]" virtualenv-name)))))

(provide 'pyenv)

;;; pyenv.el ends here
