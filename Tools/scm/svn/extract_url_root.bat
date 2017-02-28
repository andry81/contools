@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script extracts URL root component from SVN URL.

rem Examples:
rem 1. call extract_url_root.bat file:///root/subdir
rem    echo "RETURN_VALUE=%RETURN_VALUE%"
rem 2. call extract_url_root.bat https://root/subdir
rem    echo "RETURN_VALUE=%RETURN_VALUE%"

set "RETURN_VALUE="

rem Drop last error level
cd .

setlocal

set "URL=%~1"

set "URL_SCHEME="
set "URL_PATH="
for /F "eol= tokens=1,* delims=:" %%i in ("%URL%") do (
  set "URL_SCHEME=%%i"
  set "URL_PATH=%%j"
)

if "%URL_SCHEME%" == "file" (
  set "URL_PATH=%URL_PATH:~3%"
) else (
  set "URL_PATH=%URL_PATH:~2%"
)

for /F "eol= tokens=1,* delims=/" %%i in ("%URL_PATH%") do (
  set "URL_DOMAIN=%%i"
)

(
  endlocal
  if "%URL_SCHEME%" == "file" (
    set "RETURN_VALUE=%URL_SCHEME%:///%URL_DOMAIN%"
  ) else (
    set "RETURN_VALUE=%URL_SCHEME%://%URL_DOMAIN%"
  )
)

exit /b 0
