@echo off

setlocal

rem Do not continue if already in Impl Mode
if defined IMPL_MODE set /A IMPL_MODE+=0

if %IMPL_MODE%0 NEQ 0 (
  echo.%~nx0: error: Impl Mode already used.
  exit /b 255
) >&2

rem CAUTION:
rem   The `& "%CONTOOLS_ROOT%/std/errlvl.bat"` is required to workaround `cmd.exe` not zero exit code issue.
rem   See the `KNOWN ISSUES` section in the `README_EN.txt`.
rem
(
  endlocal
  set IMPL_MODE=1
  "%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe"%MINTTY_CALLF_BARE_FLAGS% ^
    "%COMSPECLNK%" "/c \"@\"%?~f0%\" {*} ^& \"%CONTOOLS_ROOT%/std/errlvl.bat\"\"" ^
    %*
)

call "%CONTOOLS_ROOT%/exec/exec_terminal_cleanup.bat"
