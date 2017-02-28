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

call "%%~dp0init.bat"

echo Running %~nx0...
title %~nx0 %*

set /A NEST_LVL+=1

setlocal EnableDelayedExpansion

set __COUNTER1=1
set __STRING__=a
set __STRING_LEN__=1

for /L %%i in (1,1,13) do (
  call :TEST
)

echo.

goto EXIT

:TEST
call :CMD "%%TOOLS_PATH%%\strlen.bat" /v
set LASTERRORLEVEL=%ERRORLEVEL%
goto CMD_END

:CMD
echo.^>%~nx1 %2
(%*)
exit /b
:CMD_END

if %__STRING_LEN__% EQU %LASTERRORLEVEL% (
  set /A __PASSED_TESTS+=1
  rem print string containing __STRING__ and __CHARS__ environment variable value which may hold batch control characters
  "%TOOLS_PATH%\printf.exe" "PASSED: %__COUNTER1%: (%__STRING_LEN__% == %LASTERRORLEVEL%) STRING=`${__STRING__}`"
) else (
  "%TOOLS_PATH%\printf.exe" "FAILED: %__COUNTER1%: (%__STRING_LEN__% == %LASTERRORLEVEL%) STRING=`${__STRING__}`"
)

set /A __OVERALL_TESTS+=1
set /A __COUNTER1+=1

set __STRING__=!__STRING__!!__STRING__!
set /A __STRING_LEN__*=2

goto :EOF

:EXIT
rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set __PASSED_TESTS=%__PASSED_TESTS%
  set __OVERALL_TESTS=%__OVERALL_TESTS%
  set NEST_LVL=%NEST_LVL%
)

set /A NEST_LVL-=1

if %NEST_LVL%0 EQU 0 (
  echo    %__PASSED_TESTS% of %__OVERALL_TESTS% tests is passed.
  pause
)
