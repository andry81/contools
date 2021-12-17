@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script prints substrings concatenated together by split character.
rem   String can exists as string literal or stores in file.
rem   If stores in file, then additionally could be multilined.

rem Command arguments:
rem %1 - Text to process.
rem %2 - Character to split by.
rem %3 - Flags 1:
rem    -f - (Default) Text to process is path to file with strings.
rem    -s - Text to process is string literal.
rem %4 - Flags 2:
rem    -t - Trim spaces left and right from each splitted string.
rem %5 - Flags 3:
rem    -e - Additionally expand each string.
rem You should use special variables in the string/file to avoid problems with
rem respective characters:
rem   %?0% - expands to ^ (Useful when -e flag defined)
rem   %?1% - expands to " (Should always be used instead)
rem   !?2! - expands to ! (Should always be used inside
rem          "setlocal ENABLEDELAYEDEXPANSION")

rem Examples:
rem 1. call splitvars.bat "%PATH%" ";" -s

if "%~1" == "" (
  exit /b 65
)

if "%~2" == "" (
  exit /b 66
)

if not "%~3" == "-s" (
  if not exist "%~1" (
    exit /b 67
  )
)

rem Drop last error level.
call;

set "?0=^"
set ?1="
set !?2!=!

if /i "%~3" == "-s" (
  set "__PARSING_KEYWORDS=tokens=1,* delims=%~2"
) else (
  set "__PARSING_KEYWORDS=usebackq tokens=1,* delims=%~2"
)
if /i "%~4" == "-t" (
  set __DO_TRIM=1
)
if /i "%~5" == "-e" (
  set __DO_EXPAND=1
)

for /F "%__PARSING_KEYWORDS%" %%i in ("%~1") do (
  set __VAR1=0
  set "__VAR1=%%i"
  set __VAR2=0
  set "__VAR2=%%j"
  call :PRINT_AND_PARSENEXT_ROUTINE "%~2"
)

rem Exit with current error level.
goto EXIT

:PRINT_AND_PARSENEXT_ROUTINE
if defined __DO_EXPAND (
  set __VAR1=0
  call set "__VAR1=%__VAR1%"
)
if defined __DO_TRIM (
  call :TRIMVAR_ROUTINE "%%__VAR1%%
)
rem If variable was empty, then prints empty string.
echo.%__VAR1%

if defined __VAR2 (
  rem Process next internal variable.
  for /F "tokens=1,* delims=%~1" %%i in ("%__VAR2%") do (
    set __VAR1=0
    set "__VAR1=%%i"
    set __VAR2=0
    set "__VAR2=%%j"
    goto PRINT_AND_PARSENEXT_ROUTINE
  )
)

rem Exit with current error level.
exit /b

:TRIMVAR_ROUTINE
rem Set variable with spaces trim.
set __VAR1=0
if not "%~1" == "" (
  for /F "tokens=* delims= " %%i in ("%~1") do set "__VAR1=%%i"
) else (
  set __VAR1=
)
exit /b

:EXIT

rem Drop internal variables
(
  set ?0=
  set ?1=
  set !?2!=
  set __PARSING_KEYWORDS=0
  set __PARSING_KEYWORDS=
  set __DO_TRIM=0
  set __DO_TRIM=
  set __DO_EXPAND=0
  set __DO_EXPAND=
  set __VAR1=0
  set __VAR1=
  set __VAR2=0
  set __VAR2=
)
