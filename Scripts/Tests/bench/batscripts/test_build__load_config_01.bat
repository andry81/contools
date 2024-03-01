@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

setlocal

set "BEGIN_TIME=%TIME%"
call "%%CONTOOLS_ROOT%%/build/load_config.bat" "%%TEST_DATA_BASE_DIR%%/test_build__load_config" . config.system.01.vars || (
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

set /A TIME_SECS=%TIMEDIFF% / 1000
set /A TIME_MSECS=%TIMEDIFF% %% 1000
echo Time spent: %TIME_SECS%.%TIME_MSECS% secs

exit /b 0
