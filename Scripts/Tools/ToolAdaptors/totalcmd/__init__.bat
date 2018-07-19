@echo off

if %__TOTALCMD_INIT__%0 NEQ 0 exit /b 0

if exist "%~dp0configure.user.bat" ( call "%~dp0configure.user.bat" || goto :EOF )
if defined CONTOOLS_ROOT_TO set "CONTOOLS_ROOT=%CONTOOLS_ROOT_TO%"

set "TOTALCMD_ROOT=%~dp0"
set "TOTALCMD_ROOT=%TOTALCMD_ROOT:\=/%"
if "%TOTALCMD_ROOT:~-1%" == "/" set "TOTALCMD_ROOT=%TOTALCMD_ROOT:~0,-1%"

call "%%~dp0Tools\__init__.bat" || goto :EOF

set __TOTALCMD_INIT__=1
