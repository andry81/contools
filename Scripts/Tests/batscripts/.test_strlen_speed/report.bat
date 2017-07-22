@echo off

setlocal

if %TESTLIB__OVERALL_TESTS% GTR %TESTLIB__TEST_COUNT% (
  set "TEST_REPORT_PREFIX_STR=%TESTLIB__OVERALL_TESTS%`%TESTLIB__TEST_COUNT%"
) else set "TEST_REPORT_PREFIX_STR=%TESTLIB__TEST_COUNT%"

if %STRING_LEN% EQU %ERRORLEVEL_RETURNED% (
  rem print string containing __STRING__ environment variable value which may hold batch control characters
  "%CONTOOLS_ROOT%/printf.exe" "PASSED: %TEST_REPORT_PREFIX_STR%: (%ERRORLEVEL_RETURNED% == %STRING_LEN%) STRING=`${__STRING__}`"
  exit /b 0
)

rem print string containing __STRING__ environment variable value which may hold batch control characters
"%CONTOOLS_ROOT%/printf.exe" "FAILED: %TEST_REPORT_PREFIX_STR%: (%ERRORLEVEL_RETURNED% == %STRING_LEN%) STRING=`${__STRING__}`"

exit /b 1
