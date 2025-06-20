@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config.bat" "%%TEST_DATA_IN_ROOT%%/test_build__load_config" . test_01.vars "" OS64 || (
  echo;%~nx0: error: failed to execute `load_config.bat`
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
