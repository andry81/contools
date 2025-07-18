@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

call :TEST "_common/01_empty.txt"   "01_empty"
call :TEST "_common/02_base.txt"    "11_inexact"
call :TEST "_common/02_base.txt"    "12_exact"                  -exact
call :TEST "_common/02_base.txt"    "21_inexact_w_props"
call :TEST "_common/02_base.txt"    "22_exact_w_props"          -exact
call :TEST "_common/02_base.txt"    "31_inexact_ignore_props"           -ignore-props
call :TEST "_common/02_base.txt"    "32_exact_ignore_props"     -exact  -ignore-props

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
