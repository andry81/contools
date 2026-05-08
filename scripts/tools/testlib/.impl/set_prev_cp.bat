@echo off

if not defined TESTLIB__CHCP_EXE (
  echo;%~nx0: error: `TESTLIB__CHCP_EXE` is not initialized.
  exit /b 255
) >&2

if not defined WINDOWS_MAJOR_VER (
  echo;%~nx0: error: `WINDOWS_MAJOR_VER` is not defined.
  exit /b 255
) >&2

rem Use a different inner code page for Windows XP

if %WINDOWS_MAJOR_VER% GEQ 6 (
  if defined TESTLIB__PREV_CP if not "%TESTLIB__PREV_CP%" == "65001" "%TESTLIB__CHCP_EXE%" %TESTLIB__PREV_CP% >nul
) else if defined TESTLIB__PREV_CP if not "%TESTLIB__PREV_CP%" == "437" "%TESTLIB__CHCP_EXE%" %TESTLIB__PREV_CP% >nul

exit /b 0
