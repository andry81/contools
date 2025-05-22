@echo off

if not defined TESTLIB__CHCP_EXE (
  echo;%~nx0: error: `TESTLIB__CHCP_EXE` is not initialized.
  exit /b 255
) >&2

if defined TESTLIB__TEST_CP if not "%TESTLIB__TEST_CP%" == "65001" "%TESTLIB__CHCP_EXE%" 65001 >nul

exit /b 0
