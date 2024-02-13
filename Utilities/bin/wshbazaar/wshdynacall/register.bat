@echo off

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL
"%SystemRoot%\System32\net.exe" session >nul 2>&1 && goto ELEVATED

:ELEVATE
set IMPL=1

if "%PROCESSOR_ARCHITECTURE%" == "x86" goto X86

if not exist "%SystemRoot%\Syswow64\*" (
  echo.%~nx0: error: not x86 system without Syswow64 system directory.
  exit /b 255
) >&2

rem CAUTION: ShellExecute does not wait a child process close!
start /B /WAIT "" "%SystemRoot%\System32\mshta.exe" vbscript:Close^(CreateObject^("Shell.Application").ShellExecute^("%SystemRoot%\Syswow64\cmd.exe"^,"/c @call ""%~f0"" %*"^,""^,"runas"^,True))
exit /b

:X86
rem CAUTION: ShellExecute does not wait a child process close!
start /B /WAIT "" "%SystemRoot%\System32\mshta.exe" vbscript:Close^(CreateObject^("Shell.Application").ShellExecute^("%COMSPEC%"^,"/c @call ""%~f0"" %*"^,""^,"runas"^,True))
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
"%SystemRoot%\System32\net.exe" session >nul 2>&1 || (
  echo.%~nx0: error: process must be elevated before continue.
  exit /b 255
) >&2

"%SystemRoot%\System32\regsvr32.exe" "%~dp0wshdynacall32.dll"

pause
