@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

set __STRING__=a

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,13) do call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v & set __STRING__=!__STRING__!!__STRING__!

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 13

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
