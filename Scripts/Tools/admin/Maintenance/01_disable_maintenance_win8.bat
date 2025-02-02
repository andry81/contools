@echo off

rem Description:
rem   Script disables maintenance tasks in Windows 8...
rem
rem   Based on:
rem     https://serverfault.com/questions/866336/do-i-need-to-disable-tiworker-exe-and-respective-tasksheduler-task-in-windows-se

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0..\__init__\__init__.bat"

rem cast to integer
set /A ADMIN_ELEVATED+=0
set /A SYSTEM_ELEVATED+=0

call :IS_SYSTEM_ELEVATED && goto SYSTEM_ELEVATED

if %SYSTEM_ELEVATED%0 NEQ 0 (
  echo.%~nx0: error: process must be System account elevated to continue.
  exit /b 255
) >&2

call :IS_ADMIN_ELEVATED && goto ADMIN_ELEVATED

if %ADMIN_ELEVATED%0 NEQ 0 (
  echo.%~nx0: error: process must be Administrator account elevated to continue.
  exit /b 255
) >&2

rem Must elevate to be able to install `psexesvc` service
goto ADMIN_ELEVATE

rem CAUTIOM:
rem   Windows 7 has an issue around the `find.exe` utility and code page 65001.
rem   We use `findstr.exe` instead of `find.exe` to workaround it.
rem
rem   Based on: https://superuser.com/questions/557387/pipe-not-working-in-cmd-exe-on-windows-7/1869422#1869422

:IS_ADMIN_ELEVATED
if exist "%SystemRoot%\System32\whoami.exe" "%SystemRoot%\System32\whoami.exe" /groups | "%SystemRoot%\System32\findstr.exe" /L "S-1-16-12288" >nul 2>nul & exit /b
if exist "%SystemRoot%\System32\fltmc.exe" "%SystemRoot%\System32\fltmc.exe" >nul 2>nul & exit /b
if exist "%SystemRoot%\System64\openfiles.exe" "%SystemRoot%\System64\openfiles.exe" >nul 2>nul & exit /b
if exist "%SystemRoot%\System32\openfiles.exe" "%SystemRoot%\System32\openfiles.exe" >nul 2>nul & exit /b
if exist "%SystemRoot%\System32\config\system" exit /b 0
exit /b 255

:IS_SYSTEM_ELEVATED
if exist "%SystemRoot%\System32\whoami.exe" "%SystemRoot%\System32\whoami.exe" /groups | "%SystemRoot%\System32\findstr.exe" /L "S-1-16-16384" >nul 2>nul & exit /b
exit /b 255

:ADMIN_ELEVATE
rem Based on:
rem   `Uniform variant of a command line as a single argument for the `mshta.exe` executable and other cases` :
rem   https://github.com/andry81/contools/discussions/11

rem Windows Batch compatible command line with escapes (`\""` is a single nested `"`, `\""""` is a double nested `"` and so on).
set ?.=set "ADMIN_ELEVATED=1" ^& "%~f0" %*

rem translate Windows Batch compatible escapes into escape placeholders
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$=$0!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""""""""=$4!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""""=$3!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""=$2!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:"^=$1!"") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:~0,-1!") do endlocal & set "?.=%%i"

rem translate escape placeholders into `mshta.exe` (vbs) escapes (`""` is a single nested `"`, `""""` is a double nested `"` and so on)
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$4=""""""""""""""""""""""""""""""""!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$3=""""""""""""""""!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$2=""""""""!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$1=""""!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$0=$!") do endlocal & set "?.=%%i"

rem CAUTION: ShellExecute does not wait a child process close!
rem NOTE: `ExecuteGlobal` is used as a workaround, because the `mshta.exe` first argument must not be used with the surrounded quotes
start /B /WAIT "" "%SystemRoot%\System32\mshta.exe" vbscript:ExecuteGlobal("Close(CreateObject(""Shell.Application"").ShellExecute(""%COMSPEC%"", ""/c @%?.%"", """", ""runas"", True))")
exit /b

:ADMIN_ELEVATED
set SYSTEM_ELEVATED=1

rem run as `System` account and doesn't wait
call :CMD "%%CONTOOLS_SYSINTERNALS_ROOT%%/psexec.exe" -i -s -d %%0 %%*
exit /b

:SYSTEM_ELEVATED
call :CMD schtasks /Change /tn "\Microsoft\Windows\TaskScheduler\Idle Maintenance" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\TaskScheduler\Manual Maintenance" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\TaskScheduler\Regular Maintenance" /Disable

call :CMD "%%SystemRoot%%\System32\reg.exe" add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f

echo.

pause

exit /b

:CMD
echo.^>%*
(
  %*
)
