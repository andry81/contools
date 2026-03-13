@echo off

setlocal

set "LOCK_NAME=%~1"

set "RAND=%RANDOM%-%RANDOM%"

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "LOCK_PATH=%SCRIPT_TEMP_CURRENT_DIR%"
) else set "LOCK_PATH=%TEMP%"
set "PRE_LOCK_FILE=prelock_mutex0.%LOCK_NAME%"
set "LOCK_DIR=lock_mutex0.%LOCK_NAME%"
set "UNLOCK_DIR=unlock0"
set "UNLOCK_FILE=unlock0"
set "WAITERS_DIR=waiters"
set "WAITER_FILE=waiter.%RAND%"

set "OLD_LOCK_DIR=%LOCK_DIR%.%RAND%"

:PRE_LOCK_LOOP
rem prelock via redirection to file
set PRE_LOCK_ACQUIRE=0
( ( rem if lock is acquired, then we are in...
    set PRE_LOCK_ACQUIRE=1
    rem clean up if leaked by crash or ctrl-c, won't be removed if already acquired because of lock by current directory in a process of lock_dir_impl.bat
    rename "%LOCK_PATH%\%LOCK_DIR%" "%OLD_LOCK_DIR%" >nul 2>nul && rmdir /S /Q "%LOCK_PATH%\%OLD_LOCK_DIR%" >nul 2>nul

    pushd "%LOCK_PATH%\%LOCK_DIR%\%WAITERS_DIR%" >nul 2>nul || (
      set LAST_ERROR=-1
      echo;Waiter [ %LOCK_NAME%\%WAITER_FILE% ] already unlocked
      goto EXIT_FROM_PRELOCK
    )
    echo;waiter_%LOCK_NAME% > "%LOCK_PATH%\%LOCK_DIR%\%WAITERS_DIR%\%WAITER_FILE%"
    popd
) 9> "%LOCK_PATH%\%PRE_LOCK_FILE%" ) 2>nul

rem could not prelock operations over the lock directory - somebody is already processing it for locking/unlocking
if %PRE_LOCK_ACQUIRE% EQU 0 (
  rem rem busy wait for 20 msec
  rem call "%%~dp0busy_wait.bat" 20

  goto PRE_LOCK_LOOP
)

rem directory lock is declared to release under the prelock, now is safe to remove the prelock file
call :CLEANUP_PRELOCK

:WAIT_LOOP
if not exist "%LOCK_PATH%\%LOCK_DIR%\%WAITERS_DIR%\%WAITER_FILE%" goto EXIT

rem busy wait for 20 msec
call "%%~dp0busy_wait.bat" 20

goto WAIT_LOOP

:EXIT
rem Try to clean up the lock directory before the exit.

rem prelock via redirection to file
( ( rem if lock is acquired, then we are in...
    rem clean up if leaked by crash or ctrl-c, won't be removed if already acquired because of lock by current directory in a process of lock_dir_impl.bat
    rename "%LOCK_PATH%\%LOCK_DIR%" "%OLD_LOCK_DIR%" >nul 2>nul && rmdir /S /Q "%LOCK_PATH%\%OLD_LOCK_DIR%" >nul 2>nul
) 9> "%LOCK_PATH%\%PRE_LOCK_FILE%" ) 2>nul

rem directory lock is cleaned up under the prelock, now is safe to remove the prelock file
call :CLEANUP_PRELOCK

echo;Waiter [ %LOCK_NAME%\%WAITER_FILE% ] exited

exit /b 0

:EXIT_FROM_PRELOCK
call :CLEANUP_PRELOCK
exit /b %LAST_ERROR%

:CLEANUP_PRELOCK
del /F /Q /A:-D "%LOCK_PATH%\%PRE_LOCK_FILE%" >nul 2>nul
exit /b
