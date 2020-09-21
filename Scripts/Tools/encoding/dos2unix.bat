@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

set "?~nx0=%~nx0"

set "INPUT_FILE=%~1"

if not exist "%INPUT_FILE%" (
  echo.%?~nx0%: error: INPUT_FILE does not exist: INPUT_FILE="%INPUT_FILE%".
  exit /b 1
) >&2

type "%INPUT_FILE%" | "%CONTOOLS_GNUWIN32_ROOT%/bin/tr.exe" -d "\15\32"
