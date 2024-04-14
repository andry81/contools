@echo off

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

set "__?VAR_PREFIX=__?:%RANDOM%-%RANDOM%:"

for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%__?CONFIG_FILE_NAME_DIR%/%__?CONFIG_FILE_NAME%") do set "__?VALUE=%%j" & call :PARSE "%%__?FLAG_NO_EXPAND%%" "%%__?PARAM0%%" "%%__?PARAM1%%" %%i

for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set "%%__?VAR_PREFIX%%" 2^>nul`) do ^
for /F "eol= tokens=3 delims=:" %%k in ("%%i") do endlocal & set "__?VALUE=%%j" & setlocal ENABLEDELAYEDEXPANSION & ^
set "__?VALUE=!__?VALUE:~1!" & if defined __?VALUE (
  set "__?VALUE=!__?VALUE:="!"
  for /F "eol= tokens=* delims=" %%l in ("!__?VALUE!") do endlocal & set "%%k=%%l"
) else set "%%k="

set "__?VALUE="

exit /b 0

:PARSE "%__?FLAG_NO_EXPAND%" "%__?PARAM0%" "%__?PARAM1%" [ATTRS] VAR[:PARAM0[:PARAM1]]
setlocal ENABLEDELAYEDEXPANSION & ^
set "__?ATTR=|" & set "__?VAR_EXPR=" & set "__?COUNT=-1" & for %%i in (%*) do ^
set /A "__?COUNT+=1" & if !__?COUNT! GTR 2 set "__?ATTR=!__?ATTR!!__?VAR_EXPR!|" & set "__?VAR_EXPR=%%i"
if not defined __?VAR_EXPR exit /b 1

set "__?ATTR=!__?ATTR:"=!"
set "__?VAR_EXPR=!__?VAR_EXPR:"=!"
set "__?VAR_EXPR=!__?VAR_EXPR:::=:.:!"
if "!__?VAR_EXPR:~0,1!" == ":" set "__?VAR_EXPR=.!__?VAR_EXPR!"

for /F "eol= tokens=1,2,* delims=:" %%i in ("!__?VAR_EXPR!") do for /F "eol= tokens=* delims=" %%l in ("!__?ATTR!") do endlocal & ^
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
if not "!__?ATTR:|upath|=!" == "!__?ATTR!" ( for /F "eol= tokens=* delims=" %%i in ("!__?VALUE:\=/!") do endlocal & set "%__?VAR_PREFIX%%~1=.%%i" & set "%~1=%%i"
) else for /F "eol= tokens=* delims=" %%i in ("!__?VALUE!") do endlocal & set "%__?VAR_PREFIX%%~1=.%%i" & set "%~1=%%i"
exit /b 0

rem Another implementation, ~30% slower

rem for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%__?CONFIG_FILE_NAME_DIR%/%__?CONFIG_FILE_NAME%") do (
rem   set "__?VAR_EXPR=%%i" & set "__?VAR=" & set "__?VALUE=%%j" & set "__?PARAM0=%__?PARAM0%" & set "__?PARAM1=%__?PARAM1%" & set "__?~dp0=%__?~dp0%"
rem
rem   if defined __?VAR_EXPR (
rem     rem __?VAR_EXPR=[once] [export] [upath] VAR[:PARAM0[:PARAM1]]
rem     setlocal ENABLEDELAYEDEXPANSION & set "__?VAR_EXPR=!__?VAR_EXPR:::=:.:!" & for /F "eol= tokens=1,2,* delims=:" %%i in ("!__?VAR_EXPR!") do endlocal & (
rem       set "__?VAR_EXPR=%%i" & set "__?VAR_PARAM0=%%j" & set "__?VAR_PARAM1=%%k" & if "%%j" == "." set "__?VAR_PARAM0="
rem     )
rem
rem     if defined __?VAR_EXPR (
rem       setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=1,2,3,* delims= " %%i in ("!__?VAR_EXPR!") do endlocal & (
rem         if "%%j" == "" ( set "__?VAR=%%i" & set "__?ATTR=." ) else if "%%k" == "" ( set "__?VAR=%%j" & set "__?ATTR=|%%i|"
rem         ) else if "%%l" == "" ( set "__?VAR=%%k" & set "__?ATTR=|%%i|%%j|" ) else set "__?VAR=%%l" & set "__?ATTR=|%%i|%%j|%%k|"
rem       )
rem
rem       setlocal ENABLEDELAYEDEXPANSION & if defined __?VALUE if not "!__?VALUE:~1,-1!" == "" (
rem         if "!__?VALUE:~0,1!!__?VALUE:~-1!" == """" set "__?VALUE=!__?VALUE:~1,-1!"
rem       ) else if "!__?VALUE!" == """" set "__?VALUE="
rem
rem       if defined __?VALUE (
rem         if defined __?VAR_PARAM0 call "%%__?~dp0%%.load_config/load_config.trim_left.bat" __?VAR_PARAM0 ) & (
rem           if defined __?VAR_PARAM0 call "%%__?~dp0%%.load_config/load_config.trim_right.bat" __?VAR_PARAM0 ) & (
rem           if defined __?VAR_PARAM1 call "%%__?~dp0%%.load_config/load_config.trim_left.bat" __?VAR_PARAM1 ) & (
rem           if defined __?VAR_PARAM1 call "%%__?~dp0%%.load_config/load_config.trim_right.bat" __?VAR_PARAM1 )
rem       )
rem
rem       set "__?P0=" & set "__?P1=" & ( if defined __?VAR_PARAM0 set "__?P0=!__?VAR_PARAM0!" ) & ( if defined __?VAR_PARAM1 set "__?P1=!__?VAR_PARAM1!" )
rem       if "!__?P0!" == "SH" ( set "__?CONTINUE=1" ) else if "!__?P0!" == "OSUNIX" ( set "__?CONTINUE=1" ) else set "__?CONTINUE=0"
rem       if !__?CONTINUE! EQU 0 (
rem         if not "!__?P0!" == "BAT" if not "!__?P0!" == "OSWIN" (
rem           if defined __?P0 if defined __?PARAM0 ( if not "!__?P0!" == "!__?PARAM0!" set "__?CONTINUE=1" ) else set "__?CONTINUE=1"
rem         )
rem         if !__?CONTINUE! EQU 0 (
rem           if defined __?P1 if defined __?PARAM1 ( if not "!__?P1!" == "!__?PARAM1!" set "__?CONTINUE=1" ) else set "__?CONTINUE=1"
rem         )
rem         if !__?CONTINUE! EQU 0 (
rem           call "%%__?~dp0%%.load_config/load_config.trim_left.bat" __?VAR & if defined __?VAR call "%%__?~dp0%%.load_config/load_config.trim_right.bat" __?VAR
rem
rem           if not "!__?ATTR:|once|=!" == "!__?ATTR!" if defined !__?VAR! set "__?CONTINUE=1"
rem
rem           if !__?CONTINUE! EQU 0 if defined __?VALUE if !__?FLAG_NO_EXPAND! EQU 0 (
rem             rem recode characters
rem             set "__?VALUE=!__?VALUE:$=$24!" & set "__?VALUE=!__?VALUE:"=$22!"
rem             setlocal DISABLEDELAYEDEXPANSION & call set "__?VALUE=%%__?VALUE:!=$21%%"
rem             for /F "eol= tokens=* delims=" %%j in ("!__?VALUE:^=$5E!") do endlocal & set "__?VALUE=%%j"
rem             call set "__?VALUE=!__?VALUE!"
rem             if defined __?VALUE (
rem               setlocal DISABLEDELAYEDEXPANSION & call set "__?VALUE=%%__?VALUE:!=$21%%"
rem               for /F "eol= tokens=* delims=" %%j in ("!__?VALUE:$5E=^!") do endlocal & set "__?VALUE=%%j"
rem               set "__?VALUE=!__?VALUE:$22="!"
rem               set "__?VALUE=!__?VALUE:$24=$!"
rem             )
rem           )
rem         )
rem       )
rem
rem       if !__?CONTINUE! EQU 0 (
rem         if defined __?VAR (
rem           for /F "eol= tokens=* delims=" %%j in ("!__?VAR!") do if defined __?VALUE (
rem             if not "!__?ATTR:|upath|=!" == "!__?ATTR!" (
rem               for /F "eol= tokens=* delims=" %%k in ("!__?VALUE:\=/!") do endlocal & endlocal & set "%%j=%%k"
rem             ) else for /F "eol= tokens=* delims=" %%k in ("!__?VALUE!") do endlocal & endlocal & set "%%j=%%k"
rem           ) else endlocal & endlocal & set "%%j="
rem         ) else endlocal & endlocal
rem       ) else endlocal & endlocal
rem
rem       setlocal DISABLEDELAYEDEXPANSION
rem     )
rem   )
rem )
rem
rem exit /b 0
rem