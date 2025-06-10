@echo off

setlocal DISABLEDELAYEDEXPANSION

rem update CMDLINE with FLAGS
set "PREFIXED_CMDLINE="
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!CMDLINE!") do endlocal & if defined FLAGS (
  set "PREFIXED_CMDLINE=%FLAGS% %%i"
) else set "PREFIXED_CMDLINE=%%i"

set RETURN_VALUE=-1
call "%%CONTOOLS_ROOT%%/std/ifn_and.bat" %%PREFIXED_CMDLINE%% && set "RETURN_VALUE=1" || set "RETURN_VALUE=0"

if defined PREFIXED_CMDLINE (
  set $CMDLINE=${PREFIXED_CMDLINE}
) else set "$CMDLINE="

"%CONTOOLS_UTILS_BIN_ROOT%/contools/envvarcmp.exe" RETURN_VALUE RETURN_REFERENCE "" ^
  "PASSED: %TESTLIB__TEST_ORDER_NUMBER%: RESULT=`{0}` CMDLINE=`%$CMDLINE%`" ^
  "FAILED: %TESTLIB__TEST_ORDER_NUMBER%: RESULT=`{0}` REFERENCE=`{1}` CMDLINE=`%$CMDLINE%`" || exit /b 1

exit /b 0
