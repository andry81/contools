@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

set "UNEXISTED="
set "VARREF="

set ERRLVL=321

call :SETERR %%ERRLVL%%

call :TEST VAR

set VAL=123
set VARREF=123
call :TEST VAR VAL

set VARREF=23
call :TEST VAR VAL:~1

set "VARREF="
call :TEST VAR VAL:~100

call :TEST VAR UNEXISTED

call :TEST VAR UNEXISTED:~1

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
call :SETERR %%ERRLVL%%
exit /b

:SETERR
exit /b %*
