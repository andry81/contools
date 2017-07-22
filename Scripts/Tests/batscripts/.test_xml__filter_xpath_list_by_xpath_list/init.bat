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

exit /b 0
