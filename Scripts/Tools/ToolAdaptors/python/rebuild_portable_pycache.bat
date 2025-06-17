@echo off & goto DOC_END

rem Description:
rem   Script for rebuilding the python cache files (*.pyc) for the portable
rem   version.

rem WARNING:
rem   1. .pyc files are cross platform
rem   2. ALL .pyc files must be the same version and must be executed by the
rem      same python version which has been used to build them!
rem   3. The last path in below example command is a mandatory, otherwise if
rem      empty then the -d flag won't apply or if not empty then may be
rem      incorrect (the portable version does address modules internally w/o
rem      the `site-packages` subdirectory and does use relative paths!).
rem   4. You have to trace and process all dependent packages which are not
rem      a part of the `site-packages` directory on your own and call this
rem      script on them separately but with different last path in a command.

rem CAUTION:
rem   1. Because all the .pyc files in the destination directory will be
rem      rebuilt, then you have to make a copy of the destination directory
rem      (in examples below this is the `site-packages` directory) on yourself
rem      to avoid any changed in the original directory. To do so just do copy
rem      the original directory and run the script on the copied one instead of
rem      on the original.
rem      This will leave the original directory .pyc files intact after the
rem      rebuild which is might be important for debugging from installed
rem      python.
rem   2. Some modules still can has absolute paths in their .pyc files even
rem      after the full recompilation.
rem      For example, the PyInstaller will use them. But because, the
rem      PyInstaller is not intended to be used as a portable module then it is
rem      not might be so important.

rem Examples:
rem   1. call rebuild_portable_pycache.bat "c:\Python36" "c:\Python36\Lib\site-packages"
rem   2. call rebuild_portable_pycache.bat -exclude_dirs "__pycache__|__pycache__/37" "c:\Python36" "c:\Python36\Lib\site-packages"
rem
:DOC_END

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

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
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

if not defined FLAG_VALUE_EXCLUDE_DIRS set "FLAG_VALUE_EXCLUDE_DIRS=__pycache__"

set "PYTHON_DIR=%~f1"
set "DESTDIR=%~2"
set "DESTDIR_ABS=%~f2"

set "PYTHON_EXE=%PYTHON_DIR%\python.exe"

if not exist "%PYTHON_EXE%" (
  echo;%?~%: error: python.exe is not found: "%PYTHON_EXE%"
  exit /b 255
) >&2

if defined DESTDIR ^
if exist "%DESTDIR_ABS%\*" goto DESTDIR_OK

(
  echo;%?~%: error: DESTDIR is invalid: "%DESTDIR_ABS%"
  exit /b 254
) >&2

:DESTDIR_OK

rem process the root explicitly
call :CMD "%%PYTHON_EXE%%" -m compileall -f -d "" "%%DESTDIR_ABS%%" -r 0

rem CAUTION:
rem   1. If a variable is empty, then it would not be expanded in the `cmd.exe`
rem      command line or in the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement.
rem   2. The `cmd.exe` command line or the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement does expand twice.
rem
rem   We must expand the command line into a variable to avoid these above.
rem
set ?.=@dir "%DESTDIR_ABS%" /A:D /B /O:N /S 2^>nul

for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
  set FILE_PATH=%%i
  call :REBUILD_FILE_PATH || exit /b
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
for /F "tokens=1,* delims=|"eol^= %%i in ("%NEXT_EXCLUDE_DIR%") do (
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
echo;^>%*
(
  %*
)
echo;
exit /b

:PREPROCESS_EXCLUDE_DIR
call set "FILE_PATH_FROM_PREFIX=%%FILE_PATH_FROM:%EXCLUDE_DIR%=%%"
if not defined FILE_PATH_FROM_PREFIX set "FILE_PATH_FROM=" & exit /b 0
if not "%FILE_PATH_FROM_PREFIX%%EXCLUDE_DIR%" == "%FILE_PATH_FROM%" exit /b 1
if not "%FILE_PATH_FROM_PREFIX:~-1%" == "/" exit /b 1
set "FILE_PATH_FROM="
exit /b 0
