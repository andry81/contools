@echo off & goto DOC_END

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
:DOC_END

rem Drop last error level
call;

rem Create local variable's stack
setlocal

set "__REG_PATH=%~1"

if not defined __REG_PATH exit /b 65

rem remove last slash, otherwise reg.exe will exit with error code
set __REG_PATH_LAST_SLASH=0
if "%__REG_PATH:~-1%" == "\" (
  set __REG_PATH=%__REG_PATH:~0,-1%
  set __REG_PATH_LAST_SLASH=1
)

rem test if key is exist
"%SystemRoot%\System32\reg.exe" query "%__REG_PATH%" >nul 2>nul || exit /b 1

rem call "%%~dp0__init__.bat" || exit /b

rem call "%%CONTOOLS_ROOT%%/cstresc.bat" "%%__REG_PATH%%" "__KEYPATH" "\.*^$[]"
set "__KEYPATH=%__REG_PATH:\=\\%"
set "__KEYPATH=%__KEYPATH:.=\.%"
set "__KEYPATH=%__KEYPATH:^=\^%"
set "__KEYPATH=%__KEYPATH:$=\$%"
set "__KEYPATH=%__KEYPATH:[=\[%"
set "__KEYPATH=%__KEYPATH:]=\]%"

if /i "%__KEYPATH:~0,5%" == "HKLM\" set "__KEYPATH=HKEY_LOCAL_MACHINE\%__KEYPATH:~5%"
if /i "%__KEYPATH:~0,5%" == "HKCU\" set "__KEYPATH=HKEY_CURRENT_USER\%__KEYPATH:~5%"
if /i "%__KEYPATH:~0,5%" == "HKCR\" set "__KEYPATH=HKEY_CLASSES_ROOT\%__KEYPATH:~5%"
if /i "%__KEYPATH:~0,5%" == "HKU\" set "__KEYPATH=HKEY_USERS\%__KEYPATH:~5%"
if /i "%__KEYPATH:~0,5%" == "HKCC\" set "__KEYPATH=HKEY_CURRENT_CONFIG\%__KEYPATH:~5%"

if %__REG_PATH_LAST_SLASH% EQU 0 (
  "%SystemRoot%\System32\reg.exe" query "%__REG_PATH%" 2>nul | "%SystemRoot%\System32\findstr.exe" /I /R /C:"%__KEYPATH%"
) else (
  "%SystemRoot%\System32\reg.exe" query "%__REG_PATH%" 2>nul | "%SystemRoot%\System32\findstr.exe" /I /R /C:"^%__KEYPATH%\\\\"
)

exit /b 0
