@echo off

setlocal DISABLEDELAYEDEXPANSION

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

if "%~1" == "" (
  echo;%?~%: error: variable's name is not defined.
  exit /b 255
) >&2

if "%~2" == "" (
  echo;%?~%: error: variable's value is not defined: "%~1".
  exit /b 255
) >&2

if defined %~1 exit /b 0

for /F "tokens=* delims="eol^= %%i in ("%~2\.") do endlocal & set "%~1=%%~fi"

exit /b 0
