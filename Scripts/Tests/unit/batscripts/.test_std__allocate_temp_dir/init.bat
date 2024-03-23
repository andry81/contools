@echo off

set "TEST_DATA_REF_DIR=%~1"
set "TEST_DATA_REF_DIR=%TEST_DATA_REF_DIR:\=/%"

set "TEST_TEMP_DIR_NAME=%TEST_SCRIPT_FILE_NAME%.%TESTLIB__CURRENT_TESTS%.%RANDOM%_%RANDOM%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_TEMP_DIR "%%TEST_TEMP_BASE_DIR%%\%%TEST_TEMP_DIR_NAME%%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir.bat" "%%TEST_TEMP_DIR%%" >nul || exit /b 127

exit /b 0
