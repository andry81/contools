@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script extracts `Last Changed Version` from svnversion dump.

rem Examples:
rem 1. call extract_last_changed_rev.bat 100 100:120M
rem    rem RETURN_VALUE=120
rem    echo "RETURN_VALUE=%RETURN_VALUE%"
rem 2. call extract_last_changed_rev.bat 120 130
rem    rem RETURN_VALUE=120
rem    echo "RETURN_VALUE=%RETURN_VALUE%"
rem 3. call extract_last_changed_rev.bat 100 100:120M
rem    rem RETURN_VALUE=120
rem    echo "RETURN_VALUE=%RETURN_VALUE%"
rem 4. call extract_last_changed_rev.bat 120 130
rem    rem RETURN_VALUE=130
rem    echo "RETURN_VALUE=%RETURN_VALUE%"

set "RETURN_VALUE="

rem Drop last error level
cd .

setlocal

set "?~nx0=%~nx0"

rem script flags
set FLAG_SVN_USE_CURRENT_REV=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  if "%FLAG%" == "-crev" (
    set FLAG_SVN_USE_CURRENT_REV=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

set "INFO_LAST_CHANGED_REV=%~1"
set "SVNVERSION_VALUE=%~2"

if "%INFO_LAST_CHANGED_REV%" == "" set INFO_LAST_CHANGED_REV=0

set "SVNVERSION_LAST_CHANGED_REV="
set "SVNVERSION_LAST_MIXED_REV="
for /F "eol= tokens=1,2,* delims=:" %%i in ("%SVNVERSION_VALUE%") do (
  set "SVNVERSION_LAST_CHANGED_REV=%%i"
  set "SVNVERSION_LAST_MIXED_REV=%%j"
)

rem parse all revisions before compare them

set INDEX=0
:INFO_LAST_CHANGED_REV_LOOP
call :LAST_MIXED_REV_IS_NUMBER "%%INFO_LAST_CHANGED_REV:~%INDEX%,1%%"
if %ERRORLEVEL% EQU 0 (
  set /A INDEX+=1
  goto INFO_LAST_CHANGED_REV_LOOP
)

call set "INFO_LAST_CHANGED_REV_NUM=%%INFO_LAST_CHANGED_REV:~0,%INDEX%%%"

set INDEX=0
:SVNVERSION_LAST_CHANGED_REV_LOOP
call :LAST_MIXED_REV_IS_NUMBER "%%SVNVERSION_LAST_CHANGED_REV:~%INDEX%,1%%"
if %ERRORLEVEL% EQU 0 (
  set /A INDEX+=1
  goto SVNVERSION_LAST_CHANGED_REV_LOOP
)

call set "SVNVERSION_LAST_CHANGED_REV_NUM=%%SVNVERSION_LAST_CHANGED_REV:~0,%INDEX%%%"

if "%SVNVERSION_LAST_MIXED_REV%" == "" set SVNVERSION_LAST_MIXED_REV=0

set INDEX=0
:SVNVERSION_LAST_MIXED_REV_LOOP
call :LAST_MIXED_REV_IS_NUMBER "%%SVNVERSION_LAST_MIXED_REV:~%INDEX%,1%%"
if %ERRORLEVEL% EQU 0 (
  set /A INDEX+=1
  goto SVNVERSION_LAST_MIXED_REV_LOOP
)

call set "SVNVERSION_LAST_MIXED_REV_NUM=%%SVNVERSION_LAST_MIXED_REV:~0,%INDEX%%%"

rem echo %INFO_LAST_CHANGED_REV_NUM% %SVNVERSION_LAST_CHANGED_REV_NUM% %SVNVERSION_LAST_MIXED_REV_NUM%

if %SVNVERSION_LAST_MIXED_REV_NUM% NEQ 0 goto USE_LAST_MIXED_REV

rem use info or svnversion `Last Changed Rev`
if %INFO_LAST_CHANGED_REV_NUM% NEQ 0 (
  if %FLAG_SVN_USE_CURRENT_REV% EQU 0 (
    if %SVNVERSION_LAST_CHANGED_REV_NUM% GTR %INFO_LAST_CHANGED_REV_NUM% goto INFO_LAST_CHANGED_REV_NUM
  ) else (
    if %INFO_LAST_CHANGED_REV_NUM% GEQ %SVNVERSION_LAST_CHANGED_REV_NUM% goto INFO_LAST_CHANGED_REV_NUM
  )
)

(
  endlocal
  set "RETURN_VALUE=%SVNVERSION_LAST_CHANGED_REV_NUM%"
)
exit /b 0

:INFO_LAST_CHANGED_REV_NUM
(
  endlocal
  set "RETURN_VALUE=%INFO_LAST_CHANGED_REV_NUM%"
)
exit /b 0

:USE_LAST_MIXED_REV
rem use svnversion `Last Mixed Rev` or info `Last Changed Rev`
if %SVNVERSION_LAST_MIXED_REV_NUM% GEQ %INFO_LAST_CHANGED_REV_NUM% (
  endlocal
  set "RETURN_VALUE=%SVNVERSION_LAST_MIXED_REV_NUM%"
) else (
  endlocal
  set "RETURN_VALUE=%INFO_LAST_CHANGED_REV_NUM%"
)

exit /b 0

:LAST_MIXED_REV_IS_NUMBER
for %%i in (0 1 2 3 4 5 6 7 8 9) do if "%%i" == "%~1" exit /b 0
exit /b 1
