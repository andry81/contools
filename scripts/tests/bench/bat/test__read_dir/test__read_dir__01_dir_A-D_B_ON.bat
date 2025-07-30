@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_READ_DIR  "%%TEST_DATA_IN_ROOT%%/test_read_dir/dir"

rem find closest version (greater)
set ?.=@dir "*_*_*.lst" /A:-D /B /O:N 2^>nul

call "%%CONTOOLS_ROOT%%/std/echo_var.bat" ?.

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

cd "%TEST_READ_DIR%"

for /F "usebackq tokens=* delims="eol^= %%j in (`%%?.%%`) do echo;%%j

for /L %%i in (1,1,9) do (
  for /F "usebackq tokens=* delims="eol^= %%j in (`%%?.%%`) do rem
)

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 10

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
