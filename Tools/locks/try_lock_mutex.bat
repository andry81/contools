@echo off

setlocal

set "LOCK_NAME=%~1"

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0.."
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

call "%%TOOLS_PATH%%/uuidgen.bat"

set "LOCK_PATH=%TEMP%"
set "PRE_LOCK_FILE=prelock_mutex0_%LOCK_NAME%"
set "LOCK_DIR=lock_mutex0_%LOCK_NAME%"
set "UNLOCK_DIR=unlock0"
set "UNLOCK_FILE=unlock0"
set "WAITERS_DIR=waiters"

set "OLD_LOCK_DIR=%LOCK_DIR%_%RETURN_VALUE%"

:PRE_LOCK_LOOP
rem prelock via redirection to file
set PRE_LOCK_ACQUIRE=0
(
  (
    rem cleanup if leaked by crash or ctrl-c, won't be removed if already acquired because of lock by current directory in a process of lock_dir_impl.bat
    rename "%LOCK_PATH%\%LOCK_DIR%" "%OLD_LOCK_DIR%" >nul 2>&1 && rmdir /S /Q "%LOCK_PATH%\%OLD_LOCK_DIR%" >nul 2>&1

    mkdir "%LOCK_PATH%\%LOCK_DIR%" >nul 2>&1 || (
      set LASTERROR=-1
      goto EXIT_FROM_PRELOCK
    )

    rem make pushd to lock directory remove until start /D will be executed
    pushd "%LOCK_PATH%\%LOCK_DIR%" >nul 2>&1 || (
      rem do not leave lock directory in case of push error
      rmdir /S /Q "%LOCK_PATH%\%LOCK_DIR%" >nul 2>&1
    )

    rem Drop error level to 0 to avoid accidental exit by error from above commands.
    rem Error must be raised ONLY by the redirection command!
    cd .

  ) 9> "%LOCK_PATH%\%PRE_LOCK_FILE%" && set PRE_LOCK_ACQUIRE=1
) 2>nul

rem could not prelock operations over the lock directory - somebody is already proccessing it for locking/unlocking
if %PRE_LOCK_ACQUIRE% EQU 0 (
  rem pathping localhost -n -q 1 -p 20 >nul 2>&1

  goto PRE_LOCK_LOOP
)

rem directory lock is executed successfully under the prelock, now is safe to remove the prelock file
call :CLEANUP_PRELOCK

rem Make pushd to lock directory remove until "start /D" will be executed.
rem Create nested directories to enable mutex commands.
mkdir "%LOCK_PATH%\%LOCK_DIR%\%UNLOCK_DIR%"
mkdir "%LOCK_PATH%\%LOCK_DIR%\%WAITERS_DIR%"

start "" /D "%LOCK_PATH%\%LOCK_DIR%" /B cmd.exe /c call "%~dp0lock_dir_impl.bat" "%LOCK_PATH%" "%PRE_LOCK_FILE%" "%LOCK_DIR%" "%UNLOCK_DIR%" "%UNLOCK_FILE%" "%WAITERS_DIR%"

rem just in case
rem pathping localhost -n -q 1 -p 20 >nul 2>&1

popd

exit /b 0

:EXIT_FROM_PRELOCK
call :CLEANUP_PRELOCK
exit /b %LASTERROR%

:CLEANUP_PRELOCK
del /F /Q /A:-D "%LOCK_PATH%\%PRE_LOCK_FILE%" >nul 2>&1
goto :EOF
