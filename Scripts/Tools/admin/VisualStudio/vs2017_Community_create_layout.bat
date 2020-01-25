@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

if not defined VS2017COMM_LAYOUT_ROOT (
  echo.%~nx0: error: VS2017COMM_LAYOUT_ROOT directory path is not defined.
  exit /b 1
) >&2

if not exist "%VS2017COMM_LAYOUT_ROOT%\" (
  echo.%~nx0: error: VS2017COMM_LAYOUT_ROOT directory path does not exist: "%VS2017COMM_LAYOUT_ROOT%".
  exit /b 2
) >&2

if not defined VS2017COMM_LAYOUT_DIR (
  echo.%~nx0: error: VS2017COMM_LAYOUT_DIR subdirectory path is not defined.
  exit /b 3
) >&2

if not exist "%VS2017COMM_LAYOUT_ROOT%\%VS2017COMM_LAYOUT_DIR%\" (
  echo.%~nx0: error: VS2017COMM_LAYOUT_ROOT/VS2017COMM_LAYOUT_DIR directory path does not exist: "%VS2017COMM_LAYOUT_ROOT%\%VS2017COMM_LAYOUT_DIR%".
  exit /b 4
) >&2

vs_community.exe --layout "%VS2017COMM_LAYOUT_ROOT%\%VS2017COMM_LAYOUT_DIR%" --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --lang en-US %*
