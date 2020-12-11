@echo off

set "TEST_DATA_DIR=%TEST_SCRIPT_FILE_NAME%/%~1"
shift

set "TEST_DATA_SED_CMD_LINE="
:TEST_DATA_SED_CMD_LINE_LOOP
if "%~1" == "" goto TEST_DATA_SED_CMD_LINE_LOOP_END

set TEST_DATA_SED_CMD_LINE=%TEST_DATA_SED_CMD_LINE%%1 
shift

goto TEST_DATA_SED_CMD_LINE_LOOP

:TEST_DATA_SED_CMD_LINE_LOOP_END

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%TEST_SCRIPT_FILE_NAME%%" "" "%%TEST_TEMP_BASE_DIR%%"

set "TEST_TEMP_DIR_NAME=%TEST_SCRIPT_FILE_NAME%.%SCRIPT_TEMP_ROOT_DATE%.%SCRIPT_TEMP_ROOT_TIME%"
set "TEST_TEMP_DIR_PATH=%SCRIPT_TEMP_CURRENT_DIR%"

rem initialize setup parameters
call :CANONICAL_PATH TEST_DATA_OUT_FILE "%%TEST_TEMP_DIR_PATH%%\output.txt"

exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("%~2\.") do set "RETURN_VALUE=%%~fi"
set "RETURN_VALUE=%RETURN_VALUE:\=/%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
