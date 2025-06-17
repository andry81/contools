@echo off

setlocal

set "LOCK_NAMES=%~1"

call "%%~dp0__init__.bat" || exit /b

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "LOCK_PATH=%SCRIPT_TEMP_CURRENT_DIR%"
) else set "LOCK_PATH=%TEMP%"
set "UNLOCK_DIR=unlock0"
set "UNLOCK_FILE=unlock0"
set "WAITERS_DIR=waiters"

call :PREPARE_LOCK_WAITERS
if %NUM_WAITERS_UNEXISTED% GEQ %NUM_LOCK_WAITERS% exit /b -1
set NUM_WAITERS_COMPLETE=0
goto WAIT_LOOP

:PREPARE_LOCK_WAITERS
set NUM_LOCK_WAITERS=0
set NUM_WAITERS_UNEXISTED=0
set "LOCK_NAME="
set LOCK_WAITER_INDEX=1

:PREPARE_LOCK_WAITERS_IMPL
set "LOCK_NAME="
for /F "eol=# tokens=%LOCK_WAITER_INDEX% delims=:" %%i in ("%LOCK_NAMES%") do set "LOCK_NAME=%%i"
if not defined LOCK_NAME exit /b 0
call :PREPARE_LOCK_WAITER
set NUM_LOCK_WAITERS=%LOCK_WAITER_INDEX%
set /A LOCK_WAITER_INDEX+=1
goto PREPARE_LOCK_WAITERS_IMPL

:PREPARE_LOCK_WAITER
set "PRE_LOCK_FILE=prelock_mutex0.%LOCK_NAME%"
set "LOCK_DIR=lock_mutex0.%LOCK_NAME%"

set "RAND=%RANDOM%.%RANDOM%.%RANDOM%.%RANDOM%"

set "WAITER_FILE=waiter.%RAND%"
set "WAITER_FILE_%LOCK_WAITER_INDEX%="

rem clean up if leaked by crash or ctrl-c, won't be removed if already acquired because of lock by current directory in a process of lock_dir_impl.bat
set "OLD_LOCK_DIR=%LOCK_DIR%.%RAND%"

:PRE_LOCK_LOOP0
rem prelock via redirection to file
set PRE_LOCK_ACQUIRE=0
(
  (
    rename "%LOCK_PATH%\%LOCK_DIR%" "%OLD_LOCK_DIR%" >nul 2>nul && rmdir /S /Q "%LOCK_PATH%\%OLD_LOCK_DIR%" >nul 2>nul

    pushd "%LOCK_PATH%\%LOCK_DIR%\%WAITERS_DIR%" >nul 2>nul || (
      set LAST_ERROR=0
      set /A NUM_WAITERS_UNEXISTED+=1
      echo;Waiter [ %LOCK_NAME%\%WAITER_FILE% ] already unlocked
      goto EXIT_FROM_PRELOCK
    )

    set "LOCK_NAME_%LOCK_WAITER_INDEX%=%LOCK_NAME%"
    set "PRE_LOCK_FILE_%LOCK_WAITER_INDEX%=%PRE_LOCK_FILE%"
    set "LOCK_DIR_%LOCK_WAITER_INDEX%=%LOCK_DIR%"
    set "WAITER_FILE_%LOCK_WAITER_INDEX%=%WAITER_FILE%"

    echo;waiter_%LOCK_NAME% > "%LOCK_PATH%\%LOCK_DIR%\%WAITERS_DIR%\%WAITER_FILE%"

    popd

    rem Drop error level to 0 to avoid accidental exit by error from above commands.
    rem Error must be raised ONLY by the redirection command!
    call;

  ) 9> "%LOCK_PATH%\%PRE_LOCK_FILE%" && set PRE_LOCK_ACQUIRE=1
) 2>nul

rem could not prelock operations over the lock directory - somebody is already processing it for locking/unlocking
if %PRE_LOCK_ACQUIRE% NEQ 0 exit /b 0

rem call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20

goto PRE_LOCK_LOOP0

rem directory lock is declared to release under the prelock, now is safe to remove the prelock file
call :CLEANUP_PRELOCK

:WAIT_LOOP
call :LOCK_WAITING && exit /b 0

call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20

goto WAIT_LOOP

:LOCK_WAITING
set LOCK_WAITER_INDEX=1
for /L %%i in (%LOCK_WAITER_INDEX%,1,%NUM_LOCK_WAITERS%) do call :WAIT_LOCK "%%i"
set /A NUM_WAITERS_OVERALL=%NUM_WAITERS_UNEXISTED%+%NUM_WAITERS_COMPLETE%
goto EXIT

:WAIT_LOCK
set "LOCK_WAITER_INDEX=%~1"
call set "WAITER_FILE=%%WAITER_FILE_%LOCK_WAITER_INDEX%%%"

if not defined WAITER_FILE exit /b 0

call set "LOCK_NAME=%%LOCK_NAME_%LOCK_WAITER_INDEX%%%"
call set "PRE_LOCK_FILE=%%PRE_LOCK_FILE_%LOCK_WAITER_INDEX%%%"
call set "LOCK_DIR=%%LOCK_DIR_%LOCK_WAITER_INDEX%%%"

set "OLD_LOCK_DIR=%LOCK_DIR%.%RANDOM%.%RANDOM%.%RANDOM%.%RANDOM%"

rem prelock via redirection to file
(
  (
    rem clean up if leaked by crash or ctrl-c, won't be removed if already acquired because of lock by current directory in a process of lock_dir_impl.bat
    rename "%LOCK_PATH%\%LOCK_DIR%" "%OLD_LOCK_DIR%" >nul 2>nul && rmdir /S /Q "%LOCK_PATH%\%OLD_LOCK_DIR%" >nul 2>nul
  ) 9> "%LOCK_PATH%\%PRE_LOCK_FILE%"
) 2>nul

if not exist "%LOCK_PATH%\%LOCK_DIR%\%WAITERS_DIR%\%WAITER_FILE%" (
  rem release waiter
  set "WAITER_FILE_%LOCK_WAITER_INDEX%="
  set /A NUM_WAITERS_COMPLETE+=1

  rem Try to clean up the lock directory before the exit.

  rem prelock via redirection to file
  (
    (
      rem clean up if leaked by crash or ctrl-c, won't be removed if already acquired because of lock by current directory in a process of lock_dir_impl.bat
      rename "%LOCK_PATH%\%LOCK_DIR%" "%OLD_LOCK_DIR%" >nul 2>nul && rmdir /S /Q "%LOCK_PATH%\%OLD_LOCK_DIR%" >nul 2>nul
    ) 9> "%LOCK_PATH%\%PRE_LOCK_FILE%"
  ) 2>nul

  rem directory lock is cleaned up under the prelock, now is safe to remove the prelock file
  call :CLEANUP_PRELOCK

  echo;Waiter [ %LOCK_NAME%\%WAITER_FILE% ] exited
)

exit /b 0

:EXIT
if %NUM_WAITERS_OVERALL% GEQ %NUM_LOCK_WAITERS% exit /b 0
exit /b 1

:EXIT_FROM_PRELOCK
call :CLEANUP_PRELOCK
exit /b %LAST_ERROR%

:CLEANUP_PRELOCK
del /F /Q /A:-D "%LOCK_PATH%\%PRE_LOCK_FILE%" >nul 2>nul
exit /b
