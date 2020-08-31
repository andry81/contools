@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to parse comand line from a project root build script.

rem Examples:
rem 1. rem somethere in the build_x86.bat
rem    set "BUILD_CMD_VARS=MYPROJECT.PROJECT_TYPE ?MYPROJECT.TARGET_NAME ?MYPROJECT.APP_TARGET_NAME"
rem    set BUILD_CMD_LINE=%*
rem    ...
rem    rem somethere in another script in pipeline
rem    call parse_cmd_build_params.bat "%%BUILD_CMD_VARS%%" %%BUILD_CMD_LINE%% || exit /b
rem    ...
rem    rem usage example, 2 and 3 parameters are optional
rem    call build_x86.bat release target123

set "__VARS__=%~1"

shift

set __INDEX__=1

:VARS_LOOP
setlocal

set "__VAR__="
set __VAR_OPTIONAL__=0
set __VAR_VALUE_IS_FLAG__=0
set __VAR_VALUE_IS_USER_PARAM__=0
for /F "eol= tokens=%__INDEX__% delims= " %%i in ("%__VARS__%") do set "__VAR__=%%i"

if not defined __VAR__ goto VARS_LOOP_END
if "%__VAR__:~0,1%" == "-" goto VARS_LOOP_END

if "%__VAR__:~0,1%" == "?" (
  set "__VAR__=%__VAR__:~1%"
  set __VAR_OPTIONAL__=1
)

set "__VAR_VALUE__=%~1"
set "__ARG=%__VAR_VALUE__%"

if defined __VAR_VALUE__ (
  if "%__VAR_VALUE__:~0,1%" == "-" (
    set __VAR_VALUE_IS_FLAG__=1
    call :PROCESS_FLAG
  )
)

call :PROCESS_USER_PARAM

if %__VAR_OPTIONAL__% EQU 0 (
  if not defined __VAR_VALUE__ (
    call :ERROR0
    endlocal
    set "__VARS__="
    set "__INDEX__="
    exit /b %__INDEX__%
  ) else if %__VAR_VALUE_IS_FLAG__% NEQ 0 (
    call :ERROR0
    endlocal
    set "__VARS__="
    set "__INDEX__="
    exit /b %__INDEX__%
  ) else if defined __USER_PARAM__ (
    call :ERROR0
    endlocal
    set "__VARS__="
    set "__INDEX__="
    exit /b %__INDEX__%
  )
)

(
  endlocal
  rem reset variable after endlocal
  if not "%__USER_PARAM__%" == "" (
    set "%__USER_PARAM__%=%__USER_VALUE__%"
  ) else if not "%__VAR_VALUE__%" == "" if %__VAR_VALUE_IS_FLAG__% EQU 0 (
    set "%__VAR__%=%__VAR_VALUE__%"
  )
  rem restore flags
  set "FLAGS_REGEN=%FLAGS_REGEN%"
  set "FLAGS_REBUILD=%FLAGS_REBUILD%"
)

set /A __INDEX__+=1

shift

goto VARS_LOOP

:VARS_LOOP_END

endlocal

:ARGS_LOOP

set "__ARG=%~1"

if not defined __ARG goto ARGS_LOOP_END

call :PROCESS_FLAG

call :PROCESS_USER_PARAM

if defined __USER_PARAM__ (
  set "%__USER_PARAM__%=%__USER_VALUE__%"
)

shift

goto ARGS_LOOP

:ARGS_LOOP_END

rem drop local variables
(
  set "__VARS__="
  set "__INDEX__="
  set "__FLAG="
  set "__USER_PARAM__="
  set "__USER_VALUE__="
  set "__ARG="
)

exit /b 0

:ERROR0
echo.%~nx0: error: %__VAR__% is not set.>&2

exit /b

:PROCESS_FLAG
set "__FLAG="
if "%__ARG:~0,1%" == "-" (
  rem space at the end to uniform parsing
  set "__FLAG=%__ARG% "
)

rem script flags
if defined __FLAG (
  if not "%__FLAG%" == "%__FLAG:-g =%" set FLAGS_REGEN=1
  if not "%__FLAG%" == "%__FLAG:-r =%" set FLAGS_REBUILD=1
)

exit /b

:PROCESS_USER_PARAM

rem process for user parameters
set "__USER_PARAM__="
set "__USER_VALUE__="
for /F "eol= tokens=1,* delims==" %%i in ("%__ARG%") do (
  set "__USER_PARAM__=%%i"
  set "__USER_VALUE__=%%j"
)

rem if "=" is not found
if "%__ARG%" == "%__USER_PARAM__%" (
  set "__USER_PARAM__="
  set "__USER_VALUE__="
)

exit /b
