@echo off

rem <PATH_SUBTRUCT> = <TO_PATH> - <FROM_PATH>

rem drop return value
set "RETURN_VALUE="

rem Drop last error level
cd .

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "FROM_PATH=%~dpf1"
set "TO_PATH=%~dpf2"

rem the drive must be the same before subtraction
if /i not "%FROM_PATH:~0,1%" == "%TO_PATH:~0,1%" exit /b 1

call "%%CONTOOLS_ROOT%%/strlen.bat" /v FROM_PATH
set FROM_PATH_LEN=%ERRORLEVEL%

call "%%CONTOOLS_ROOT%%/strlen.bat" /v TO_PATH
set TO_PATH_LEN=%ERRORLEVEL%

set "PATH_SUBTRUCT="

if %TO_PATH_LEN% GTR %FROM_PATH_LEN% (
  call set "PATH_SUBTRUCT=%%TO_PATH:~%FROM_PATH_LEN%%%"
)

if %FROM_PATH_LEN% GTR 0 (
  if not "%PATH_SUBTRUCT%" == "" (
    if "%PATH_SUBTRUCT:~0,1%" == "\" (
      set "PATH_SUBTRUCT=%PATH_SUBTRUCT:~1%"
    )
  )
) else (
  set "PATH_SUBTRUCT="
)

(
  endlocal
  set "RETURN_VALUE=%PATH_SUBTRUCT%"
)

if not "%RETURN_VALUE%" == "" exit /b 0

exit /b 1
