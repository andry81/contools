@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

if not exist "%SystemRoot%\System32\wbem\wmic.exe" goto SKIP_TEST

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,20) do call "%%CONTOOLS_WMI_ROOT%%/get_wmic_local_datetime.bat"

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 20

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0

:SKIP_TEST
(
  echo;warning: `wmic.exe` is not found, skipped
) >&2
echo;

exit /b -1
