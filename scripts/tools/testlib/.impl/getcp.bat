@echo off

if not defined TESTLIB__CHCP_EXE (
  echo;%~nx0: error: `TESTLIB__CHCP_EXE` is not initialized.
  exit /b 255
) >&2

set "TESTLIB__CURRENT_CP="
for /F "usebackq tokens=1,* delims=:"eol^= %%i in (`@"%%TESTLIB__CHCP_EXE%%" ^<nul 2^>nul`) do set "TESTLIB__CURRENT_CP=%%j"
if defined TESTLIB__CURRENT_CP set "TESTLIB__CURRENT_CP=%TESTLIB__CURRENT_CP: =%"

exit /b 0
