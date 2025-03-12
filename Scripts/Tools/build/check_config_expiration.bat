@echo off

rem USAGE:
rem   check_config_expiration.bat [<flags>] [--] <InputFile> <OutputFile>

rem Description:
rem   Script to check <OutputFile> expiration versus <InputFile> to prevent
rem   <OutputFile> accidental overwrite.

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

setlocal

set "?~n0=%~n0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "?~nx0=%~nx0"

rem script flags
set FLAG_OPTIONAL_COMPARE=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-optional_compare" (
    set FLAG_OPTIONAL_COMPARE=1
  ) else if not "%FLAG%" == "--" (
    echo.%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

set "VARS_FILE_IN=%~1"
set "VARS_FILE=%~2"

if not defined VARS_FILE_IN (
  echo.%?~%: error: input config file is not defined.
  exit /b 255
) >&2

if not defined VARS_FILE (
  echo.%?~%: error: output config file is not defined.
  exit /b 255
) >&2

for /F "tokens=* delims="eol^= %%i in ("%VARS_FILE_IN%\.") do set "VARS_FILE_IN=%%~fi"
for /F "tokens=* delims="eol^= %%i in ("%VARS_FILE%\.") do set "VARS_FILE=%%~fi"

if not exist "%VARS_FILE_IN%" (
  echo.%?~%: error: input config file does not exist: "%VARS_FILE_IN%".
  exit /b 255
) >&2

if not exist "%VARS_FILE%" (
  if %FLAG_OPTIONAL_COMPARE% EQU 0 (
    echo.%?~%: error: output config file does not exist: "%VARS_FILE%".
    exit /b 255
  ) >&2 else exit /b 0
)

rem Based on:
rem   https://stackoverflow.com/questions/1687014/how-do-i-compare-timestamps-of-files-in-a-batch-script/58323817#58323817
rem
"%SystemRoot%\System32\xcopy.exe" /L /D /R /Y "%VARS_FILE_IN%" "%VARS_FILE%" 2>nul | "%SystemRoot%\System32\findstr.exe" /B /C:"1 " >nul && (
  echo.%?~%: error: output config is expired, either merge it with or regenerate it from the input config file:
  echo.%?~nx0%: info: input config file : "%VARS_FILE_IN%"
  echo.%?~nx0%: info: output config file: "%VARS_FILE%"
  exit /b 100
) >&2

rem compare versions

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "VERSION_LINE_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\%?~n0%.version.%RANDOM%-%RANDOM%.txt"
) else set "VERSION_LINE_TEMP_FILE=%TEMP%\%?~n0%.version.%RANDOM%-%RANDOM%.txt"

"%SystemRoot%\System32\findstr.exe" /B /C:"#%%%% version:" "%VARS_FILE_IN%" > "%VERSION_LINE_TEMP_FILE%"

set /P CONFIG_IN_FILE_VERSION_LINE=<"%VERSION_LINE_TEMP_FILE%"

if not defined CONFIG_IN_FILE_VERSION_LINE (
  del /F /Q /A:-D "%VERSION_LINE_TEMP_FILE%" >nul 2>nul
  goto SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK
)

set "CONFIG_IN_FILE_VERSION_LINE=%CONFIG_IN_FILE_VERSION_LINE:"=%"

set "CONFIG_OUT_FILE_VERSION_LINE="
set CONFIG_OUT_FILE_VERSION_EQUAL=0
"%SystemRoot%\System32\findstr.exe" /X /B /E /C:"%CONFIG_IN_FILE_VERSION_LINE%" "%VARS_FILE%" >nul && set CONFIG_OUT_FILE_VERSION_EQUAL=1

if %CONFIG_OUT_FILE_VERSION_EQUAL% EQU 0 (
  "%SystemRoot%\System32\findstr.exe" /B /C:"#%%%% version:" "%VARS_FILE%" > "%VERSION_LINE_TEMP_FILE%"

  set /P CONFIG_OUT_FILE_VERSION_LINE=<"%VERSION_LINE_TEMP_FILE%"
)

del /F /Q /A:-D "%VERSION_LINE_TEMP_FILE%" >nul 2>nul

if %CONFIG_OUT_FILE_VERSION_EQUAL% EQU 0 (
  echo.%?~%: error: input config version line is not found in the output config file, either merge it with or regenerate it from the input config file:
  echo.%?~nx0%: info: input config file : "%VARS_FILE_IN%"
  echo.%?~nx0%: info: output config file: "%VARS_FILE%"
  echo.%?~nx0%: info: input config version line : "%CONFIG_IN_FILE_VERSION_LINE%"
  echo.%?~nx0%: info: output config version line: "%CONFIG_OUT_FILE_VERSION_LINE%"
  exit /b 101
) >&2

:SKIP_OUTPUT_CONFIG_EXPIRATION_CHECK

exit /b 0
