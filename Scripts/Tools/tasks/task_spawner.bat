@echo off

setlocal

if not exist "%LOCK_FILE0%" exit /b -1

rem A TASK MUST WAIT HERE
rem ----------------------------------------
%*
rem ----------------------------------------

:REPEAT_DECREMENT_LOOP

rem lock via redirection to file
set LOCK_FILE0_ACQUIRE=0
(
  (
    rem if lock is acquired, then we are in...
    set /P RUNNING_TASKS_COUNTER= < "%RUNNING_TASKS_COUNTER_FILE%"
    if not defined RUNNING_TASKS_COUNTER set RUNNING_TASKS_COUNTER=0
    set /A RUNNING_TASKS_COUNTER-=1
    (call echo;%%RUNNING_TASKS_COUNTER%%) > "%RUNNING_TASKS_COUNTER_FILE%"

    rem Drop error level to 0 to avoid interference with the error level from the redirection command below.
    call;
  ) 9> "%LOCK_FILE0%" && set LOCK_FILE0_ACQUIRE=1
) 2>nul

rem has lock been acquired and counter updated?
if %LOCK_FILE0_ACQUIRE% EQU 0 (
  rem repeat the action
  goto REPEAT_DECREMENT_WAIT
)

exit /b 0

:REPEAT_DECREMENT_WAIT

rem improvised sleep of 20 msec wait
call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20

goto REPEAT_DECREMENT_LOOP
