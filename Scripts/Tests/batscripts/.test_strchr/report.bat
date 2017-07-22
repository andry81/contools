@echo off

setlocal

if %TESTLIB__OVERALL_TESTS% GTR %TESTLIB__TEST_COUNT% (
  set "TEST_REPORT_PREFIX_STR=%TESTLIB__OVERALL_TESTS%`%__TEST_COUNT_OUTTER%`%TESTLIB__TEST_COUNT%"
) else set "TEST_REPORT_PREFIX_STR=%__TEST_COUNT_OUTTER%`%TESTLIB__TEST_COUNT%"

if %ERRORLEVEL_RETURNED% GEQ 0 (
  call set "FOUND_CHAR=%%__STRING__:~%ERRORLEVEL_RETURNED%,1%%"
) else set "FOUND_CHAR="

if "%FOUND_CHAR%^" == "~%ERRORLEVEL_RETURNED%,1^" set "FOUND_CHAR="
if %STRING_OFFSET% EQU %ERRORLEVEL_RETURNED% (
  rem print string containing __STRING__ and __CHARS__ environment variable value which may hold batch control characters
  "%CONTOOLS_ROOT%/printf.exe" "PASSED: %TEST_REPORT_PREFIX_STR%: (%STRING_OFFSET% == %ERRORLEVEL_RETURNED%) FOUND_CHAR=`${FOUND_CHAR}` STRING=`${__STRING__}` CHARS=`${__CHARS__}`"
  exit /b 0
)

rem print string containing __STRING__ and __CHARS__ environment variable value which may hold batch control characters
"%CONTOOLS_ROOT%/printf.exe" "FAILED: %TEST_REPORT_PREFIX_STR%: (%STRING_OFFSET% == %ERRORLEVEL_RETURNED%) FOUND_CHAR=`${FOUND_CHAR}` STRING=`${__STRING__}` CHARS=`${__CHARS__}`"

exit /b 1
