@echo off

rem Drop last error level
cd .

rem Create local variable's stack
setlocal

if 0%__CTRL_SETLOCAL% EQU 1 (
  echo.%~nx0: error: cmd.exe is broken, please restart it!>&2
  exit /b 65535
)
set __CTRL_SETLOCAL=1

call "%%~dp0__init__.bat" || goto :EOF
call "%%TESTLIB_ROOT%%/init.bat" "%%~dpf0" || goto :EOF

call :TEST "_common/01_empty.txt"   "01_empty"
call :TEST "_common/02_base.txt"    "11_inexact"
call :TEST "_common/02_base.txt"    "12_exact"                  -exact
call :TEST "_common/02_base.txt"    "21_inexact_w_props"
call :TEST "_common/02_base.txt"    "22_exact_w_props"          -exact
call :TEST "_common/02_base.txt"    "31_inexact_ignore_props"           -ignore-props
call :TEST "_common/02_base.txt"    "32_exact_ignore_props"     -exact  -ignore-props

if %LASTERROR% EQU 0 echo.

rem WARNING: must be called without the call prefix!
"%TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%TESTLIB_ROOT%%/test.bat" %%*
exit /b
