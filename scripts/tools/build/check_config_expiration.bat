@echo off & goto DOC_END

rem USAGE:
rem   check_config_expiration.bat [<flags>] [--] <InputFile> <OutputFile>

rem Description:
rem   Script to check <OutputFile> expiration versus <InputFile> to prevent
rem   <OutputFile> accidental overwrite.
rem
rem   The script detects the input file change after the output file change and
rem   returns an error.
rem
rem   Additionally the `#%% version: ...` first line does read from both files
rem   to force the user to manually update the output configuration file from
rem   the input configuration file in case if these lines are not equal.
rem
rem   If the first line of the `<InputFile>` does not begin by the
rem   `#%% version:`, then the first line of the `<OutputFile>` does ignore.

rem <flags>:
rem   -optional_compare
rem     Does not require <OutputFile> existence.

rem --:
rem   Separator to stop parse flags.
rem

rem <InputFile>:
rem   Input configuration file path.

rem <OutputFile>:
rem   Output configuration file path.
rem   Must exist if `-optional_compare` is not defined.
:DOC_END

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "?~nx0=%~nx0"

call "%%?~dp0%%.check_config_expiration/check_config_expiration.read_flags.bat" %%* || exit /b

if %FLAG_SHIFT% GTR 0 for /L %%i in (1,1,%FLAG_SHIFT%) do shift

set "VARS_FILE_IN=%~1"
set "VARS_FILE=%~2"

if not defined VARS_FILE_IN (
  echo;%?~%: error: input config file is not defined.
  exit /b 255
) >&2

if not defined VARS_FILE (
  echo;%?~%: error: output config file is not defined.
  exit /b 255
) >&2

for /F "tokens=* delims="eol^= %%i in ("%VARS_FILE_IN%\.") do set "VARS_FILE_IN=%%~fi"

if not exist "%VARS_FILE_IN%" (
  echo;%?~%: error: input config file does not exist: "%VARS_FILE_IN%".
  exit /b 255
) >&2

for /F "tokens=* delims="eol^= %%i in ("%VARS_FILE%\.") do set "VARS_FILE=%%~fi"

if /i "%VARS_FILE_IN%" == "%VARS_FILE%" (
  echo;%?~%: error: input and output config file paths must be different.
  echo;%?~nx0%: info: input config file : "%VARS_FILE_IN%"
  echo;%?~nx0%: info: output config file: "%VARS_FILE%"
  exit /b 99
) >&2

if not exist "%VARS_FILE%" (
  if %FLAG_OPTIONAL_COMPARE% EQU 0 (
    echo;%?~%: error: output config file does not exist: "%VARS_FILE%".
    exit /b 255
  ) >&2 else exit /b 0
)

set /P CONFIG_IN_FILE_VERSION_LINE=<"%VARS_FILE_IN%"
set /P CONFIG_OUT_FILE_VERSION_LINE=<"%VARS_FILE%"

rem Based on:
rem   https://stackoverflow.com/questions/1687014/how-do-i-compare-timestamps-of-files-in-a-batch-script/58323817#58323817
rem
"%SystemRoot%\System32\xcopy.exe" /L /D /R /Y "%VARS_FILE_IN%" "%VARS_FILE%" 2>nul | "%SystemRoot%\System32\findstr.exe" /B /C:"1 " >nul || goto OUTPUT_CONFIG_EXPIRATION_CHECK_END

setlocal ENABLEDELAYEDEXPANSION & ^
for /F "usebackq tokens=* delims="eol^= %%i in ('"!CONFIG_IN_FILE_VERSION_LINE!"') do ^
for /F "usebackq tokens=* delims="eol^= %%j in ('"!CONFIG_OUT_FILE_VERSION_LINE!"') do endlocal & (
  echo;%?~%: error: output config is expired, either merge it with or regenerate it from the input config file:
  echo;%?~nx0%: info: input config file : "%VARS_FILE_IN%"
  echo;%?~nx0%: info: output config file: "%VARS_FILE%"
  echo;%?~nx0%: info: input config file first line : "%%~i"
  echo;%?~nx0%: info: output config file first line: "%%~j"
  exit /b 100
) >&2

:OUTPUT_CONFIG_EXPIRATION_CHECK_END

rem compare first lines
if defined CONFIG_IN_FILE_VERSION_LINE ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!CONFIG_IN_FILE_VERSION_LINE:~0,12!") do endlocal & ^
if not "%%i" == "#%%%% version:" exit /b 0

set "CONFIG_IN_FILE_VERSION_LINE_KEY=" & set "CONFIG_IN_FILE_VERSION_LINE_VALUE="
set "CONFIG_OUT_FILE_VERSION_LINE_KEY=" & set "CONFIG_OUT_FILE_VERSION_LINE_VALUE="

if defined CONFIG_IN_FILE_VERSION_LINE setlocal ENABLEDELAYEDEXPANSION & ^
for /F "tokens=* delims="eol^= %%i in ("!CONFIG_IN_FILE_VERSION_LINE:~0,12!") do ^
for /F "tokens=* delims="eol^= %%j in ("!CONFIG_IN_FILE_VERSION_LINE:~12!") do endlocal & ^
set "CONFIG_IN_FILE_VERSION_LINE_KEY=%%i" & set "CONFIG_IN_FILE_VERSION_LINE_VALUE=%%j"

if defined CONFIG_OUT_FILE_VERSION_LINE setlocal ENABLEDELAYEDEXPANSION & ^
for /F "tokens=* delims="eol^= %%i in ("!CONFIG_OUT_FILE_VERSION_LINE:~0,12!") do ^
for /F "tokens=* delims="eol^= %%j in ("!CONFIG_OUT_FILE_VERSION_LINE:~12!") do endlocal & ^
set "CONFIG_OUT_FILE_VERSION_LINE_KEY=%%i" & set "CONFIG_OUT_FILE_VERSION_LINE_VALUE=%%j"

rem if-OR-else
setlocal ENABLEDELAYEDEXPANSION & ^
for /F "usebackq tokens=* delims="eol^= %%i in ('"!CONFIG_IN_FILE_VERSION_LINE_KEY!"') do ^
for /F "usebackq tokens=* delims="eol^= %%j in ('"!CONFIG_OUT_FILE_VERSION_LINE_KEY!"') do ^
for /F "usebackq tokens=* delims="eol^= %%k in ('"!CONFIG_IN_FILE_VERSION_LINE_VALUE!"') do ^
for /F "usebackq tokens=* delims="eol^= %%l in ('"!CONFIG_OUT_FILE_VERSION_LINE_VALUE!"') do endlocal & (
  call;
  if not "%%~i" == "%%~j" (call) else if "%%~k" == "" (call) else if "%%~l" == "" (call) else if not "%%~k" == "%%~l" (call)
) || (
  echo;%?~%: error: input config file version line is empty/not found/not equal versus/in/to the output config file version line, either merge it with or regenerate it from the input config file:
  echo;%?~nx0%: info: input config file : "%VARS_FILE_IN%"
  echo;%?~nx0%: info: output config file: "%VARS_FILE%"
  echo;%?~nx0%: info: input config version line : "%%~i%%~k"
  echo;%?~nx0%: info: output config version line: "%%~j%%~l"
  exit /b 101
) >&2

exit /b 0
