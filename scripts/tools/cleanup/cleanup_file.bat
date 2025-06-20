@echo off

setlocal

set "CLEANUP_FILE=%~1"

rem CAUTION:
rem   The `sed` does reformat the line returns.
rem

rem * remove all custom tokens (ppk_XXXXXXXXXXXXXXXX) (password private key)
rem * remove all GitHub tokens (ghp_XXXXXXXXXXXXXXXX)
rem * remove all GitHub tokens (github_pat_XXXXXXXXXXXXXXXXXXXXXX_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX)
"%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe" -E -i -b ^
  "s/ppk_[0-9a-zA-Z]{16,}/ppk_*/g; s/ghp_[0-9a-zA-Z]{16,}/ghp_*/g; s/github_pat_[0-9a-zA-Z]{22,}_[0-9a-zA-Z]{71,}/github_pat_*/g" ^
  "%CLEANUP_FILE%"
