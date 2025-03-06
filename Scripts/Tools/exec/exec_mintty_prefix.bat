@echo off

setlocal

rem cast to integer
set /A IMPL_MODE+=0

rem do not continue if already in Impl Mode
if %IMPL_MODE% NEQ 0 (
  echo.%~nx0: error: Impl Mode already used.
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
