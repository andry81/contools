@echo off & goto DOC_END

rem Description:
rem   Script reads a version string and sets variable RETURN_VALUE
rem     to extracted value.
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
rem %1 - Version string.
rem %2 - Flags:
rem   -d: extract digits only

rem Examples:
rem 1. call extract_version.bat "1.3-10" -d
rem    echo VER_STR=%RETURN_VALUE%
rem output: 1.3.0.10
rem
rem 2. call extract_version.bat "1.3.30c.10" -d
rem    echo VER_STR=%RETURN_VALUE%
rem output: 1.3.30.10
rem
:DOC_END

rem Drop return value
set RETURN_VALUE=

if "%~1" == "" exit /b 65

call :MAIN %%*
exit /b

:MAIN
rem Create local variable's stack
setlocal

set "VER_STR=%~1"
set "FLAGS=%~2"

rem set flag -d variable
set FLAG_NO_D=
if defined FLAGS set "FLAG_NO_D=%FLAGS:d=%"
set FLAG_D=0
if not "%FLAG_NO_D%" == "%FLAGS%" set FLAG_D=1

set __VER_MAJOR=
set __VER_MINOR=
set __VER_PATCH=
set __VER_REVISION1=
set __VER_REVISION2=

for /F "tokens=1,* delims=-"eol^= %%i in ("%VER_STR%") do (
  set "__VER_MAJOR=%%i"
  set "__VER_REVISION2=%%j"
)

for /F "tokens=1,* delims=."eol^= %%i in ("%__VER_MAJOR%") do (
  set "__VER_MAJOR=%%i"
  set "__VER_MINOR=%%j"
)

for /F "tokens=1,* delims=."eol^= %%i in ("%__VER_MINOR%") do (
  set "__VER_MINOR=%%i"
  set "__VER_PATCH=%%j"
)

if not defined __VER_PATCH (
  for /F "tokens=1,* delims=p"eol^= %%i in ("%__VER_MINOR%") do (
    set "__VER_MINOR=%%i"
    set "__VER_PATCH=%%j"
  )
)

if not defined __VER_PATCH (
  for /F "tokens=1,* delims=_"eol^= %%i in ("%__VER_MINOR%") do (
    set "__VER_MINOR=%%i"
    set "__VER_PATCH=%%j"
  )
)

if defined __VER_PATCH (
  for /F "tokens=1,* delims=."eol^= %%i in ("%__VER_PATCH%") do (
    set "__VER_PATCH=%%i"
    set "__VER_REVISION1=%%j"
  )
)

if defined __VER_REVISION1 (
  for /F "tokens=1,* delims=."eol^= %%i in ("%__VER_REVISION1%") do (
    set "__VER_REVISION1=%%i"
    if not "%%j" == "" set "__VER_REVISION2=%%j"
  )
) else (
  if defined __VER_REVISION2 (
    set "__VER_REVISION1=%__VER_REVISION2%"
    set "__VER_REVISION2="
  )
)

if not defined __VER_MAJOR set __VER_MAJOR=0
if not defined __VER_MINOR set __VER_MINOR=0
if not defined __VER_PATCH set __VER_PATCH=0
if not defined __VER_REVISION1 set __VER_REVISION1=0

if %FLAG_D%0 NEQ 0 call :FILTER_DIGITS "%__VER_MAJOR%" __VER_MAJOR
if %FLAG_D%0 NEQ 0 call :FILTER_DIGITS "%__VER_MINOR%" __VER_MINOR
if %FLAG_D%0 NEQ 0 call :FILTER_DIGITS "%__VER_PATCH%" __VER_PATCH
if %FLAG_D%0 NEQ 0 call :FILTER_DIGITS "%__VER_REVISION1%" __VER_REVISION1

if %FLAG_D%0 NEQ 0 (
  if defined __VER_REVISION2 call :FILTER_DIGITS "%__VER_REVISION2%" __VER_REVISION2
)

if not defined __VER_REVISION2 (
  set "RETURN_VALUE=%__VER_MAJOR%.%__VER_MINOR%.%__VER_PATCH%.%__VER_REVISION1%"
) else (
  set "RETURN_VALUE=%__VER_MAJOR%.%__VER_MINOR%.%__VER_PATCH%.%__VER_REVISION1%.%__VER_REVISION2%"
)

endlocal & set "RETURN_VALUE=%RETURN_VALUE%"

exit /b 0

:FILTER_DIGITS

set "__VER_STR_C=%~1"
set __OUT_VAR=%~2

rem filter only digits from string
set "__VER_STR_C_NO_D=%__VER_STR_C:0=%"
if not defined __VER_STR_C_NO_D goto FILTER_DIGITS_END
set "__VER_STR_C_NO_D=%__VER_STR_C_NO_D:1=%"
if not defined __VER_STR_C_NO_D goto FILTER_DIGITS_END
set "__VER_STR_C_NO_D=%__VER_STR_C_NO_D:2=%"
if not defined __VER_STR_C_NO_D goto FILTER_DIGITS_END
set "__VER_STR_C_NO_D=%__VER_STR_C_NO_D:3=%"
if not defined __VER_STR_C_NO_D goto FILTER_DIGITS_END
set "__VER_STR_C_NO_D=%__VER_STR_C_NO_D:4=%"
if not defined __VER_STR_C_NO_D goto FILTER_DIGITS_END
set "__VER_STR_C_NO_D=%__VER_STR_C_NO_D:5=%"
if not defined __VER_STR_C_NO_D goto FILTER_DIGITS_END
set "__VER_STR_C_NO_D=%__VER_STR_C_NO_D:6=%"
if not defined __VER_STR_C_NO_D goto FILTER_DIGITS_END
set "__VER_STR_C_NO_D=%__VER_STR_C_NO_D:7=%"
if not defined __VER_STR_C_NO_D goto FILTER_DIGITS_END
set "__VER_STR_C_NO_D=%__VER_STR_C_NO_D:8=%"
if not defined __VER_STR_C_NO_D goto FILTER_DIGITS_END
set "__VER_STR_C_NO_D=%__VER_STR_C_NO_D:9=%"

:FILTER_DIGITS_END

if defined __VER_STR_C_NO_D call set "__VER_STR_C=%%__VER_STR_C:%__VER_STR_C_NO_D%=%%"

set "%__OUT_VAR%=%__VER_STR_C%"

exit /b
