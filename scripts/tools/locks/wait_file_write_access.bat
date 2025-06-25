@echo off & goto DOC_END

rem USAGE:
rem   wait_file_write_access.bat <file-path> [<wait-timeout-msec>|-1]

rem Description:
rem   Awaits a file for a write access permission.
rem   Minimum wait timeout can not be less than 20 msec to reduce CPU
rem   consumption.

rem Based on:
rem   https://stackoverflow.com/questions/1999988/how-to-check-whether-a-file-dir-is-writable-in-batch-scripts/59884789#59884789

rem Pros:
rem   * Awaits on a file write access privilege.
rem   * Awaits on deny write access privilege change like
rem     `Everyone Deny Access` removement.
rem   * Awaits on a parent directory write access privilege in case of
rem     privileges inheritance.
rem   * Does not wait a parent directory write access privilege if a file
rem     directory already has an exclusive not inherited write access
rem     privilege.
rem   * Does not wait a file directory write access privilege if a file
rem     already has an exclusive not inherited write access privilege.
rem   * Does not wait on a path if has permissions to read a path as a
rem     directory.
rem   * Can sleep on a specified timeout in milliseconds between checks.

rem Cons:
rem   * Does not support long paths (but detects them to exit correctly).
:DOC_END

setlocal

if "%~1" == "" exit /b 0

for /F "tokens=* delims=" %%i in ("%~1\.") do set "FILE_PATH=%%~fi"
for /F "tokens=* delims=" %%i in ("\\?\%FILE_PATH%") do set "FILE_PATH_ATTR=%%~ai"

if not defined FILE_PATH_ATTR exit /b 255
if /i "%FILE_PATH_ATTR:~0,1%" == "d" exit /b 255

if not "%~2" == "" if %~20 LSS 0 move /Y "%~1" "%~1" >nul 2>nul & exit /b

:FILE_MOVE_LOOP
move /Y "%~1" "%~1" >nul 2>nul || ( call :SLEEP %%2 & goto FILE_MOVE_LOOP )
exit /b 0

:SLEEP
set "TIME_SLEEP_MSEC=%~1"

rem minimum wait timeout
if not defined TIME_SLEEP_MSEC set TIME_SLEEP_MSEC=20
if %TIME_SLEEP_MSEC% LEQ 20 set TIME_SLEEP_MSEC=20

"%SystemRoot%\System32\cscript.exe" //NOLOGO "%~dp0sleep.vbs" "%TIME_SLEEP_MSEC%"
