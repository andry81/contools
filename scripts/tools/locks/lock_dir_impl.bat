@echo off

rem external process script to lock directory by start /D command

setlocal

set "LOCK_PATH=%~1"
set "PRE_LOCK_FILE=%~2"
set "LOCK_DIR=%~3"
set "UNLOCK_DIR=%~4"
set "UNLOCK_FILE=%~5"
set "WAITERS_DIR=%~6"

call "%%~dp0__init__.bat" || exit /b

set "RAND=%RANDOM%.%RANDOM%.%RANDOM%.%RANDOM%"

set "OLD_LOCK_DIR=%LOCK_DIR%.%RAND%"
set "OLD_UNLOCK_DIR=%UNLOCK_DIR%.%RAND%"
set "OLD_WAITERS_DIR=%WAITERS_DIR%.%RAND%"

:WAIT_LOOP
if exist "%LOCK_PATH%\%LOCK_DIR%\%UNLOCK_DIR%\%UNLOCK_FILE%" goto EXIT

call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20

goto WAIT_LOOP

:EXIT

rem clean up nested directories recursively before exit
:EXIT_CLEANUP_LOOP0
set CLEANUP_UNLOCK_DIR=0
set CLEANUP_WAITERS_DIR=0

rename "%LOCK_PATH%\%LOCK_DIR%\%UNLOCK_DIR%" "%OLD_UNLOCK_DIR%" >nul 2>nul && rmdir /S /Q "%LOCK_PATH%\%LOCK_DIR%\%OLD_UNLOCK_DIR%" >nul 2>nul
if not exist "%LOCK_PATH%\%LOCK_DIR%\%UNLOCK_DIR%" (
  rem the lock directory will be unlocked at exit
  set CLEANUP_UNLOCK_DIR=1
)

rename "%LOCK_PATH%\%LOCK_DIR%\%WAITERS_DIR%" "%OLD_WAITERS_DIR%" >nul 2>nul && rmdir /S /Q "%LOCK_PATH%\%LOCK_DIR%\%OLD_WAITERS_DIR%" >nul 2>nul
if not exist "%LOCK_PATH%\%LOCK_DIR%\%WAITERS_DIR%" (
  rem the lock directory will be unlocked at exit
  set CLEANUP_WAITERS_DIR=1
)

rem we should not exit until nested directories would not be fully cleaned up
if %CLEANUP_UNLOCK_DIR% EQU 0 goto EXIT_CLEANUP_LOOP0
if %CLEANUP_WAITERS_DIR% EQU 0 goto EXIT_CLEANUP_LOOP0

rem acquire the prelock to maintain the lock

:EXIT_PRE_LOCK_LOOP
rem prelock via redirection to file
set PRE_LOCK_ACQUIRE=0
(
  (
    rem now is safe to release the lock and clean up the lock directory
    call :RELEASE_AND_CLEANUP_LOCK

    rem Drop error level to 0 to avoid accidental exit by error from above commands.
    rem Error must be raised ONLY by the redirection command!
    call;

  ) 9> "%LOCK_PATH%\%PRE_LOCK_FILE%" && set PRE_LOCK_ACQUIRE=1
) 2>nul

rem if could not prelock operations over the lock directory - somebody is already processing it for locking/unlocking
if %PRE_LOCK_ACQUIRE% NEQ 0 (
  rem directory lock is released and cleaned up under the prelock, now is safe to remove the prelock file
  del /F /Q /A:-D "%LOCK_PATH%\%PRE_LOCK_FILE%" >nul 2>nul

  exit /b 0
)

rem call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20

goto EXIT_PRE_LOCK_LOOP

:RELEASE_AND_CLEANUP_LOCK
rem release the lock
cd "%LOCK_PATH%"

:RELEASE_AND_CLEANUP_LOCK_LOOP
rem clean up the lock directory
rename "%LOCK_PATH%\%LOCK_DIR%" "%OLD_LOCK_DIR%" >nul 2>nul && rmdir /S /Q "%LOCK_PATH%\%OLD_LOCK_DIR%" >nul 2>nul

if not exist "%LOCK_PATH%\%LOCK_DIR%" exit /b 0

rem we should not exit until the lock directory would not be cleaned up
rem call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20

goto RELEASE_AND_CLEANUP_LOCK_LOOP
