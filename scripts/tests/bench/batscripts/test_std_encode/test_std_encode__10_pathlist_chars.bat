@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

set __STRING__=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,10) do (
  call "%%CONTOOLS_ROOT%%/std/encode/encode_pathlist_chars.bat"
  call "%%CONTOOLS_ROOT%%/std/encode/decode_pathlist_chars.bat"
)

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 10

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
