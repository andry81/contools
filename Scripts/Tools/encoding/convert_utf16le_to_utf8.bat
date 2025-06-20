@echo off

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "FROM_FILE_PATH=%~1"
set "TO_FILE_PATH=%~2"
set "TO_FILE_DIR_PATH=%~dp2"

if not exist "%FROM_FILE_PATH%" (
  echo;%?~%: error: FROM_FILE_PATH file does not exist: "%FROM_FILE_PATH%".
  exit /b 1
) >&2

if not exist "%TO_FILE_DIR_PATH%" (
  echo;%?~%: error: TO_FILE_DIR_PATH directory does not exist: "%TO_FILE_DIR_PATH%".
  exit /b 2
) >&2

rem UTF-16 w/o byte ordering suffix to avoid BOM generation
"%CONTOOLS_MSYS2_USR_ROOT%/bin/iconv.exe" -c -f UTF-16 -t UTF-8 "%FROM_FILE_PATH%" > "%TO_FILE_PATH%"
