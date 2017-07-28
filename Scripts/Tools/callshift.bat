@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script calls first argument and passes to it all arguments beginning from %3 plus index from %2

rem Command arguments:
rem %1 - command line executable path.
rem %2 - index
rem %3-... - command line arguments.

rem Examples:
rem 1. call callshift.bat echo
rem    echo PATH_VALUE=%PATH_VALUE%

rem Drop last error level
type nul>nul

setlocal

set __ARGS_INDEX_FROM=2

set "__CMD_ARGS__="
set __ARG_INDEX=0

set ?0=^^

:ARGS_LOOP
if %__ARG_INDEX% EQU 1 set "__ARGS_INDEX_FROM=%~1"
if %__ARG_INDEX% EQU 1 if "%__ARGS_INDEX_FROM%" == "" set __ARGS_INDEX_FROM=0
if %__ARG_INDEX% EQU 1 ( set /A __ARGS_INDEX_FROM+=2 & goto ARGS_LOOP_CONTINUE )
if %__ARG_INDEX% NEQ 0 if %__ARG_INDEX% LSS %__ARGS_INDEX_FROM% goto ARGS_LOOP_CONTINUE

set __ARG=%1

rem Save first character, even if a special character. If argument was empty then substution of `%__ARG:~0,1%` will be `~0,1` (bug case around default value).
set __SET1=^%__ARG:~0,1%/-

rem cmd.exe issue workaround: extract second character, because the statement if ^~0,1/ == / will raise error around ~0,1 characters sequence!
set __SET2=%__SET1:~1,1%

rem because __SET2 variable's value does not have special characters, then we can test it w/o any tricks

if %__SET2% == 0 goto ARGS_LOOP_END

call set __ARG#%__ARG_INDEX%=%%1
if %__ARG_INDEX% GTR 0 (
  set __CMD_ARGS__=%__CMD_ARGS__% %%__ARG#%__ARG_INDEX%%%
) else (
  set __CMD_ARGS__=%%__ARG#%__ARG_INDEX%%%
)

:ARGS_LOOP_CONTINUE
set /A __ARG_INDEX+=1

shift

goto ARGS_LOOP

:ARGS_LOOP_END
if %__ARG_INDEX% GTR 0 call %__CMD_ARGS__%
