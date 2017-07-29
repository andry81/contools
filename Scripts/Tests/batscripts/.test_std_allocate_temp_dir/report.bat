@echo off

if %LASTERROR% NEQ 0 (
  echo.FAILED: %TESTLIB__OVERALL_TESTS%.%TESTLIB__CURRENT_TESTS%: ERROR=%LASTERROR% REFERENCE=`%TEST_DATA_REF_DIR%` OUTPUT=`%TEST_SRC_BASE_DIR%\_output\%TEST_TEMP_DIR_NAME%` TEMPDIR=`%TEST_TEMP_DIR%`
  echo.
  exit /b 0
)

echo.PASSED: %TESTLIB__OVERALL_TESTS%.%TESTLIB__CURRENT_TESTS%: REFERENCE=`%TEST_DATA_REF_DIR%`

exit /b 0
