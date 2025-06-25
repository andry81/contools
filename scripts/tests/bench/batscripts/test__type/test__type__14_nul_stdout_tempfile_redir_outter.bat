@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

set "TEMP_FILE=%TEMP%\@type-%RANDOM%-%RANDOM%.txt"

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

( for /L %%i in (1,1,10000) do type nul ) > "%TEMP_FILE%"

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 10

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

del /F /Q /A:-D "%TEMP_FILE%" >nul 2>nul

exit /b 0
