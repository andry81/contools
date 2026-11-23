@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,1000) do for /F "usebackq eol=# tokens=* delims=" %%i in ("%TEST_DATA_IN_ROOT%\test_build__load_config\test_01.vars") do @

call "%%CONTOOLS_ROOT%%/time/end_time.bat"

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0
