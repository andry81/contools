@echo off

setlocal

call "%%CONTOOLS_ROOT%%/std/trim_var.bat" STRING_TO_TRIM STRING_TRIMMED

"%CONTOOLS_UTILS_BIN_ROOT%/contools/envvarcmp.exe" STRING_TRIMMED STRING_REFERENCE "" ^
  "PASSED: %TESTLIB__TEST_ORDER_NUMBER%: RESULT=`{0}`" ^
  "FAILED: %TESTLIB__TEST_ORDER_NUMBER%: RESULT=`{0}` REFERENCE=`{1}`" || exit /b 1

exit /b 0
