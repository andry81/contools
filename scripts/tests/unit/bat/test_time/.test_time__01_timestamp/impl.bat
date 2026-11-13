@echo off

call "%%CONTOOLS_ROOT%%/time/timestamp.bat" "%%IN%%"
set TEST_IMPL_ERROR=%ERRORLEVEL%

set "OUT=%HOURS%:%MINS%:%SECS%.%MSECS%"

exit /b 0
