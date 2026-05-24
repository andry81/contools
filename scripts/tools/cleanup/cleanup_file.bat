@echo off

setlocal

set "CLEANUP_FILE=%~1"

rem CAUTION:
rem   The `sed` does reformat the line returns.
rem

rem * remove all custom tokens:
rem    - ppk_XXXXXXXXXXXXXXXX (password private key)
rem * remove all GitHub tokens:
rem    - ghs_XXX...~520...XXX (https://github.blog/changelog/2026-05-15-github-app-installation-tokens-per-request-override-header/)
rem    - ghp_XXXXXXXXXXXXXXXX
rem * remove all GitHub tokens:
rem    - github_pat_XXXXXXXXXXXXXXXXXXXXXX_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

"%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe" -E -i -b ^
  "s/ppk_[0-9a-zA-Z]{16,}/ppk_*/g; s/ghs_[A-Za-z0-9\._]{36,}/ghs_*/g; s/ghp_[A-Za-z0-9]{16,}/ghp_*/g; s/github_pat_[A-Za-z0-9]{22,}_[A-Za-z0-9]{71,}/github_pat_*/g" ^
  "%CLEANUP_FILE%"
