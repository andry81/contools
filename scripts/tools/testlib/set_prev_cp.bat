@echo off

if not defined TESTLIB__CHCP_EXE (
  echo;%~nx0: error: `TESTLIB__CHCP_EXE` is not initialized.
  exit /b 255
) >&2

if defined TESTLIB__TEST_CP if defined TESTLIB__PREV_CP if not "%TESTLIB__TEST_CP%" == "%TESTLIB__PREV_CP%" "%TESTLIB__CHCP_EXE%" %TESTLIB__PREV_CP% >nul

exit /b 0
