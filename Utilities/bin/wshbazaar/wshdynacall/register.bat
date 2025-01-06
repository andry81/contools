@echo off

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL
call :IS_ADMIN_ELEVATED && goto ELEVATED

goto ELEVATE

rem CAUTIOM:
rem   Windows 7 has an issue around the `find.exe` utility and code page 65001.
rem   We use `findstr.exe` instead of `find.exe` to workaround it.
rem
rem   Details: https://superuser.com/questions/557387/pipe-not-working-in-cmd-exe-on-windows-7/1869422#1869422

:IS_ADMIN_ELEVATED
if exist "%SystemRoot%\System32\whoami.exe" "%SystemRoot%\System32\whoami.exe" /groups | "%SystemRoot%\System32\findstr.exe" /L "S-1-16-12288" >nul 2>nul && exit /b
if exist "%SystemRoot%\System32\fltmc.exe" "%SystemRoot%\System32\fltmc.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\System64\openfiles.exe" "%SystemRoot%\System64\openfiles.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\System32\openfiles.exe" "%SystemRoot%\System32\openfiles.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\System32\config\system" exit /b 0
exit /b 255

:ELEVATE
set IMPL=1

if "%PROCESSOR_ARCHITECTURE%" == "x86" goto X86

if not exist "%SystemRoot%\Syswow64\*" (
  echo.%~nx0: error: not x86 system without Syswow64 system directory.
  exit /b 255
) >&2

rem CAUTION: ShellExecute does not wait a child process close!
start /B /WAIT "" "%SystemRoot%\System32\mshta.exe" vbscript:Close^(CreateObject^("Shell.Application").ShellExecute^("%SystemRoot%\Syswow64\cmd.exe"^,"/c @call ""%~f0"" %* & pause"^,""^,"runas"^,True))
exit /b

:X86
rem CAUTION: ShellExecute does not wait a child process close!
start /B /WAIT "" "%SystemRoot%\System32\mshta.exe" vbscript:Close^(CreateObject^("Shell.Application").ShellExecute^("%COMSPEC%"^,"/c @call ""%~f0"" %* & pause"^,""^,"runas"^,True))
exit /b

:ELEVATED
set IMPL=1

if "%PROCESSOR_ARCHITECTURE%" == "x86" goto IMPL

if not exist "%SystemRoot%\Syswow64\*" (
  echo.%~nx0: error: not x86 system without Syswow64 system directory.
  exit /b 255
) >&2

rem CAUTION: ShellExecute does not wait a child process close!
"%SystemRoot%\Syswow64\cmd.exe" /c @call "%~f0" %*
exit /b

:IMPL
call :IS_ADMIN_ELEVATED || (
  echo.%~nx0: error: process must be elevated before continue.
  exit /b 255
) >&2

"%SystemRoot%\System32\regsvr32.exe" "%~dp0wshdynacall32.dll"
