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

set ?0=^^

call :TEST "file:///./root/dir1/test"                 "file:///./root/./dir1/2/3/4/../../.././dir2/.." "./test"
call :TEST "file:///./root/dir2/test"                 "file:///./root/./dir1/.././dir2" "./test"
call :TEST "file:///./root/test"                      "file:///./root/./dir1/.././dir2" "../test"
call :TEST "https://root/dir1/test"                   "https://root/./dir1/./dir2/.."   "%%?0%%/test"     "https://root/./dir1"
call :TEST "https://root2/test"                       "https://root/./dir1/./dir2/.."   "//root2/test"    "https://root/./dir1"
call :TEST "https://root/test"                        "https://root/./dir1/./dir2/.."   "/test"           "https://root/./dir1"
call :TEST "https://root/dir1/test"                   "https://root/./dir1/./dir2/.."   "test"
call :TEST "https://root/dir1/dir2/dir3"              "https://root/./dir1/./dir2/.."   "https://root/./dir1/./dir2/./dir3"

echo.

goto EXIT

:TEST
set "STRING_REFERENCE=%~1"
call :CMD "%%SVNCMD_TOOLS_ROOT%%/make_url_absolute.bat" %%2 %%3 %%4
set LASTERRORLEVEL=%ERRORLEVEL%
goto CMD_END

:CMD
echo.^>%~nx1 %2 %3 %4
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
