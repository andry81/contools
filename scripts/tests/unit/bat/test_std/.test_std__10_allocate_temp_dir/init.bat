@echo off

set "TEST_DATA_REF_DIR=%~1"

if not defined TEST_DATA_REF_DIR exit /b 255

rem CAUTION:
rem   We can not use here variables from the being tested script like `SCRIPT_TEMP_ROOT_DATE` and `SCRIPT_TEMP_ROOT_TIME`.

call "%%CONTOOLS_WMI_ROOT%%\get_wmi_local_datetime.vbs.bat"
set "TEST_DATE=%RETURN_VALUE:~0,4%'%RETURN_VALUE:~4,2%'%RETURN_VALUE:~6,2%"
set "TEST_TIME=%RETURN_VALUE:~8,2%'%RETURN_VALUE:~10,2%'%RETURN_VALUE:~12,2%''%RETURN_VALUE:~15,3%"

set "TEST_TEMP_DIR_NAME=%TEST_DATE%.%TEST_TIME%.%TEST_SCRIPT_FILE_NAME%.%TESTLIB__TEST_ORDER_NUMBER%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_TEMP_DIR           "%%TEST_DATA_TEMP_ROOT%%\%%TEST_TEMP_DIR_NAME%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_DATA_REF_DIR_PATH  "%%TEST_DATA_IN_ROOT%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_REF_DIR%%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir.bat" "%%TEST_TEMP_DIR%%" >nul || exit /b 127

exit /b 0
