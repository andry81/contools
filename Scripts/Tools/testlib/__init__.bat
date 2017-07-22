@echo off

rem Description:
rem   The testlib first time initialization script.

if %__TESTLIB_INIT__%0 NEQ 0 exit /b 0

rem initialize Tools "module"
call "%%~dp0..\__init__.bat" || goto :EOF

set "TESTLIB_ROOT=%CONTOOLS_ROOT%/testlib"

set __TESTLIB_INIT__=1
