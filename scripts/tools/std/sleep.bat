<!-- : bat in wsf skip

@echo off & goto DOC_END

rem USAGE:
rem   sleep.bat [-vbs] [-flush_conin] [--] <timeout-msec>

rem Description:
rem   Script to sleep a period of time in milliseconds.
rem   By default does not flash console input buffer on exit.

rem -vbs:
rem   Use WSF+VBS implementation to wait from.

rem -flush_conin:
rem   Flush console input buffer on exit.

rem --:
rem   Separator to end flags scope to parse.

rem <timeout-msec>:
rem   Period of time in milliseconds.
rem   If greater or equal to 500, then calls to `pathping.exe` instead of
rem   `busy_wait.bat` script.
rem
rem   NOTE:
rem     Both implementations does not flush the console input buffer.
:DOC_END

setlocal DISABLEDELAYEDEXPANSION

set "?~f0=%~f0"
set "?~dp0=%~dp0"

set /A "FLAG_VBS_SLEEP=0", "FLAG_FLUSH_CONIN=0"

if "%~1" == "-vbs"          set "FLAG_VBS_SLEEP=1"    & shift
if "%~1" == "-flush_conin"  set "FLAG_FLUSH_CONIN=1"  & shift
if "%~1" == "--" shift

set /A "TIME_SLEEP_MSEC=%~1--0"

if %TIME_SLEEP_MSEC% LEQ 0 exit /b 0

if %FLAG_VBS_SLEEP% NEQ 0 (
  "%SystemRoot%\System32\cscript.exe" //nologo //JOB:SLEEP "%?~f0%?.wsf" "%TIME_SLEEP_MSEC%"
) else if %TIME_SLEEP_MSEC% GEQ 500 (
  "%SystemRoot%\System32\pathping.exe" 127.0.0.1 -n -q 1 -p %TIME_SLEEP_MSEC% >nul 2>nul
) else call "%%?~dp0%%busy_wait.bat" "%TIME_SLEEP_MSEC%"

if %FLAG_FLUSH_CONIN% NEQ 0 "%SystemRoot%\System32\timeout.exe" /T 0 >nul

exit /b 0

rem end of bat -->

<package>
  <job id="SLEEP">
    <script language="VBScript">
      Dim objShell : Set objShell = CreateObject("WScript.Shell")
      WScript.Sleep WScript.Arguments(0)
    </script>
  </job>
</package>
