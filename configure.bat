@echo off

setlocal

set "CONFIGURE_ROOT=%~dp0"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:~0,-1%"

if exist "%CONFIGURE_ROOT%/Scripts/__init__.bat" exit /b 1

rem generate default configure.user.bat
(
  echo.@echo off
  echo.
  echo.call "%%~dp0..\..\__init__.bat" ^|^| goto :EOF
) > "%CONFIGURE_ROOT%/Scripts/__init__.bat"

exit /b 0
