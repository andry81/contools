@echo off

set "TEST_DATA_REF_DIR=%~1"
set "TEST_DATA_REF_DIR=%TEST_DATA_REF_DIR:\=/%"

set "TEST_TEMP_DIR_NAME=%TEST_SCRIPT_FILE_NAME%.%TESTLIB__CURRENT_TESTS%.%RANDOM%_%RANDOM%"

call :CANONICAL_PATH TEST_TEMP_DIR "%%TEST_TEMP_BASE_DIR%%\%%TEST_TEMP_DIR_NAME%%"

if not defined TEST_TEMP_DIR exit /b 127

mkdir "%TEST_TEMP_DIR%"

exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("%~2\.") do set "RETURN_VALUE=%%~fi"
rem set "RETURN_VALUE=%RETURN_VALUE:\=/%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
