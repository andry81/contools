@echo off

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem cast to integer
set /A IMPL_MODE+=0

rem do not continue if already in Impl Mode
if %IMPL_MODE% NEQ 0 (
  echo;%?~%: error: Impl Mode already used.
  exit /b 255
) >&2

rem CAUTION:
rem   The `& "%CONTOOLS_ROOT%/std/errlvl.bat"` is required to workaround `cmd.exe` not zero exit code issue.
rem   See the `KNOWN ISSUES` section in the `README_EN.txt`.
rem
endlocal & "%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe"%MINTTY_CALLF_BARE_FLAGS% /v IMPL_MODE 1 // ^
  "%COMSPECLNK%" "/c \"@\"%?~f0%\" {*} ^& \"%CONTOOLS_ROOT%/std/errlvl.bat\"\"" ^
  %*

call "%%CONTOOLS_ROOT%%/exec/exec_terminal_cleanup.bat"
