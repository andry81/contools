@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script runs gen_branch_wrokingset.bat script with time measurement.

rem Examples:
rem 1. call gen_branch_workingset_time.bat -R branch/current root_info.txt root_diff.patch root_externals.lst workingset.lst workingset
rem    type root_info.txt
rem    type root_diff.patch
rem    type root_externals.lst
rem    type workingset.lst
rem    dir workingset

rem Drop last error level
cd .

setlocal

call "%%~dp0__init__.bat" || goto :EOF

call "%%CONTOOLS_ROOT%%/get_datetime.bat"
set "BEGIN_DATE=%RETURN_VALUE:~0,4%-%RETURN_VALUE:~4,2%-%RETURN_VALUE:~6,2%"
set "BEGIN_TIME=%RETURN_VALUE:~8,2%-%RETURN_VALUE:~10,2%-%RETURN_VALUE:~12,2%,%RETURN_VALUE:~15,3%"
call "%%CONTOOLS_ROOT%%/timestamp.bat" "%%RETURN_VALUE%%"
set "BEGIN_TIMESTAMP=%TIMESTAMP%"

echo.%~nx0: start time: %BEGIN_DATE% %BEGIN_TIME% ^(%BEGIN_TIMESTAMP%^)

call "%%SVNCMD_TOOLS_ROOT%%/gen_branch_workingset.bat" %*
set LASTERROR=%ERRORLEVEL%

call "%%CONTOOLS_ROOT%%/get_datetime.bat"
set "END_DATE=%RETURN_VALUE:~0,4%-%RETURN_VALUE:~4,2%-%RETURN_VALUE:~6,2%"
set "END_TIME=%RETURN_VALUE:~8,2%-%RETURN_VALUE:~10,2%-%RETURN_VALUE:~12,2%,%RETURN_VALUE:~15,3%"
call "%%CONTOOLS_ROOT%%/timestamp.bat" "%%RETURN_VALUE%%"
set "END_TIMESTAMP=%TIMESTAMP%"

echo.%~nx0: end time: %END_DATE% %END_TIME% ^(%END_TIMESTAMP%^)

set /A TIMEDIFF=END_TIMESTAMP-BEGIN_TIMESTAMP

set /A TIMEDIFF_SEC=TIMEDIFF / 1000
set /A TIMEDIFF_MSEC=TIMEDIFF - TIMEDIFF_SEC * 1000

set TIMEDIFF_MIN=0
if %TIMEDIFF_SEC% GEQ 60 set /A TIMEDIFF_MIN=TIMEDIFF_SEC / 60
if %TIMEDIFF_MIN% GTR 0 set /A TIMEDIFF_SEC=TIMEDIFF_SEC - TIMEDIFF_MIN * 60

set TIMEDIFF_HOUR=0
if %TIMEDIFF_MIN% GEQ 60 set /A TIMEDIFF_HOUR=TIMEDIFF_MIN / 60
if %TIMEDIFF_HOUR% GTR 0 set /A TIMEDIFF_MIN=TIMEDIFF_MIN - TIMEDIFF_HOUR * 60

set TIMEDIFF_DAY=0
if %TIMEDIFF_HOUR% GEQ 24 set /A TIMEDIFF_DAY=TIMEDIFF_HOUR / 24
if %TIMEDIFF_DAY% GTR 0 set /A TIMEDIFF_HOUR=TIMEDIFF_HOUR - TIMEDIFF_DAY * 24

set "TIMEDIFF_MSEC_STR=%TIMEDIFF_MSEC%"
if %TIMEDIFF_MSEC% LSS 100 set "TIMEDIFF_MSEC_STR=0%TIMEDIFF_MSEC_STR%"
if %TIMEDIFF_MSEC% LSS 10 set "TIMEDIFF_MSEC_STR=0%TIMEDIFF_MSEC_STR%"

set TIMEDIFF_PRINT_STR=%TIMEDIFF_SEC%,%TIMEDIFF_MSEC_STR%s
if %TIMEDIFF_MIN% GTR 0 (
  set TIMEDIFF_PRINT_STR=%TIMEDIFF_MIN%m %TIMEDIFF_PRINT_STR%
)
if %TIMEDIFF_HOUR% GTR 0 (
  set TIMEDIFF_PRINT_STR=%TIMEDIFF_HOUR%h %TIMEDIFF_PRINT_STR%
)
if %TIMEDIFF_DAY% GTR 0 (
  set TIMEDIFF_PRINT_STR=%TIMEDIFF_DAY%d %TIMEDIFF_PRINT_STR%
)

echo.%~nx0: time diff: %TIMEDIFF_PRINT_STR%.
echo.

exit /b %LASTERROR%
