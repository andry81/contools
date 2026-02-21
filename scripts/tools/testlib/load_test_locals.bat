@echo off & goto DOC_END

rem USAGE:
rem   load_test_locals.bat
:DOC_END

if not defined SETUP_CP goto SKIP_SETUP_CP
if not defined CHCP goto SKIP_SETUP_CP
if %NO_CHCP%0 NEQ 0 goto SKIP_SETUP_CP

rem reread current code page for each test, before run and after run

rem reads the current code page into `TESTLIB__TEST_CP` variable
call "%%CONTOOLS_TESTLIB_ROOT%%/getcp.bat"

rem assigns the inner code page (`CHCP`, must be not 65000) if is different with a current code page (`TESTLIB__TEST_CP`)
call "%%CONTOOLS_TESTLIB_ROOT%%/set_inner_cp.bat"

:SKIP_SETUP_CP

call "%%CONTOOLS_TESTLIB_ROOT%%/load_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%"

rem restores an outer code page (`TESTLIB__TEST_CP`) if is different with the inner code page (`CHCP`, must be not 65000)
if defined SETUP_CP if defined CHCP if %NO_CHCP%0 EQU 0 call "%%CONTOOLS_TESTLIB_ROOT%%/set_outer_cp.bat"
