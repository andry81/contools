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

set __COUNTER1=1

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

goto EXIT

:TEST
set "STRING_LEN=%~1"
set "STRING_REFERENCE=%~2"
call :CMD "%%TOOLS_PATH%%\strrep.bat" /v "" "" ESCAPED_STRING
set LASTERRORLEVEL=%ERRORLEVEL%
goto CMD_END

:CMD
echo.^>%~nx1 %2 %3 %4 %5
(%*)
exit /b
:CMD_END

if %LASTERRORLEVEL% NEQ %STRING_LEN% goto TEST_LASTERRORLEVEL

"%TOOLS_PATH%\envvarcmp.exe" ESCAPED_STRING STRING_REFERENCE "" ^
  "PASSED: %__COUNTER1%: (%LASTERRORLEVEL% == %STRING_LEN%) RESULT=`{0}` STRING=`${__STRING__}` CHARS=`${__CHARS__}`" ^
  "FAILED: %__COUNTER1%: (%LASTERRORLEVEL% == %STRING_LEN%) RESULT=`{0}` STRING=`${__STRING__}` CHARS=`${__CHARS__}` (`{0hs}` != `{1hs}`)"

if %ERRORLEVEL% NEQ 0 goto TEST_END

:TEST_LASTERRORLEVEL
rem additional test on errorlevel
if %LASTERRORLEVEL% NEQ %STRING_LEN% (
  "%TOOLS_PATH%\envvarcmp.exe" ESCAPED_STRING STRING_REFERENCE "" ^
    "FAILED: %__COUNTER1%: (%LASTERRORLEVEL% == %STRING_LEN%) RESULT=`{0}` STRING=`${__STRING__}` CHARS=`${__CHARS__}`" ^
    "FAILED: %__COUNTER1%: (%LASTERRORLEVEL% == %STRING_LEN%) RESULT=`{0}` STRING=`${__STRING__}` CHARS=`${__CHARS__}` (`{0hs}` != `{1hs}`)"
  goto TEST_END
)

set /A __PASSED_TESTS+=1

:TEST_END
set /A __OVERALL_TESTS+=1
set /A __COUNTER1+=1

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
