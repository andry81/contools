@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

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

rem overflow tests
setlocal ENABLEDELAYEDEXPANSION

set __STRING__=a
set STRING_LEN=1

for /L %%i in (1,1,13) do (
  call :TEST "%%STRING_LEN%%"

  set "__STRING__=!__STRING__!!__STRING__!"
  set /A STRING_LEN*=2
)

endlocal

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
