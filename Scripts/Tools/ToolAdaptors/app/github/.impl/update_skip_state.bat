@echo off

setlocal

set "CMD=%~1"
set "PARAM0=%~2"
set "PARAM1=%~3"

if not defined SKIPPING_CMD exit /b 0

set HAD_SKIPPING_CMD=%SKIPPING_CMD%

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

if defined HAD_SKIPPING_CMD if not defined SKIPPING_CMD (
  echo.---
  echo.
)

(
  endlocal

  rem return values
  if %SKIPPING_CMD%0 NEQ 0 (
    set SKIPPING_CMD=1
  ) else set "SKIPPING_CMD="

  exit /b %LAST_ERROR%
)

:MAIN
set SKIPPING_CMD=1

if not "%FROM_CMD%" == "*" if not "%FROM_CMD%" == "%CMD%" exit /b 255

set "MATCH_PARAM0="
set "MATCH_PARAM1="

if defined FROM_CMD_PARAM0 (
  if "%FROM_CMD_PARAM0%" == "*" (
    set MATCH_PARAM0=1
  ) else if defined PARAM0 (
    if "%FROM_CMD_PARAM0%" == "%PARAM0%" set MATCH_PARAM0=1
  )
) else if not defined PARAM0 set MATCH_PARAM0=1

if not defined MATCH_PARAM0 exit /b 255

if defined FROM_CMD_PARAM1 (
  if "%FROM_CMD_PARAM1%" == "*" (
    set MATCH_PARAM1=1
  ) else if defined PARAM1 (
    if "%FROM_CMD_PARAM1%" == "%PARAM1%" set MATCH_PARAM1=1
  )
) else if not defined PARAM1 set MATCH_PARAM1=1

if not defined MATCH_PARAM1 exit /b 255

rem complete or partial match, stop command skip
set "SKIPPING_CMD="

exit /b 0
