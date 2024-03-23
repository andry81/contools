@echo off

rem Create local variable's stack
setlocal

if 0%__CTRL_SETLOCAL% EQU 1 (
  echo.%~nx0: error: cmd.exe is broken, please restart it!>&2
  exit /b 65535
)
set __CTRL_SETLOCAL=1

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

set __STRING__=012345 78901^	-'`^?^*^&^|^<^>^(^)
set __CHARS__= ^	-/
call :TEST 24 "012345	78901	/'`?*&|<>()"

set __STRING__=012345 78901^	-'`^?^*^&^|^<^>^(^)
set __CHARS__= /^&^|^|^&
call :TEST 24 "012345/78901	-'`?*|&<>()"

set __STRING__=^^
set __CHARS__= /^^^*
call :TEST 1 "*"

set __STRING__=012345
set __CHARS__=1/3/
call :TEST 6 "0/2/45"

set __STRING__=Hello world!
set __CHARS__= ^|!/
call :TEST 12 "Hello|world/"

set "__STRING__="
set __CHARS__= ^|!/
call :TEST 0 ""

echo.

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
