@echo off & goto DOC_END

rem USAGE:
rem   gen_config_dir.bat [-+] [<flags>] [--] <InputDir> <OutputDir> <ConfigFiles>...

rem Description:
rem   Script to generate a list of configuration files in the output directory
rem   using the input directory and the `gen_Config.bat` script.
rem
rem   Script ignores these set of files:
rem     * config.system.vars.in
rem     * config.0.vars.in
rem     * ...
rem     * config.N.vars.in
rem
rem   To specifically generate these files you must use `load_config*.bat`
rem   scripts instead.
rem
rem   NOTE:
rem     All the rest description is in the `gen_config.bat` script.

rem <flags>:
rem   -r <sed_replace_from> <sed_replace_to>
rem     The expression to replace for the sed in form:
rem       `s|<sed_replace_from>|<sed_replace_to>}mg`
rem
rem     To pass a special code character you can use the `$/<char>` or `$/\xNN`
rem     syntax, where `NN` is a hexadecimal code of a character.
rem
rem   -if_notexist
rem     Generate if output config does not exist.
rem
rem   -noexpire
rem     Disables output file expiration detection as by default.

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

rem <ConfigFiles>:
rem   Input/Output configuration files with globbing.
rem   Must not contain `.in` suffix.

rem NOTE:
rem   All the rest parameters is in the `gen_config.bat` script.
:DOC_END

setlocal

set "?~dp0=%~dp0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

call "%%?~dp0%%.gen_config/gen_config_dir.read_flags.bat" %%* || exit /b

if %FLAG_SHIFT% GTR 0 for /L %%i in (1,1,%FLAG_SHIFT%) do shift

set "CONFIG_IN_DIR=%~1"
set "CONFIG_OUT_DIR=%~2"

if not defined CONFIG_IN_DIR (
  echo;%?~%: error: input config directory is not defined.
  exit /b 1
) >&2

if not defined CONFIG_OUT_DIR (
  echo;%?~%: error: output config directory is not defined.
  exit /b 2
) >&2

for /F "tokens=* delims="eol^= %%i in ("%CONFIG_IN_DIR%\.") do set "CONFIG_IN_DIR=%%~fi"
for /F "tokens=* delims="eol^= %%i in ("%CONFIG_OUT_DIR%\.") do set "CONFIG_OUT_DIR=%%~fi"

if not exist "%CONFIG_IN_DIR%\*" (
  echo;%?~%: error: input config directory does not exist: "%CONFIG_IN_DIR%".
  exit /b 10
) >&2

if not exist "%CONFIG_OUT_DIR%\*" (
  echo;%?~%: error: output config directory does not exist: "%CONFIG_OUT_DIR%".
  exit /b 11
) >&2

rem initialize only in case of the sed usage
if %HAS_SED_FLAGS% NEQ 0 call "%%?~dp0%%__init__.bat" || exit /b

shift
shift

set "CONFIG_FILE=%~1"

if not defined CONFIG_FILE (
  echo;%?~%: error: config files list is not defined.
  exit /b 20
) >&2

:CONFIG_FILE_LOOP
for %%i in ("%CONFIG_IN_DIR%\%CONFIG_FILE%.in") do (
  for /F "tokens=* delims="eol^= %%j in ("%%i") do set "CONFIG_FILE_NAME=%%~nj"
  call "%%?~dp0%%gen_config.bat" -skip_checks -+%%GEN_CONFIG_FLAGS%% -- "%%CONFIG_IN_DIR%%" "%%CONFIG_OUT_DIR%%" "%%CONFIG_FILE_NAME%%" || exit /b
)

shift

set "CONFIG_FILE=%~1"

if not defined CONFIG_FILE exit /b 0

goto CONFIG_FILE_LOOP
