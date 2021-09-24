@echo off

setlocal

rem CAUTION:
rem   In Windowx XP an elevated call under data protection flag will block the wmic tool, so we have to use `ver` command instead!
rem
set "WINDOWS_VER_STR="
for /F "usebackq tokens=1,2,* delims=[]" %%i in (`ver`) do for /F "tokens=1,2,* delims= " %%l in ("%%j") do set "WINDOWS_VER_STR=%%m"

set WINDOWS_MAJOR_VER=0
set WINDOWS_MINOR_VER=0
for /F "eol= tokens=1,2,* delims=." %%i in ("%WINDOWS_VER_STR%") do ( set "WINDOWS_MAJOR_VER=%%i" & set "WINDOWS_MINOR_VER=%%j" )

(
  endlocal
  set "WINDOWS_VER_STR=%WINDOWS_VER_STR%"
  set "WINDOWS_MAJOR_VER=%WINDOWS_MAJOR_VER%"
  set "WINDOWS_MINOR_VER=%WINDOWS_MINOR_VER%"
)

exit /b 0
