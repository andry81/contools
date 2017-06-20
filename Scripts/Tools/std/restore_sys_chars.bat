@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to restore !, %, and = characters in variables from respective
rem   ?00, ?01 and ?02 placeholders.

setlocal DISABLEDELAYEDEXPANSION

set "__VAR__=%~1"

if "%__VAR__%" == "" exit /b 1

rem ignore empty variables
call set "STR=%%%__VAR__%%%"
if "%STR%" == "" exit /b 0

setlocal ENABLEDELAYEDEXPANSION

set STR=!STR:?01=%%!
set STR=!STR:?02==!

(
  endlocal
  set "STR=%STR%"
)

set "STR=%STR:?00=!%"

(
  endlocal
  set "%__VAR__%=%STR%"
)

exit /b 0
