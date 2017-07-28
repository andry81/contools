@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script outputs subkeys of registry key by read and parse output of
rem   reg.exe utility. Utility findstr.exe searches target string by regular
rem   expression without case sensitivity. String partially escapes before been
rem   passed to findstr.exe.
rem   If key doesn't exist, then error level sets to 1, otherwise - 0.

rem Command arguments:
rem %1 - Registry key path.

rem Examples:
rem 1. call regenum.bat "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft"
rem 2. call regenum.bat "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\"

rem Drop last error level
type nul>nul

rem Create local variable's stack
setlocal

set "__REG_PATH=%~1"

if "%__REG_PATH%" == "" exit /b 65

rem remove last slash, otherwise reg.exe will exit with error code
set __REG_PATH_LAST_SLASH=0
if "%__REG_PATH:~-1%" == "\" (
  set __REG_PATH=%__REG_PATH:~0,-1%
  set __REG_PATH_LAST_SLASH=1
)

rem test if key is exist
reg.exe query "%__REG_PATH%" 2>&1 >nul
if %ERRORLEVEL% NEQ 0 exit /b 1

rem call "%%~dp0__init__.bat" || goto :EOF

rem call "%%CONTOOLS_ROOT%%/cstresc.bat" "%%__REG_PATH%%" "__KEYPATH" "\.*^$[]"
set "__KEYPATH=%__REG_PATH:\=\\%"
set "__KEYPATH=%__KEYPATH:.=\.%"
set "__KEYPATH=%__KEYPATH:^=\^%"
set "__KEYPATH=%__KEYPATH:$=\$%"
set "__KEYPATH=%__KEYPATH:[=\[%"
set "__KEYPATH=%__KEYPATH:]=\]%"

if %__REG_PATH_LAST_SLASH% EQU 0 (
  reg.exe query "%__REG_PATH%" 2>nul | findstr.exe /I /R /C:"%__KEYPATH%"
) else (
  reg.exe query "%__REG_PATH%" 2>nul | findstr.exe /I /R /C:"^%__KEYPATH%\\\\"
)

exit /b 0
