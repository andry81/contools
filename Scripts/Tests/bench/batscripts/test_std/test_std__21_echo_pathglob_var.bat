@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

rem CAUTION: no globbing characters here, because the result is dependent on the file system
set __LIST__=$^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+ ,;=

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,10) do call "%%CONTOOLS_ROOT%%/std/echo_pathglob_var.bat" __LIST__ >nul

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 10

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
