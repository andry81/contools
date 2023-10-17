@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%*

rem script flags
set "SED_BARE_FLAGS="
set "SED_REPLACE_FROM="
set "SED_REPLACE_TO="

:FLAGS_LOOP

if defined SED_REPLACE_FROM set "SED_REPLACE_FROM=%SED_REPLACE_FROM:\=\\%"
if defined SED_REPLACE_FROM set "SED_REPLACE_FROM=%SED_REPLACE_FROM:|=\|%"
if defined SED_REPLACE_FROM set "SED_REPLACE_FROM=%SED_REPLACE_FROM:{=\{%"
if defined SED_REPLACE_FROM set "SED_REPLACE_FROM=%SED_REPLACE_FROM:}=\}%"

if defined SED_REPLACE_TO set "SED_REPLACE_TO=%SED_REPLACE_TO:\=\\%"
if defined SED_REPLACE_TO set "SED_REPLACE_TO=%SED_REPLACE_TO:|=\|%"
if defined SED_REPLACE_TO set "SED_REPLACE_TO=%SED_REPLACE_TO:{=\{%"
if defined SED_REPLACE_TO set "SED_REPLACE_TO=%SED_REPLACE_TO:}=\}%"

if defined SED_REPLACE_FROM if defined SED_REPLACE_TO set SED_BARE_FLAGS=%SED_BARE_FLAGS% -e "s|%SED_REPLACE_FROM%|%SED_REPLACE_TO%|mg"

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-r" (
    set "SED_REPLACE_FROM=%~2"
    set "SED_REPLACE_TO=%~3"
    shift
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "CONFIG_IN_DIR=%~1"
set "CONFIG_OUT_DIR=%~2"
set "CONFIG_FILE=%~3"

if not defined CONFIG_IN_DIR (
  echo.%?~nx0%: error: input config directory is not defined.
  exit /b 1
) >&2

if not defined CONFIG_OUT_DIR (
  echo.%?~nx0%: error: output config directory is not defined.
  exit /b 2
) >&2

for /F "eol= tokens=* delims=" %%i in ("%CONFIG_IN_DIR%\.") do set "CONFIG_IN_DIR=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%CONFIG_OUT_DIR%\.") do set "CONFIG_OUT_DIR=%%~fi"

if not exist "%CONFIG_IN_DIR%\*" (
  echo.%?~nx0%: error: input config directory does not exist: "%CONFIG_IN_DIR%".
  exit /b 10
) >&2

if not exist "%CONFIG_OUT_DIR%\*" (
  echo.%?~nx0%: error: output config directory does not exist: "%CONFIG_OUT_DIR%".
  exit /b 11
) >&2

if not exist "%CONFIG_OUT_DIR%\%CONFIG_FILE%" ^
if exist "%CONFIG_IN_DIR%\%CONFIG_FILE%.in" (
  echo."%CONFIG_IN_DIR%\%CONFIG_FILE%.in" -^> "%CONFIG_OUT_DIR%\%CONFIG_FILE%"
  if defined SED_BARE_FLAGS (
    type "%CONFIG_IN_DIR%\%CONFIG_FILE%.in" | "%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" -r -b%SED_BARE_FLAGS% > "%CONFIG_OUT_DIR%\%CONFIG_FILE%"
  ) else type "%CONFIG_IN_DIR%\%CONFIG_FILE%.in" > "%CONFIG_OUT_DIR%\%CONFIG_FILE%"
)
