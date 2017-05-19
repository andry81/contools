@echo off

setlocal

set "CONFIGURE_ROOT=%~dp0"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:~0,-1%"

if exist "%CONFIGURE_ROOT%/Scripts/Tools/scm/svn/__init__.bat" exit /b 1

rem generate __init__.bat in "Tools/scm/svn"
(
  echo.@echo off
  echo.
  echo.call "%%%%~dp0..\..\__init__.bat" ^|^| goto :EOF
) > "%CONFIGURE_ROOT%/Scripts/Tools/scm/svn/__init__.bat"

exit /b 0
