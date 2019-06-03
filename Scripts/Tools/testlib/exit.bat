@echo off

rem Description:
rem   The tests exit script. Must be called one time in user test script after
rem   the last call to the test.bat script.

rem WARNING:
rem   The script must be called without the call prefix!

set LASTERROR=0

:TEST_TEARDOWN
if %TESTLIB__TEST_DO_TEARDOWN%0 NEQ 0 (
  set "TESTLIB__TEST_DO_TEARDOWN="
  call :TEST_TEARDOWN || ( call set "LASTERROR=%%ERRORLEVEL%%" )
)

rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set "LASTERROR=%LASTERROR%"
  set "TESTLIB__OVERALL_PASSED_TESTS=%TESTLIB__OVERALL_PASSED_TESTS%"
  set "TESTLIB__OVERALL_TESTS=%TESTLIB__OVERALL_TESTS%"
  set "TESTLIB__NEST_LVL=%TESTLIB__NEST_LVL%"
)

set /A TESTLIB__NEST_LVL-=1

if %TESTLIB__NEST_LVL%0 EQU 0 (
  echo    %TESTLIB__OVERALL_PASSED_TESTS% of %TESTLIB__OVERALL_TESTS% tests is passed.
  echo.^
  pause
)

exit /b

:TEST_TEARDOWN
if %TESTLIB__TEST_SETUP%0 EQU 0 exit /b -1
set "TESTLIB__TEST_SETUP="
set TESTLIB__TEST_TEARDOWN=1

rem call user teardown script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.teardown%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.teardown%%TEST_SCRIPT_FILE_EXT%%" || exit /b
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/teardown%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/teardown%%TEST_SCRIPT_FILE_EXT%%" || exit /b
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/teardown%TEST_SCRIPT_FILE_EXT%" (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/teardown%%TEST_SCRIPT_FILE_EXT%%" || exit /b
  )
)

rem negative return code to indicate no error in the teardown
if %LASTERROR% EQU 0 ^
if %TESTLIB__CURRENT_PASSED_TESTS% LSS %TESTLIB__CURRENT_TESTS% set /A LASTERROR=TESTLIB__CURRENT_PASSED_TESTS-TESTLIB__CURRENT_TESTS

exit /b %LASTERROR%
