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

set __STRING__=a^&^|\c
call :TEST 5

set __STRING__=a^^^^^>^>
call :TEST 5

set __STRING__=%%a%%\!b!
call :TEST 7

set __STRING__=^	-^"'`^?^*^&^|^<^>^(^)
call :TEST 13

set __STRING__= ^	-^"'`^?^*
call :TEST 8

set __STRING__='`^?^*^&^|^<^>^(^)
call :TEST 10

set __STRING__= ^	-^"'`^?^*^&^|^<^>^(^)^"
call :TEST 15

set __STRING__= ^	-^"'`^?^*^&^|^<^>^(^)^"'`%%
call :TEST 18

set __STRING__=	
call :TEST 1

set __STRING__= ^	
call :TEST 2

set __STRING__=^^
call :TEST 1

set __STRING__=^"
call :TEST 1

set "__STRING__="
call :TEST 0

echo.

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
