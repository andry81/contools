@echo off

if %__TOTALCMD_INIT__%0 NEQ 0 exit /b 0

set "TOTALCMD_ROOT=%~dp0"
set "TOTALCMD_ROOT=%TOTALCMD_ROOT:\=/%"
if "%TOTALCMD_ROOT:~-1%" == "/" set "TOTALCMD_ROOT=%TOTALCMD_ROOT:~0,-1%"

call "%%TOTALCMD_ROOT%%/loadvars.bat" "%%TOTALCMD_ROOT%%/profile.vars" || exit /b

call "%%~dp0Tools\__init__.bat" || exit /b

set __TOTALCMD_INIT__=1
