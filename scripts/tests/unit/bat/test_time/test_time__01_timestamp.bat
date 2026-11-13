@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

call :TEST 0:0:0.0             0 ""
call :TEST 0:0:0.0             0 " "
call :TEST 0:0:0.0             0 "0"
call :TEST 0:0:0.0             0 ":"
call :TEST 0:0:0.0             0 "/"
call :TEST 0:0:0.0             0 "-"
call :TEST 0:0:0.0             0 "."
call :TEST 0:0:0.0             0 ","
call :TEST 0:0:0.0             0 ";"
call :TEST 0:0:0.0             0 "00:00:00.00"
call :TEST 0:0:0.0             0 " 0: 0: 0. 0"
call :TEST 1:1:1.1       3661010 " 1: 1: 1. 1"
call :TEST 1:1:1.1       3661010 "01:01:01.01"
call :TEST 9:9:9.9      32949090 "09:09:09.09"
call :TEST 19:19:19.19  69559190 "19:19:19.19"
call :TEST 10:10:10.10  36610100 "10:10:10.10"

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
