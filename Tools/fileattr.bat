@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script gets file attributes from relative or absolute path.
rem   If success script sets variable FILE_ATTR and returns 0.
rem   Otherwise returns non zero error level.

rem Command arguments:
rem %1 - Path.

rem Examples:
rem 1. call fileattr.bat "%WINDIR%\system32\cmd.exe"
rem    echo FILE_ATTR=%FILE_ATTR%

rem Drop variable FILE_ATTR.
(
  set FILE_ATTR=0
  set FILE_ATTR=
)

if "%~1" == "" exit /b 65

rem Drop last error level.
cd .

if exist "%~1" (
  set "FILE_ATTR=%~a1"
) else (
  exit /b 1
)
