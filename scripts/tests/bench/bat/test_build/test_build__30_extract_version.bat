@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,100) do call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/extract_version.bat" "123.456_78901234-567" || (
  echo;%~nx0: error: failed to execute `extract_version.bat`
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/time/end_time.bat"

echo Time spent: %TIME_INTS:*0=%%TIME_FRACS:~0,1%.%TIME_FRACS:~1%0 msecs
echo;

exit /b 0
