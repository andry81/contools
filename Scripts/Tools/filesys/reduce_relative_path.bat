@echo off

rem Author: Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script converts relative path with . and .. occurrences to the absolute
rem   path and tries subtract current directory path from it.
rem   If no . and .. occurrences found or could not subtract then leave
rem   relative path or intermediate absolute path as is.

rem Command arguments:
rem %1 - Relative path.

rem Examples:
rem 1. call reduce_relative_path.bat "./Test"
rem    rem RETURN_VALUE=Test
rem 2. call reduce_relative_path.bat "../Test"
rem 3. call reduce_relative_path.bat "aaa/../bbb"
rem    rem RETURN_VALUE=bbb

rem Drop return value
set "RETURN_VALUE=%~1"

rem Drop last error level
call;

setlocal

call "%%~dp0__init__.bat" || exit /b

set "REL_PATH=%~1"
if "%REL_PATH:.=%" == "%REL_PATH%" exit /b 0

call :ABS_PATH "%%REL_PATH%%"

call "%%CONTOOLS_ROOT%%/filesys/subtract_path.bat" "%%CD%%" "%%ABS_PATH%%"

rem use absolute path on error
if %ERRORLEVEL% NEQ 0 set "RETURN_VALUE=%ABS_PATH%"

(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE%"
)

exit /b

:ABS_PATH
set "ABS_PATH=%~f1"
