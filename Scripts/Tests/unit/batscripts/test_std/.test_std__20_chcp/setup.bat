@echo off

rem read current code page
call "%%CONTOOLS_ROOT%%/std/getcp.bat" SETUP_CP

rem reset `return.vars` variables before testing
for /F "usebackq tokens=* delims="eol^= %%i in ("%~dp0return.vars") do set "%%i="

exit /b 0
