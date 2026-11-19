@echo off

set "WINDOWS_VER_STR=" & set "WINDOWS_MAJOR_VER=" & set "WINDOWS_MINOR_VER=" & set "WINDOWS_X64_VER=" & set "COMSPEC_X64_VER="

if not defined PROCESSOR_ARCHITECTURE (
  echo;%~nx0: error: PROCESSOR_ARCHITECTURE is not defined.
  exit /b 255
) >&2

rem CAUTION:
rem   In Windows XP an elevated call under data protection flag will block the wmic tool, so we have to use `ver` command instead!

for /F "usebackq tokens=1,2,* delims=[]" %%i in (`@ver 2^>nul`) do set "WINDOWS_VER_STR=%%j"

if not defined WINDOWS_VER_STR exit /b 0

setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!WINDOWS_VER_STR:* =!"') do endlocal & set "WINDOWS_VER_STR=%%~i"

set /A "WINDOWS_MAJOR_VER=0", "WINDOWS_MINOR_VER=0"
for /F "tokens=1,2,* delims=."eol^= %%i in ("%WINDOWS_VER_STR%") do set "WINDOWS_MAJOR_VER=%%i" & set "WINDOWS_MINOR_VER=%%j"

set /A "WINDOWS_X64_VER=0", "WINDOWS_X32_VER=0"
if defined PROCESSOR_ARCHITEW6432 (
  set /A "WINDOWS_X64_VER=1", "WINDOWS_X32_VER=1"
) else if not "%PROCESSOR_ARCHITECTURE:64=%" == "%PROCESSOR_ARCHITECTURE%" (
  set /A "WINDOWS_X64_VER=1"
) else (
  set /A "WINDOWS_X32_VER=1"
)

rem `SysWOW64` is visible from both 32-bit and 64-bit `cmd.exe`
if not defined PROCESSOR_ARCHITEW6432 if exist "%SystemRoot%\SysWOW64\*" set /A "WINDOWS_X32_VER=1", "WINDOWS_X64_VER=1"

rem CAUTION:
rem   Specific case for Windows XP x64 SP2, where both PROCESSOR_ARCHITECTURE and PROCESSOR_ARCHITEW6432 can be are equal to AMD64 for 32-bit `cmd.exe` process!

set /A "COMSPEC_X64_VER=0"
if not "%PROCESSOR_ARCHITECTURE:64=%" == "%PROCESSOR_ARCHITECTURE%" if not defined PROCESSOR_ARCHITEW6432 set /A "COMSPEC_X64_VER=1"

exit /b 0
