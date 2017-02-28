@echo off

rem <PATH_SUBTRUCT> = <TO_PATH> - <FROM_PATH>

rem drop return value
set "RETURN_VALUE="

rem Drop last error level
cd .

setlocal

set "FROM_PATH=%~dpf1"
set "TO_PATH=%~dpf2"

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0"
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

call "%%TOOLS_PATH%%\strlen.bat" /v FROM_PATH
set /A FROM_PATH_LEN=%ERRORLEVEL%

call "%%TOOLS_PATH%%\strlen.bat" /v TO_PATH
set /A TO_PATH_LEN=%ERRORLEVEL%

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
