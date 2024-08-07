@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo.^>%~nx0

setlocal

set "BEGIN_TIME=%TIME%"
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config.bat" "%%TEST_DATA_BASE_DIR%%/test_build__load_config" . test_01.vars "" OS64 || (
  echo.%~nx0: error: failed to execute `load_config.bat`
  exit /b 255
) >&2
set "END_TIME=%TIME%"

(
  endlocal
  set "BEGIN_TIME=%BEGIN_TIME%"
  set "END_TIME=%END_TIME%"
)

call "%%CONTOOLS_ROOT%%/timediff.bat" "%%BEGIN_TIME%%" "%%END_TIME%%"

rem set /A TIMEDIFF/=10

set /A TIME_SECS=%TIMEDIFF% / 1000
set /A TIME_MSECS=%TIMEDIFF% %% 1000

if "%TIME_MSECS:~2,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"
if "%TIME_MSECS:~1,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"

echo Time spent: %TIME_SECS%.%TIME_MSECS% secs
echo.

exit /b 0
