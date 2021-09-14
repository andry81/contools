@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

set "BEGIN_TIME=%TIME%"

setlocal
call "%%CONTOOLS_ROOT%%/std/load_config.bat" "%%TEST_DATA_BASE_DIR%%/test_std__load_config" "%%TEST_DATA_BASE_DIR%%/test_std__load_config" config.system.fast.vars || (
  echo.%~nx0: error: failed to execute `load_config.bat`
  exit /b 255
) >&2
endlocal

call "%%CONTOOLS_ROOT%%/timediff.bat" "%%BEGIN_TIME%%" "%%TIME%%"

set /A TIME_SECS=%TIMEDIFF% / 1000
set /A TIME_MSECS=%TIMEDIFF% %% 1000
echo Time spent: %TIME_SECS%.%TIME_MSECS% secs

exit /b 0
