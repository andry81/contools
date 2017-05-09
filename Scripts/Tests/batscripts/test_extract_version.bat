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

call :TEST "1.7.5.1"      "1.7.5-1" 
call :TEST "1.7.5.1"      "1.7.5-1" -d
call :TEST "2.1.0.1"      "2.1-1"
call :TEST "2.1.0.1"      "2.1-1" -d
call :TEST "1.4.6.10"     "1.4p6-10"
call :TEST "1.4.6.10"     "1.4p6-10" -d
call :TEST "00885.0.0.1"  "00885-1"
call :TEST "00885.0.0.1"  "00885-1" -d
call :TEST "1.3.30c.10"   "1.3.30c-10"
call :TEST "1.3.30.10"    "1.3.30c-10" -d
call :TEST "20050522.0.0.1"   "20050522-1"
call :TEST "20050522.0.0.1"   "20050522-1" -d
call :TEST "5.7.20091114.14"  "5.7_20091114-14"
call :TEST "5.7.20091114.14"  "5.7_20091114-14" -d
call :TEST "4.5.20.2.2"   "4.5.20.2-2"
call :TEST "4.5.20.2.2"   "4.5.20.2-2" -d
call :TEST "2009k.0.0.1"  "2009k-1"
call :TEST "2009.0.0.1"   "2009k-1" -d
call :TEST "1.2.3c.4.5"   "1.2.3c.4.5"
call :TEST "1.2.3.4.5"    "1.2.3c.4.5" -d

echo.

goto EXIT

:TEST
set "STRING_REFERENCE=%~1"
call :CMD "%%CONTOOLS_ROOT%%/extract_version.bat" %%2 %%3
set LASTERRORLEVEL=%ERRORLEVEL%
goto CMD_END

:CMD
echo.^>%~nx1 %2 %3
(%*)
exit /b
:CMD_END

if %LASTERRORLEVEL% NEQ 0 goto TEST_LASTERRORLEVEL

"%CONTOOLS_ROOT%/envvarcmp.exe" RETURN_VALUE STRING_REFERENCE "" ^
  "PASSED: %__COUNTER1%: ERRORLEVEL=%LASTERRORLEVEL% RESULT=`{0}`" ^
  "FAILED: %__COUNTER1%: ERRORLEVEL=%LASTERRORLEVEL% RESULT=`{0}` REFERENCE=`{1}` (`{0hs}` != `{1hs}`)"

if %ERRORLEVEL% NEQ 0 goto TEST_END

:TEST_LASTERRORLEVEL
rem additional test on errorlevel
if %LASTERRORLEVEL% NEQ 0 (
  "%CONTOOLS_ROOT%/envvarcmp.exe" RETURN_VALUE STRING_REFERENCE "" ^
    "FAILED: %__COUNTER1%: ERRORLEVEL=%LASTERRORLEVEL% RESULT=`{0}`" ^
    "FAILED: %__COUNTER1%: ERRORLEVEL=%LASTERRORLEVEL% RESULT=`{0}` REFERENCE=`{1}` (`{0hs}` != `{1hs}`)"
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
  set __NEST_LVL=%__NEST_LVL%
)

set /A __NEST_LVL-=1

if %__NEST_LVL%0 EQU 0 (
  echo    %__PASSED_TESTS% of %__OVERALL_TESTS% tests is passed.
  pause
)
