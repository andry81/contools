@echo off & goto DOC_END

rem Description:
rem   Script reads version of msys dll and sets variable MSYS_VER_STR
rem     to read value.
rem   Parse version number in to 4 or 5 numbers:
rem     <MajorVersion>.<MinorVersion>.<PatchNumber>.<Revision1>[.<Revision2>]
rem   Version conversion examples:
rem     - 1.7.5-1         ->  1.7.5.1
rem     - 2.1-1           ->  2.1.0.1
rem     - 1.4p6-10        ->  1.4.6.10
rem     - 00885-1         ->  885.0.0.1
rem     - 1.3.30c-10      ->  1.3.30c.10
rem     - 20050522-1      ->  20050522.0.0.1
rem     - 5.7_20091114-14 ->  5.7.20091114.14
rem     - 4.5.20.2-2      ->  4.5.20.2.2
rem     - 2009k-1         ->  2009k.0.0.1

rem Command arguments:
rem %1 - Reserved.
rem %2 - Path to msys directory.

rem Examples:
rem 1. call msysver.bat msys "c:\msys\1.0"
rem    echo MSYS_VER_STR=%MSYS_VER_STR%
:DOC_END

rem Drop output values before request
set "MSYS_VER_STR="

if "%~1" == "" exit /b 65
if "%~2" == "" exit /b 66
if not exist "%~2\bin\uname.exe" exit /b 67

rem Create local variable's stack
setlocal

call "%%~dp0__init__.bat" || exit /b

for /F "usebackq tokens=* delims="eol^= %%i in (`@"%~2\bin\uname.exe" -r`) do ^
for /F "tokens=1,* delims= " %%j in ("%%i") do (
  set MSYS_VER_STR=0
  set "MSYS_VER_STR=%%j"
)

if not defined MSYS_VER_STR set "MSYS_VER_STR=%STDOUT_VALUE%"

rem Drop internal variables but use some changed value(s) for the return
if not defined MSYS_VER_STR (
  endlocal
  set "MSYS_VER_STR=%MSYS_VER_STR%"
  exit /b 1
)

for /F "tokens=1,* delims=(" %%i in ("%MSYS_VER_STR%") do (
  set __MSYS_VER_MAJOR=0
  set "__MSYS_VER_MAJOR=%%i"
)

for /F "tokens=1,* delims=-" %%i in ("%__MSYS_VER_MAJOR%") do (
  set __MSYS_VER_MAJOR=0
  set "__MSYS_VER_MAJOR=%%i"
  set __MSYS_VER_REVISION2=0
  set "__MSYS_VER_REVISION2=%%j"
)

for /F "tokens=1,* delims=." %%i in ("%__MSYS_VER_MAJOR%") do (
  set __MSYS_VER_MAJOR=0
  set "__MSYS_VER_MAJOR=%%i"
  set __MSYS_VER_MINOR=0
  set "__MSYS_VER_MINOR=%%j"
)

for /F "tokens=1,* delims=." %%i in ("%__MSYS_VER_MINOR%") do (
  set __MSYS_VER_MINOR=0
  set "__MSYS_VER_MINOR=%%i"
  set __MSYS_VER_PATCH=0
  set "__MSYS_VER_PATCH=%%j"
)

if not defined __MSYS_VER_PATCH (
  for /F "tokens=1,* delims=p" %%i in ("%__MSYS_VER_MINOR%") do (
    set __MSYS_VER_MINOR=0
    set "__MSYS_VER_MINOR=%%i"
    set __MSYS_VER_PATCH=0
    set "__MSYS_VER_PATCH=%%j"
  )
)

if not defined __MSYS_VER_PATCH (
  for /F "tokens=1,* delims=_" %%i in ("%__MSYS_VER_MINOR%") do (
    set __MSYS_VER_MINOR=0
    set "__MSYS_VER_MINOR=%%i"
    set __MSYS_VER_PATCH=0
    set "__MSYS_VER_PATCH=%%j"
  )
)

if defined __MSYS_VER_PATCH (
  for /F "tokens=1,* delims=." %%i in ("%__MSYS_VER_PATCH%") do (
    set __MSYS_VER_PATCH=0
    set "__MSYS_VER_PATCH=%%i"
    set __MSYS_VER_REVISION1=0
    set "__MSYS_VER_REVISION1=%%j"
  )
)

if not defined __MSYS_VER_REVISION1 (
  if defined __MSYS_VER_REVISION2 (
    set __MSYS_VER_REVISION1=0
    set "__MSYS_VER_REVISION1=%__MSYS_VER_REVISION2%"
    set __MSYS_VER_REVISION2=0
    set __MSYS_VER_REVISION2=
  )
)

rem echo %__MSYS_VER_MAJOR%.%__MSYS_VER_MINOR%.%__MSYS_VER_PATCH%.%__MSYS_VER_REVISION1%

if defined __MSYS_VER_MAJOR (
  set "MSYS_VER_STR=%__MSYS_VER_MAJOR%"
) else (
  set MSYS_VER_STR=0
)
if defined __MSYS_VER_MINOR (
  set "MSYS_VER_STR=%MSYS_VER_STR%.%__MSYS_VER_MINOR%"
) else (
  set "MSYS_VER_STR=%MSYS_VER_STR%.0"
)
if defined __MSYS_VER_PATCH (
  set "MSYS_VER_STR=%MSYS_VER_STR%.%__MSYS_VER_PATCH%"
) else (
  set "MSYS_VER_STR=%MSYS_VER_STR%.0"
)
if defined __MSYS_VER_REVISION1 (
  set "MSYS_VER_STR=%MSYS_VER_STR%.%__MSYS_VER_REVISION1%"
) else (
  set "MSYS_VER_STR=%MSYS_VER_STR%.0"
)
if defined __MSYS_VER_REVISION2 (
  set "MSYS_VER_STR=%MSYS_VER_STR%.%__MSYS_VER_REVISION2%"
)

:EXIT
rem Drop internal variables but use some changed value(s) for the return
endlocal & set "MSYS_VER_STR=%MSYS_VER_STR%"

exit /b 0
