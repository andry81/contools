@echo off

setlocal

call "%%CONTOOLS_ROOT%%/extract_version.bat" "%%VERSION_IN%%" %%TEST_DATA_CMD_LINE%%
set "ERRORLEVEL_RETURNED=%ERRORLEVEL%"
set "VERSION_RETURNED=%RETURN_VALUE%"

if %TESTLIB__OVERALL_TESTS% GTR %TESTLIB__CURRENT_TESTS% (
  set "TEST_REPORT_PREFIX_STR=%TESTLIB__OVERALL_TESTS%`%TESTLIB__CURRENT_TESTS%"
) else set "TEST_REPORT_PREFIX_STR=%TESTLIB__CURRENT_TESTS%"

if %ERRORLEVEL_RETURNED% NEQ 0 (
  call "%CONTOOLS_ROOT%/envvarcmp.exe" VERSION_RETURNED VERSION_REF "" ^
    "FAILED: %TEST_REPORT_PREFIX_STR%: ERRORLEVEL=%ERRORLEVEL_RETURNED% RESULT=`{0}` REFERENCE=`{1}`" ^
    "FAILED: %TEST_REPORT_PREFIX_STR%: ERRORLEVEL=%ERRORLEVEL_RETURNED% RESULT=`{0}` REFERENCE=`{1}` (`{0hs}` != `{1hs}`)"
  echo.
  exit /b 1
)

"%CONTOOLS_ROOT%/envvarcmp.exe" VERSION_RETURNED VERSION_REF "" ^
  "PASSED: %TEST_REPORT_PREFIX_STR%: ERRORLEVEL=%ERRORLEVEL_RETURNED% RESULT=`{0}`" ^
  "FAILED: %TEST_REPORT_PREFIX_STR%: ERRORLEVEL=%ERRORLEVEL_RETURNED% RESULT=`{0}` REFERENCE=`{1}` (`{0hs}` != `{1hs}`)"
if %ERRORLEVEL% NEQ 0 (
  echo.
  exit /b 2
)

exit /b 0
