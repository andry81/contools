@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script sets WINVER_VALUE to string in format:
rem   <Name>|<PlatformType>|<Version>
rem   Examples:
rem     Windows 2000 32bit for x86            -> Windows2000|x86|5.00.2195
rem     Windows XP 32bit for x86              -> WindowsXP|x86|5.1.2600
rem     Windows XP 64bit for x86              -> WindowsXP|x64|5.2.3790
rem     Windows XP 64bit for Itanium          -> WindowsXP|i64|5.2.XXXX
rem     Windows Vista 32bit for x86           -> WindowsVista|x86|6.0.6001
rem     Windows Vista 64bit for x86           -> WindowsVista|x64|6.0.6001
rem     Windows 7 32bit for x86               -> Windows7|x86|6.1.7600
rem     Windows 7 64bit for x86               -> Windows7|x64|6.1.7600
rem     Windows 8 64bit for x86               -> Windows8|x64|6.2.9200
rem     Windows Server 2008 R2 64bit for x86  -> WindowsSrv2008R2|x64|6.1.7600

rem Drop WINVER_VALUE variable
set "WINVER_VALUE="

rem Drop last error level
cd .

rem Create local variable's stack
setlocal

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0"
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

set "?0=^"
set "?2=|"

rem Windows 2000
call "%%TOOLS_PATH%%\setvarfromstd.bat" ver%%%%?2%%%% findstr.exe /I /R /C:"Windows[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*2000"
if not "%STDOUT_VALUE%" == "" set WINVER_VALUE=Windows2000
if not "%WINVER_VALUE%" == "" goto CHECK_PLATFORM

rem Higher than Windows 2000
call "%%TOOLS_PATH%%\setvarfromstd.bat" reg.exe query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "ProductName" %%%%?2%%%% findstr.exe /I /R /C:"ProductName[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*REG_[A-Z][A-Z]*" 2>nul

rem Truncate 2 fields before value
if not "%STDOUT_VALUE%" == "" (
  set "STDOUT_VALUE=%STDOUT_VALUE:~11%"
)

for /F "tokens=1,*" %%i in ("%STDOUT_VALUE%") do (
  set STDOUT_VALUE=0
  set "STDOUT_VALUE=%%j"
)

set WINVER_VALUE_FULL=0
set "WINVER_VALUE_FULL=%STDOUT_VALUE%"

rem Windows XP
call "%%TOOLS_PATH%%\setvarfromstd.bat" echo "%%WINVER_VALUE_FULL%%"%%%%?2%%%% findstr.exe /I /R /C:"Windows[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*XP"
if not "%STDOUT_VALUE:~1,-1%" == "~1,-1" (
  if not "%STDOUT_VALUE:~1,-1%" == "" set WINVER_VALUE=WindowsXP
)
if not "%WINVER_VALUE%" == "" goto CHECK_PLATFORM

rem Windows Vista
call "%%TOOLS_PATH%%\setvarfromstd.bat" echo "%%WINVER_VALUE_FULL%%"%%%%?2%%%% findstr.exe /I /R /C:"[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*Vista[%%?0%%a-zA-Z0-9\\/]*"
if not "%STDOUT_VALUE:~1,-1%" == "~1,-1" (
  if not "%STDOUT_VALUE:~1,-1%" == "" set WINVER_VALUE=WindowsVista
)
if not "%WINVER_VALUE%" == "" goto CHECK_PLATFORM

rem Windows 7
call "%%TOOLS_PATH%%\setvarfromstd.bat" echo "%%WINVER_VALUE_FULL%%"%%%%?2%%%% findstr.exe /I /R /C:"Windows[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*7"
if not "%STDOUT_VALUE:~1,-1%" == "~1,-1" (
  if not "%STDOUT_VALUE:~1,-1%" == "" set WINVER_VALUE=Windows7
)
if not "%WINVER_VALUE%" == "" goto CHECK_PLATFORM

rem Windows 8
call "%%TOOLS_PATH%%\setvarfromstd.bat" echo "%%WINVER_VALUE_FULL%%"%%%%?2%%%% findstr.exe /I /R /C:"Windows[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*8"
if not "%STDOUT_VALUE:~1,-1%" == "~1,-1" (
  if not "%STDOUT_VALUE:~1,-1%" == "" set WINVER_VALUE=Windows8
)
if not "%WINVER_VALUE%" == "" goto CHECK_PLATFORM

rem Windows Server 2003
call "%%TOOLS_PATH%%\setvarfromstd.bat" echo "%%WINVER_VALUE_FULL%%"%%%%?2%%%% findstr.exe /I /R /C:"Server[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*2003"
if not "%STDOUT_VALUE:~1,-1%" == "~1,-1" (
  if not "%STDOUT_VALUE:~1,-1%" == "" set WINVER_VALUE=WindowsSrv2003
)
if not "%WINVER_VALUE%" == "" goto CHECK_PLATFORM

rem Windows Server 2008 R2
call "%%TOOLS_PATH%%\setvarfromstd.bat" echo "%%WINVER_VALUE_FULL%%"%%%%?2%%%% findstr.exe /I /R /C:"Server[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*2008[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*R2"
if not "%STDOUT_VALUE:~1,-1%" == "~1,-1" (
  if not "%STDOUT_VALUE:~1,-1%" == "" set WINVER_VALUE=WindowsSrv2008R2
)
if not "%WINVER_VALUE%" == "" goto CHECK_PLATFORM

rem Windows Server 2008 R1
call "%%TOOLS_PATH%%\setvarfromstd.bat" echo "%%WINVER_VALUE_FULL%%"%%%%?2%%%% findstr.exe /I /R /C:"Server[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*2008[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*R1"
if not "%STDOUT_VALUE:~1,-1%" == "~1,-1" (
  if not "%STDOUT_VALUE:~1,-1%" == "" set WINVER_VALUE=WindowsSrv2008R1
)
if not "%WINVER_VALUE%" == "" goto CHECK_PLATFORM

rem Windows Server 2008
call "%%TOOLS_PATH%%\setvarfromstd.bat" echo "%%WINVER_VALUE_FULL%%"%%%%?2%%%% findstr.exe /I /R /C:"Server[%%?0%%a-zA-Z0-9\\/][%%?0%%a-zA-Z0-9\\/]*2008"
if not "%STDOUT_VALUE:~1,-1%" == "~1,-1" (
  if not "%STDOUT_VALUE:~1,-1%" == "" set WINVER_VALUE=WindowsSrv2008
)
if not "%WINVER_VALUE%" == "" goto CHECK_PLATFORM

set WINVER_VALUE=Windows

:CHECK_PLATFORM

if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set "WINVER_VALUE=%WINVER_VALUE%|x64"
) else if "%PROCESSOR_ARCHITEW6432%" == "AMD64" (
  set "WINVER_VALUE=%WINVER_VALUE%|x64"
) else if "%PROCESSOR_ARCHITECTURE%" == "IA64" (
  set "WINVER_VALUE=%WINVER_VALUE%|i64"
) else if "%PROCESSOR_ARCHITEW6432%" == "IA64" (
  set "WINVER_VALUE=%WINVER_VALUE%|i64"
) else (
  set "WINVER_VALUE=%WINVER_VALUE%|x86"
)

:CHECK_VERSION

call "%%TOOLS_PATH%%\setvarfromstd.bat" ver

rem Truncate 2 fields before value
if not "%STDOUT_VALUE%" == "" (
  set "STDOUT_VALUE=%STDOUT_VALUE:~14%"
)

for /F "tokens=1,* delims=[" %%i in ("%STDOUT_VALUE%") do (
  set STDOUT_VALUE=0
  set "STDOUT_VALUE=%%j"
)

for /F "tokens=1,* delims= " %%i in ("%STDOUT_VALUE%") do (
  set STDOUT_VALUE=0
  set "STDOUT_VALUE=%%j"
)

for /F "tokens=1,* delims=]" %%i in ("%STDOUT_VALUE%") do (
  set STDOUT_VALUE=0
  set "STDOUT_VALUE=%%i"
)

set "WINVER_VALUE=%WINVER_VALUE%|%STDOUT_VALUE%"

rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set "WINVER_VALUE=%WINVER_VALUE%"
)

exit /b 0
