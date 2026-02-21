@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%TEST_SCRIPT_FILE_NAME%%" "" "%%TEST_DATA_TEMP_ROOT%%" || exit /b

set "TEST_TEMP_DIR_PATH=%SCRIPT_TEMP_CURRENT_DIR%"

set "X=123"

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/gen_config.bat" ^
  -+ ^
  -r "{{A}}" "A" -r "{{B}}" "B" -r "{{C}}" "C" ^
  -r!+ -r "{{X}}" "!X!" -r!- ^
  -- "%%TEST_DATA_IN_ROOT%%/test_build__gen_config" "%%TEST_TEMP_DIR_PATH%%" test_01.vars >nul || (
  echo;%~nx0: error: failed to execute `gen_config.bat`
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
