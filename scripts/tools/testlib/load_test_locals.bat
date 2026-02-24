@echo off & goto DOC_END

rem USAGE:
rem   load_test_locals.bat
:DOC_END

if not defined SETUP_CP goto SKIP_SETUP_CP

rem reread current code page for each test, before run and after run

rem reads the current code page into `TESTLIB__CURRENT_CP` variable
call "%%CONTOOLS_TESTLIB_ROOT%%/getcp.bat"

rem assigns the inner code page if is different with a current code page (`TESTLIB__CURRENT_CP`)
call "%%CONTOOLS_TESTLIB_ROOT%%/set_inner_cp.bat"

:SKIP_SETUP_CP

call "%%CONTOOLS_TESTLIB_ROOT%%/load_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%"

rem restores a previous code page (`TESTLIB__PREV_CP`) if is different with the inner code page
if defined SETUP_CP call "%%CONTOOLS_TESTLIB_ROOT%%/set_prev_cp.bat"
