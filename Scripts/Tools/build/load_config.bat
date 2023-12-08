@echo off

rem USAGE:
rem   load_config.bat [<Flags>] <InputDir> <OutputDir> <ConfigFileName> [<Param0> [<Param1>]]

rem Description:
rem   Script to load a configuration file which can consist of an input and
rem   output parts.
rem   The input configuration file is deteminded by the `.in` suffix in the
rem   file name and basically stores in a version control system.
rem   The output configuration file must not contain the `.in` suffix in the
rem   file name and is used as a local storage for a user values.
rem   The script detects the input file change before the output file change
rem   and interrupts the load with an error.
rem   Additionally the `#%% version: ...` line is used to force the user to
rem   manually update the output confuguration file from the input
rem   configuration file in case if are not equal.
rem   By default the script does load the input configuration from the
rem   `<ConfigFileName>` file. If `-load_output_config` flag is used, then the
rem   input configuration file name is used as `<ConfigFileName>.in`.
rem   The fast parse logic is used by default.

rem <Flags>:
rem   -gen_config
rem     Generates the output configuration file from the input configuration
rem     file if the output configuration file does not exist, otherwise skips
rem     the generation.
rem     Implies `-load_output_config` flag.
rem   -load_output_config
rem     Loads the output configuration file instead of the input configuration
rem     file as by default.
rem   -lite_parse
rem     Uses the lite parse logic (fastest).
rem   -full_parse
rem     Uses the full parse logic (slowest).
rem   -noexpand
rem     Disables expansion of %-variables.
rem     Has effect only if `-lite_parse` is used.
rem   -allow_not_known_class_as_var_name
rem     Allows to set a variable together with the class name in case if not
rem     known class name.
rem     Has effect only for Fast/Full parse.

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
rem   Custom parameters to load a parameterized variable.
rem   Has no effect for Fast/Full parse logics.

rem CONFIGURATION FILE FORMAT:
rem   [<attributes>] <variable>[:[[<class_name>][:[<param0>][:[<param1>]]]]]=<value>
rem
rem <attributes>:           Variable space separated attributes: once | export | upath
rem <variable>:             Variable name corresponding to the regex: [_a-zA-Z][_a-zA-Z0-9]*
rem <class_name>:           class variant name: OSWIN | OSUNIX | BAT | SH
rem   OSWIN:                Apply on Windows system including cygwin/mingw/msys subsystems.
rem   OSUNIX:               Apply on Unix/Linux systems excluding cygwin/mingw/msys subsystems.
rem   BAT:                  Apply on Windows system when this file has loaded from the Windows batch script loader.
rem   SH:                   Apply on any system when this file has loaded from the Bash shell script loader.
rem
rem <param0>, <param1>:     Ex: MyVar:OSWIN:XP:32=...
rem
rem <value>:                Value with substitution support:
rem                         * Lite parse:       `%<variable>%`.
rem                         * Fast/Full parse:  `$/{<variable>}`.
rem                         Can start by the `"` quote character, but two quotes does remove only when exist on both ends of a value.
rem
rem <attributes>:
rem   once
rem     Sets the variable only if it is not defined.
rem   export
rem     (Unix shell only)
rem     Exports the variable additionally to the set.
rem   upath
rem     Treats a variable value as a path and converts it to a uniform absolute
rem     path (use forward slashes only).

rem Parse logic:
rem  Lite parse:
rem   Use builtin variable's value replacer and %-variables expansion.
rem   The only `%<variable>%` placeholders can be expanded in a variable value.
rem
rem Fast parse:
rem   Use builtin variable's value replacer and !-variables expansion.
rem   The only `$/{<variable>}` placeholders can be expanded in a variable
rem   value.
rem
rem Full parse:
rem   Use char by char parse logic as most precise but even more slower.
rem   The only `$/{<variable>}` placeholders can be expanded in a variable
rem   value.

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
set "__?CONFIG_FILE=%~3"
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

set __?CONFIG_FILE_GENERATED=0

set "__?CONFIG_FILE_DIR=%__?CONFIG_OUT_DIR%"
if %__?FLAG_GEN_CONFIG% EQU 0 (
  if %__?FLAG_LOAD_OUTPUT_CONFIG% EQU 0 set "__?CONFIG_FILE_DIR=%__?CONFIG_IN_DIR%"
) else (
  if not exist "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE%" if exist "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE%.in" (
    echo."%__?CONFIG_IN_DIR%\%__?CONFIG_FILE%.in" -^> "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE%"
    type "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE%.in" > "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE%"
    set __?CONFIG_FILE_GENERATED=1
  )
)

rem load configuration files
if not exist "%__?CONFIG_FILE_DIR%\%__?CONFIG_FILE%" (
  echo.%__?~nx0%: error: config file is not found: "%__?CONFIG_FILE_DIR%\%__?CONFIG_FILE%".
  exit /b 20
) >&2

if %__?FLAG_GEN_CONFIG% EQU 0 if %__?FLAG_LOAD_OUTPUT_CONFIG% EQU 0 goto SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK
if %__?CONFIG_FILE_GENERATED% NEQ 0 goto SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK
if not exist "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE%.in" goto SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK

rem Based on:
rem   https://stackoverflow.com/questions/1687014/how-do-i-compare-timestamps-of-files-in-a-batch-script/58323817#58323817
rem
"%SystemRoot%\System32\xcopy.exe" /L /D /R /Y "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE%.in" "%__?CONFIG_FILE_DIR%\%__?CONFIG_FILE%" 2>nul | findstr /B /C:"1 " >nul && (
  echo.%__?~nx0%: error: output config is expired, either merge it with or regenerate it from the input config file:
  echo.%__?~nx0%: info: input config file : "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE%.in"
  echo.%__?~nx0%: info: output config file: "%__?CONFIG_FILE_DIR%\%__?CONFIG_FILE%"
  exit /b 100
) >&2

rem compare versions

set "__?VERSION_LINE_TEMP_FILE=%TEMP%\%__?~n0%.version.%RANDOM%-%RANDOM%.txt"

findstr /B /C:"#%%%% version:" "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE%.in" > "%__?VERSION_LINE_TEMP_FILE%"

set /P __?CONFIG_IN_FILE_VERSION_LINE=<"%__?VERSION_LINE_TEMP_FILE%"

if not defined __?CONFIG_IN_FILE_VERSION_LINE (
  del /F /Q /A:-D "%__?VERSION_LINE_TEMP_FILE%" >nul 2>&1
  goto SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK
)

set "__?CONFIG_IN_FILE_VERSION_LINE=%__?CONFIG_IN_FILE_VERSION_LINE:"=%"

set "__?CONFIG_OUT_FILE_VERSION_LINE="
set __?CONFIG_OUT_FILE_VERSION_EQUAL=0
findstr /X /B /C:"%__?CONFIG_IN_FILE_VERSION_LINE%" "%__?CONFIG_FILE_DIR%\%__?CONFIG_FILE%" >nul && set __?CONFIG_OUT_FILE_VERSION_EQUAL=1

if %__?CONFIG_OUT_FILE_VERSION_EQUAL% EQU 0 (
  findstr /B /C:"#%%%% version:" "%__?CONFIG_FILE_DIR%\%__?CONFIG_FILE%" > "%__?VERSION_LINE_TEMP_FILE%"

  set /P __?CONFIG_OUT_FILE_VERSION_LINE=<"%__?VERSION_LINE_TEMP_FILE%"
)

del /F /Q /A:-D "%__?VERSION_LINE_TEMP_FILE%" >nul 2>&1

if %__?CONFIG_OUT_FILE_VERSION_EQUAL% EQU 0 (
  echo.%__?~nx0%: error: input config version line is not found in the output config file, either merge it with or regenerate it from the input config file:
  echo.%__?~nx0%: info: input config file : "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE%.in"
  echo.%__?~nx0%: info: output config file: "%__?CONFIG_FILE_DIR%\%__?CONFIG_FILE%"
  echo.%__?~nx0%: info: input config version line : "%__?CONFIG_IN_FILE_VERSION_LINE%"
  echo.%__?~nx0%: info: output config version line: "%__?CONFIG_OUT_FILE_VERSION_LINE%"
  exit /b 101
) >&2

:SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK

if %__?FLAG_LITE_PARSE% NEQ 0 (
  "%__?~dp0%/.load_config/load_config.lite_parse.bat" "%__?FLAG_NO_EXPAND%" "%__?PARAM0%" "%__?PARAM1%"
) else if %__?FLAG_FULL_PARSE% EQU 0 (
  "%__?~dp0%/.load_config/load_config.fast_parse.bat" %__?FLAG_ALLOW_NOT_KNOWN_CLASS_AS_VAR_NAME%
) else "%__?~dp0%.load_config/load_config.full_parse.bat" %__?FLAG_ALLOW_NOT_KNOWN_CLASS_AS_VAR_NAME%
