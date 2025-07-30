@echo off

set "GEN_CONFIG_FILE_NAME=%~1"
set "TEST_DATA_FILE_IN_DIR=%~2"
set "TEST_DATA_FILE_REF_DIR=%~3"

if not defined GEN_CONFIG_FILE_NAME exit /b 255
if not defined TEST_DATA_FILE_IN_DIR exit /b 255
if not defined TEST_DATA_FILE_REF_DIR exit /b 255

call "%%CONTOOLS_ROOT%%/std/setshift.bat" -skip 1 3 GEN_CONFIG_FLAGS_CMD_LINE -+ %%*

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_DATA_IN_FILE "%%TEST_DATA_IN_ROOT%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_FILE_IN_DIR%%\%%GEN_CONFIG_FILE_NAME%%.in"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_DATA_REF_DIR "%%TEST_DATA_IN_ROOT%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_FILE_REF_DIR%%"

set "TEST_DATA_REF_FILE=%TEST_DATA_REF_DIR%\output.txt"

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%TEST_SCRIPT_FILE_NAME%%" "" "%%TEST_DATA_TEMP_ROOT%%" || exit /b

set "TEST_TEMP_DIR_NAME=%SCRIPT_TEMP_DIR_NAME%"
set "TEST_TEMP_DIR_PATH=%SCRIPT_TEMP_CURRENT_DIR%"

rem initialize setup parameters
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_TEMP_DATA_OUT_FILE "%%TEST_TEMP_DIR_PATH%%\%%GEN_CONFIG_FILE_NAME%%"

rem extract path to directory
call :GET_TEST_DATA_FILE_DIR "%%TEST_DATA_IN_FILE%%"
set "TEST_DATA_FILE_IN_DIR=%RETURN_VALUE%"

rem extract file name
call :GET_TEST_DATA_FILE_NAME "%%TEST_DATA_IN_FILE%%"
set "TEST_DATA_FILE_IN_NAME=%RETURN_VALUE%"

(
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%TEST_DATA_IN_ROOT%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_FILE_IN_DIR%%" "%%TEST_DATA_FILE_IN_NAME%%" "%%TEST_TEMP_DIR_PATH%%" /Y /H /E
) >nul

pushd "%TEST_TEMP_DIR_PATH%"

exit /b 0

:GET_TEST_DATA_FILE_DIR
for /F "tokens=* delims="eol^= %%i in ("%~dp1.") do set "FILE_PATH=%%~fi"
call set "RETURN_VALUE=%%FILE_PATH:%TEST_DATA_IN_ROOT%\%TEST_SCRIPT_FILE_NAME%\=%%"
exit /b 0

:GET_TEST_DATA_FILE_NAME
set "RETURN_VALUE=%~nx1"
exit /b 0
