@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

(
  for /L %%i in (1,1,10) do call "%%CONTOOLS_ROOT%%/encoding/dos2unix.bat" -fix-tail-lr "%%TEST_DATA_IN_ROOT%%/test_encoding__dos2unix/test_01.txt"
) >nul

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 10

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
