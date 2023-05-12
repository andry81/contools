@echo off

rem Description:
rem   Another variant of a configuration file variables read and set script.
rem   Loads variables from a file using exclusion list with builtin and
rem   specific custom variables.
rem
rem   The script must stay as simple as possible, so for this task it uses these parameters:
rem   1. path where to lock a lock file
rem   2. path where to read a file with variable names and value in format of `NAME=VALUE`.

rem disable alternative variables expansion to avoid `!` character consumption
setlocal DISABLEDELAYEDEXPANSION

set "FILE_LOCK_PATH=%~1"
set "FILE_VARS_PATH=%~2"
set "PRINT_VARS_SET=%~3"

set "FILE_LOCK_DIR=%~d1"

rem the lock file directory must already exist
if not exist "%FILE_LOCK_DIR%" (
  echo.%~nx0: error: FILE_LOCK_DIR does not exist: "%FILE_LOCK_DIR%"
  exit /b 1
) >&2

if not exist "%FILE_VARS_PATH%" (
  echo.%~nx0: error: FILE_VARS_PATH does not exist: "%FILE_VARS_PATH%"
  exit /b 2
) >&2

rem The endlocal works only in the same call context
endlocal

rem exclusive acquire of the lock file
:REPEAT_LOCK_LOOP

(
  (
    rem if lock is acquired, then we are in...
    call :MAIN "%%~2" "%%~3"
    call set "LASTERROR=%%ERRORLEVEL%%"

    rem exit with return code from the MAIN
  ) 9> "%~1" && (del /F /Q /A:-D "%~1" & goto EXIT)
) 2>nul

rem Busy wait: with external call significantly reduces CPU consumption while in a waiting state
pathping localhost -n -q 1 -p 20 >nul 2>&1
goto REPEAT_LOCK_LOOP

:EXIT
exit /b %LASTERROR%

:MAIN
rem drop last error
call;

if %~20 NEQ 0 goto SET_WITH_PRINT

for /f "usebackq eol=# tokens=1,* delims==" %%i in ("%~1") do ( call :FILTER && set "%%i=%%j" )
exit /b 0

:SET_WITH_PRINT
for /f "usebackq eol=# tokens=1,* delims==" %%i in ("%~1") do ( call :FILTER && ( echo.%%i=%%j& set "%%i=%%j" ) )
exit /b 0

:FILTER
for /F "usebackq eol=# tokens=* delims=" %%k in ("%~dp0.set_vars_from_file\exclusion.vars") do ( if /i "%%i" == "%%k" exit /b 1 )
exit /b 0
