@echo off

rem drop last error level
call;

if "%~1" == "" (
  echo.%~nx0: error: command argument is not defined.
  exit /b 255
) >&2

if exist "%~1" call "%%~dp0callshift.bat" 1 "%%~1" %%*
