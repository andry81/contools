@echo off

rem Description:
rem   Copies file time stamps from one file to another by input path pattern.
rem

setlocal

call "%%~dp0__init__.bat" || exit /b

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "?~=%~nx0"

set "INPUT_PATH_PTTN=%~1"
set "OUTPUT_DIR=%~2"
set "OUTPUT_EXT=%~3"

if not defined INPUT_PATH_PTTN (
  echo;%?~%: error: INPUT_PATH_PTTN input file path pattern is not set.
  exit /b 1
) >&2

if not defined OUTPUT_DIR (
  echo;%?~%: error: OUTPUT_DIR output directory path is not set.
  exit /b 2
) >&2

if not exist "%OUTPUT_DIR%\*" (
  echo;%?~%: error: OUTPUT_DIR output directory path does not exist: "%OUTPUT_DIR%".
  exit /b 3
) >&2

if not defined OUTPUT_EXT (
  echo;%?~%: error: OUTPUT_EXT output file extension is not set.
  exit /b 4
) >&2

if "%OUTPUT_EXT:~0,1%" == "." (
  echo;%?~%: error: OUTPUT_EXT should not begins by dot: "%OUTPUT_EXT%".
  exit /b 5
) >&2

set "INPUT_DIR_PATH=%~dp1"

chcp 1251

rem CAUTION:
rem   1. If a variable is empty, then it would not be expanded in the `cmd.exe`
rem      command line or in the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement.
rem   2. The `cmd.exe` command line or the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement does expand twice.
rem
rem   We must expand the command line into a variable to avoid these above.
rem
set ?.=@dir "%INPUT_PATH_PTTN%" /A:-D /B /O:N 2^>nul

for /F "usebackq eol=| tokens=* delims=" %%i in (`%%?.%%`) do (
  set "INPUT_FILE_NAME=%%i"
  call :PROCESS_INPUT_FILE_PATH "%%INPUT_FILE_NAME%%" || exit /b
)

exit /b 0

:PROCESS_INPUT_FILE_PATH
set "INPUT_FILE_PATH=%INPUT_DIR_PATH%%INPUT_FILE_NAME%"
set "OUTPUT_FILE_PATH=%OUTPUT_DIR%\%~n1.%OUTPUT_EXT%"

"%CONTOOLS_SPMILLER_CONSOLE_TOOLBOX_ROOT%/touch.exe" /c /m /a /r "%INPUT_FILE_PATH%" "%OUTPUT_FILE_PATH%"
