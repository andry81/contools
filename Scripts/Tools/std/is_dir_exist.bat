@echo off

rem Description:
rem   Script can check a directory existence in case of the read permissions
rem   deny on a directory. Does support long paths.

rem Based on:
rem   https://stackoverflow.com/questions/138981/how-to-test-if-a-file-is-a-directory-in-a-batch-script/3728742#3728742

setlocal

if not defined ?~nx0 (
  set "?~=%~nx0"
) else set "?~=%?~nx0%: %~nx0"

if "%~1" == "" (
  echo.%?~%: error: directory path is not defined.
  exit /b 255
) >&2

for /F "eol= tokens=* delims=" %%i in ("%~1\.") do set "FILE_PATH=%%~fi"

if not exist "\\?\%FILE_PATH%" (
  echo.%?~%: error: directory path does not exist: "%FILE_PATH%".
  exit /b 1
) >&2

for /F "eol= tokens=* delims=" %%i in ("\\?\%FILE_PATH%") do set "FILE_PATH_ATTR=%%~ai"

if /i not "%FILE_PATH_ATTR:~0,1%" == "d" exit /b 2

exit /b 0
