@echo off

setlocal DISABLEDELAYEDEXPANSION

setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do endlocal & set "STRING_INPUT=%%i"

call "%%CONTOOLS_ROOT%%/std/encode/encode_%%TEST_FUNC%%.bat" || exit /b 255

setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do endlocal & set "STRING_ENCODED=%%i"

call "%%CONTOOLS_ROOT%%/std/encode/decode_%%TEST_FUNC%%.bat" || exit /b 255

setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do endlocal & set "STRING_OUTPUT=%%i"

if %TESTLIB__OVERALL_TESTS% GTR %TESTLIB__CURRENT_TESTS% (
  set "TEST_REPORT_PREFIX_STR=%TESTLIB__OVERALL_TESTS%`%TESTLIB__CURRENT_TESTS%"
) else set "TEST_REPORT_PREFIX_STR=%TESTLIB__CURRENT_TESTS%"

setlocal ENABLEDELAYEDEXPANSION

rem print strings can contain batch control characters

if "!STRING_INPUT!" EQU "!STRING_OUTPUT!" (
  "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/printf.exe" "PASSED: %TEST_REPORT_PREFIX_STR%: ${TEST_FUNC}: STRING_INPUT=`${STRING_INPUT}`"
  exit /b 0
)

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/printf.exe" "FAILED: %TEST_REPORT_PREFIX_STR%: ${TEST_FUNC}: STRING_INPUT=`${STRING_INPUT}` STRING_OUTPUT=`${STRING_OUTPUT}`"

exit /b 1
