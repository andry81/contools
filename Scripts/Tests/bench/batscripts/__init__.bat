@echo off

if /i "%TEST_BENCH_BATSCRIPTS_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0__init__/__init__.bat" || exit /b

set "TEST_BENCH_BATSCRIPTS_INIT0_DIR=%~dp0"

call :CANONICAL_PATH TESTS_ROOT "%%~dp0"

call :CANONICAL_PATH TEST_SRC_BASE_DIR  "%%TESTS_ROOT%%"
call :CANONICAL_PATH TEST_DATA_BASE_DIR "%%TEST_SRC_BASE_DIR%%/_testdata"

exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
set "RETURN_VALUE=%~dpf2"
set "RETURN_VALUE=%RETURN_VALUE:\=/%"
if "%RETURN_VALUE:~-1%" == "/" set "RETURN_VALUE=%RETURN_VALUE:~0,-1%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
