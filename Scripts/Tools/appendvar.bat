@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script appends value to variable values splitted by separator.

rem Command arguments:
rem %1 - Variable name, which would be appended.
rem %2 - Appending value.
rem %3 - Separator character.

rem Examples:
rem 1. call appendvar.bat PATH "C:\blabla\blabla" ";"
rem 2. set "AAA=C:\blabla\blabla\"
rem    call appendvar.bat AAA "blabla\blabla" \

rem Drop last error level
call;

rem Create local variable's stack
setlocal

set "?~nx0=%~nx0"

rem script flags
rem set variable in global registry for current user
set __FLAG_SET_GLOBAL_REGISTRY=0
rem Set variable in global registry for all users.
rem Has no meaning if global flag has not used.
set __FLAG_SET_GLOBAL_REGISTRY_ALL_USERS=0
rem If setting global variable, then do include changes for a local cmd.exe process environment (by default, it is excluded)
rem Has no meaning if global flag has not used.
set __FLAG_SET_LOCAL=0
rem Force append even if exist.
set __FLAG_FORCE=0

:FLAGS_LOOP

rem flags always at first
set "__FLAG=%~1"

if defined __FLAG ^
if not "%__FLAG:~0,1%" == "-" set "__FLAG="

if defined __FLAG (
  if "%__FLAG%" == "-g" (
    set __FLAG_SET_GLOBAL_REGISTRY=1
    shift
  ) else if "%__FLAG%" == "-all" (
    if %__FLAG_SET_GLOBAL_REGISTRY% NEQ 0 set __FLAG_SET_GLOBAL_REGISTRY_ALL_USERS=1
    shift
  ) else if "%__FLAG%" == "-l" (
    set __FLAG_SET_LOCAL=1
    shift
  ) else if "%__FLAG%" == "-f" (
    set __FLAG_FORCE=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %__FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

if "%~1" == "" (
  echo.%?~nx0%: error: variable name is not set.
  exit /b 1
)

set "__SEPARATOR="
if not "%~3" == "" set "__SEPARATOR=%~3"
if not defined __SEPARATOR set "__SEPARATOR=;"
set "__SEPARATOR=%__SEPARATOR:~0,1%"

set "__NEW_VALUE=%~2"

rem remove trailing separator character
if defined __NEW_VALUE (
  if "%__SEPARATOR%" == "%__NEW_VALUE:~-1%" (
    set "__NEW_VALUE=%__NEW_VALUE:~0,-1%"
  )
)

rem remove trailing "\" character
if defined __NEW_VALUE (
  if "\" == "%__NEW_VALUE:~-1%" (
    set "__NEW_VALUE=%__NEW_VALUE:~0,-1%"
  )
)

if not defined __NEW_VALUE (
  if "%~2" == "" exit /b 0
  rem the variable value is a separator character only
  exit /b 2
)

rem set local at least
if %__FLAG_SET_GLOBAL_REGISTRY%%__FLAG_SET_LOCAL% EQU 0 set __FLAG_SET_LOCAL=1
if %__FLAG_SET_GLOBAL_REGISTRY% EQU 0 goto SET_GLOBAL_END

rem global setup
set "__VAR_VALUE="

if %__FLAG_SET_GLOBAL_REGISTRY_ALL_USERS% NEQ 0 (
  set __FLAG_SET_GLOBAL_REGISTRY_WMIC_WHERE_EXP=where "Name='Path' and UserName='<SYSTEM>'"
) else (
  set __FLAG_SET_GLOBAL_REGISTRY_WMIC_WHERE_EXP=where "Name='Path' and UserName!='<SYSTEM>'"
)

for /F "usebackq eol= tokens=1,* delims==" %%i in (`wmic environment %__FLAG_SET_GLOBAL_REGISTRY_WMIC_WHERE_EXP% get VariableValue /VALUE 2^>nul`) do if "%%i" == "VariableValue" set "__VAR_VALUE=%%j"

if defined __VAR_VALUE (
  if "%__SEPARATOR%" == "%__VAR_VALUE:~-1%" (
    set "__VAR_VALUE=%__VAR_VALUE:~0,-1%"
  )
)

rem check on existance
if %__FLAG_FORCE% NEQ 0 goto SET_GLOBAL_IMPL
if not defined __VAR_VALUE goto SET_GLOBAL_IMPL

set "__VAR_VALUE_TMP=%__SEPARATOR%%__VAR_VALUE%%__SEPARATOR%"

call set "__VAR_VALUE_TMP_EXCLUDED=%%__VAR_VALUE_TMP:%__SEPARATOR%%__NEW_VALUE%%__SEPARATOR%=%%"

if /i not "%__VAR_VALUE_TMP_EXCLUDED%" == "%__VAR_VALUE_TMP%" goto SET_GLOBAL_END

:SET_GLOBAL_IMPL
if defined __VAR_VALUE (
  wmic environment %__FLAG_SET_GLOBAL_REGISTRY_WMIC_WHERE_EXP% set VariableValue="%__VAR_VALUE%%__SEPARATOR%%__NEW_VALUE%"
) else (
  wmic environment %__FLAG_SET_GLOBAL_REGISTRY_WMIC_WHERE_EXP% set VariableValue="%__NEW_VALUE%"
)

:SET_GLOBAL_END
if %__FLAG_SET_LOCAL% EQU 0 exit /b

rem local setup
call set "__VAR_VALUE=%%%~1%%"

if defined __VAR_VALUE (
  if "%__SEPARATOR%" == "%__VAR_VALUE:~-1%" (
    set "__VAR_VALUE=%__VAR_VALUE:~0,-1%"
  )
)

rem check on existance
if %__FLAG_FORCE% NEQ 0 goto SET_LOCAL_IMPL
if not defined __VAR_VALUE goto SET_LOCAL_IMPL

set "__VAR_VALUE_TMP=%__SEPARATOR%%__VAR_VALUE%%__SEPARATOR%"

call set "__VAR_VALUE_TMP_EXCLUDED=%%__VAR_VALUE_TMP:%__SEPARATOR%%__NEW_VALUE%%__SEPARATOR%=%%"

if /i not "%__VAR_VALUE_TMP_EXCLUDED%" == "%__VAR_VALUE_TMP%" goto SET_LOCAL_END

:SET_LOCAL_IMPL
if defined __VAR_VALUE (
  endlocal
  set "%~1=%__VAR_VALUE%%__SEPARATOR%%__NEW_VALUE%"
) else (
  endlocal
  set "%~1=%__NEW_VALUE%"
)

:SET_LOCAL_END

exit /b 0
