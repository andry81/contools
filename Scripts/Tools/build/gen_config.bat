@echo off

rem USAGE:
rem   gen_config.bat [<flags>] [--] <InputDir> <OutputDir> <ConfigFileName>

rem Description:
rem   Script to generate a configuration file which can consist of an input and
rem   output parts using `sed` utility.
rem   The input configuration file is deteminded by the `.in` suffix in the
rem   file name and basically stores in a version control system.
rem   The output configuration file must not contain the `.in` suffix in the
rem   file name and is used as a local storage for a user values.

rem <Flags>:
rem   --
rem     Stop flags parse.
rem   -r <sed_replace_from> <sed_replace_to>
rem     The expression to replace for the sed in form:
rem       `s|<sed_replace_from>|<sed_replace_to>}mg`
rem   -if_notexist
rem     Generate if output config does not exist.

rem <InputDir>:
rem   Input configuration file directory.
rem   Must be not empty and exist.

rem <OutputDir>:
rem   Output configuration file directory.
rem   Must be not empty and exist.

rem <ConfigFileName>:
rem   Input/Output configuration file.
rem   Must not contain `.in` suffix.

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem script flags
set FLAG_IF_NOTEXIST=0
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

rem special `$/<char>` sequence to pass `<char>` character as is (ex: `$/\x22` translates into `\x22` - a quote character)
if defined SED_REPLACE_FROM set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$/\\=\%"
if defined SED_REPLACE_TO set "SED_REPLACE_TO=%SED_REPLACE_TO:$/\\=\%"

if defined SED_REPLACE_FROM if defined SED_REPLACE_TO set SED_BARE_FLAGS=%SED_BARE_FLAGS% -e "s|%SED_REPLACE_FROM%|%SED_REPLACE_TO%|mg"

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-if_notexist" (
    set FLAG_IF_NOTEXIST=1
  ) else if "%FLAG%" == "-r" (
    set "SED_REPLACE_FROM=%~2"
    set "SED_REPLACE_TO=%~3"
    shift
    shift
  ) else if not "%FLAG%" == "--" (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
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

if not defined CONFIG_FILE (
  echo.%?~nx0%: error: config file is not defined.
  exit /b 3
) >&2

for /F "eol= tokens=* delims=" %%i in ("%CONFIG_IN_DIR%\.") do set "CONFIG_IN_DIR=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%CONFIG_OUT_DIR%\.") do set "CONFIG_OUT_DIR=%%~fi"

if not exist "%CONFIG_IN_DIR%\%CONFIG_FILE%.in" (
  echo.%?~nx0%: error: input config file does not exist: "%CONFIG_IN_DIR%\%CONFIG_FILE%.in".
  exit /b 10
) >&2

if not exist "%CONFIG_OUT_DIR%\*" (
  echo.%?~nx0%: error: output config directory does not exist: "%CONFIG_OUT_DIR%".
  exit /b 11
) >&2

if %FLAG_IF_NOTEXIST% NEQ 0 if exist "%CONFIG_OUT_DIR%\%CONFIG_FILE%" exit /b 0

echo."%CONFIG_IN_DIR%\%CONFIG_FILE%.in" -^> "%CONFIG_OUT_DIR%\%CONFIG_FILE%"

if defined SED_BARE_FLAGS (
  type "%CONFIG_IN_DIR%\%CONFIG_FILE%.in" | "%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" -r -b%SED_BARE_FLAGS% > "%CONFIG_OUT_DIR%\%CONFIG_FILE%"
) else type "%CONFIG_IN_DIR%\%CONFIG_FILE%.in" > "%CONFIG_OUT_DIR%\%CONFIG_FILE%"
