@echo off

rem Create local variable's stack
setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

set "CMDLINE="
set ARGS_COUNT_REFERENCE=0
call :TEST
call :TEST --
call :TEST -exe
call :TEST -exe --
echo;---

set "CMDLINE= 	 		  	 "
set ARGS_COUNT_REFERENCE=0
call :TEST
call :TEST --
call :TEST -exe
call :TEST -exe --
echo;---

rem CAUTION:
rem   Last 2 pargument is a single argument!
rem
set CMDLINE= 	 	 	 1 ! 2 ^| 3 ^& 4 ^^ 5 = 6 , 7 ; 8 * 9 # 0 %% 1 / 2 \ 3 ? 4 ^> 5 ^< 6 " 7 	 	 	 
set ARGS_COUNT_REFERENCE=29
call :TEST
call :TEST --
set ARGS_COUNT_REFERENCE=32
call :TEST -exe
call :TEST -exe --
echo;---

set CMDLINE="1 2" ! ? * ^& ^| , ; = ^= "=" 3
set ARGS_COUNT_REFERENCE=8
call :TEST
call :TEST --
set ARGS_COUNT_REFERENCE=12
call :TEST -exe
call :TEST -exe --
echo;---

set CMDLINE=$*^|^&(=)^<^>^"='`^^%%!+?** ,;=
set ARGS_COUNT_REFERENCE=2
call :TEST
call :TEST --
set ARGS_COUNT_REFERENCE=1
call :TEST -exe
call :TEST -exe --

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
