@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to clear existing variables set created by *_list*.bat scripts.

rem Command arguments:
rem %1 - Variable name for the list.

rem Examples:
rem 1. call clear_list.bat MyList

set "__VAR_NAME=%~1"

if not defined __VAR_NAME exit /b -1

call set "__LIST_SIZE=%%%__VAR_NAME%.SIZE%%"

if not defined __LIST_SIZE exit /b -2

set __INDEX_EXT=0

:LOOP
if %__INDEX_EXT% GEQ %__LIST_SIZE% goto LOOP_END
set "%__VAR_NAME%[%__INDEX_EXT%]="
set /A __INDEX_EXT+=1
goto LOOP

:LOOP_END

set "%__VAR_NAME%.SIZE="

rem drop temporary variables
(
  set "__VAR_NAME="
  set "__INDEX_EXT="
  set "__LIST_SIZE="

  exit /b %__LIST_SIZE%
)
