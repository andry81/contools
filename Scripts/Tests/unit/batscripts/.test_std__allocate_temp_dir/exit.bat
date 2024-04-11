@echo off

setlocal

if %LAST_ERROR% NEQ 0 (
  rem copy workingset on error
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_dir.bat"  "%%TEST_DATA_REF_DIR_ROOT%%" "%%TEST_DATA_OUT_DIR%%\%%TEST_TEMP_DIR_NAME%%\ref" /Y /H /E
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%TEST_TEMP_DIR%%" "%%TEST_DATA_OUTPUT_FILE_NAME%%" "%%TEST_DATA_OUT_DIR%%\%%TEST_TEMP_DIR_NAME%%" /Y /H /E
)

del /F /Q /A:-D "%TEST_TEMP_DIR%\output*.txt" 2>nul

rem CAUTION:
rem   If a variable is empty, then it would not be expanded in the `cmd.exe` command line or in case of `for /F ...`!
rem   We must expand the command line into a variable.
rem
set ?.=@dir "%TEST_TEMP_DIR%" /B /O:-N

rem cleanup empty temporary directory
set "TEST_TEMP_DIR_PATH_ITEM="
for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
  set "TEST_TEMP_DIR_PATH_ITEM=%%i"
  goto EXIT
)

:EXIT
if defined TEST_TEMP_DIR_PATH_ITEM exit /b 64

rmdir "%TEST_TEMP_DIR%"

exit /b 0
