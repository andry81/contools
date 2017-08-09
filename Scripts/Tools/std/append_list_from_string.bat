@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to append string list separated by a character into set of
rem   variables: MyList[0], MyList[1], .., MyList[N], MyList.SIZE=N.

rem Command arguments:
rem %1 - Variable name for the list.
rem %2 - Offset to copy from.
rem %3 - Length to copy of. if -1 then copy until empty item.
rem %4 - Appended list size.
rem %5 - String with character separated items.
rem %6 - Character separator, ':' if not set.

rem Examples:
rem 1. call append_list_from_string.bat MyList 1 -1 "" "000:111:222:333"
rem    rem MyList: 111 222 333 MyList.SIZE=3
rem 2. call append_list_from_string.bat MyList 1 2 "" "000:111:222:333"
rem    rem MyList: 111 222 MyList.SIZE=2
rem    call append_list_from_string.bat MyList 0 -1 APPENDEDSIZE "000:111:222:333"
rem    rem MyList: 111 222 000 111 222 333 MyList.SIZE=6 APPENDEDSIZE=4

set "__VAR_NAME=%~1"
rem from len or list length output variable name
set "__FROM_OFFSET=%~2"
set "__COPY_SIZE=%~3"
set "__VAR_SIZE_NAME=%~4"
set "__STRING=%~5"
set "__SEPARATOR=%~6"

if not defined __VAR_NAME exit /b -1

if not defined __FROM_OFFSET set __FROM_OFFSET=0
if not defined __SEPARATOR set __SEPARATOR=:

set __GOTO_LOOP=ALL_LOOP
if not defined __COPY_SIZE set __COPY_SIZE=-1
if %__COPY_SIZE% GEQ 0 set __GOTO_LOOP=RANGE_LOOP

set /A __INDEX_INT_IN=1+__FROM_OFFSET
set __INDEX_INT_OUT=0
set __INDEX_EXT=0

call set "__LIST_OUT_SIZE=%%%__VAR_NAME%.SIZE%%"
if defined __LIST_OUT_SIZE set /A __INDEX_EXT+=__LIST_OUT_SIZE

goto %__GOTO_LOOP%

:RANGE_LOOP
if %__INDEX_INT_OUT% GEQ %__COPY_SIZE% goto LOOP_END

:ALL_LOOP
set "__VALUE="
for /F "tokens=%__INDEX_INT_IN% delims=%__SEPARATOR%" %%i in ("%__STRING%") do set "__VALUE=%%i"
if not defined __VALUE goto LOOP_END

set "%__VAR_NAME%[%__INDEX_EXT%]=%__VALUE%"

set /A __INDEX_INT_IN+=1
set /A __INDEX_INT_OUT+=1
set /A __INDEX_EXT+=1

goto %__GOTO_LOOP%

:LOOP_END

if defined __VAR_SIZE_NAME set %__VAR_SIZE_NAME%=%__INDEX_INT_OUT%
set %__VAR_NAME%.SIZE=%__INDEX_EXT%

rem drop temporary variables
(
  set "__VAR_NAME="
  set "__FROM_OFFSET="
  set "__COPY_SIZE="
  set "__VAR_SIZE_NAME="
  set "__STRING="
  set "__SEPARATOR="
  set "__GOTO_LOOP="
  set "__INDEX_INT_IN="
  set "__INDEX_INT_OUT="
  set "__INDEX_EXT="
  set "__LIST_OUT_SIZE="

  exit /b %__INDEX_INT_OUT%
)
