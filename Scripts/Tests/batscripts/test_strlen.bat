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

echo.

goto EXIT

:TEST
set "STRING_LEN=%~1"
call :CMD "%%CONTOOLS_ROOT%%/strlen.bat" /v
set LASTERRORLEVEL=%ERRORLEVEL%
goto CMD_END

:CMD
echo.^>%~nx1 %2
(%*)
exit /b
:CMD_END

if %STRING_LEN% EQU %LASTERRORLEVEL% (
  set /A __PASSED_TESTS+=1
  rem print string containing __STRING__ environment variable value which may hold batch control characters
  "%CONTOOLS_ROOT%/printf.exe" "PASSED: %__COUNTER1%: (%LASTERRORLEVEL% == %STRING_LEN%) STRING=`${__STRING__}`"
) else (
  rem print string containing __STRING__ environment variable value which may hold batch control characters
  "%CONTOOLS_ROOT%/printf.exe" "FAILED: %__COUNTER1%: (%LASTERRORLEVEL% == %STRING_LEN%) STRING=`${__STRING__}`"
)

set /A __OVERALL_TESTS+=1
set /A __COUNTER1+=1

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
