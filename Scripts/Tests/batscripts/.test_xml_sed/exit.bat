@echo off

if %LASTERROR% EQU 0 exit /b 0

rem copy workingset on error
mkdir "%TEST_SRC_BASE_DIR%\_output\%TEST_TEMP_DIR_NAME%\reference\%TEST_DATA_DIR:*/=%"
call "%%CONTOOLS_ROOT%%/xcopy_dir.bat" "%%TEST_TEMP_DIR_PATH%%" "%%TEST_SRC_BASE_DIR%%\_output\%%TEST_TEMP_DIR_NAME%%" /Y /H /E > nul
call "%%CONTOOLS_ROOT%%/xcopy_dir.bat" "%%TEST_DATA_BASE_DIR%%\%%TEST_DATA_DIR%%" "%%TEST_SRC_BASE_DIR%%\_output\%%TEST_TEMP_DIR_NAME%%\reference\%TEST_DATA_DIR:*/=%" /Y /H /E > nul
