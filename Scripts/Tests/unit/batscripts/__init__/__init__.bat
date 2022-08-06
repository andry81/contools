@echo off

if defined CONTOOLS_PROJECT_TESTS_INIT0_DIR if exist "%CONTOOLS_PROJECT_TESTS_INIT0_DIR%\" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "CONTOOLS_PROJECT_TESTS_INIT0_DIR=%~dp0"

call :CANONICAL_PATH TESTS_PROJECT_ROOT "%%~dp0.."

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" "%%TESTS_PROJECT_ROOT%%/_config" || exit /b

call "%%CONTOOLS_ROOT%%/std/mkdir_if_notexist.bat" "%%TEST_DATA_OUT_DIR%%" || exit /b 10
call "%%CONTOOLS_ROOT%%/std/mkdir_if_notexist.bat" "%%TEST_TEMP_BASE_DIR%%" || exit /b 11

rem initialize testlib "module"
call "%%CONTOOLS_ROOT%%/testlib/__init__.bat" || exit /b

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
