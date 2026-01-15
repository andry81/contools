@echo off & goto DOC_END

rem USAGE:
rem   gen_config.bat [-+] [<flags>] [--] <InputDir> <OutputDir> <ConfigFileName>

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
rem   If the first line of the `<InputDir>/<ConfigFileName>.in` does not begin
rem   by the `#%% version:`, then the first line of the
rem   `<OutputDir>/<ConfigFileName>` does not check.

rem <flags>:
rem   -s
rem     Replace in the entire file as a single instead of in each line as by
rem     default.
rem
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

rem -+:
rem   Separator to begin flags scope to parse.
rem --:
rem   Separator to end flags scope to parse.
rem   Required if `-+` is used.
rem   If `-+` is used, then must be used the same quantity of times.

rem <InputDir>:
rem   Input configuration file directory.
rem   Must be not empty and exist.

rem <OutputDir>:
rem   Output configuration file directory.
rem   Must be not empty and exist.

rem <ConfigFileName>:
rem   Input/Output configuration file.
rem   Must not contain `.in` suffix.

rem CAUTION:
rem   The `sed` does interpret the input as a character stream separated by
rem   line returns. So if you want to replace in the entire file as a single,
rem   then you must use `-s` flag.

rem NOTE:
rem   These characters can not be used directly and must be escaped with the
rem   `$/\xNN` sequence:
rem
rem     NUL   ->    $/\x00
rem     LF    ->    $/\x0A
rem     CR    ->    $/\x0D
rem     SUB   ->    $/\x1A
rem     "     ->    $/\x22
rem
rem   These characters can be used directly but has side effects and has to be
rem   escaped with the `$/\xNN` sequence:
rem
rem     ^     ->    $/\x5E (duplicates by the `call` prefix)
rem
rem   These characters can be used directly but still can be escaped with the
rem   `$/\xNN` sequence:
rem
rem     %     ->    $/\x25
rem
rem   The character with code higher than 127 (7F) still must be escaped with
rem   `$/\xNN` sequence.
rem
rem   The unicode characters can be escaped by `$/\uNNNN` sequence.

:DOC_END

setlocal DISABLEDELAYEDEXPANSION

set "?~dp0=%~dp0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

call "%%?~dp0%%.gen_config/gen_config.read_flags.bat" %%* || exit /b

if %FLAG_SHIFT% GTR 0 for /L %%i in (1,1,%FLAG_SHIFT%) do shift

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

rem Based on: https://unix.stackexchange.com/questions/182153/sed-read-whole-file-into-pattern-space-without-failing-on-single-line-input/182154#182154
rem
rem NOTE:
rem   Reads portably whole file into pattern space.
rem
if %FLAG_SINGLE% NEQ 0 set SED_BARE_FLAGS= -e "H;1h;$!d;x"%SED_BARE_FLAGS%

type "%CONFIG_IN_DIR%\%CONFIG_FILE%.in" | "%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe" -r -b%SED_BARE_FLAGS% > "%CONFIG_OUT_DIR%\%CONFIG_FILE%"
