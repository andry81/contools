@echo off & goto DOC_END

rem USAGE:
rem   set_vars_from_locked_file_pair.bat <lock-file> <var-names-file> <var-values-file> [<print-set-flag>]

rem Description:
rem   Another variant of a configuration file variables read and set script.
rem   The script must stay as simple as possible, so for this task it uses these parameters:
rem   1. path where to lock a lock file
rem   2. path where to read a file with variable names (each per line)
rem   3. path where to read a file with variable values (each per line, must be the same quantity of lines with the variable names file)
:DOC_END

rem disable alternative variables expansion to avoid `!` character consumption
setlocal DISABLEDELAYEDEXPANSION

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "FILE_VAR_NAMES_PATH=%~2"
set "FILE_VAR_VALUES_PATH=%~3"

set "FILE_LOCK_DIR=%~d1"

rem the lock file directory must already exist
if not exist "%FILE_LOCK_DIR%" (
  echo;%?~%: error: FILE_LOCK_DIR does not exist: "%FILE_LOCK_DIR%"
  exit /b 1
) >&2

if not exist "%FILE_VAR_NAMES_PATH%" (
  echo;%?~%: error: FILE_VAR_NAMES_PATH does not exist: "%FILE_VAR_NAMES_PATH%"
  exit /b 2
) >&2

if not exist "%FILE_VAR_VALUES_PATH%" (
  echo;%?~%: error: FILE_VAR_VALUES_PATH does not exist: "%FILE_VAR_VALUES_PATH%"
  exit /b 3
) >&2

rem The endlocal works only in the same call context
endlocal

rem exclusive acquire of the lock file
:REPEAT_LOCK_LOOP

( ( rem if lock is acquired, then we are in...
    call :MAIN "%%~2" "%%~3" "%%~4"
    call set "LAST_ERROR=%%ERRORLEVEL%%"

    rem exit with return code from the MAIN, check on empty variable to avoid accidental `del /Q ""` case
) 9> "%~1" && (if not "%~1" == "" del /F /Q /A:-D "%~1" & goto EXIT) ) 2>nul

rem Busy wait: with external call significantly reduces CPU consumption while in a waiting state
"%SystemRoot%\System32\pathping.exe" 127.0.0.1 -n -q 1 -p 20 >nul 2>nul
goto REPEAT_LOCK_LOOP

:EXIT
exit /b %LAST_ERROR%

:MAIN
rem drop last error
call;

if %~30 NEQ 0 goto SET_WITH_PRINT

rem trick with simultaneous iteration over 2 lists in the same time
(
  for /f "usebackq eol=# tokens=* delims=" %%i in ("%~1") do (
    set /p "%%i="
  )
) < "%~2"

exit /b 0

:SET_WITH_PRINT
rem trick with simultaneous iteration over 2 lists in the same time
(
  for /f "usebackq eol=# tokens=* delims=" %%i in ("%~1") do (
    set /p "%%i="
    rem to filter out wrong matches of a variable from the `set "%%i"`
    for /f "usebackq eol=# tokens=1,* delims==" %%j in (`set "%%i"`) do if /i "%%j" == "%%i" echo;%%i=%%k
  )
) < "%~2"

exit /b 0
