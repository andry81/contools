@echo off

rem Description:
rem   Tests for `for` loop expressions in variables from
rem   `declare_func_vars.bat` script.
rem
rem   Demonstrates a big for-loop with the fast exit.

rem CAUTION:
rem   The delayed expansion feature must be disabled in the case of %-syntax:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b


call "%%CONTOOLS_ROOT%%/std/declare_func_vars.bat" || exit /b

rem reset all test variables at first
set INDEX=0
set INDEXREF=0

rem immediate exit

%@DO_LOOP_16x8@% ^
goto :EXIT
:EXIT
call :TEST

rem 10 iterations

setlocal
set INDEXREF=10
%@DO_LOOP_16x8@% (
  set /A INDEX+=1
  call "%%CONTOOLS_ROOT%%/std/if_.bat" %%INDEX%% GEQ %%INDEXREF%% && goto :EXIT
)
:EXIT
call :TEST
endlocal

rem 10 iterations in a subroutine

setlocal
set INDEXREF=10
%@DO_LOOP_16x8@% call :FOR || goto EXIT
goto EXIT
:FOR
set /A INDEX+=1
if %INDEX% GEQ %INDEXREF% exit /b 1
exit /b 0
:EXIT
call :TEST
endlocal

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
