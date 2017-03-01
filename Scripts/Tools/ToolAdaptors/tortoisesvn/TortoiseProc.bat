@echo off

setlocal

rem script flags
set FLAG_WAIT_EXIT=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  if "%FLAG%" == "-wait" (
    set FLAG_WAIT_EXIT=1
    shift
  )

  rem read until no flags
  goto FLAGS_LOOP
)

set "COMMAND=%~1"
set "PWD=%~2"
shift
shift

if "%PWD%" == "" goto NOPWD
( %PWD:~0,2% && cd "%PWD%" ) || exit /b 1

:NOPWD

rem run COMMAND over selected files/directories in the PWD directory
:CURDIR_LOOP
set "FILENAME=%~1"

if "%FILENAME%" == "" exit /b 0

if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" TortoiseProc.exe %%COMMAND%% /path:"%%FILENAME%%"
) else (
  call :CMD start /B "" TortoiseProc.exe %%COMMAND%% /path:"%%FILENAME%%"
)

shift

goto CURDIR_LOOP

:CMD
echo.^>%*
(%*)
