@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,20) do call "%%CONTOOLS_WMI_ROOT%%/get_wmi_local_datetime.vbs.bat"

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 20

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
