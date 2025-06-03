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
call set "__?FILE_PATH=%%%~1:"=%%"
if not exist "%__?FILE_PATH%" (
  echo;%__?~%: error: `%1` file path is not found: "%__?FILE_PATH%".
  set __?LAST_ERROR=255
  goto EXIT
) >&2
if exist "%__?FILE_PATH%\*" (
  echo;%__?~%: error: `%1` file path is a directory: "%__?FILE_PATH%".
  set __?LAST_ERROR=255
  goto EXIT
) >&2
if defined __?EXEC_ON_ENDLOCAL (
  for /F "tokens=* delims="eol^= %%i in ("%__?FILE_PATH%\.") do set __?EXEC_ON_ENDLOCAL=%__?EXEC_ON_ENDLOCAL% ^& set "%~1=%%~fi"
) else for /F "tokens=* delims="eol^= %%i in ("%__?FILE_PATH%\.") do set __?EXEC_ON_ENDLOCAL=set "%~1=%%~fi"
shift
goto LOOP

:EXIT
(
  endlocal
  %__?EXEC_ON_ENDLOCAL%
  exit /b %__?LAST_ERROR%
)
