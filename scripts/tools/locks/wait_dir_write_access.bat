@echo off & goto DOC_END

rem USAGE:
rem   wait_dir_write_access.bat <dir-path> [<wait-timeout-msec>|-1]

rem Description:
rem   Awaits a directory for a write access permission excluding
rem   subdirectories.
rem   Minimum wait timeout can not be less than 20 msec to reduce CPU
rem   consumption.

rem Pros:
rem   * Awaits on a directory write access privilege.
rem   * Awaits on deny write access privilege change like
rem     `Everyone Deny Access` removement.
rem   * Awaits on a parent directory write access privilege in case of
rem     privileges inheritance.
rem   * Does not wait a parent directory write access privilege if a directory
rem     already has an exclusive not inherited write access privilege.
rem   * Does not wait on a path if has permissions to read a path as a
rem     file.
rem   * Does support long paths.
rem   * Can sleep on a specified timeout in milliseconds between checks.

rem Cons:
rem   * Does not support directories in nested directories including
rem     subdirectories in `<dir-path>` directory.
:DOC_END

setlocal

if "%~1" == "" exit /b 0

for /F "tokens=* delims=" %%i in ("%~1\.") do set "FILE_PATH=%%~fi"
for /F "tokens=* delims=" %%i in ("\\?\%FILE_PATH%") do set "FILE_PATH_ATTR=%%~ai"

if not defined FILE_PATH_ATTR exit /b 255
if /i not "%FILE_PATH_ATTR:~0,1%" == "d" exit /b 255

set "FILE_NAME_TMP=.%~n0.%RANDOM%-%RANDOM%.tmp"

if not "%~2" == "" if %~20 LSS 0 (
  ( type nul > "\\?\%FILE_PATH%\%FILE_NAME_TMP%" ) 2>nul || exit /b 1
  "%SystemRoot%\System32\cscript.exe" //NOLOGO "%~dp0delete_file.vbs" "\\?\%FILE_PATH%\%FILE_NAME_TMP%"
  exit /b 0
)

:FILE_WRITE_LOOP
( type nul > "\\?\%FILE_PATH%\%FILE_NAME_TMP%" ) 2>nul || ( call :SLEEP %%2 & goto FILE_WRITE_LOOP )
"%SystemRoot%\System32\cscript.exe" //NOLOGO "%~dp0delete_file.vbs" "\\?\%FILE_PATH%\%FILE_NAME_TMP%"
exit /b 0

:SLEEP
set "TIME_SLEEP_MSEC=%~1"

rem minimum wait timeout
if not defined TIME_SLEEP_MSEC set TIME_SLEEP_MSEC=20
if %TIME_SLEEP_MSEC% LEQ 20 set TIME_SLEEP_MSEC=20

"%SystemRoot%\System32\cscript.exe" //NOLOGO "%~dp0sleep.vbs" "%TIME_SLEEP_MSEC%"
