@echo off

rem USAGE:
rem   mkdir.bat <path>

rem Description:
rem   A build pipeline wrapper over builtin `mkdir` command with
rem   single long path workaround through the `robocopy` executable utility and
rem   `EMPTY_DIR_TMP` variable.
rem
rem   Directory in the `EMPTY_DIR_TMP` variable must be not a long path.

rem <path>
rem   Single directory path.

setlocal

if "%~1" == "" (
  echo.%~nx0: error: a directory is not defined.
  echo.
  exit /b 255
) >&2

for /F "eol= tokens=* delims=" %%i in ("%~1\.") do set "FILE_PATH=%%~fi"

if exist "\\?\%FILE_PATH%\*" (
  echo.%~nx0: error: directory already exists: "%FILE_PATH%".
  echo.
  exit /b 1
) >&2 else if exist "\\?\%FILE_PATH%" (
  echo.%~nx0: error: path does exist and is not a directory: "%FILE_PATH%".
  echo.
  exit /b 1
) >&2

echo.^>mkdir "%FILE_PATH%"

mkdir "%FILE_PATH%" 2>nul && (
  echo.
  echo /b 0
)

if not defined EMPTY_DIR_TMP (
  set EMPTY_DIR_TMP_INTERNAL=1
  set "EMPTY_DIR_TMP=%TEMP%\%~nx0.%RANDOM%-%RANDOM%"
) else (
  set EMPTY_DIR_TMP_INTERNAL=0
  for /F "eol= tokens=* delims=" %%i in ("%EMPTY_DIR_TMP%\.") do set "EMPTY_DIR_TMP=%%~fi"
)

if not exist "\\?\%SystemRoot%\System32\robocopy.exe" (
  echo.%~nx0: error: could not create a target file directory: "%FILE_PATH%".
  echo.
  exit /b 255
) >&2

if exist "\\?\EMPTY_DIR_TMP\*" (
  rem touch the temporary directory
  copy /B "%EMPTY_DIR_TMP%"+,, "%EMPTY_DIR_TMP%" >nul
) else mkdir "%EMPTY_DIR_TMP%" >nul

rem updates the modification file time if exists
"%SystemRoot%\System32\robocopy.exe" /CREATE "%EMPTY_DIR_TMP%" "%FILE_PATH%" >nul

if %EMPTY_DIR_TMP_INTERNAL% NEQ 0 rmdir /S /Q "%EMPTY_DIR_TMP%" >nul

echo.
