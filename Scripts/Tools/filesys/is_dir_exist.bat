@echo off

rem Description:
rem   Script can check a directory existence in case of Read permissions deny
rem   on a directory.

rem Based on:
rem   https://stackoverflow.com/questions/138981/how-to-test-if-a-file-is-a-directory-in-a-batch-script/3728742#3728742

setlocal

if "%~1" == "" (
  echo.%~nx0: error: directory path is not defined.
  exit /b 255
) >&2

for /F "eol= tokens=* delims=" %%i in ("%~1\.") do set "FILE_PATH=%%~fi"

if not exist "%FILE_PATH%" (
  echo.%~nx0: error: directory path does not exist: "%FILE_PATH%".
  exit /b 1
) >&2

set "ATTR=%~a1"
set "DIRATTR=%ATTR:~0,1%"

if /i not "%DIRATTR%" == "d" (
  echo.%~nx0: error: directory path exists and is not a directory: "%FILE_PATH%".
  exit /b 2
) >&2

exit /b 0
