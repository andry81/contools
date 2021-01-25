@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Installation script to create `System64` directory through the
rem   `mklink_system64.bat` or `juntion.exe` utility.
rem

if exist "%SystemRoot%\System64\" exit /b 0

setlocal

rem drop last error
type nul >nul

for %%i in (CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 1
  ) >&2
)

if not exist "%CONTOOLS_ROOT%\" (
  echo.%~nx0: error: CONTOOLS_ROOT directory does not exist: "%CONTOOLS_ROOT%"
  exit /b 2
) >&2

if not exist "%CONTOOLS_UTILITIES_BIN_ROOT%\" (
  echo.%~nx0: error: CONTOOLS_UTILITIES_BIN_ROOT directory does not exist: "%CONTOOLS_UTILITIES_BIN_ROOT%"
  exit /b 3
) >&2

rem CAUTION:
rem   Usage of the `ver` is not reliable because rely on the `XP` suffix, which in Windows XP x64 SP1 MAY DOES NOT EXIST!
rem
call "%%CONTOOLS_ROOT%%/std/get_wmic_os_version.bat"
set "WINDOWS_VER_STR=%RETURN_VALUE%"

set WINDOWS_MAJOR_VER=0
set WINDOWS_MINOR_VER=0
for /F "eol= tokens=1,2,* delims=." %%i in ("%WINDOWS_VER_STR%") do ( set "WINDOWS_MAJOR_VER=%%i" & set "WINDOWS_MINOR_VER=%%j" )

echo.Creating link: "%SystemRoot%\System64" -^> "%SystemRoot%\System32"

if %WINDOWS_MAJOR_VER% GTR 5 (
  call "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk/mklink_system64.bat"
) else (
  rem Sysinternals junction utility
  "%CONTOOLS_UTILITIES_BIN_ROOT%/sysinternals/junction.exe" -nobanner -accepteula "%SystemRoot%\System64" "%SystemRoot%\System32"
)
