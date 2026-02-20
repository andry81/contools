@echo off

setlocal DISABLEDELAYEDEXPANSION

for /F "usebackq eol=# tokens=1,* delims=|" %%i in ("%TESTS_LIST_FILE%") do call :TEST %%*
exit /b 0

:TEST
for %%a in (:) do for /F "usebackq tokens=1 delims=	 "eol^= %%k in ('"%%i"') do set "RETURN_REFERENCE=%%~k"
for %%a in (:) do for /F "usebackq tokens=* delims=	 "eol^= %%l in ('"%%j"') do set "CMDLINE=%%~l"

set TEST_LAST_ERROR=0
set TEST_IMPL_ERROR=0

if not defined RETURN_REFERENCE set "TEST_LAST_ERROR=255" & goto SKIP_TEST
if not defined CMDLINE set "TEST_LAST_ERROR=255" & goto SKIP_TEST

rem explicitly escape double quotes for the `sed` command line
setlocal ENABLEDELAYEDEXPANSION
set "CMDLINE_ESCAPED=!CMDLINE:"=\"!"
for /F "tokens=* delims="eol^= %%i in ("!CMDLINE_ESCAPED!") do endlocal ^
  & set "CMDLINE_ESCAPED=%%i"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/gen_config.bat" ^
  -+ -noexpire -skip_checks ^
  -r "{{CONTOOLS_ROOT}}" "%%CONTOOLS_ROOT%%" ^
  -r "{{CONTOOLS_PROJECT_EXTERNALS_ROOT}}" "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%" ^
  -r!+ -r "{{SCRIPT}}" "!CMDLINE_ESCAPED!" -r!- ^
  -- "%%TEST_SCRIPT_FILE_DIR%%/.impl" "%%TEST_TEMP_DIR_PATH%%" "test_std__run_singleton_script.bat" >nul ^
  || ( set "LAST_ERROR=255" & goto SKIP_TEST )

rem NOTE:
rem   To debug use `/create-console` instead.

rem isolated test
start "" /I /B /WAIT "%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe" ^
  /no-expand-env /no-subst-pos-vars /create-child-console /no-window /ret-child-exit // ^
  "%COMSPEC%" "/D /C \"@\"%TEST_TEMP_DIR_PATH%/test_std__run_singleton_script.bat\" {*} ^& \"%CONTOOLS_ROOT%/std/errlvl.bat\"\"" ^
  %*

set "TEST_IMPL_ERROR=%ERRORLEVEL%"

call "%%CONTOOLS_ROOT%%/std/cmp_nvar.bat" TEST_IMPL_ERROR EQU RETURN_REFERENCE || set TEST_LAST_ERROR=255

:SKIP_TEST
if %TEST_LAST_ERROR% NEQ 0 (
  call "%%CONTOOLS_ROOT%%/testlib/set_test_failed.bat"
  setlocal ENABLEDELAYEDEXPANSION
  echo;FAILED: !TESTLIB__TEST_ORDER_NUMBER!: RESULT=`!TEST_IMPL_ERROR!` REFERENCE=`!RETURN_REFERENCE!` CMDLINE=`!CMDLINE!`
  echo;
  exit /b 1
)

call "%%CONTOOLS_ROOT%%/testlib/set_test_passed.bat"

setlocal ENABLEDELAYEDEXPANSION
echo;PASSED: !TESTLIB__TEST_ORDER_NUMBER!: RESULT=`!TEST_IMPL_ERROR!` CMDLINE=`!CMDLINE!`

exit /b 0
