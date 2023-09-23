@echo off

setlocal

rem CAUTION:
rem   The `& "%CONTOOLS_ROOT%/std/errlvl.bat"` is required to workaround `cmd.exe` not zero exit code issue.
rem   See the `KNOWN ISSUES` section in the `README_EN.txt`.
rem
(
  endlocal
  set IMPL_MODE=1
  "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"%MINTTY_CALLF_BARE_FLAGS% ^
    "%COMSPECLNK%" "/c \"@\"%?~f0%\" {*} ^& \"%CONTOOLS_ROOT%/std/errlvl.bat\"\"" ^
    %*
)

call "%CONTOOLS_ROOT%/exec/exec_terminal_cleanup.bat"
