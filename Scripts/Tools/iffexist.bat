@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script checks file existence in directory list.
rem   If success script sets variable FOUND_PATH and returns 0.
rem   Otherwise returns non zero error level.

rem Command arguments:
rem %1 - Searching file name.
rem %2 - Path to file with directory list/path-like string list/variable name
rem      with path-like substrings.
rem %3 - Flags 1:
rem    -f - (Default) %2 - Path to file with directory list.
rem    -s - %2 - Path-like string list.
rem    -a - %2 - Variable name (used built-in search functionality).
rem %4 - Flags 2: Unused only if %3=-a
rem    -t - Trims spaces left and right from each path-string.
rem %5 - Flags 3: Unused only if %3=-a
rem    -e - Additionally expands each path-string.
rem You should use special variables in the string list to avoid problems with
rem respective characters:
rem   %?0% - expands to ^ (Useful when -e flag defined)
rem   %?1% - expands to " (Should always be used instead)

rem Examples:
rem 1. call iffexist.bat cmd.exe PATH -a
rem    echo FOUND_PATH=%FOUND_PATH%

rem Drop variable FOUND_PATH.
set "FOUND_PATH="

if "%~1" == "" exit /b 65

if "%~3" == "-f" (
  :ARG3_DEFAULT
  if "%~2" == "" exit /b 64
  if not exist "%~2" exit /b 63
  goto BEGIN10
) else if "%~3" == "-a" (
  if "%~2" == "" exit /b 64
) else if "%~3" == "" (
  goto :ARG3_DEFAULT
)

:BEGIN10

rem Drop last error level
type nul>nul

rem Create local variable's stack
setlocal

call "%%~dp0__init__.bat" || goto :EOF

if "%~3" == "-a" (
  rem Built-in search functionality
  set FOUND_PATH=0
  call set "FOUND_PATH=%%~$%~2:1"
  goto EXIT
)

set "?0=^"
set ?1="

if "%~3" == "-s" (
  set __PARSING_KEYWORDS=tokens=1,* delims=;
) else (
  set __PARSING_KEYWORDS=usebackq tokens=1,* delims=;
)
if "%~4" == "-t" (
  set __DO_TRIM=1
)
if "%~5" == "-e" (
  set __DO_EXPAND=1
)

for /F "%__PARSING_KEYWORDS%" %%i in ("%~2") do (if not "%FOUND_PATH%" == "" goto :END_FOR10) && (
  set __VAR1=0
  set "__VAR1=%%i"
  set __VAR2=0
  set "__VAR2=%%j"
  call :CHECK_OR_PARSENEXT_ROUTINE "%%~1"
)
:END_FOR10

goto EXIT

:CHECK_OR_PARSENEXT_ROUTINE
if not "%__DO_EXPAND%" == "" (
  set __VAR1=0
  call set "__VAR1=%__VAR1%"
)
if not "%__DO_TRIM%" == "" (
  call :TRIMVAR_ROUTINE "%%__VAR1%%
)

call "%%CONTOOLS_ROOT%%/appendvar.bat" __VAR1 "%%~1" "\"
if exist "%__VAR1%" (
  set "FOUND_PATH=%__VAR1%"
  goto :EOF
)

if not "%__VAR2%" == "" (
  rem Process next internal variable.
  for /F "tokens=1,* delims=;" %%i in ("%__VAR2%") do (
    set __VAR1=0
    set "__VAR1=%%i"
    set __VAR2=0
    set "__VAR2=%%j"
    goto CHECK_OR_PARSENEXT_ROUTINE
  )
)

rem Exit with current error level.
goto :EOF

:TRIMVAR_ROUTINE
rem Set variable with spaces trim.
set __VAR1=0
if not "%~1" == "" (
  for /F "tokens=* delims= " %%i in ("%~1") do set "__VAR1=%%i"
) else (
  set __VAR1=
)
goto :EOF

:EXIT
rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set "FOUND_PATH=%FOUND_PATH%"
)
if "%FOUND_PATH%" == "" exit /b 1
exit /b 0
