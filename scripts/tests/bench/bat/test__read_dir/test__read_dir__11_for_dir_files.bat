@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_READ_DIR  "%%TEST_DATA_IN_ROOT%%/test_read_dir/dir"

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

cd "%TEST_READ_DIR%"

for %%j in (*_*_*.lst) do echo;%%j

for /L %%i in (1,1,999) do (
  for %%j in (*_*_*.lst) do rem
)

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0
