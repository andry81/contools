@echo off & goto DOC_END

rem <TO_PATH_SUFFIX> = <TO_PATH> - <FROM_PATH>
:DOC_END

rem drop return value
set "RETURN_VALUE="

setlocal

call "%%~dp0__init__.bat" || exit /b

set "FROM_PATH=%~1"
set "TO_PATH=%~2"

rem convert all back slashes
set "FROM_PATH=%FROM_PATH:\=/%"
set "TO_PATH=%TO_PATH:\=/%"

rem drop last slash character
if "%FROM_PATH:~-1%" == "/" set "FROM_PATH=%FROM_PATH:~0,-1%"
if "%TO_PATH:~-1%" == "/" set "TO_PATH=%TO_PATH:~0,-1%"

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v FROM_PATH
set FROM_PATH_LEN=%ERRORLEVEL%

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v TO_PATH
set TO_PATH_LEN=%ERRORLEVEL%

if %TO_PATH_LEN% LSS %FROM_PATH_LEN% exit /b 1

call set "TO_PATH_PREFIX=%%TO_PATH:~0,%FROM_PATH_LEN%%%"

rem both paths must has the same common part
if /i not "%TO_PATH_PREFIX%" == "%FROM_PATH%" exit /b 1

call set "TO_PATH_SUFFIX=%%TO_PATH:~%FROM_PATH_LEN%%%"

if %FROM_PATH_LEN% GTR 0 (
  if defined TO_PATH_SUFFIX (
    if "%TO_PATH_SUFFIX:~0,1%" == "/" (
      set "TO_PATH_SUFFIX=%TO_PATH_SUFFIX:~1%"
    ) else set "TO_PATH_SUFFIX="
  )
) else set "TO_PATH_SUFFIX="

(
  endlocal
  set "RETURN_VALUE=%TO_PATH_SUFFIX%"
  if defined RETURN_VALUE exit /b 0
  if %FROM_PATH_LEN% EQU %TO_PATH_LEN% exit /b 0
)

exit /b 1
