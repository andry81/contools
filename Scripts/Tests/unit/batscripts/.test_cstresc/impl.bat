@echo off

setlocal

call "%%CONTOOLS_ROOT%%/cstresc.bat" "%%__STRING__%%" STRING_ESCAPED "%%__CHARS__%%"
set ERRORLEVEL_RETURNED=%ERRORLEVEL%

if %TESTLIB__OVERALL_TESTS% GTR %TESTLIB__CURRENT_TESTS% (
  set "TEST_REPORT_PREFIX_STR=%TESTLIB__OVERALL_TESTS%`%TESTLIB__CURRENT_TESTS%"
) else set "TEST_REPORT_PREFIX_STR=%TESTLIB__CURRENT_TESTS%"

if %ERRORLEVEL_RETURNED% NEQ %STRING_LEN% (
  "%CONTOOLS_UTILITIES_BIN_ROOT%/envvarcmp.exe" STRING_ESCAPED STRING_REFERENCE "" ^
    "FAILED: %TEST_REPORT_PREFIX_STR%: (%ERRORLEVEL_RETURNED% == %STRING_LEN%) RESULT=`{0}` STRING=`${__STRING__}` REFERENCE=`{1}` CHARS=`${__CHARS__}`" ^
    "FAILED: %TEST_REPORT_PREFIX_STR%: (%ERRORLEVEL_RETURNED% == %STRING_LEN%) RESULT=`{0}` STRING=`${__STRING__}` REFERENCE=`{1}` CHARS=`${__CHARS__}` (`{0hs}` != `{1hs}`)"
  echo.
  exit /b 1
)

"%CONTOOLS_UTILITIES_BIN_ROOT%/envvarcmp.exe" STRING_ESCAPED STRING_REFERENCE "" ^
  "PASSED: %TEST_REPORT_PREFIX_STR%: STRING_LEN=%STRING_LEN% RESULT=`{0}` STRING=`${__STRING__}` CHARS=`${__CHARS__}`" ^
  "FAILED: %TEST_REPORT_PREFIX_STR%: STRING_LEN=%STRING_LEN% RESULT=`{0}` STRING=`${__STRING__}` REFERENCE=`{1}` CHARS=`${__CHARS__}` (`{0hs}` != `{1hs}`)"
if %ERRORLEVEL% NEQ 0 (
  echo.
  exit /b 2
)

exit /b 0
