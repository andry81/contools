@echo off

if not defined WINDOWS_MAJOR_VER (
  echo;%~nx0: error: `WINDOWS_MAJOR_VER` is not defined.
  exit /b 255
) >&2

rem read current code page
call "%%CONTOOLS_ROOT%%/std/getcp.bat" OUTER_CP

rem outer code page
set OUTER_CP

rem state variables of the `std/chcp.bat` script
set CURRENT_CP
set LAST_CP
set CP_HISTORY_LIST

rem reset `return.vars` variables before testing
for /F "usebackq tokens=* delims="eol^= %%i in ("%~dp0return.vars") do set "%%i="

if %WINDOWS_MAJOR_VER% GEQ 6 (
  set SETUP_CP=65001
) else set SETUP_CP=437

rem explicitly set initial code page for tests
"%SystemRoot%\System32\chcp.com" %SETUP_CP%

exit /b 0
