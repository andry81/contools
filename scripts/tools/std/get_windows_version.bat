@echo off

setlocal

set "WINDOWS_VER_STR="
set "WINDOWS_MAJOR_VER="
set "WINDOWS_MINOR_VER="
set "WINDOWS_X64_VER="
set "COMSPEC_X64_VER="

rem CAUTION:
rem   In Windowx XP an elevated call under data protection flag will block the wmic tool, so we have to use `ver` command instead!
rem
for /F "usebackq tokens=1,2,* delims=[]" %%i in (`@ver 2^>nul`) do set "WINDOWS_VER_STR=%%j"

if not defined WINDOWS_VER_STR goto EXIT

setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!WINDOWS_VER_STR:* =!"') do endlocal & set "WINDOWS_VER_STR=%%~i"

set WINDOWS_MAJOR_VER=0
set WINDOWS_MINOR_VER=0
for /F "tokens=1,2,* delims=."eol^= %%i in ("%WINDOWS_VER_STR%") do set "WINDOWS_MAJOR_VER=%%i" & set "WINDOWS_MINOR_VER=%%j"

set WINDOWS_X64_VER=0
if defined PROCESSOR_ARCHITEW6432 ( set "WINDOWS_X64_VER=1" ) else if /i not "%PROCESSOR_ARCHITECTURE%" == "x86" set WINDOWS_X64_VER=1

rem CAUTION:
rem   Specific case for Windows XP x64 SP2, where both PROCESSOR_ARCHITECTURE and PROCESSOR_ARCHITEW6432 are equal to AMD64 for 32-bit cmd.exe process!
rem
set COMSPEC_X64_VER=0
if /i not "%PROCESSOR_ARCHITECTURE%" == "x86" if not defined PROCESSOR_ARCHITEW6432 set COMSPEC_X64_VER=1

:EXIT
(
  endlocal
  set "WINDOWS_VER_STR=%WINDOWS_VER_STR%"
  set "WINDOWS_MAJOR_VER=%WINDOWS_MAJOR_VER%"
  set "WINDOWS_MINOR_VER=%WINDOWS_MINOR_VER%"
  set "WINDOWS_X64_VER=%WINDOWS_X64_VER%"
  set "COMSPEC_X64_VER=%COMSPEC_X64_VER%"
)

exit /b 0
