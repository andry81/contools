@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script do SVN update to a file directory.

rem Examples:
rem 1. call svn_up.bat branch/current https://blabla/repo/branch/current my_branch

rem Drop last error level
cd .

setlocal

echo.%~nx0 %*
echo.

call "%%~dp0__init__.bat" || goto :EOF

set "?~nx0=%~nx0"

rem svn flags
set "SVN_CMD_FLAG_ARGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  if "%FLAG%" == "-r" (
    set SVN_CMD_FLAG_ARGS=%SVN_CMD_FLAG_ARGS%%1 %2
    shift
  ) else (
    set SVN_CMD_FLAG_ARGS=%SVN_CMD_FLAG_ARGS%%1 
  )

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "SVN_BASE_PATH=%~dpf1"
set "SVN_URL_PATH=%~2"
set "SVN_REF_PATH=%~3"

if not "%SVN_BASE_PATH%" == "" set "SVN_BASE_PATH=%SVN_BASE_PATH:\=/%"
if not "%SVN_URL_PATH%" == "" set "SVN_URL_PATH=%SVN_URL_PATH:\=/%"
if not "%SVN_REF_PATH%" == "" set "SVN_REF_PATH=%SVN_REF_PATH:\=/%"

if not "%SVN_URL_PATH%" == "" ^
if "%SVN_URL_PATH:~-1%" == "/" set "SVN_URL_PATH=%SVN_URL_PATH:~0,-1%"

rem parse 3 arguments into 2: local path + svn url
set "SVN_UP_DIR=%SVN_BASE_PATH%"

if not "%SVN_REF_PATH%" == "" goto SVN_REF_PATH_NOT_EMPTY
goto SVN_REF_PATH_EMPTY

:SVN_REF_PATH_NOT_EMPTY
set "SVN_UP_DIR=%SVN_UP_DIR%/%SVN_REF_PATH%"
goto SVN_REF_PATH_END

:SVN_REF_PATH_EMPTY
if not "%SVN_URL_PATH%" == "" call :GET_URL_FILE_NAME "%%SVN_URL_PATH%%"
if not "%SVN_URL_PATH%" == "" set "SVN_UP_DIR=%SVN_UP_DIR%/%URL_FILE_NAME%"

:SVN_REF_PATH_END
echo."%SVN_UP_DIR%" ^<- "%SVN_URL_PATH%" ^("%SVN_REF_PATH%"^)

if not exist "%SVN_UP_DIR%\" (
  echo.%~nx0: error: could not SVN update, because directory does not exist: "%SVN_UP_DIR%"
  exit /b 254
) >&2

pushd "%SVN_UP_DIR%" || (
  echo.%~nx0: error: could not SVN update, because could not make directory current: "%SVN_UP_DIR%"
  exit /b 253
) >&2

svn up %SVN_CMD_FLAG_ARGS%

popd

goto :EOF

:GET_URL_FILE_NAME
set "SVN_URL_PATH_PREFIX=%~1"

call "%%SVNCMD_TOOLS_ROOT%%/make_url_canonical.bat" "%%SVN_URL_PATH_PREFIX%%"
set "SVN_URL_PATH_PREFIX=%RETURN_VALUE%"

rem strip until empty
:GET_URL_FILE_NAME_STRIP_LOOP
if not "%SVN_URL_PATH_PREFIX%" == "" set "SVN_URL_PATH_SUFFIX=%SVN_URL_PATH_PREFIX:*/=%"

if not "%SVN_URL_PATH_SUFFIX%" == "" ^
if not "%SVN_URL_PATH_PREFIX%" == "%SVN_URL_PATH_SUFFIX%" (
  set "SVN_URL_PATH_PREFIX=%SVN_URL_PATH_SUFFIX%"

  goto GET_URL_FILE_NAME_STRIP_LOOP
)

set "URL_FILE_NAME=%SVN_URL_PATH_PREFIX%"

exit /b 0
