@echo off & goto DOC_END

rem USAGE:
rem   sleep.bat [-vbs] <timeout-msec>
:DOC_END

setlocal

set VBS_SLEEP=0
if "%~1" == "-vbs" (
  set VBS_SLEEP=1
  shift
)

set /A "TIME_SLEEP_MSEC=%~1--0"

if %TIME_SLEEP_MSEC% LEQ 0 exit /b 0

if %VBS_SLEEP% NEQ 0 "%SystemRoot%\System32\cscript.exe" //nologo "%~dp0sleep.vbs" "%TIME_SLEEP_MSEC%" & exit /b 0

rem use pingpath to wait longer than 500 msec
if %TIME_SLEEP_MSEC% GEQ 500 "%SystemRoot%\System32\pathping.exe" 127.0.0.1 -n -q 1 -p %TIME_SLEEP_MSEC% >nul 2>nul & exit /b 0

rem no code after this line
"%~dp0busy_wait.bat" "%TIME_SLEEP_MSEC%"
