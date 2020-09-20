@echo off

if defined TEST_DATA_FILE_IN (
  call :GET_ABSOLUTE_PATH "%%TEST_DATA_BASE_DIR%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_FILE_IN%%"
) else (
  call :GET_ABSOLUTE_PATH "%%TEST_DATA_BASE_DIR%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_FILE_REF_DIR%%\xpath_in.txt"
)
set "TEST_DATA_IN_FILE=%RETURN_VALUE%"

call :GET_TEST_DATA_FILE_DIR "%%TEST_DATA_IN_FILE%%"
set "TEST_DATA_FILE_IN_DIR=%RETURN_VALUE%"

call :GET_TEST_DATA_FILE_NAME "%%TEST_DATA_IN_FILE%%"
set "TEST_DATA_FILE_IN_NAME=%RETURN_VALUE%"

call :GET_ABSOLUTE_PATH "%%TEST_DATA_BASE_DIR%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_FILE_REF_DIR%%"
set "TEST_DATA_REF_DIR_ROOT=%RETURN_VALUE%"

set "TEST_DATA_FILTER_FILE=%TEST_DATA_REF_DIR_ROOT%\xpath_filter.txt"
set "TEST_DATA_REF_FILE=%TEST_DATA_REF_DIR_ROOT%\output.txt"

rem builtin commands
(
  call "%%XML_TOOLS_ROOT%%/filter_xpath_list_by_xpath_list.bat" %%TEST_DATA_CMD_LINE%% "%%TEST_DATA_IN_FILE%%" "%%TEST_DATA_FILTER_FILE%%"
) > "%TEST_DATA_OUT_FILE%" || ( call set "INTERRORLEVEL=%%ERRORLEVEL%%" & set "LASTERROR=20" & goto EXIT )

if not exist "%TEST_DATA_OUT_FILE%" ( set "LASTERROR=21" & goto EXIT )
if not exist "%TEST_DATA_REF_FILE%" ( set "LASTERROR=22" & goto EXIT )

fc "%TEST_DATA_OUT_FILE:/=\%" "%TEST_DATA_REF_FILE%" > nul
if %ERRORLEVEL% NEQ 0 set LASTERROR=23

:EXIT
exit /b %LASTERROR%

:GET_ABSOLUTE_PATH
set "RETURN_VALUE=%~dpf1"
exit /b 0

:GET_TEST_DATA_FILE_DIR
set "FILE_PATH=%~dp1"
call set "RETURN_VALUE=%%FILE_PATH:%TEST_DATA_BASE_DIR%\%TEST_SCRIPT_FILE_NAME%\=%%"
exit /b 0

:GET_TEST_DATA_FILE_NAME
set "RETURN_VALUE=%~nx1"
exit /b 0
