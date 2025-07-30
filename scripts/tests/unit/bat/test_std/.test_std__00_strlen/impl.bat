@echo off

setlocal

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v
set ERRORLEVEL_RETURNED=%ERRORLEVEL%

if %STRING_LEN% EQU %ERRORLEVEL_RETURNED% (
  rem print string containing __STRING__ environment variable value which may hold batch control characters
  "%CONTOOLS_UTILS_BIN_ROOT%/contools/printf.exe" "PASSED: %TESTLIB__TEST_ORDER_NUMBER%: STRING_LEN=%STRING_LEN% STRING=`${__STRING__}`"
  exit /b 0
)

rem print string containing __STRING__ environment variable value which may hold batch control characters
"%CONTOOLS_UTILS_BIN_ROOT%/contools/printf.exe" "FAILED: %TESTLIB__TEST_ORDER_NUMBER%: (%ERRORLEVEL_RETURNED% == %STRING_LEN%) STRING=`${__STRING__}`"

exit /b 1
