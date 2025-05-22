@echo off

if not defined TESTLIB__CHCP_EXE (
  echo;%~nx0: error: `TESTLIB__CHCP_EXE` is not initialized.
  exit /b 255
) >&2

set "TESTLIB__TEST_CP="
for /F "usebackq tokens=1,* delims=:"eol^= %%i in (`@"%%TESTLIB__CHCP_EXE%%" ^<nul 2^>nul`) do set "TESTLIB__TEST_CP=%%j"
if defined TESTLIB__TEST_CP set "TESTLIB__TEST_CP=%TESTLIB__TEST_CP: =%"

exit /b 0
