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

call "%%~dp0__init__.bat"

echo Running %~nx0...
title %~nx0 %*

set /A __NEST_LVL+=1

set __COUNTER1=1

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
set __COUNTER2=1

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

set /A __COUNTER1+=1

echo.

exit /b 0

:TEST_SEQ2
set __COUNTER2=1

set "__CHARS__="
call :TEST %%1

set __CHARS__=hW
call :TEST %%2

set __CHARS__=OW
call :TEST %%3 /i

set __CHARS__=!
call :TEST %%4

set /A __COUNTER1+=1

echo.

exit /b 0

:TEST
set "STRING_OFFSET=%~1"
call :CMD "%%CONTOOLS_ROOT%%/strchr.bat" /v "" "" %%2
set LASTERRORLEVEL=%ERRORLEVEL%
goto CMD_END

:CMD
echo.^>%~nx1 %2 %3 %4 %5
(%*)
exit /b
:CMD_END

if %LASTERRORLEVEL% GEQ 0 (
  call set "FOUND_CHAR=%%__STRING__:~%LASTERRORLEVEL%,1%%"
) else set "FOUND_CHAR="

if "%FOUND_CHAR%^" == "~%LASTERRORLEVEL%,1^" set "FOUND_CHAR="
if %STRING_OFFSET% EQU %LASTERRORLEVEL% (
  set /A __PASSED_TESTS+=1
  rem print string containing __STRING__ and __CHARS__ environment variable value which may hold batch control characters
  "%CONTOOLS_ROOT%/printf.exe" "PASSED: %__COUNTER1%.%__COUNTER2%: (%STRING_OFFSET% == %LASTERRORLEVEL%) FOUND_CHAR=`${FOUND_CHAR}` STRING=`${__STRING__}` CHARS=`${__CHARS__}`"
) else (
  rem print string containing __STRING__ and __CHARS__ environment variable value which may hold batch control characters
  "%CONTOOLS_ROOT%/printf.exe" "FAILED: %__COUNTER1%.%__COUNTER2%: (%STRING_OFFSET% == %LASTERRORLEVEL%) FOUND_CHAR=`${FOUND_CHAR}` STRING=`${__STRING__}` CHARS=`${__CHARS__}`"
)

set /A __OVERALL_TESTS+=1
set /A __COUNTER2+=1

goto :EOF

:EXIT
rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set __PASSED_TESTS=%__PASSED_TESTS%
  set __OVERALL_TESTS=%__OVERALL_TESTS%
  set __NEST_LVL=%__NEST_LVL%
)

set /A __NEST_LVL-=1

if %__NEST_LVL%0 EQU 0 (
  echo    %__PASSED_TESTS% of %__OVERALL_TESTS% tests is passed.
  pause
)
