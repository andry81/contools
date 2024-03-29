@echo off

rem USAGE:
rem   load_config.bat [<Flags>] [--] <InputDir> <OutputDir> <ConfigFileName> [<Param0> [<Param1>]]

rem Description:
rem   Script to load a configuration file which can consist of an input and
rem   output parts.
rem
rem   The input configuration file is determinded by the `.in` suffix in the
rem   file name and basically stores in a version control system.
rem   The output configuration file must not contain the `.in` suffix in the
rem   file name and is used as a local storage for a user values.
rem
rem   The script detects the input file change before the output file change
rem   and interrupts the load with an error.
rem
rem   Additionally the `#%% version: ...` line is used to force the user to
rem   manually update the output confuguration file from the input
rem   configuration file in case if are not equal.
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

setlocal DISABLEDELAYEDEXPANSION

set "__?~dp0=%~dp0"
set "__?~n0=%~n0"
set "__?~nx0=%~nx0"

if defined NO_GEN set /A NO_GEN+=0

call "%%__?~dp0%%.load_config/load_config.read_flags.bat" %%* || exit /b

if %NO_GEN%0 NEQ 0 if %__?FLAG_GEN_CONFIG% NEQ 0 (
  echo.%__?~nx0%: error: can not generate config while NO_GEN is set.
  exit /b 255
) >&2

if %__?FLAG_SHIFT% GTR 0 for /L %%i in (1,1,%__?FLAG_SHIFT%) do shift

set "__?CONFIG_IN_DIR=%~1"
set "__?CONFIG_OUT_DIR=%~2"
set "__?CONFIG_FILE_NAME=%~3"
set "__?PARAM0=%~4"
set "__?PARAM1=%~5"

if not defined __?CONFIG_IN_DIR (
  echo.%__?~nx0%: error: input config directory is not defined.
  exit /b 1
) >&2

if not defined __?CONFIG_OUT_DIR (
  echo.%__?~nx0%: error: output config directory is not defined.
  exit /b 2
) >&2

for /F "eol= tokens=* delims=" %%i in ("%__?CONFIG_IN_DIR%\.") do set "__?CONFIG_IN_DIR=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%__?CONFIG_OUT_DIR%\.") do set "__?CONFIG_OUT_DIR=%%~fi"

if not exist "%__?CONFIG_IN_DIR%\*" (
  echo.%__?~nx0%: error: input config directory does not exist: "%__?CONFIG_IN_DIR%".
  exit /b 10
) >&2

if %__?FLAG_GEN_CONFIG% EQU 0 if %__?FLAG_LOAD_OUTPUT_CONFIG% EQU 0 goto SKIP_CONFIG_OUT_DIR_CHECK

if not exist "%__?CONFIG_OUT_DIR%\*" (
  echo.%__?~nx0%: error: output config directory does not exist: "%__?CONFIG_OUT_DIR%".
  exit /b 11
) >&2

:SKIP_CONFIG_OUT_DIR_CHECK

set __?CONFIG_FILE_NAME_GENERATED=0

set "__?CONFIG_FILE_NAME_DIR=%__?CONFIG_OUT_DIR%"
if %__?FLAG_GEN_CONFIG% EQU 0 (
  if %__?FLAG_LOAD_OUTPUT_CONFIG% EQU 0 set "__?CONFIG_FILE_NAME_DIR=%__?CONFIG_IN_DIR%"
) else (
  if not exist "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE_NAME%" if exist "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE_NAME%.in" (
    echo."%__?CONFIG_IN_DIR%\%__?CONFIG_FILE_NAME%.in" -^> "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE_NAME%"
    type "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE_NAME%.in" > "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE_NAME%"
    set __?CONFIG_FILE_NAME_GENERATED=1
  )
)

rem load configuration files
if not exist "%__?CONFIG_FILE_NAME_DIR%\%__?CONFIG_FILE_NAME%" (
  echo.%__?~nx0%: error: config file is not found: "%__?CONFIG_FILE_NAME_DIR%\%__?CONFIG_FILE_NAME%".
  exit /b 20
) >&2

if %__?FLAG_GEN_CONFIG% EQU 0 if %__?FLAG_LOAD_OUTPUT_CONFIG% EQU 0 goto SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK
if %__?CONFIG_FILE_NAME_GENERATED% NEQ 0 goto SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK
if not exist "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE_NAME%.in" goto SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK

call "%%__?~dp0%%check_config_expiration.bat" -- "%%__?CONFIG_IN_DIR%%\%%__?CONFIG_FILE_NAME%%.in" "%%__?CONFIG_FILE_NAME_DIR%%\%%__?CONFIG_FILE_NAME%%" || exit /b

:SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK

(
  endlocal
  rem recode quote and exclamation characters
  set "__?ESC__=^"
  set __?QUOT__=^"
  set "__?EXCL__=!"
  for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%__?CONFIG_FILE_NAME_DIR%/%__?CONFIG_FILE_NAME%") do set "__?VALUE=%%j" & call :PARSE "%__?FLAG_NO_EXPAND%" "%__?PARAM0%" "%__?PARAM1%" %%i
  set "__?VALUE=" & set "__?ATTR=" & set "__?UPATH=" & set "__?VAR_EXPR=" & set "__?P0=" & set "__?P1=" & set "__?COUNT=" & set "__?ESC__=" & set "__?QUOT__=" & set "__?EXCL__="
)
exit /b 0

:PARSE "%__?FLAG_NO_EXPAND%" "%__?PARAM0%" "%__?PARAM1%" [ATTRS] VAR[:PARAM0[:PARAM1]]
set "__?ATTR=|" & set "__?VAR_EXPR=" & set "__?COUNT=0" & for %%i in (%*) do (
  setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%j in ("!__?COUNT!") do for /F "eol= tokens=* delims=" %%k in ("!__?ATTR!") do (
    endlocal & if %%j GTR 2 (
      if defined __?VAR_EXPR setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%l in ("!__?VAR_EXPR!") do endlocal & set "__?ATTR=%%k%%l|"
      set "__?VAR_EXPR=%%i"
    )
  )
  set /A __?COUNT+=1
)

set "__?ATTR=%__?ATTR:"=%"
set "__?VAR_EXPR=%__?VAR_EXPR:"=%"
set "__?VAR_EXPR=%__?VAR_EXPR:::=:.:%"
if "%__?VAR_EXPR:~0,1%" == ":" set "__?VAR_EXPR=.%__?VAR_EXPR%"

for /F "eol= tokens=1,2,* delims=:" %%i in ("%__?VAR_EXPR%") do call :PARSE_EXPR "%%~i" "%%~j" "%%~k" "%%~1" "%%~2" "%%~3"
exit /b 0

:PARSE_EXPR VAR PARAM0 PARAM1 "%__?FLAG_NO_EXPAND%" "%__?PARAM0%" "%__?PARAM1%"
if "%~1" == "." exit /b 1
if not defined __?VALUE goto PARSE_VAR

setlocal ENABLEDELAYEDEXPANSION & if not "!__?VALUE:~1,-1!" == "" (
  for /F "eol= tokens=* delims=" %%i in ("!__?VALUE:~1,-1!") do endlocal & if ^"/ == ^%__?VALUE:~0,1%/ if ^"/ == ^%__?VALUE:~-1%/ set "__?VALUE=%%i"
) else if "!__?VALUE!" == """" ( endlocal & set "__?VALUE=" ) else endlocal
if not defined __?VALUE goto PARSE_VAR 

rem replace a value quote characters by the \x01 character
set "__?VALUE=%__?VALUE:"=%"

rem recode quote and exclamation characters
set "__?VALUE=%__?VALUE:!=!__?EXCL__!%"
set "__?VALUE=%__?VALUE:^=!__?ESC__!%"
set "__?VALUE=%__?VALUE:=!__?QUOT__!%"

if %~4 EQU 0 call set "__?VALUE=%__?VALUE%"

:PARSE_VAR
set "__?P0=" & set "__?P1=" & ( if not "%~2" == "" if not "%~2" == "." set "__?P0=%~2" ) & ( if not "%~3" == "" if not "%~3" == "." set "__?P1=%~3" )

if "%__?P0%" == "BAT" ( goto PARSE_P1 ) else if "%__?P0%" == "OSWIN" ( goto PARSE_P1 ) else if "%__?P0%" == "SH" ( exit /b 1 ) else if "%__?P0%" == "OSUNIX" exit /b 1

if defined __?P0 if not "%~5" == "" ( if not "%__?P0%" == "%~5" exit /b 1 ) else exit /b 1
:PARSE_P1
if defined __?P1 if not "%~6" == "" ( if not "%__?P1%" == "%~6" exit /b 1 ) else exit /b 1

:PARSE_VALUE
if not "%__?ATTR:|once|=%" == "%__?ATTR%" if defined %~1 exit /b 0
if not defined __?VALUE set "%~1=" & exit /b 0
set "__?UPATH=0" & if defined __?ATTR if not "%__?ATTR:|upath|=%" == "%__?ATTR%" set __?UPATH=1

rem safe set
setlocal ENABLEDELAYEDEXPANSION & if %__?UPATH% NEQ 0 ( for /F "eol= tokens=* delims=" %%i in ("!__?VALUE:\=/!") do for /F "eol= tokens=* delims=" %%j in ("%%i") do endlocal & endlocal & set "%~1=%%j" ) else ^
for /F "eol= tokens=* delims=" %%i in ("!__?VALUE!") do for /F "eol= tokens=* delims=" %%j in ("%%i") do endlocal & endlocal & set "%~1=%%j"
