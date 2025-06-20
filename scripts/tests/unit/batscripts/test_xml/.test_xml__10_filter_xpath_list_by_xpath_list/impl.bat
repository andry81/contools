@echo off

if not defined TEST_DATA_FILE_IN exit /b 255

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_DATA_IN_FILE "%%TEST_DATA_IN_ROOT%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_FILE_IN%%"

call :GET_TEST_DATA_FILE_DIR "%%TEST_DATA_IN_FILE%%"
set "TEST_DATA_FILE_IN_DIR=%RETURN_VALUE%"

call :GET_TEST_DATA_FILE_NAME "%%TEST_DATA_IN_FILE%%"
set "TEST_DATA_FILE_IN_NAME=%RETURN_VALUE%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_DATA_REF_DIR_ROOT "%%TEST_DATA_IN_ROOT%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_FILE_REF_DIR%%"

set "TEST_DATA_FILTER_FILE=%TEST_DATA_REF_DIR_ROOT%\xpath_filter.txt"
set "TEST_DATA_REF_FILE=%TEST_DATA_REF_DIR_ROOT%\output.txt"

rem builtin commands
(
  call "%%CONTOOLS_XML_TOOLS_ROOT%%/filter_xpath_list_by_xpath_list.bat" %%TEST_DATA_CMD_LINE%% "%%TEST_DATA_IN_FILE%%" "%%TEST_DATA_FILTER_FILE%%"
) > "%TEST_DATA_OUT_FILE%" || ( call set "TEST_IMPL_ERROR=%%ERRORLEVEL%%" & set "TEST_LAST_ERROR=20" & goto EXIT )

if not exist "%TEST_DATA_OUT_FILE%" set "TEST_LAST_ERROR=21" & goto EXIT
if not exist "%TEST_DATA_REF_FILE%" set "TEST_LAST_ERROR=22" & goto EXIT

"%SystemRoot%\System32\fc.exe" "%TEST_DATA_OUT_FILE:/=\%" "%TEST_DATA_REF_FILE%" >nul || set "TEST_LAST_ERROR=23"

:EXIT
exit /b %TEST_LAST_ERROR%

:GET_TEST_DATA_FILE_DIR
for /F "tokens=* delims="eol^= %%i in ("%~dp1.") do set "FILE_PATH=%%~fi"
call set "RETURN_VALUE=%%FILE_PATH:%TEST_DATA_IN_ROOT:/=\%\%TEST_SCRIPT_FILE_NAME%\=%%"
exit /b 0

:GET_TEST_DATA_FILE_NAME
set "RETURN_VALUE=%~nx1"
exit /b 0
