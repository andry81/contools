@echo off

rem Description:
rem   Tests demonstrates assignment of any variable's value using only %-syntax
rem   (no need a `setlocal ENABLEDELAYEDEXPANSION`).
rem
rem   NOTE:
rem     Does not include the case with the `setlocal ENABLEDELAYEDEXPANSION`
rem     where `!` is escaped.

rem CAUTION:
rem   The delayed expansion feature must be disabled in the case of %-syntax:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem double quotes plus escaping

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR="
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=^"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=""
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=^""
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR="^"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=^"^"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR="""
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=^"""
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR="^""
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=""^"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=^"^""
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR="^"^"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=^"^"^"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=^""^"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

rem double quotes plus some control characters

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR="1 2 3" ^& "4 | 5"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR="1 2 3" ^& "4 | 5"x
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=x"1 2 3" ^& "4 | 5"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=x"1 2 3" ^& "4 | 5"x
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR="1 2 3" ^& "4 | 5""
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=""1 2 3" & "4 ^| 5""
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=""1 2 3" & "4 ^| 5"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=1 2 3" & "4 ^| 5"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=1 2 3" & "4 ^| 5
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=1 2 3 ^& "4 | 5
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=1 2 3 ^& 4 ^| 5
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

rem mixed

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR= ^	-^"'`^?^*^&^|^<^>^(^)
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR= ^	-^"'`^?^*
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR='`^?^*^&^|^<^>^(^)%%
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR= ^	-^"'`^?^*^&^|^<^>^(^)^"
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR= ^	-^"'`^?^*^&^|^<^>^(^)^"'`
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR= 	 	 	 1 ! 2 ^| 3 ^& 4 ^^ 5 = 6 , 7 ; 8 * 9 # 0 %% 1 / 2 \ 3 ? 4 ^> 5 ^< 6 " 7 	 	 	 
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR="1 2" ! ? * ^& ^| , ; = ^= "=" 3
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=$*^|^&(=)^<^>^"='`^^%%!+?** ,;=
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=	
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR= ^	
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set RVAR=^^
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

rem empty variable test

call "%%CONTOOLS_TESTLIB_ROOT%%/echo_on.bat"
set "RVAR="
@call "%%CONTOOLS_TESTLIB_ROOT%%/echo_off.bat"
call :TEST

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
