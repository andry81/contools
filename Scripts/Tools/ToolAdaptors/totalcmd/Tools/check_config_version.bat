@echo off

setlocal

set "OPTIONAL_COMPARE=%~1"
set "VARS_PROFILE_FILE_IN=%~2"
set "VARS_PROFILE_FILE=%~3"

if not defined OPTIONAL_COMPARE set OPTIONAL_COMPARE=0

if not exist "%VARS_PROFILE_FILE_IN%" (
  echo.%~nx0: error: VARS_PROFILE_FILE_IN does not exist: "%VARS_PROFILE_FILE_IN%".
  exit /b 1
) >&2

if %OPTIONAL_COMPARE% EQU 0 if not exist "%VARS_PROFILE_FILE%" (
  echo.%~nx0: error: VARS_PROFILE_FILE does not exist: "%VARS_PROFILE_FILE%".
  exit /b 2
) >&2

rem must be not empty to avoid bug in the parser of the if expression around `<var>:~` expression
set "VARS_PROFILE_FILE_IN_VER_LINE=."
set "VARS_PROFILE_FILE_VER_LINE=."

if exist "%VARS_PROFILE_FILE_IN%" if exist "%VARS_PROFILE_FILE%" (
  rem Test input and output files on version equality, otherwise we must stop and warn the user to merge the changes by yourself!
  set /P VARS_PROFILE_FILE_IN_VER_LINE=<"%VARS_PROFILE_FILE_IN%"
  set /P VARS_PROFILE_FILE_VER_LINE=<"%VARS_PROFILE_FILE%"
)

rem avoid any quote characters
set "VARS_PROFILE_FILE_IN_VER_LINE=%VARS_PROFILE_FILE_IN_VER_LINE:"=%"
set "VARS_PROFILE_FILE_VER_LINE=%VARS_PROFILE_FILE_VER_LINE:"=%"

if exist "%VARS_PROFILE_FILE_IN%" if exist "%VARS_PROFILE_FILE%" (
  if /i "%VARS_PROFILE_FILE_IN_VER_LINE:~0,12%" == "#%%%% version:" (
    if not "%VARS_PROFILE_FILE_IN_VER_LINE:~13%" == "%VARS_PROFILE_FILE_VER_LINE:~13%" (
      echo.%~nx0: error: version of "%VARS_PROFILE_FILE_IN%" is not equal to version of "%VARS_PROFILE_FILE%", user must merge changes by yourself!
      exit /b 10
    ) >&2
  )
)

exit /b 0
