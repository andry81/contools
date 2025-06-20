@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal

rem make sure the output config is later
call "%%CONTOOLS_ROOT%%/std/touch_file.bat" ^
  "%%TEST_DATA_IN_ROOT%%/test_build__check_config_expiration/01_config.vars.in" ^
  "%%TEST_DATA_IN_ROOT%%/test_build__check_config_expiration/01_config.vars"

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,10) do call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/check_config_expiration.bat" "%%TEST_DATA_IN_ROOT%%/test_build__check_config_expiration/01_config.vars.in" "%%TEST_DATA_IN_ROOT%%/test_build__check_config_expiration/01_config.vars" || (
  echo;%~nx0: error: failed to execute `check_config_expiration.bat`
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 10

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
