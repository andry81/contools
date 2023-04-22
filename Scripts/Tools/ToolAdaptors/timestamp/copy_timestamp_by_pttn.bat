@echo off

rem Description:
rem   Copies file time stamps from one file to another by input path pattern.
rem

setlocal

call "%%~dp0__init__.bat" || exit /b

set "INPUT_PATH_PTTN=%~1"
set "OUTPUT_DIR=%~2"
set "OUTPUT_EXT=%~3"

if not defined INPUT_PATH_PTTN (
  echo.%~nx0: error: INPUT_PATH_PTTN input file path pattern is not set.
  exit /b 1
) >&2

if not defined OUTPUT_DIR (
  echo.%~nx0: error: OUTPUT_DIR output directory path is not set.
  exit /b 2
) >&2

if not exist "%OUTPUT_DIR%\" (
  echo.%~nx0: error: OUTPUT_DIR output directory path does not exist: "%OUTPUT_DIR%".
  exit /b 3
) >&2

if not defined OUTPUT_EXT (
  echo.%~nx0: error: OUTPUT_EXT output file extension is not set.
  exit /b 4
) >&2

if "%OUTPUT_EXT:~0,1%" == "." (
  echo.%~nx0: error: OUTPUT_EXT should not begins by dot: "%OUTPUT_EXT%".
  exit /b 5
) >&2

set "INPUT_DIR_PATH=%~dp1"

chcp 1251

for /F "usebackq eol=| tokens=* delims=" %%i in (`dir /A:-D /B /O:N "%INPUT_PATH_PTTN%"`) do (
  set "INPUT_FILE_NAME=%%i"
  call :PROCESS_INPUT_FILE_PATH "%%INPUT_FILE_NAME%%" || exit /b
)

exit /b 0

:PROCESS_INPUT_FILE_PATH
set "INPUT_FILE_PATH=%INPUT_DIR_PATH%%INPUT_FILE_NAME%"
set "OUTPUT_FILE_PATH=%OUTPUT_DIR%\%~n1.%OUTPUT_EXT%"

"%CONTOOLS_SPMILLER_CONSOLE_TOOLBOX_ROOT%/touch.exe" /c /m /a /r "%INPUT_FILE_PATH%" "%OUTPUT_FILE_PATH%"
