@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script clears all environment variables which are not declared in a target
rem   text file. Text file has a simple file format with a variable name on
rem   each string line.

rem Command arguments:
rem %1 - Flags:
rem    -p - Do print cleared/changed variables.
rem    -e - Additionally expands all variable values from target text file.
rem    -r - Only reset variables, don't clear variables which are not in the
rem         list
rem %2, %3, etc - Paths to text file with environment variables list.

rem Examples:
rem 1. call resetenv.bat "./env_vars.lst"
rem 1. call resetenv.bat -p "./env_vars.lst"
rem 2. call resetenv.bat -p -e "./env_vars.lst"

rem Example of variables text file:
rem   See the file "vars_winxp.lst" as an example of the default Window XP
rem   environment.

rem Drop last error level
call;

set "?~nx0=%~nx0"

set ?LAST_ERROR=0

rem script flags
set ?FLAG_PRINT=0
set ?FLAG_EXPAND=0
set ?FLAG_RESET=0

:FLAGS_LOOP

rem flags always at first
set "?FLAG=%~1"

if defined ?FLAG ^
if not "%?FLAG:~0,1%" == "-" set "?FLAG="

if defined ?FLAG (
  if "%?FLAG%" == "-p" (
    set ?FLAG_PRINT=1
    shift
  ) else if "%?FLAG%" == "-e" (
    set ?FLAG_EXPAND=1
    shift
  ) else if "%?FLAG%" == "-r" (
    set ?FLAG_RESET=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

if "%~1" == "" (
  set ?LAST_ERROR=1
  echo.%?~nx0%: error: no input files
  goto CLEANUP_AND_EXIT
) >&2

set "?RESET_ENV_FILES="

:RESET_ENV_FILES_LOOP

if "%~1" == "" goto RESET_ENV_FILES_LOOP_END

if not exist "%~1" (
  set ?LAST_ERROR=2
  echo.%?~nx0%: error: file does not exist: "%~1"
  goto CLEANUP_AND_EXIT
) >&2

set ?RESET_ENV_FILES=%?RESET_ENV_FILES% %1

shift

goto RESET_ENV_FILES_LOOP

:RESET_ENV_FILES_LOOP_END

call :RESET_VARS %%?RESET_ENV_FILES%%
if %?FLAG_RESET% NEQ 0 goto CLEANUP_AND_EXIT

call :CLEAR_VARS
goto CLEANUP_AND_EXIT

rem Reset variables before clear
:RESET_VARS

call :RESET_VARS_IMPL %%1

shift

if exist "%~1" goto RESET_VARS

exit /b

:RESET_VARS_IMPL
for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%~1") do call :RESET_VAR "%%i" "%%j"
exit /b

:RESET_VAR
if "%~1" == "" exit /b
if "%~2" == "" exit /b
if %?FLAG_EXPAND% NEQ 0 (
  call set "%%~1=%~2"
) else (
  set "%~1=%~2"
)
if %?FLAG_PRINT% NEQ 0 echo.^*"%~1"
exit /b

rem Clear variables
:CLEAR_VARS

for /F "usebackq eol=# tokens=1,* delims==" %%i in (`set 2^>nul`) do call :CLEAR_VAR "%%i"
exit /b

:CLEAR_VAR
set "?CLEAR_VAR_NAME=%~1"
if not defined ?CLEAR_VAR_NAME exit /b
if "%?CLEAR_VAR_NAME:~0,1%" == "?" exit /b

call :CLEAR_VAR_LOOP %%?RESET_ENV_FILES%%
exit /b

:CLEAR_VAR_LOOP

call :RESET_LIST "%%~1"
if %ERRORLEVEL% NEQ 0 exit /b

shift

if exist "%~1" goto CLEAR_VAR_LOOP

call set "?CLEAR_VAR_VALUE=%%%?CLEAR_VAR_NAME%%%"
if defined ?CLEAR_VAR_VALUE (
  set "%?CLEAR_VAR_NAME%="
  if %?FLAG_PRINT% NEQ 0 echo.-"%?CLEAR_VAR_NAME%"
)

exit /b

:RESET_LIST
for /F "usebackq eol= tokens=1,* delims==" %%i in (`type "%~f1"`) do if /i "%?CLEAR_VAR_NAME%" == "%%i" exit /b 1
exit /b 0

:CLEANUP_AND_EXIT
rem Cleanup all ? variables
(
  for /F "usebackq eol=# tokens=1,* delims==" %%i in (`set ? 2^>nul`) do set "%%i="
  exit /b %?LAST_ERROR%
)
