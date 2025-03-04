@echo off

rem Description:
rem   Installation script to create `System64` directory through the
rem   `mklink_system64.bat` or `juntion.exe` utility.
rem

if exist "%SystemRoot%\System64\*" exit /b 0

setlocal

rem drop last error
call;

for %%i in (CONTOOLS_ROOT CONTOOLS_SYSINTERNALS_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 1
  ) >&2
)

if not exist "%CONTOOLS_ROOT%\*" (
  echo.%~nx0: error: CONTOOLS_ROOT directory does not exist: "%CONTOOLS_ROOT%"
  exit /b 2
) >&2

if not exist "%CONTOOLS_SYSINTERNALS_ROOT%\*" (
  echo.%~nx0: error: CONTOOLS_SYSINTERNALS_ROOT directory does not exist: "%CONTOOLS_SYSINTERNALS_ROOT%"
  exit /b 3
) >&2

rem CAUTION:
rem   In Windowx XP an elevated call under data protection flag will block the wmic tool, so we have to use `ver` command instead!
rem
for /F "usebackq tokens=1,2,* delims=[]" %%i in (`ver`) do for /F "tokens=1,2,* delims= " %%l in ("%%j") do set "WINDOWS_VER_STR=%%m"

set WINDOWS_MAJOR_VER=0
set WINDOWS_MINOR_VER=0
for /F "tokens=1,2,* delims=."eol^= %%i in ("%WINDOWS_VER_STR%") do set "WINDOWS_MAJOR_VER=%%i" & set "WINDOWS_MINOR_VER=%%j"

echo.Creating link: "%SystemRoot%\System64" -^> "%SystemRoot%\System32"

if %WINDOWS_MAJOR_VER% GTR 5 (
  call "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk/mklink_system64.bat"
) else (
  rem Sysinternals junction utility
  "%CONTOOLS_SYSINTERNALS_ROOT%/junction.exe" -nobanner -accepteula "%SystemRoot%\System64" "%SystemRoot%\System32"
)
