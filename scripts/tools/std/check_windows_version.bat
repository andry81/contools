@echo off

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "MAJOR_VER=%~1"
set "MINOR_VER=%~2"

if not defined MINOR_VER set MINOR_VER=0

if not defined MAJOR_VER goto WINDOWS_VER_NOT_SUPPORTED

if not defined WINDOWS_VER_STR goto WINDOWS_VER_NOT_SUPPORTED
if not defined WINDOWS_MAJOR_VER goto WINDOWS_VER_NOT_SUPPORTED
if not defined WINDOWS_MINOR_VER goto WINDOWS_VER_NOT_SUPPORTED

if %WINDOWS_MAJOR_VER% GTR %MAJOR_VER% goto WINDOWS_VER_OK
if %WINDOWS_MAJOR_VER% EQU %MAJOR_VER% if %WINDOWS_MINOR_VER% GEQ %MINOR_VER% goto WINDOWS_VER_OK

:WINDOWS_VER_NOT_SUPPORTED

(
  echo;%?~%: error: unsupported version of Windows: "%WINDOWS_VER_STR%"
  exit /b 255
) >&2

:WINDOWS_VER_OK

exit /b 0
