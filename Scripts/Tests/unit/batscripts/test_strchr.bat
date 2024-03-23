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

set __TEST_COUNT_OUTTER=1

set __STRING__=012345 78901^	-^"'`^?^*^&^|^<^>^(^)
call :TEST_SEQ1 6 6 15 12 6 -1 14 -1 25

set __STRING__=012345 78901^&^|^<^>^(^)%%
call :TEST_SEQ1 6 6 12 -1 6 -1 -1 18 19

set __STRING__=^^
call :TEST_SEQ1 -1 -1 -1 -1 -1 0 -1 -1 1

set __STRING__=^"
call :TEST_SEQ1 0 0 -1 -1 -1 -1 0 -1 1

set __STRING__=012345
call :TEST_SEQ1 -1 -1 -1 -1 -1 -1 -1 -1 6

set __STRING__=Hello world!
call :TEST_SEQ2 12 -1 4 11

set "__STRING__="
call :TEST_SEQ2 -1 -1 -1 -1

goto EXIT

:TEST_SEQ1
rem reset tests counter
set TESTLIB__CURRENT_TESTS=0

set __CHARS__= ^	-^"'`^?^*^&^|^<^>^(^)
call :TEST %%1

set __CHARS__= ^	-^"'`^?^*
call :TEST %%2

set __CHARS__='`^?^*^&^|^<^>^(^)
call :TEST %%3

set __CHARS__=	
call :TEST %%4

set __CHARS__= ^	
call :TEST %%5

set __CHARS__=^^
call :TEST %%6

set __CHARS__=^"
call :TEST %%7

set __CHARS__=%%
call :TEST %%8

set "__CHARS__="
call :TEST %%9

set /A __TEST_COUNT_OUTTER+=1

echo.

exit /b 0

:TEST_SEQ2
rem reset tests counter
set TESTLIB__CURRENT_TESTS=0

set "__CHARS__="
call :TEST %%1

set __CHARS__=hW
call :TEST %%2

set __CHARS__=OW
call :TEST %%3 /i

set __CHARS__=!
call :TEST %%4

set /A __TEST_COUNT_OUTTER+=1

echo.

exit /b 0

:EXIT
echo.

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
