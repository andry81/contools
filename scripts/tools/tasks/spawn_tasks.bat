@echo off

rem Description:
rem   Script to spawn tasks in parallel but not greater than maximum.

setlocal

set "?~dp0=%~dp0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem overall tasks to spawn, exit when reached
set "MAX_SPAWN_TASKS=%~1"

rem max permitted tasks to run together, otherwise wait
set "MAX_BUSY_TASKS=%~2"

rem min busy tasks to unlock spawn new tasks, may be left empty to not lock to spawn
set "MIN_BUSY_TASKS_TO_UNLOCK_SPAWN=%~3"

if not defined MAX_SPAWN_TASKS (
  echo;%?~%: error: max spawn tasks is not defined.
  exit /b 1
) >&2

if not defined MAX_BUSY_TASKS (
  echo;%?~%: error: max busy tasks is not defined.
  exit /b 2
) >&2

if "%~4" == "" (
  echo;%?~%: error: command line is empty.
  exit /b -1
) >&2

call "%%?~dp0%%__init__.bat" || exit /b

set SPAWN_TASK_INDEX=0
set RUNNING_TASKS_COUNTER=0
set PREV_RUNNING_TASKS_COUNTER=0
set IS_TASK_SPAWN_LOCKED=0

set RND=%RANDOM%.%RANDOM%

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "RUNNING_TASKS_COUNTER_FILE=%SCRIPT_TEMP_CURRENT_DIR%\spawn_tasks.counter.%RND%.var"
  set "LOCK_FILE0=%SCRIPT_TEMP_CURRENT_DIR%\spawn_tasks.lock.%RND%.var"
) else (
  set "RUNNING_TASKS_COUNTER_FILE=%TEMP%\spawn_tasks.counter.%RND%.var"
  set "LOCK_FILE0=%TEMP%\spawn_tasks.lock.%RND%.var"
)

:REPEAT_READ_LOOP

rem lock via redirection to file
set LOCK_FILE0_ACQUIRE=0
(
  (
    rem if lock is acquired, then we are in...
    set /P RUNNING_TASKS_COUNTER= < "%RUNNING_TASKS_COUNTER_FILE%"
    if not defined RUNNING_TASKS_COUNTER set RUNNING_TASKS_COUNTER=0

    rem Drop error level to 0 to avoid interference with the error level from the redirection command below.
    call;
  ) 9> "%LOCK_FILE0%" && set LOCK_FILE0_ACQUIRE=1
) 2>nul

rem has lock been acquired and counter updated?
if %LOCK_FILE0_ACQUIRE% EQU 0 (
  rem repeat the action
  goto REPEAT_READ_WAIT
)

:REPEAT_SPAWN_LOOP

rem can run more tasks?
if not defined MIN_BUSY_TASKS_TO_UNLOCK_SPAWN (
  if %RUNNING_TASKS_COUNTER% LSS %MAX_BUSY_TASKS% goto SPAWN_TASK
) else if %IS_TASK_SPAWN_LOCKED% EQU 0 (
  if %RUNNING_TASKS_COUNTER% LSS %MAX_BUSY_TASKS% goto SPAWN_TASK
  set IS_TASK_SPAWN_LOCKED=1
) else if %MIN_BUSY_TASKS_TO_UNLOCK_SPAWN% GEQ %RUNNING_TASKS_COUNTER% (
  set IS_TASK_SPAWN_LOCKED=0
  if %RUNNING_TASKS_COUNTER% LSS %MAX_BUSY_TASKS% goto SPAWN_TASK
)

:REPEAT_READ_WAIT

rem improvised sleep of 20 msec wait
call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20

goto REPEAT_READ_LOOP

:SPAWN_TASK
rem the task spawner CAN decrement the counter to the negative value, this is not critical here
start /B "" "%COMSPEC%" /c @"%%CONTOOLS_ROOT%%/std/callshift.bat" 3 "%%?~dp0%%task_spawner.bat" %*

set /A SPAWN_TASK_INDEX+=1

set PREV_RUNNING_TASKS_COUNTER=%RUNNING_TASKS_COUNTER%

:REPEAT_INCREMENT_LOOP

rem lock via redirection to file
set LOCK_FILE0_ACQUIRE=0
(
  (
    rem if lock is acquired, then we are in...
    rem reread the counter
    set /P RUNNING_TASKS_COUNTER= < "%RUNNING_TASKS_COUNTER_FILE%"
    if not defined RUNNING_TASKS_COUNTER set RUNNING_TASKS_COUNTER=0
    set /A RUNNING_TASKS_COUNTER+=1
    (call echo;%%RUNNING_TASKS_COUNTER%%) > "%RUNNING_TASKS_COUNTER_FILE%"

    rem Drop error level to 0 to avoid interference with the error level from the redirection command below.
    call;
  ) 9> "%LOCK_FILE0%" && set LOCK_FILE0_ACQUIRE=1
) 2>nul

rem has lock been acquired and counter updated?
if %LOCK_FILE0_ACQUIRE% EQU 0 (
  rem repeat the action
  goto REPEAT_INCREMENT_WAIT
)

if %SPAWN_TASK_INDEX% GEQ %MAX_SPAWN_TASKS% goto MAX_SPAWN_REACHED

rem can run more tasks?
if not defined MIN_BUSY_TASKS_TO_UNLOCK_SPAWN (
  if %RUNNING_TASKS_COUNTER% LSS %MAX_BUSY_TASKS% goto SPAWN_TASK
) else if %IS_TASK_SPAWN_LOCKED% EQU 0 (
  if %RUNNING_TASKS_COUNTER% LSS %MAX_BUSY_TASKS% goto SPAWN_TASK
  set IS_TASK_SPAWN_LOCKED=1
) else if %MIN_BUSY_TASKS_TO_UNLOCK_SPAWN% GEQ %RUNNING_TASKS_COUNTER% (
  set IS_TASK_SPAWN_LOCKED=0
  if %RUNNING_TASKS_COUNTER% LSS %MAX_BUSY_TASKS% goto SPAWN_TASK
)

rem don't wait
goto REPEAT_READ_LOOP

:REPEAT_INCREMENT_WAIT

rem improvised sleep of 20 msec wait
call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20

goto REPEAT_INCREMENT_LOOP

:MAX_SPAWN_REACHED
rem wait until counter updated 0 or less, then cleanup lock and exit

:WAIT_EXIT_LOOP

rem lock via redirection to file
set LOCK_FILE0_ACQUIRE=0
(
  (
    rem if lock is acquired, then we are in...
    set /P RUNNING_TASKS_COUNTER= < "%RUNNING_TASKS_COUNTER_FILE%"
    if not defined RUNNING_TASKS_COUNTER set RUNNING_TASKS_COUNTER=0

    rem Drop error level to 0 to avoid interference with the error level from the redirection command below.
    call;
  ) 9> "%LOCK_FILE0%" && set LOCK_FILE0_ACQUIRE=1
) 2>nul

rem has lock been acquired and counter updated?
if %LOCK_FILE0_ACQUIRE% EQU 0 (
  rem repeat the action
  goto REPEAT_WAIT_EXIT
)

if %RUNNING_TASKS_COUNTER% GTR 0 goto REPEAT_WAIT_EXIT

rem cleanup files
del /F /Q /A:-D "%LOCK_FILE0%" >nul 2>nul
del /F /Q /A:-D "%RUNNING_TASKS_COUNTER_FILE%" >nul 2>nul

exit /b 0

:REPEAT_WAIT_EXIT

rem improvised sleep of 20 msec wait
call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20

goto WAIT_EXIT_LOOP
