@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to spawn tasks in parallel but not greater than maximum.

setlocal

set MAX_SPAWN_TASKS=%~1
set MAX_WAIT_TASKS=%~2

if not defined MAX_SPAWN_TASKS (
  echo.%~nx0: error: max spawn tasks is not defined.
  exit /b 1
) >&2

if not defined MAX_WAIT_TASKS (
  echo.%~nx0: error: max wait tasks is not defined.
  exit /b 2
) >&2

if "%~3" == "" (
  echo.%~nx0: error: command line is empty.
  exit /b -1
) >&2

set SPAWNED_TASKS=0

set RND=%RANDOM%.%RANDOM%
set "RUNNING_TASKS_COUNTER_FILE=%TEMP%\spawn_tasks.counter.%RND%.var"
set "LOCK_FILE0=%TEMP%\spawn_tasks.lock.%RND%.var"

:REPEAT_READ_LOOP

rem lock via redirection to file
set LOCK_FILE0_ACQUIRE=0
(
  (
    rem if lock is acquired, then we are in...
    set /p RUNNING_TASKS_COUNTER= < "%RUNNING_TASKS_COUNTER_FILE%"
    if not defined RUNNING_TASKS_COUNTER set RUNNING_TASKS_COUNTER=0

    rem Drop error level to 0 to avoid interference with the error level from the redirection command below.
    type nul>nul
  ) 9> "%LOCK_FILE0%" && set LOCK_FILE0_ACQUIRE=1
) 2>nul

rem has lock been acquired and counter updated?
if %LOCK_FILE0_ACQUIRE% EQU 0 (
  rem repeat the action
  goto REPEAT_READ_WAIT
)

:REPEAT_SPAWN_LOOP

rem can run more tasks?
if %RUNNING_TASKS_COUNTER% LSS %MAX_WAIT_TASKS% goto SPAWN_TASK

:REPEAT_READ_WAIT

rem improvised sleep of 500 msec wait
pathping localhost -n -q 1 -p 500 >nul

goto REPEAT_READ_LOOP

:SPAWN_TASK
rem the task spawner CAN decrement the counter to the negative value, this is not critical here
start /B "" "%COMSPEC%" /c call "%~dp0task_spawner.bat" %3 %4 %5 %6 %7 %8 %9

set /a SPAWNED_TASKS+=1

:REPEAT_INCREMENT_LOOP

rem lock via redirection to file
set LOCK_FILE0_ACQUIRE=0
(
  (
    rem if lock is acquired, then we are in...
    rem reread the counter
    set /p RUNNING_TASKS_COUNTER= < "%RUNNING_TASKS_COUNTER_FILE%"
    if not defined RUNNING_TASKS_COUNTER set RUNNING_TASKS_COUNTER=0
    set /a RUNNING_TASKS_COUNTER+=1
    (call echo.%%RUNNING_TASKS_COUNTER%%) > "%RUNNING_TASKS_COUNTER_FILE%"

    rem Drop error level to 0 to avoid interference with the error level from the redirection command below.
    type nul>nul
  ) 9> "%LOCK_FILE0%" && set LOCK_FILE0_ACQUIRE=1
) 2>nul

rem has lock been acquired and counter updated?
if %LOCK_FILE0_ACQUIRE% EQU 0 (
  rem repeat the action
  goto REPEAT_INCREMENT_WAIT
)

if %SPAWNED_TASKS% GEQ %MAX_SPAWN_TASKS% goto MAX_SPAWN_REACHED

rem can run more tasks?
if %RUNNING_TASKS_COUNTER% LSS %MAX_WAIT_TASKS% goto SPAWN_TASK

rem don't wait
goto REPEAT_READ_LOOP

:REPEAT_INCREMENT_WAIT

rem improvised sleep of 500 msec wait
pathping localhost -n -q 1 -p 500 >nul

goto REPEAT_INCREMENT_LOOP

:MAX_SPAWN_REACHED
rem wait until counter updated 0 or less, then cleanup lock and exit

:WAIT_EXIT_LOOP

rem lock via redirection to file
set LOCK_FILE0_ACQUIRE=0
(
  (
    rem if lock is acquired, then we are in...
    set /p RUNNING_TASKS_COUNTER= < "%RUNNING_TASKS_COUNTER_FILE%"
    if not defined RUNNING_TASKS_COUNTER set RUNNING_TASKS_COUNTER=0

    rem Drop error level to 0 to avoid interference with the error level from the redirection command below.
    type nul>nul
  ) 9> "%LOCK_FILE0%" && set LOCK_FILE0_ACQUIRE=1
) 2>nul

rem has lock been acquired and counter updated?
if %LOCK_FILE0_ACQUIRE% EQU 0 (
  rem repeat the action
  goto REPEAT_WAIT_EXIT
)

if %RUNNING_TASKS_COUNTER% GTR 0 goto REPEAT_WAIT_EXIT

rem cleanup files
del /F /Q /A:-D "%LOCK_FILE0%" >nul 2>&1
del /F /Q /A:-D "%RUNNING_TASKS_COUNTER_FILE%" >nul 2>&1

exit /b 0

:REPEAT_WAIT_EXIT

rem improvised sleep of 500 msec wait
pathping localhost -n -q 1 -p 500 >nul

goto WAIT_EXIT_LOOP
