@echo off

setlocal DISABLEDELAYEDEXPANSION

rem script names call stack
if defined ?~ ( set "__?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "__?~=%?~nx0%-^>%~nx0" ) else set "__?~=%~nx0"

set "__?EXEC_ON_ENDLOCAL="
set __?LAST_ERROR=0

:LOOP
if "%~1" == "" goto EXIT

if not defined %1 (
  echo;%__?~%: error: `%1` variable is not defined.
  set __?LAST_ERROR=255
  goto EXIT
) >&2

call set "__?DIR_PATH=%%%~1:"=%%"

set "__?DIR_PATH=%__?DIR_PATH:/=\%"

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%__?DIR_PATH:~0,1%" goto DIR_PATH_ERROR

rem ...double `\\` character
if not "%__?DIR_PATH%" == "%__?DIR_PATH:\\=\%" goto DIR_PATH_ERROR

rem ...trailing `\` character
if "\" == "%__?DIR_PATH:~-1%" goto DIR_PATH_ERROR

rem check on invalid characters in path
if not "%__?DIR_PATH%" == "%__?DIR_PATH:**=%" goto DIR_PATH_ERROR
if not "%__?DIR_PATH%" == "%__?DIR_PATH:?=%" goto DIR_PATH_ERROR
if not "%__?DIR_PATH%" == "%__?DIR_PATH:<=%" goto DIR_PATH_ERROR
if not "%__?DIR_PATH%" == "%__?DIR_PATH:>=%" goto DIR_PATH_ERROR

goto DIR_PATH_OK

:DIR_PATH_ERROR
(
  echo;%?~%: error: a variable path value is invalid:
  echo;  %~1="%__?DIR_PATH%"
  set __?LAST_ERROR=254
  goto EXIT
) >&2

:DIR_PATH_OK

for /F "tokens=* delims="eol^= %%i in ("%__?DIR_PATH%\.") do (
  if not exist "%%~fi" (
    echo;%?~%: error: path does not exist:
    echo;  %~1="%%~fi"
    set __?LAST_ERROR=1
    goto EXIT
  ) >&2

  if not exist "%%~fi\*" (
    echo;%?~%: error: existed path is not a directory path:
    echo;  %~1="%%~fi"
    set __?LAST_ERROR=2
    goto EXIT
  ) >&2
)

if defined __?EXEC_ON_ENDLOCAL (
  for /F "tokens=* delims="eol^= %%i in ("%__?DIR_PATH%\.") do set __?EXEC_ON_ENDLOCAL=%__?EXEC_ON_ENDLOCAL% ^& set "%~1=%%~fi"
) else for /F "tokens=* delims="eol^= %%i in ("%__?DIR_PATH%\.") do set __?EXEC_ON_ENDLOCAL=set "%~1=%%~fi"

shift

goto LOOP

:EXIT
(
  endlocal
  %__?EXEC_ON_ENDLOCAL%
  exit /b %__?LAST_ERROR%
)
