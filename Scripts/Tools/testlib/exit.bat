@echo off

rem Description:
rem   The tests exit script. Must be called one time in user test script after
rem   the last call to the test.bat script.

rem WARNING:
rem   Must be called without the call prefix!

rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set LASTERROR=%LASTERROR%
  set TESTLIB__PASSED_TESTS=%TESTLIB__PASSED_TESTS%
  set TESTLIB__OVERALL_TESTS=%TESTLIB__OVERALL_TESTS%
  set TESTLIB__NEST_LVL=%TESTLIB__NEST_LVL%
)

set /A TESTLIB__NEST_LVL-=1

if %TESTLIB__NEST_LVL%0 EQU 0 (
  echo    %TESTLIB__PASSED_TESTS% of %TESTLIB__OVERALL_TESTS% tests is passed.
  echo.^
  pause
)
