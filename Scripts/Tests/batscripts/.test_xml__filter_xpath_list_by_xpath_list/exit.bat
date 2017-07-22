@echo off

if %LASTERROR% EQU 0 exit /b 0

rem copy workingset on error
mkdir "%TEST_SRC_BASE_DIR%\_output\%TEST_TEMP_DIR_NAME%\%TEST_DATA_FILE_IN_DIR%"
mkdir "%TEST_SRC_BASE_DIR%\_output\%TEST_TEMP_DIR_NAME%\%TEST_DATA_FILE_REF_DIR%"
call "%%CONTOOLS_ROOT%%/xcopy_dir.bat" "%%TEST_TEMP_DIR_PATH%%" "%%TEST_SRC_BASE_DIR%%\_output\%%TEST_TEMP_DIR_NAME%%" /Y /H /E > nul
call "%%CONTOOLS_ROOT%%/xcopy_file.bat" "%%TEST_DATA_BASE_DIR%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_FILE_IN_DIR%%" "%%TEST_DATA_FILE_IN_NAME%%" "%%TEST_SRC_BASE_DIR%%\_output\%%TEST_TEMP_DIR_NAME%%\%TEST_DATA_FILE_IN_DIR%" /Y /H /E > nul
call "%%CONTOOLS_ROOT%%/xcopy_dir.bat" "%%TEST_DATA_BASE_DIR%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_FILE_REF_DIR%%" "%%TEST_SRC_BASE_DIR%%\_output\%%TEST_TEMP_DIR_NAME%%\%TEST_DATA_FILE_REF_DIR%" /Y /H /E > nul
