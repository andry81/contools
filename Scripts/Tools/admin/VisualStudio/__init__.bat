@echo off

if %__BASE_INIT__%0 NEQ 0 exit /b

if not defined NEST_LVL set NEST_LVL=0

set "CONFIGURE_ROOT=%~dp0"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:~0,-1%"

rem load config
call "%%CONFIGURE_ROOT%%\tools\load_config.bat" "%%CONFIGURE_ROOT%%" "config.vars" || exit /b

set __BASE_INIT__=1

exit /b 0
