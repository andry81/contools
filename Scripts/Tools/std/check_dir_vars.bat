@echo off

setlocal DISABLEDELAYEDEXPANSION

rem script names call stack
if defined ?~ ( set "__?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "__?~=%?~nx0%-^>%~nx0" ) else set "__?~=%~nx0"

:LOOP
if "%~1" == "" exit /b 0
if not defined %1 (
  echo;%__?~%: error: `%1` variable is not defined.
  exit /b 255
) >&2
call set "__?DIR_PATH__=%%%~1:"=%%"
if not exist "%__?DIR_PATH__%" (
  echo;%__?~%: error: `%1` file path is not found: "%__?DIR_PATH__%".
  exit /b 255
) >&2
if not exist "%__?DIR_PATH__%\*" (
  echo;%__?~%: error: `%1` directory does not exist: "%__?DIR_PATH__%".
  exit /b 255
) >&2
shift
goto LOOP
