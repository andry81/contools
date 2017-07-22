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

set __STRING__= ^	-^"'`^?^*^&^|^<^>^(^)
call :TEST 14

set __STRING__= ^	-^"'`^?^*
call :TEST 8

set __STRING__='`^?^*^&^|^<^>^(^)%%
call :TEST 11

set __STRING__= ^	-^"'`^?^*^&^|^<^>^(^)^"
call :TEST 15

set __STRING__= ^	-^"'`^?^*^&^|^<^>^(^)^"'`
call :TEST 17

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

if %LASTERROR% EQU 0 echo.

rem WARNING: must be called without the call prefix!
"%TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%TESTLIB_ROOT%%/test.bat" %%*
exit /b
