@echo off

setlocal DISABLEDELAYEDEXPANSION

set "TEST_LOG=%TEST_TEMP_DIR_PATH%/test_impl.log"

rem NOTE:
rem   The `CMDLINE` value has double quotes so explicitly enable delayed
rem   expansion to pass it through the Windows Batch command line.
rem   The `-esc_dbl_quote` flag automatically escapes all double quotes.
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/gen_config.bat" ^
  -+ -noexpire -skip_checks ^
  -r "{{CONTOOLS_ROOT}}" "%%CONTOOLS_ROOT%%" ^
  -r "{{CONTOOLS_TESTLIB_ROOT}}" "%%CONTOOLS_TESTLIB_ROOT%%" ^
  -r "{{CONTOOLS_PROJECT_EXTERNALS_ROOT}}" "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%" ^
  -r "{{TESTLIB__INIT}}" "%%TESTLIB__INIT%%" ^
  -r "{{TESTLIB__CHCP_EXE}}" "%%TESTLIB__CHCP_EXE%%" ^
  -r "{{TEST_SCRIPT_SHARED_VARS_FILE_PATH}}" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%" ^
  -r "{{TEST_SCRIPT_TEST_VARS_FILE_PATH}}" "%%TEST_SCRIPT_TEST_VARS_FILE_PATH%%" ^
  -r "{{TESTS_LIST_FILE}}" "%%TESTS_LIST_FILE%%" ^
  -r "{{TEST_TEMP_DIR_PATH}}" "%%TEST_TEMP_DIR_PATH%%" ^
  -r "{{TEST_LOG}}" "%%TEST_LOG%%" ^
  -- "%%TEST_SCRIPT_FILE_DIR%%/.impl" "%%TEST_TEMP_DIR_PATH%%" "test_std__run_shared_script.bat" >nul ^
  || ( set "TEST_LAST_ERROR=255" & goto SKIP_TEST )

if %TEST_DEBUG% EQU 0 (
  set CALLF_DEBUG_FLAGS=/create-child-console /no-window
) else set CALLF_DEBUG_FLAGS=/create-console

call;> "%TEST_LOG%"

rem NOTE:
rem   To debug use `/create-console` instead.

rem isolated multiple tests (shared)
start "" /I /B /WAIT "%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe" ^
  /no-expand-env /no-subst-pos-vars %CALLF_DEBUG_FLAGS% /ret-child-exit // ^
  "%COMSPEC%" "/D /C \"@\"%TEST_TEMP_DIR_PATH%/test_std__run_shared_script.bat\" {*} ^& \"%CONTOOLS_ROOT%/std/errlvl.bat\"\"" ^
  %*

if %TEST_DEBUG% NEQ 0 type "%TEST_LOG:/=\%"

exit /b 0
