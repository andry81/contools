@echo off

if /i "%CONTOOLS_UTILITIES_TESTS_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat"         TESTS_ROOT                          "%%~dp0.."

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" TEST_CALLF_REF_DIR                  "%%TESTS_ROOT%%/refs"

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" TEST_CALLF_REF_INPUT_FILE_0         "%%TEST_CALLF_REF_DIR%%/0.in"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat"         TEST_SRC_BASE_DIR                   "%%TESTS_ROOT%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat"         TEST_DATA_OUT_DIR                   "%%TEST_SRC_BASE_DIR%%/_out"

if not defined PRINTARGS_EXECUTABLE               set "PRINTARGS_EXECUTABLE=printargs.exe"

if not defined CALLF_EXECUTABLE                   set "CALLF_EXECUTABLE=callf.exe"
if not defined CALLFG_EXECUTABLE                  set "CALLFG_EXECUTABLE=callfg.exe"

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" PRINTARGS_EXE_PATH                  "%%CONTOOLS_UTILITIES_BIN_ROOT%%/contools/%%PRINTARGS_EXECUTABLE%%"

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" CALLF_EXE_PATH                      "%%CONTOOLS_UTILITIES_BIN_ROOT%%/contools/%%CALLF_EXECUTABLE%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" CALLFG_EXE_PATH                     "%%CONTOOLS_UTILITIES_BIN_ROOT%%/contools/%%CALLFG_EXECUTABLE%%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%TEST_DATA_OUT_DIR%%" || exit /b

set "CONTOOLS_UTILITIES_TESTS_ROOT_INIT0_DIR=%~dp0"

exit /b 0
