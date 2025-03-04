@echo off

setlocal

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config.bat" . . "%%CONFIG_FILE%%" "%%PARAM0%%" "%%PARAM1%%"

if %TESTLIB__OVERALL_TESTS% GTR %TESTLIB__CURRENT_TESTS% (
  set "TEST_REPORT_PREFIX_STR=%TESTLIB__OVERALL_TESTS%`%TESTLIB__CURRENT_TESTS%"
) else set "TEST_REPORT_PREFIX_STR=%TESTLIB__CURRENT_TESTS%"

echo.PARAM0=%PARAM0%
echo.PARAM1=%PARAM1%

set LAST_ERROR=0
set TEST_CASE_INDEX=1
for %%i in (%TEST_VAR_NAME_SUFFIX_LIST%) do (
  "%CONTOOLS_UTILS_BIN_ROOT%/contools/envvarcmp.exe" %TEST_VAR_NAME_PREFIX%%%i %REFERENCE_VAR_NAME_PREFIX%%%i "" ^
    "PASSED: %TEST_REPORT_PREFIX_STR%`${TEST_CASE_INDEX}: VAR=`${TEST_VAR_NAME_PREFIX}%%i` RESULT=`{0}`" ^
    "FAILED: %TEST_REPORT_PREFIX_STR%`${TEST_CASE_INDEX}: VAR=`${TEST_VAR_NAME_PREFIX}%%i` RESULT=`{0}` REFERENCE=`{1}`" || set /A "LAST_ERROR|=0x80000000"
  set /A TEST_CASE_INDEX+=1
)

echo.

exit /b %LAST_ERROR%
