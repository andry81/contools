@echo off

if /i "%TEST_UNIT_BATSCRIPTS_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0__init__/__init__.bat" || exit /b

set "TEST_UNIT_BATSCRIPTS_INIT0_DIR=%~dp0"

call :CANONICAL_PATH TESTS_ROOT "%%~dp0"

rem initialize testlib "module"
call "%%CONTOOLS_ROOT%%/testlib/__init__.bat" || exit /b

call :CANONICAL_PATH TEST_SRC_BASE_DIR  "%%TESTS_ROOT%%"
call :CANONICAL_PATH TEST_DATA_BASE_DIR "%%TEST_SRC_BASE_DIR%%/_testdata"
call :CANONICAL_PATH TEST_TEMP_BASE_DIR "%%CONTOOLS_PROJECT_ROOT%%/Temp"

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
