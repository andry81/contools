@echo off

setlocal

set "?~nx0=%~nx0"

rem script flags
set FLAG_OPTIONAL_COMPARE=0
set FLAG_OPTIONAL_SYSTEM_FILE_INSTANCE=0
set FLAG_OPTIONAL_USER_FILE_INSTANCE=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-optional_compare" (
    set FLAG_OPTIONAL_COMPARE=1
  ) else if "%FLAG%" == "-optional_system_file_instance" (
    set FLAG_OPTIONAL_SYSTEM_FILE_INSTANCE=1
  ) else if "%FLAG%" == "-optional_user_file_instance" (
    set FLAG_OPTIONAL_USER_FILE_INSTANCE=1
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

if %FLAG_OPTIONAL_COMPARE%0 NEQ 0 (
  set FLAG_OPTIONAL_SYSTEM_FILE_INSTANCE=1
  set FLAG_OPTIONAL_USER_FILE_INSTANCE=1
)

set "VARS_SYSTEM_FILE_IN=%~1"
set "VARS_SYSTEM_FILE=%~2"
set "VARS_USER_FILE_IN=%~3"
set "VARS_USER_FILE=%~4"

if not defined VARS_SYSTEM_FILE_IN if not defined VARS_USER_FILE_IN (
  echo.%?~nx0%: error: at least VARS_SYSTEM_FILE_IN or VARS_USER_FILE_IN must be defined.
  exit /b 1
) >&2

if defined VARS_SYSTEM_FILE_IN if not exist "%VARS_SYSTEM_FILE_IN%" (
  echo.%?~nx0%: error: VARS_SYSTEM_FILE_IN does not exist: "%VARS_SYSTEM_FILE_IN%".
  exit /b 10
) >&2

if %FLAG_OPTIONAL_SYSTEM_FILE_INSTANCE% EQU 0 if defined VARS_SYSTEM_FILE_IN if not exist "%VARS_SYSTEM_FILE%" (
  echo.%?~nx0%: error: VARS_SYSTEM_FILE does not exist: "%VARS_SYSTEM_FILE%".
  exit /b 11
) >&2

if defined VARS_USER_FILE_IN if not exist "%VARS_USER_FILE_IN%" (
  echo.%?~nx0%: error: VARS_USER_FILE_IN does not exist: "%VARS_USER_FILE_IN%".
  exit /b 20
) >&2

if %FLAG_OPTIONAL_USER_FILE_INSTANCE% EQU 0 if defined VARS_USER_FILE_IN if not exist "%VARS_USER_FILE%" (
  echo.%?~nx0%: error: VARS_USER_FILE does not exist: "%VARS_USER_FILE%".
  exit /b 21
) >&2

if not defined VARS_SYSTEM_FILE_IN goto IGNORE_VARS_SYSTEM_FILE_IN

rem must be not empty to avoid bug in the parser of the if expression around `<var>:~` expression
set "VARS_SYSTEM_FILE_IN_VER_LINE=."
set "VARS_SYSTEM_FILE_VER_LINE=."

if exist "%VARS_SYSTEM_FILE_IN%" if exist "%VARS_SYSTEM_FILE%" (
  rem Test input and output files on version equality, otherwise we must stop and warn the user to merge the changes by yourself!
  set /P VARS_SYSTEM_FILE_IN_VER_LINE=<"%VARS_SYSTEM_FILE_IN%"
  set /P VARS_SYSTEM_FILE_VER_LINE=<"%VARS_SYSTEM_FILE%"
)

rem avoid any quote characters
set "VARS_SYSTEM_FILE_IN_VER_LINE=%VARS_SYSTEM_FILE_IN_VER_LINE:"=%"
set "VARS_SYSTEM_FILE_VER_LINE=%VARS_SYSTEM_FILE_VER_LINE:"=%"

if exist "%VARS_SYSTEM_FILE_IN%" if exist "%VARS_SYSTEM_FILE%" (
  if /i "%VARS_SYSTEM_FILE_IN_VER_LINE:~0,12%" == "#%%%% version:" (
    if not "%VARS_SYSTEM_FILE_IN_VER_LINE:~13%" == "%VARS_SYSTEM_FILE_VER_LINE:~13%" (
      echo.%?~nx0%: error: version of "%VARS_SYSTEM_FILE_IN%" is not equal to version of "%VARS_SYSTEM_FILE%", user must merge changes by yourself!
      exit /b 30
    ) >&2
  )
)

:IGNORE_VARS_SYSTEM_FILE_IN

if not defined VARS_USER_FILE_IN goto IGNORE_VARS_USER_FILE_IN

rem must be not empty to avoid bug in the parser of the if expression around `<var>:~` expression
set "VARS_USER_FILE_IN_VER_LINE=."
set "VARS_USER_FILE_VER_LINE=."

if exist "%VARS_USER_FILE_IN%" if exist "%VARS_USER_FILE%" (
  rem Test input and output files on version equality, otherwise we must stop and warn the user to merge the changes by yourself!
  set /P VARS_USER_FILE_IN_VER_LINE=<"%VARS_USER_FILE_IN%"
  set /P VARS_USER_FILE_VER_LINE=<"%VARS_USER_FILE%"
)

rem avoid any quote characters
set "VARS_USER_FILE_IN_VER_LINE=%VARS_USER_FILE_IN_VER_LINE:"=%"
set "VARS_USER_FILE_VER_LINE=%VARS_USER_FILE_VER_LINE:"=%"

if exist "%VARS_USER_FILE_IN%" if exist "%VARS_USER_FILE%" (
  if /i "%VARS_USER_FILE_IN_VER_LINE:~0,12%" == "#%%%% version:" (
    if not "%VARS_USER_FILE_IN_VER_LINE:~13%" == "%VARS_USER_FILE_VER_LINE:~13%" (
      echo.%?~nx0%: error: version of "%VARS_USER_FILE_IN%" is not equal to version of "%VARS_USER_FILE%", user must merge changes by yourself!
      exit /b 40
    ) >&2
  )
)

:IGNORE_VARS_USER_FILE_IN

exit /b 0
