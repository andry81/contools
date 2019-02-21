@echo off

rem Another variant of a configuration file variables read and set script.
rem The script must stay as simple as possible, so for this task it uses these parameters:
rem 1. path where to lock a lock file
rem 2. path where to read a file with variable names (each per line)
rem 3. path where to read a file with variable values (each per line, must be the same quantity of lines with the variable names file)

rem disable alternative variables expansion to avoid `!` character consumption
setlocal DISABLEDELAYEDEXPANSION

set "FILE_LOCK_PATH=%~1"
set "FILE_VAR_NAMES_PATH=%~2"
set "FILE_VAR_VALUES_PATH=%~3"
set "PRINT_VARS_SET=%~4"

set "FILE_LOCK_DIR=%~d1"

rem drop last error
type nul>nul

rem the lock file directory must already exist
if not exist "%FILE_LOCK_DIR%" (
  echo.%~nx0: error: FILE_LOCK_DIR does not exist: "%FILE_LOCK_DIR%"
  exit /b 1
) >&2

if not exist "%FILE_VAR_NAMES_PATH%" (
  echo.%~nx0: error: FILE_VAR_NAMES_PATH does not exist: "%FILE_VAR_NAMES_PATH%"
  exit /b 2
) >&2

if not exist "%FILE_VAR_VALUES_PATH%" (
  echo.%~nx0: error: FILE_VAR_VALUES_PATH does not exist: "%FILE_VAR_VALUES_PATH%"
  exit /b 2
) >&2

rem The `del` on the same line to avoid interference with the endlocal:
rem expression with the lock file path variable substitution should be evaluated before the endlocal
call :MAIN & del /F /Q /A:-D "%FILE_LOCK_PATH%"
exit /b

:MAIN
rem exclusive acquire of the lock file
:REPEAT_LOCK_LOOP

rem lock via redirection to file
set LOCK_FILE0_ACQUIRE=0
(
  (
    rem if lock is acquired, then we are in...

    rem Drop error level to 0 to avoid interference with the error level from the redirection command below.
    type nul>nul
  ) 9> "%FILE_LOCK_PATH%" && set LOCK_FILE0_ACQUIRE=1
) 2>nul

rem has exclusive lock been acquired?
if %LOCK_FILE0_ACQUIRE% NEQ 0 goto LOCK_LOOP_END

rem Busy wait: with external call significally reduces CPU consumption while in a waiting state
pathping localhost -n -q 1 -p 20 >nul 2>&1
goto REPEAT_LOCK_LOOP

:LOCK_LOOP_END

if %PRINT_VARS_SET%0 NEQ 0 goto SET_WITH_PRINT

rem trick with simultaneous iteration over 2 lists in the same time
(
  rem endlocal on the same line to drop the `FILE_VAR_NAMES_PATH` variable only after the line evaluation
  endlocal & for /f "usebackq eol=# tokens=* delims=" %%i in ("%FILE_VAR_NAMES_PATH%") do (
    set /p "%%i="
  )
) < "%FILE_VAR_VALUES_PATH%"

exit /b

:SET_WITH_PRINT
rem trick with simultaneous iteration over 2 lists in the same time
(
  rem endlocal on the same line to drop the `FILE_VAR_NAMES_PATH` variable only after the line evaluation
  endlocal & for /f "usebackq eol=# tokens=* delims=" %%i in ("%FILE_VAR_NAMES_PATH%") do (
    set /p "%%i="
    rem to filter out wrong matches of a variable from the `set "%%i"`
    for /f "usebackq eol=# tokens=1,* delims==" %%j in (`set "%%i"`) do if "%%j" == "%%i" echo.%%i=%%k
  )
) < "%FILE_VAR_VALUES_PATH%"
