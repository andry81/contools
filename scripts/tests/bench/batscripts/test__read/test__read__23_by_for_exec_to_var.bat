@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,100) do (
  for /F "usebackq tokens=* delims="eol^= %%i in (`@"%SystemRoot%\system32\chcp.com"`) do set "VALUE=%%i"
)

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

echo Time spent: %TIME_INTS%%TIME_FRACS:~0,1%.%TIME_FRACS:~1%0 msecs
echo;

exit /b 0
