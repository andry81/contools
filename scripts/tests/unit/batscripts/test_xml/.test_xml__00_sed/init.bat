@echo off

set "TEST_DATA_DIR=%TEST_SCRIPT_FILE_NAME%/%~1"

call "%%CONTOOLS_ROOT%%/std/setshift.bat" 1 TEST_DATA_SED_CMD_LINE %%*

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%TEST_SCRIPT_FILE_NAME%%" "" "%%TEST_DATA_TEMP_ROOT%%" || exit /b

set "TEST_TEMP_DIR_NAME=%TEST_SCRIPT_FILE_NAME%.%SCRIPT_TEMP_ROOT_DATE%.%SCRIPT_TEMP_ROOT_TIME%"
set "TEST_TEMP_DIR_PATH=%SCRIPT_TEMP_CURRENT_DIR%"

rem initialize setup parameters
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_DATA_OUT_FILE "%%TEST_TEMP_DIR_PATH%%\output.txt"

exit /b 0
