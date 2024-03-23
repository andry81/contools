@echo off

set "TEST_DATA_FILE_IN=%~1"
set "TEST_DATA_FILE_REF_DIR=%~2"
shift
shift

set "TEST_DATA_CMD_LINE="
:TEST_DATA_CMD_LINE_LOOP
if "%~1" == "" goto TEST_DATA_CMD_LINE_LOOP_END

set TEST_DATA_CMD_LINE=%TEST_DATA_CMD_LINE%%1 
shift

goto TEST_DATA_CMD_LINE_LOOP

:TEST_DATA_CMD_LINE_LOOP_END

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%TEST_SCRIPT_FILE_NAME%%" "" "%%TEST_TEMP_BASE_DIR%%" || exit /b

set "TEST_TEMP_DIR_NAME=%SCRIPT_TEMP_DIR_NAME%"
set "TEST_TEMP_DIR_PATH=%SCRIPT_TEMP_CURRENT_DIR%"

rem initialize setup parameters
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_DATA_OUT_FILE "%%TEST_TEMP_DIR_PATH%%\output.txt"

exit /b 0
