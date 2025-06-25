@echo off

rem Description:
rem   Installation script to create `System64` directory through the
rem   `mklink_system64.bat` or `juntion.exe` utility.
rem

if exist "%SystemRoot%\System64\*" exit /b 0

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem drop last error
call;

for %%i in (CONTOOLS_ROOT CONTOOLS_SYSINTERNALS_ROOT) do ^
if not defined %%i (
  echo;%?~%: error: `%%i` variable is not defined.
  exit /b 1
) >&2

if not exist "%CONTOOLS_ROOT%\*" (
  echo;%?~%: error: CONTOOLS_ROOT directory does not exist: "%CONTOOLS_ROOT%"
  exit /b 2
) >&2

if not exist "%CONTOOLS_SYSINTERNALS_ROOT%\*" (
  echo;%?~%: error: CONTOOLS_SYSINTERNALS_ROOT directory does not exist: "%CONTOOLS_SYSINTERNALS_ROOT%"
  exit /b 3
) >&2

rem CAUTION:
rem   In Windowx XP an elevated call under data protection flag will block the wmic tool, so we have to use `ver` command instead!
rem
for /F "usebackq tokens=1,2,* delims=[]" %%i in (`@ver 2^>nul`) do for /F "tokens=1,2,* delims= " %%l in ("%%j") do set "WINDOWS_VER_STR=%%m"

if not defined WINDOWS_VER_STR goto SKIP_EMPTY

setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!WINDOWS_VER_STR:* =!"') do endlocal & set "WINDOWS_VER_STR=%%~i"

set WINDOWS_MAJOR_VER=0
set WINDOWS_MINOR_VER=0
for /F "tokens=1,2,* delims=."eol^= %%i in ("%WINDOWS_VER_STR%") do set "WINDOWS_MAJOR_VER=%%i" & set "WINDOWS_MINOR_VER=%%j"

:SKIP_EMPTY
echo;Creating link: "%SystemRoot%\System64" -^> "%SystemRoot%\System32"

if 5 GEQ %WINDOWS_MAJOR_VER% goto INSTALL_WINXP

:INSTALL_DEFAULT
call "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk/mklink_system64.bat"
exit /b

:INSTALL_WINXP
rem Sysinternals junction utility
"%CONTOOLS_SYSINTERNALS_ROOT%/junction.exe" -nobanner -accepteula "%SystemRoot%\System64" "%SystemRoot%\System32"
exit /b
