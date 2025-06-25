@echo off & goto DOC_END

rem USAGE:
rem   load_config.bat [<Flags>] [--] <InputDir> <OutputDir> <ConfigFileName> [<Param0> [<Param1>]]

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
rem

rem Description:
rem   Script to load a configuration file which can consist of an input and
rem   output parts.
rem
rem   The input configuration file is determined by the `.in` suffix in the
rem   file name and basically stores in a version control system.
rem   The output configuration file must not contain the `.in` suffix in the
rem   file name and is used as a local storage for a user values.
rem
rem   The script detects the input file change after the output file change
rem   and interrupts the load with an error.
rem
rem   Additionally the `#%% version: ...` line is searched in both files and
rem   compared to force the user to manually update the output configuration
rem   file from the input configuration file in case if are not equal.
rem
rem   By default the script does load the input configuration from the
rem   `<ConfigFileName>` file.
rem
rem   If `-gen_config` or `-load_output_config` flag is used, then the
rem   input configuration file name is used as `<ConfigFileName>.in`.

rem <Flags>:
rem   -gen_config
rem     Generates the output configuration file from the input configuration
rem     file if the output configuration file does not exist, otherwise skips
rem     the generation.
rem     Implies `-load_output_config` flag.
rem
rem   -load_output_config
rem     Loads the output configuration file instead of the input configuration
rem     file as by default.
rem
rem   -noexpand
rem     Disables expansion of %-variables.

rem --:
rem   Separator to stop parse flags.

rem <InputDir>:
rem   Input configuration file directory.
rem   Must be not empty and exist.

rem <OutputDir>:
rem   Output configuration file directory.
rem   Must be not empty.
rem   May not exist if the script does load the input configuration file.

rem <ConfigFileName>:
rem   Input/Output configuration file.
rem   May contain `.in` suffix if the script does load the input configuration
rem   file only. In all other cases - must not.

rem <Param0>, <Param1>:
rem   Parameterizes the loader to load additionally custom variables.
rem   If not defined, then custom variables does ignore.

rem CONFIGURATION FILE FORMAT:
rem   [<attributes>] <variable>[:<class_name>]=<value>
rem   [<attributes>] <variable>[:[<param0>][:[<param1>]]]=<value>
rem
rem <attributes>:           Variable space separated attributes: once | export | upath
rem <variable>:             Variable name corresponding to the regex: [_a-zA-Z][_a-zA-Z0-9]*
rem <class_name>:           Builtin class variant names: OSWIN | OSUNIX | BAT | SH
rem   OSWIN:                Apply on Windows system including cygwin/mingw/msys subsystems.
rem   OSUNIX:               Apply on Unix/Linux systems excluding cygwin/mingw/msys subsystems.
rem   BAT:                  Apply on Windows system when this file has loaded from the Windows batch script loader.
rem   SH:                   Apply on any system when this file has loaded from the Bash shell script loader.
rem
rem <param0>, <param1>:     Custom variable parameters.
rem                         Example:
rem                           <Param0>=OSWINXP
rem                           <Param1>=OS32
rem
rem                           Loads besides the builtin variable classes, these:
rem                           A:OSWINXP=...
rem                           B:OSWINXP:OS32=...
rem                           C::OS32=...
rem
rem <value>:                Value with substitution support: `%<variable>%`
rem                         Can start by the `"` quote character, but two quotes does remove only when exist on both ends of a value.
rem
rem <attributes>:
rem   once
rem     Sets the variable only if it is not defined.
rem   export
rem     (Unix shell only)
rem     Exports the variable additionally to the set.
rem   upath
rem     Treats a variable value as a path and converts it to a uniform path
rem     (use forward slashes only).

rem Parse logic:
rem   Uses %-variables expansion.
rem   The only `%<variable>%` placeholders can be expanded in a variable value.
:DOC_END

setlocal DISABLEDELAYEDEXPANSION

set "__?~dp0=%~dp0"

rem script names call stack
if defined ?~ ( set "__?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "__?~=%?~nx0%-^>%~nx0" ) else set "__?~=%~nx0"

if defined NO_GEN set /A NO_GEN+=0

call "%%__?~dp0%%.load_config/load_config.read_flags.bat" %%* || exit /b

if %NO_GEN%0 NEQ 0 if %__?FLAG_GEN_CONFIG% NEQ 0 (
  echo;%__?~%: error: can not generate config while NO_GEN is set.
  exit /b 255
) >&2

if %__?FLAG_SHIFT% GTR 0 for /L %%i in (1,1,%__?FLAG_SHIFT%) do shift

set "__?CONFIG_IN_DIR=%~1"
set "__?CONFIG_OUT_DIR=%~2"
set "__?CONFIG_FILE_NAME=%~3"
set "__?PARAM0=%~4"
set "__?PARAM1=%~5"

if not defined __?CONFIG_IN_DIR (
  echo;%__?~%: error: input config directory is not defined.
  exit /b 1
) >&2

if not defined __?CONFIG_OUT_DIR (
  echo;%__?~%: error: output config directory is not defined.
  exit /b 2
) >&2

rem check on invalid characters in params
if defined __?PARAM0 if not "%__?PARAM0%" == "%__?PARAM0:**=%" goto PARAM0_ERROR
if defined __?PARAM0 if not "%__?PARAM0%" == "%__?PARAM0:?=%" goto PARAM0_ERROR
if defined __?PARAM0 if not "%__?PARAM0%" == "%__?PARAM0:<=%" goto PARAM0_ERROR
if defined __?PARAM0 if not "%__?PARAM0%" == "%__?PARAM0:>=%" goto PARAM0_ERROR
if defined __?PARAM1 if not "%__?PARAM1%" == "%__?PARAM1:**=%" goto PARAM1_ERROR
if defined __?PARAM1 if not "%__?PARAM1%" == "%__?PARAM1:?=%" goto PARAM1_ERROR
if defined __?PARAM1 if not "%__?PARAM1%" == "%__?PARAM1:<=%" goto PARAM1_ERROR
if defined __?PARAM1 if not "%__?PARAM1%" == "%__?PARAM1:>=%" goto PARAM1_ERROR

goto PARAMS_OK

:PARAM0_ERROR
(
  echo;%__?~%: error: param0 is invalid: "%__?PARAM0%".
  exit /b 3
) >&2

:PARAM1_ERROR
(
  echo;%__?~%: error: param1 is invalid: "%__?PARAM1%".
  exit /b 4
) >&2

:PARAMS_OK

for /F "tokens=* delims="eol^= %%i in ("%__?CONFIG_IN_DIR%\.") do set "__?CONFIG_IN_DIR=%%~fi"
for /F "tokens=* delims="eol^= %%i in ("%__?CONFIG_OUT_DIR%\.") do set "__?CONFIG_OUT_DIR=%%~fi"

if not exist "%__?CONFIG_IN_DIR%\*" (
  echo;%__?~%: error: input config directory does not exist: "%__?CONFIG_IN_DIR%".
  exit /b 10
) >&2

if %__?FLAG_GEN_CONFIG% EQU 0 if %__?FLAG_LOAD_OUTPUT_CONFIG% EQU 0 goto SKIP_CONFIG_OUT_DIR_CHECK

if not exist "%__?CONFIG_OUT_DIR%\*" (
  echo;%__?~%: error: output config directory does not exist: "%__?CONFIG_OUT_DIR%".
  exit /b 11
) >&2

:SKIP_CONFIG_OUT_DIR_CHECK

set __?CONFIG_FILE_NAME_GENERATED=0

set "__?CONFIG_FILE_NAME_DIR=%__?CONFIG_OUT_DIR%"
if %__?FLAG_GEN_CONFIG% EQU 0 (
  if %__?FLAG_LOAD_OUTPUT_CONFIG% EQU 0 set "__?CONFIG_FILE_NAME_DIR=%__?CONFIG_IN_DIR%"
) else (
  if not exist "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE_NAME%" if exist "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE_NAME%.in" (
    echo;"%__?CONFIG_IN_DIR%\%__?CONFIG_FILE_NAME%.in" -^> "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE_NAME%"
    type "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE_NAME%.in" > "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE_NAME%"
    set __?CONFIG_FILE_NAME_GENERATED=1
  )
)

rem load configuration files
if not exist "%__?CONFIG_FILE_NAME_DIR%\%__?CONFIG_FILE_NAME%" (
  echo;%__?~%: error: config file is not found: "%__?CONFIG_FILE_NAME_DIR%\%__?CONFIG_FILE_NAME%".
  exit /b 20
) >&2

if %__?FLAG_GEN_CONFIG% EQU 0 if %__?FLAG_LOAD_OUTPUT_CONFIG% EQU 0 goto SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK
if %__?CONFIG_FILE_NAME_GENERATED% NEQ 0 goto SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK
if not exist "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE_NAME%.in" goto SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK

call "%%__?~dp0%%check_config_expiration.bat" -- "%%__?CONFIG_IN_DIR%%\%%__?CONFIG_FILE_NAME%%.in" "%%__?CONFIG_FILE_NAME_DIR%%\%%__?CONFIG_FILE_NAME%%" || exit /b

:SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK

set "__?VAR_PREFIX=__?:%RANDOM%-%RANDOM%:"

for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%__?CONFIG_FILE_NAME_DIR%/%__?CONFIG_FILE_NAME%") do set "__?VALUE=%%j" & call :PARSE "%%__?FLAG_NO_EXPAND%%" "%%__?PARAM0%%" "%%__?PARAM1%%" %%i

for /F "usebackq tokens=1,* delims=="eol^= %%i in (`@set "%%__?VAR_PREFIX%%" 2^>nul`) do ^
for /F "tokens=3 delims=:"eol^= %%k in ("%%i") do endlocal & set "__?VALUE=%%j" & setlocal ENABLEDELAYEDEXPANSION & ^
set "__?VALUE=!__?VALUE:~1!" & if defined __?VALUE (
  set "__?VALUE=!__?VALUE:="!"
  for /F "tokens=* delims="eol^= %%l in ("!__?VALUE!") do endlocal & set "%%k=%%l"
) else set "%%k="

set "__?VALUE="

exit /b 0

rem CAUTION:
rem   The `for %%i in (%*)` statement still can expand the globbing characters
rem   for the files in a current directory. You must avoid them.

:PARSE "%__?FLAG_NO_EXPAND%" "%__?PARAM0%" "%__?PARAM1%" [ATTRS] VAR[:PARAM0[:PARAM1]]
setlocal ENABLEDELAYEDEXPANSION & ^
set "__?ATTR=|" & set "__?VAR_EXPR=" & set "__?COUNT=-1" & for %%i in (%*) do ^
set /A "__?COUNT+=1" & if !__?COUNT! GTR 2 set "__?ATTR=!__?ATTR!!__?VAR_EXPR!|" & set "__?VAR_EXPR=%%i"
if not defined __?VAR_EXPR exit /b 1

set "__?ATTR=!__?ATTR:"=!"
set "__?VAR_EXPR=!__?VAR_EXPR:"=!"
set "__?VAR_EXPR=!__?VAR_EXPR:::=:.:!"
if "!__?VAR_EXPR:~0,1!" == ":" set "__?VAR_EXPR=.!__?VAR_EXPR!"

for /F "tokens=1,2,* delims=:"eol^= %%i in ("!__?VAR_EXPR!") do for /F "tokens=* delims="eol^= %%l in ("!__?ATTR!") do endlocal & ^
call :PARSE_EXPR "%%~i" "%%~j" "%%~k" "%%~1" "%%~2" "%%~3" "%%l"
exit /b 0

:PARSE_EXPR VAR PARAM0 PARAM1 "%__?FLAG_NO_EXPAND%" "%__?PARAM0%" "%__?PARAM1%" "[ATTRS]"
if "%~1" == "." exit /b 1
setlocal ENABLEDELAYEDEXPANSION & if not defined __?VALUE goto PARSE_VAR

if not "!__?VALUE:~1,-1!" == "" (
  if "!__?VALUE:~0,1!!__?VALUE:~-1!" == """" set "__?VALUE=!__?VALUE:~1,-1!"
) else if "!__?VALUE!" == """" set "__?VALUE="
if not defined __?VALUE goto PARSE_VAR
if %~4 NEQ 0 goto PARSE_VAR

rem encode `"` character to avoid `^` character partial duplication
set "__?VALUE=!__?VALUE:"=!"
call set "__?VALUE=!__?VALUE!" & if defined __?VALUE set "__?VALUE=!__?VALUE:^^=^!"

:PARSE_VAR
set "__?P0=" & set "__?P1=" & ( if not "%~2" == "" if not "%~2" == "." set "__?P0=%~2" ) & ( if not "%~3" == "" if not "%~3" == "." set "__?P1=%~3" )

if "%__?P0%" == "BAT" ( goto PARSE_P1 ) else if "%__?P0%" == "OSWIN" ( goto PARSE_P1 ) else if "%__?P0%" == "SH" ( exit /b 1 ) else if "%__?P0%" == "OSUNIX" exit /b 1

if defined __?P0 if not "%~5" == "" ( if not "%__?P0%" == "%~5" exit /b 1 ) else exit /b 1
:PARSE_P1
if defined __?P1 if not "%~6" == "" ( if not "%__?P1%" == "%~6" exit /b 1 ) else exit /b 1

:PARSE_VALUE
set "__?ATTR=%~7"
if not "!__?ATTR:|once|=!" == "!__?ATTR!" if defined %~1 exit /b 0
if not defined __?VALUE endlocal & set "%~1=" & exit /b 0

rem safe set
if not "!__?ATTR:|upath|=!" == "!__?ATTR!" ( for /F "tokens=* delims="eol^= %%i in ("!__?VALUE:\=/!") do endlocal & set "%__?VAR_PREFIX%%~1=.%%i" & set "%~1=%%i"
) else for /F "tokens=* delims="eol^= %%i in ("!__?VALUE!") do endlocal & set "%__?VAR_PREFIX%%~1=.%%i" & set "%~1=%%i"
exit /b 0
