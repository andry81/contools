@echo off

setlocal

set "?~nx0=%~nx0"

call "%%~dp0__init__.bat" || exit /b

rem script flags
set "FLAG_CHCP="

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem restore locale
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b %LAST_ERROR%

:MAIN
rem script flags

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "INPUT_CHARSET=%~1"
set "OUTPUT_CHARSET=%~2"
set "INPUT_FILE=%~3"

if not defined INPUT_CHARSET (
  echo.%?~nx0%: error: INPUT_CHARSET is not set.
  exit /b 1
) >&2

if not exist "%INPUT_FILE%" (
  echo.%?~nx0%: error: INPUT_FILE does not exist: INPUT_FILE="%INPUT_FILE%".
  exit /b 2
) >&2

if defined FLAG_CHCP (
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" "%%FLAG_CHCP%%"
  if not defined OUTPUT_CHARSET set "OUTPUT_CHARSET=CP%FLAG_CHCP%"
) else if not defined OUTPUT_CHARSET call :GET_CURRENT_CODE_PAGE

rem workaround for `conversion from CP65001 unsupported`
if "%OUTPUT_CHARSET%" == "CP65001" (
  "%CONTOOLS_GNUWIN32_ROOT%/bin/iconv.exe" -c -f "%INPUT_CHARSET%" -t UTF-8 "%INPUT_FILE%"
) else (
  "%CONTOOLS_GNUWIN32_ROOT%/bin/iconv.exe" -c -f "%INPUT_CHARSET%" -t "%OUTPUT_CHARSET%" "%INPUT_FILE%"
)
exit /b

:GET_CURRENT_CODE_PAGE
for /F "usebackq tokens=2 delims=:"eol^= %%i in (`chcp 2^>nul`) do set CURRENT_CODE_PAGE=%%i
rem convert chcp codepage into iconv namespace
set OUTPUT_CHARSET=CP%CURRENT_CODE_PAGE: =%
exit /b 0
