@echo off

setlocal DISABLEDELAYEDEXPANSION

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & set "STRING_INPUT=%%i"

call "%%CONTOOLS_ROOT%%/std/encode/encode_%%TEST_FUNC%%.bat" || exit /b 255

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & set "STRING_ENCODED=%%i"

call "%%CONTOOLS_ROOT%%/std/encode/decode_%%TEST_FUNC%%.bat" || exit /b 255

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & set "STRING_OUTPUT=%%i"

setlocal ENABLEDELAYEDEXPANSION

rem print strings can contain batch control characters

if "!STRING_INPUT!" EQU "!STRING_OUTPUT!" (
  "%CONTOOLS_UTILS_BIN_ROOT%/contools/printf.exe" "PASSED: %TESTLIB__TEST_ORDER_NUMBER%: ${TEST_FUNC}: STRING_INPUT=`${STRING_INPUT}`"
  exit /b 0
)

"%CONTOOLS_UTILS_BIN_ROOT%/contools/printf.exe" "FAILED: %TESTLIB__TEST_ORDER_NUMBER%: ${TEST_FUNC}: STRING_INPUT=`${STRING_INPUT}` STRING_OUTPUT=`${STRING_OUTPUT}`"

exit /b 1
