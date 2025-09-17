@echo off

if defined CHCP if %CHCP% NEQ 65000 goto CHCP_OK

(
  echo;%?~%: error: CHCP must be defined and not equals to 65000.
  exit /b 1
) >&2

:CHCP_OK

if defined NO_CHCP if %NO_CHCP%0 NEQ 0 (
  echo;%?~%: error: NO_CHCP must be not set.
  exit /b 2
) >&2

rem read current code page
call "%%CONTOOLS_ROOT%%/std/getcp.bat" SETUP_CP

rem reset `return.vars` variables before testing
for /F "usebackq tokens=* delims="eol^= %%i in ("%~dp0return.vars") do set "%%i="

exit /b 0
