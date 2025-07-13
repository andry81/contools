@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

(
  for /L %%i in (1,1,10) do "%SystemRoot%\System32\where.exe" cmd.exe
) >nul

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

if %TIME_INTS% EQU 0 set "TIME_INTS="

echo Time spent: %TIME_INTS%%TIME_FRACS:~0,2%.%TIME_FRACS:~2%00 msecs
echo;

exit /b 0
