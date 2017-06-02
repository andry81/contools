@echo off

setlocal

set "LOCK_NAME=%~1"

call "%%~dp0__init__.bat" || goto :EOF

call "%%CONTOOLS_ROOT%%/uuidgen.bat"

set "LOCK_PATH=%TEMP%"
set "PRE_LOCK_FILE=prelock_mutex0.%LOCK_NAME%"
set "LOCK_DIR=lock_mutex0.%LOCK_NAME%"
set "UNLOCK_DIR=unlock0"
set "UNLOCK_FILE=unlock0"

set "OLD_LOCK_DIR=%LOCK_DIR%.%RETURN_VALUE%"

:PRE_LOCK_LOOP
rem prelock via redirection to file
set PRE_LOCK_ACQUIRE=0
(
  (
    rem cleanup if leaked by crash or ctrl-c, won't be removed if already acquired because of lock by current directory in a process of lock_dir_impl.bat
    rename "%LOCK_PATH%\%LOCK_DIR%" "%OLD_LOCK_DIR%" >nul 2>&1 && rmdir /S /Q "%LOCK_PATH%\%OLD_LOCK_DIR%" >nul 2>&1

    pushd "%LOCK_PATH%\%LOCK_DIR%\%UNLOCK_DIR%" >nul 2>&1 || (
      set LASTERROR=-1
      goto EXIT_FROM_PRELOCK
    )
    echo.%UNLOCK_DIR%_%LOCK_NAME% > "%LOCK_PATH%\%LOCK_DIR%\%UNLOCK_DIR%\%UNLOCK_FILE%"
    popd

    rem Drop error level to 0 to avoid accidental exit by error from above commands.
    rem Error must be raised ONLY by the redirection command!
    cd .

  ) 9> "%LOCK_PATH%\%PRE_LOCK_FILE%" && set PRE_LOCK_ACQUIRE=1
) 2>nul

rem could not prelock operations over the lock directory - somebody is already proccessing it for locking/unlocking
if %PRE_LOCK_ACQUIRE% NEQ 0 (
  rem directory lock is declared to release under the prelock, now is safe to remove the prelock file
  call :CLEANUP_PRELOCK
  exit /b 0
)

rem pathping localhost -n -q 1 -p 20 >nul 2>&1

goto PRE_LOCK_LOOP

:EXIT_FROM_PRELOCK
call :CLEANUP_PRELOCK
exit /b %LASTERROR%

:CLEANUP_PRELOCK
del /F /Q /A:-D "%LOCK_PATH%\%PRE_LOCK_FILE%" >nul 2>&1
goto :EOF
