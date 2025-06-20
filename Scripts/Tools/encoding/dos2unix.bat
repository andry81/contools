@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "INPUT_FILE=%~1"

if not exist "%INPUT_FILE%" (
  echo;%?~%: error: INPUT_FILE does not exist: INPUT_FILE="%INPUT_FILE%".
  exit /b 1
) >&2

type "%INPUT_FILE%" | "%CONTOOLS_MSYS2_USR_ROOT%/bin/tr.exe" -d "\15\32"
