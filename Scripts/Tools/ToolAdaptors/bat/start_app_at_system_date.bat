@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Use callf.exe utility to elevate and change the system date on a moment
rem   to start an application under not elevated permissions.
rem   Then change system date back after a timeout (seconds).
rem

setlocal

rem disable all generation: creation files/directories, generation config, logging, etc
set NO_GEN=1

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

set "CALLF_ELEVATE_EXECUTABLE=%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"
set "CALLF_UNELEVATE_EXECUTABLE=%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"
set "CALLF_ELEVATE_BARE_FLAGS="

set "START_BARE_FLAGS="

rem script flags
set FLAG_TIMEOUT_SEC=0
set "FLAG_AT_DATE="
set FLAG_WAIT=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-gui" (
    set "CALLF_ELEVATE_EXECUTABLE=%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callfg.exe"
    set "CALLF_UNELEVATE_EXECUTABLE=%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callfg.exe"
    set CALLF_ELEVATE_BARE_FLAGS=%CALLF_ELEVATE_BARE_FLAGS% /no-window
  ) else if "%FLAG%" == "-timeout" (
    set "FLAG_TIMEOUT_SEC=%~2"
    shift
  ) else if "%FLAG%" == "-at_date" (
    set "FLAG_AT_DATE=%~2"
    shift
  ) else if "%FLAG%" == "-wait" (
    set FLAG_WAIT=1
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  )

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

if not defined FLAG_AT_DATE (
  echo.%?~nx0%: error: `-at_date` option must be defined.
  exit /b 255
) >&2

if %FLAG_WAIT% EQU 0 set START_BARE_FLAGS=%START_BARE_FLAGS% /no-wait

rem save current date
set "CURRENT_DATE=%DATE%"
echo.%1 %2

if %FLAG_TIMEOUT_SEC% NEQ 0 (
  "%CALLF_ELEVATE_EXECUTABLE%" /pause-on-exit-if-error /ret-child-exit /shell-exec runas /S1%CALLF_ELEVATE_BARE_FLAGS% "${COMSPEC}" "/c \"( date ${FLAG_AT_DATE} ^) ^^^&^^^& ( \"${CALLF_UNELEVATE_EXECUTABLE}\" /shell-exec-unelevate-from-explorer%START_BARE_FLAGS% {*} ^) ^^^&^^^& ( timeout /T ${FLAG_TIMEOUT_SEC} ^) ^^^& ( date ${CURRENT_DATE} ^)\"" %1 %2 %3 %4 %5 %6 %7 %8 %9
) else "%CALLF_ELEVATE_EXECUTABLE%" /pause-on-exit-if-error /ret-child-exit /shell-exec runas /S1%CALLF_ELEVATE_BARE_FLAGS% "${COMSPEC}" "/c \"( date ${FLAG_AT_DATE} ^) ^^^&^^^& ( \"${CALLF_UNELEVATE_EXECUTABLE}\" /shell-exec-unelevate-from-explorer%START_BARE_FLAGS% {*} ^) ^^^& ( date ${CURRENT_DATE} ^)\"" %1 %2 %3 %4 %5 %6 %7 %8 %9
