@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to replace ?, !, %, and = characters in variables by respective
rem   ?00, ?01, ?02 and ?03 placeholders.

setlocal DISABLEDELAYEDEXPANSION

set "__VAR__=%~1"

if not defined __VAR__ exit /b 1

rem ignore empty variables
call set "STR=%%%__VAR__%%%"
if not defined STR exit /b 0

set ?01=!

call set "STR=%%%__VAR__%:?=?00%%"
set "STR=%STR:!=?01%"

setlocal ENABLEDELAYEDEXPANSION

set STR=!STR:%%=?02!
set "STR_TMP="
set INDEX=1

:EQUAL_CHAR_REPLACE_LOOP
set "STR_TMP2="
for /F "tokens=%INDEX% delims== eol=" %%i in ("/!STR!/") do set STR_TMP2=%%i
if not defined STR_TMP2 goto EQUAL_CHAR_REPLACE_LOOP_END
set "STR_TMP=!STR_TMP!!STR_TMP2!?03"
set /A INDEX+=1
goto EQUAL_CHAR_REPLACE_LOOP

:EQUAL_CHAR_REPLACE_LOOP_END
if defined STR_TMP set STR=!STR_TMP:~1,-4!

(
  endlocal
  endlocal
  set "%__VAR__%=%STR%"
)

exit /b 0
