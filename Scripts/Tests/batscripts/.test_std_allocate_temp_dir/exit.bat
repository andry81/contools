@echo off

if %LASTERROR% NEQ 0 (
  rem copy workingset on error
  mkdir "%TEST_SRC_BASE_DIR%\_output\%TEST_TEMP_DIR_NAME%\ref"
  call "%%CONTOOLS_ROOT%%/xcopy_dir.bat" "%%TEST_DATA_REF_DIR_ROOT%%" "%%TEST_SRC_BASE_DIR%%\_output\%%TEST_TEMP_DIR_NAME%%\ref" /Y /H /E
  call "%%CONTOOLS_ROOT%%/xcopy_file.bat" "%%TEST_TEMP_DIR%%" "%%TEST_DATA_OUTPUT_FILE_NAME%%" "%%TEST_SRC_BASE_DIR%%\_output\%%TEST_TEMP_DIR_NAME%%" /Y /H /E
)

del /F /Q "%TEST_TEMP_DIR%\output*.txt" 2>nul

rem cleanup empty temporary directory
set "TEST_TEMP_DIR_PATH_ITEM="
for /F "usebackq eol=	 tokens=* delims=" %%i in (`dir /B "%TEST_TEMP_DIR%"`) do (
  set "TEST_TEMP_DIR_PATH_ITEM=%%i"
  goto EXIT
)

:EXIT
if defined TEST_TEMP_DIR_PATH_ITEM exit /b 64

rmdir "%TEST_TEMP_DIR%"

exit /b 0
