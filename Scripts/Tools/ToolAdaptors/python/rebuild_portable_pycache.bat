@echo off

rem Author: Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script for rebuilding the python cache files (*.pyc) for the portable
rem   version.

rem WARNING:
rem   1. .pyc files are cross platform
rem   2. ALL .pyc files must be the same version and must be executed by the
rem      same python version which has been used to build them!
rem   3. The last path in below examle command is a mandatory, otherwise if
rem      empty then the -d flag won't apply or if not empty then may be
rem      incorrect (the portable version does address modules internally w/o
rem      the `site-packages` subdirectory and does use relative paths!).
rem   4. You have to trace and process all dependent packages which are not
rem      a part of the `site-packages` directory on your own and call this
rem      script on them separately but with different last path in a command.

rem Examples:
rem   1. call rebuild_portable_pycache.bat "c:\Python36" "c:\Python36\Lib\site-packages"
rem   2. call rebuild_portable_pycache.bat -exclude_dirs "__pycache__|__pycache__/37" "c:\Python36" "c:\Python36\Lib\site-packages"
rem

setlocal

set "?~nx0=%~nx0"

rem script flags
set "FLAG_VALUE_EXCLUDE_DIRS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-exclude_dirs" (
    set "FLAG_VALUE_EXCLUDE_DIRS=%~2"
    shift
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

if not defined FLAG_VALUE_EXCLUDE_DIRS set "FLAG_VALUE_EXCLUDE_DIRS=__pycache__"

set "PYTHON_DIR=%~dpf1"
set "DESTDIR=%~2"
set "DESTDIR_ABS=%~dpf2"

set "PYTHON_EXE=%PYTHON_DIR%\python.exe"

if not exist "%PYTHON_EXE%" (
  echo.%~nx0: error: python.exe is not found: "%PYTHON_EXE%"
  exit /b 255
) >&2

if defined DESTDIR ^
if exist "%DESTDIR_ABS%\" goto DESTDIR_OK

(
  echo.%~nx0: error: DESTDIR is invalid: "%DESTDIR_ABS%"
  exit /b 254
) >&2

:DESTDIR_OK

rem process the root explicitly
call :CMD "%%PYTHON_EXE%%" -m compileall -f -d "" "%%DESTDIR_ABS%%" -r 0

for /F "usebackq eol=	 tokens=* delims=" %%i in (`dir /A:D /B /S "%DESTDIR_ABS%"`) do (
  set FILE_PATH=%%i
  call :REBUILD_FILE_PATH || goto :EOF
)

exit /b 0

:REBUILD_FILE_PATH
call set "FILE_PATH_FROM=%%FILE_PATH:%DESTDIR_ABS%=%%"
set "FILE_PATH_FROM=%FILE_PATH_FROM:\=/%"
set "FILE_PATH_FROM=%FILE_PATH_FROM:~1%"

:EXCLUDE_DIRS
set "NEXT_EXCLUDE_DIR=%FLAG_VALUE_EXCLUDE_DIRS%"
:EXCLUDE_DIRS_LOOP
set "EXCLUDE_DIR="
for /F "eol=	 tokens=1,* delims=|" %%i in ("%NEXT_EXCLUDE_DIR%") do (
  set EXCLUDE_DIR=%%i
  set NEXT_EXCLUDE_DIR=%%j
)
if not defined EXCLUDE_DIR goto EXCLUDE_DIRS_END
call :PREPROCESS_EXCLUDE_DIR && goto EXCLUDE_DIRS_END
goto EXCLUDE_DIRS_LOOP
:EXCLUDE_DIRS_END

if not defined FILE_PATH_FROM exit /b 0

set "FILE_PATH_FROM=%FILE_PATH_FROM:/=\%"

call :CMD "%%PYTHON_EXE%%" -m compileall -f -d "%%FILE_PATH_FROM%%" "%%DESTDIR_ABS%%\%%FILE_PATH_FROM%%" -r 0

exit /b 0

:CMD
echo.^>%*
(%*)
echo.
exit /b

:PREPROCESS_EXCLUDE_DIR
call set "FILE_PATH_FROM_PREFIX=%%FILE_PATH_FROM:%EXCLUDE_DIR%=%%"
if not defined FILE_PATH_FROM_PREFIX ( set "FILE_PATH_FROM=" & exit /b 0 )
if not "%FILE_PATH_FROM_PREFIX%%EXCLUDE_DIR%" == "%FILE_PATH_FROM%" exit /b 1
if not "%FILE_PATH_FROM_PREFIX:~-1%" == "/" exit /b 1
set "FILE_PATH_FROM="
exit /b 0
