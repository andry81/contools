@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

set "?~nx0=%~nx0"

rem script flags
rem set FLAG_USE_BOM=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  rem if "%FLAG%" == "-bom" (
  rem   set FLAG_USE_BOM=1
  rem   shift
  rem ) else
  (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

set "INPUT_CHARSET=%~1"
set "OUTPUT_CHARSET=%~2"
set "INPUT_FILE=%~3"

if not defined INPUT_CHARSET (
  echo.%?~nx0%: error: INPUT_CHARSET is not set.
  exit /b 1
)

if not exist "%INPUT_FILE%" (
  echo.%?~nx0%: error: INPUT_FILE does not exist: INPUT_FILE="%INPUT_FILE%".
  exit /b 2
) >&2

if not defined OUTPUT_CHARSET call :GET_CURRENT_CODE_PAGE

"%GNUWIN32_ROOT%/bin/iconv.exe" -c -f "%INPUT_CHARSET%" -t "%OUTPUT_CHARSET%" "%INPUT_FILE%"
exit /b

:GET_CURRENT_CODE_PAGE
for /F "usebackq eol=	 tokens=2 delims=:" %%i in (`chcp 2^>nul`) do set CURRENT_CODE_PAGE=%%i
rem convert chcp codepage into iconv namespace
set OUTPUT_CHARSET=CP%CURRENT_CODE_PAGE: =%

exit /b 0
