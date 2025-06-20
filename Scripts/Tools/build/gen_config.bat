@echo off & goto DOC_END

rem USAGE:
rem   gen_config.bat [<flags>] [--] <InputDir> <OutputDir> <ConfigFileName>

rem Description:
rem   Script to generate a configuration file which can consist of an input and
rem   output parts using `sed` utility.
rem
rem   The input configuration file is determined by the `.in` suffix in the
rem   file name and basically stores in a version control system.
rem   The output configuration file must not contain the `.in` suffix in the
rem   file name and is used as a local storage for a user values.
rem
rem   The script by default detects the input file change after the output
rem   file change and interrupts the generation with an error.
rem
rem   Additionally the `#%% version: ...` first line does read from both files
rem   to force the user to manually update the output configuration file from
rem   the input configuration file in case if these lines are not equal.
rem
rem   If the first line of the `<InputDir>/<ConfigFileName>` does not begin by
rem   the `#%% version:`, then the first line of the
rem   `<OutputDir>/<ConfigFileName>` does ignore.

rem <Flags>:
rem   -r <sed_replace_from> <sed_replace_to>
rem     The expression to replace for the sed in form:
rem       `s|<sed_replace_from>|<sed_replace_to>|mg`
rem
rem     Has no effect if <sed_replace_from> or <sed_replace_to> is empty.
rem
rem     To pass a special code character you can use the `$/<char>` or `$/\xNN`
rem     syntax, where `NN` is a hexadecimal code of a character.
rem
rem   -rm <sed_remove_from>
rem     The expression to replace for the sed in form:
rem       `s|<sed_remove_from>||mg`
rem
rem     Has no effect if <sed_remove_from> is empty.
rem
rem   -if_notexist
rem     Generate if output config does not exist.
rem
rem   -noexpire
rem     Disables output file expiration detection as by default.
rem
rem   -skip_checks
rem     Skip checks for faster execution.

rem --:
rem   Separator to stop parse flags.

rem <InputDir>:
rem   Input configuration file directory.
rem   Must be not empty and exist.

rem <OutputDir>:
rem   Output configuration file directory.
rem   Must be not empty and exist.

rem <ConfigFileName>:
rem   Input/Output configuration file.
rem   Must not contain `.in` suffix.
:DOC_END

setlocal

set "?~dp0=%~dp0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem script flags
set FLAG_IF_NOTEXIST=0
set FLAG_DETECT_EXPIRATION=1
set FLAG_SKIP_CHECKS=0
set "SED_BARE_FLAGS="
set "SED_REPLACE_FROM="
set "SED_REPLACE_TO="
set "SED_REMOVE_FROM="

:FLAGS_LOOP

if not defined SED_REPLACE_FROM goto SKIP_SED_REPLACE_FROM

set "SED_REPLACE_FROM=%SED_REPLACE_FROM:\=\\%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:|=\|%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:{=\{%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:}=\}%"

:SKIP_SED_REPLACE_FROM

if not defined SED_REPLACE_TO goto SKIP_SED_REPLACE_TO

set "SED_REPLACE_TO=%SED_REPLACE_TO:\=\\%"
set "SED_REPLACE_TO=%SED_REPLACE_TO:|=\|%"
set "SED_REPLACE_TO=%SED_REPLACE_TO:{=\{%"
set "SED_REPLACE_TO=%SED_REPLACE_TO:}=\}%"

:SKIP_SED_REPLACE_TO

if not defined SED_REMOVE_FROM goto SKIP_SED_REMOVE_FROM

set "SED_REMOVE_FROM=%SED_REMOVE_FROM:\=\\%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:|=\|%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:{=\{%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:}=\}%"

:SKIP_SED_REMOVE_FROM

rem special `$/<char>` sequence to pass `<char>` character as is (ex: `$/\x22` translates into `\x22` - a quote character)
if defined SED_REPLACE_FROM set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$/\\=\%"
if defined SED_REPLACE_TO set "SED_REPLACE_TO=%SED_REPLACE_TO:$/\\=\%"
if defined SED_REMOVE_FROM set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$/\\=\%"

if defined SED_REPLACE_FROM if defined SED_REPLACE_TO set SED_BARE_FLAGS=%SED_BARE_FLAGS% -e "s|%SED_REPLACE_FROM%|%SED_REPLACE_TO%|mg"
if defined SED_REMOVE_FROM set SED_BARE_FLAGS=%SED_BARE_FLAGS% -e "s|%SED_REMOVE_FROM%||mg"

set "SED_REPLACE_FROM="
set "SED_REPLACE_TO="
set "SED_REMOVE_FROM="

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-if_notexist" (
    set FLAG_IF_NOTEXIST=1
  ) else if "%FLAG%" == "-noexpire" (
    set FLAG_DETECT_EXPIRATION=0
  ) else if "%FLAG%" == "-skip_checks" (
    set FLAG_SKIP_CHECKS=1
  ) else if "%FLAG%" == "-r" (
    set "SED_REPLACE_FROM=%~2"
    set "SED_REPLACE_TO=%~3"
    shift
    shift
  ) else if "%FLAG%" == "-rm" (
    set "SED_REMOVE_FROM=%~2"
    shift
  ) else if not "%FLAG%" == "--" (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

set "CONFIG_IN_DIR=%~1"
set "CONFIG_OUT_DIR=%~2"
set "CONFIG_FILE=%~3"

if %FLAG_SKIP_CHECKS% NEQ 0 goto SKIP_CHECKS

if not defined CONFIG_IN_DIR (
  echo;%?~%: error: input config directory is not defined.
  exit /b 1
) >&2

if not defined CONFIG_OUT_DIR (
  echo;%?~%: error: output config directory is not defined.
  exit /b 2
) >&2

if not defined CONFIG_FILE (
  echo;%?~%: error: config file is not defined.
  exit /b 3
) >&2

for /F "tokens=* delims="eol^= %%i in ("%CONFIG_IN_DIR%\.") do set "CONFIG_IN_DIR=%%~fi"
for /F "tokens=* delims="eol^= %%i in ("%CONFIG_OUT_DIR%\.") do set "CONFIG_OUT_DIR=%%~fi"

if not exist "%CONFIG_IN_DIR%\%CONFIG_FILE%.in" (
  echo;%?~%: error: input config file does not exist: "%CONFIG_IN_DIR%\%CONFIG_FILE%.in".
  exit /b 10
) >&2

if not exist "%CONFIG_OUT_DIR%\*" (
  echo;%?~%: error: output config directory does not exist: "%CONFIG_OUT_DIR%".
  exit /b 11
) >&2

:SKIP_CHECKS

if exist "%CONFIG_OUT_DIR%\%CONFIG_FILE%" (
  if %FLAG_DETECT_EXPIRATION% NEQ 0 call "%%?~dp0%%check_config_expiration.bat" -- "%%CONFIG_IN_DIR%%\%%CONFIG_FILE%%.in" "%%CONFIG_OUT_DIR%%\%%CONFIG_FILE%%" || exit /b
  if %FLAG_IF_NOTEXIST% NEQ 0 exit /b 0
)

echo;"%CONFIG_IN_DIR%\%CONFIG_FILE%.in" -^> "%CONFIG_OUT_DIR%\%CONFIG_FILE%"

if not defined SED_BARE_FLAGS (
  type "%CONFIG_IN_DIR%\%CONFIG_FILE%.in" > "%CONFIG_OUT_DIR%\%CONFIG_FILE%"
  exit /b
)

rem initialize only in case of the sed usage
call "%%?~dp0%%__init__.bat" || exit /b

type "%CONFIG_IN_DIR%\%CONFIG_FILE%.in" | "%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe" -r -b%SED_BARE_FLAGS% > "%CONFIG_OUT_DIR%\%CONFIG_FILE%"
