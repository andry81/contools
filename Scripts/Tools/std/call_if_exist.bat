@echo off

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem drop last error level
call;

if "%~1" == "" (
  echo;%?~%: error: command argument is not defined.
  exit /b 255
) >&2

endlocal & if exist "%~1" call "%%~dp0callshift.bat" 1 "%%~1" %%*
