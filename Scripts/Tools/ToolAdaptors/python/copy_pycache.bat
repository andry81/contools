@echo off & goto DOC_END

rem Description:
rem   Script for __pycache__ (.pyc) files copy from source directory into
rem   target one with preserve of original directory structure with or without
rem   __pycache__ directory prefix and .pyc files name suffix.
rem
rem   This script is useful to prepare a copy of library .pyc files for the
rem   python integration package, where all python files are in a single
rem   directory and the site packages are in an archive file.
rem
rem Flags:
rem   - -prefix_dirs: |-separated list of .pyc files prefix directories.
rem       By default the "__pycache__" is used. Can has directory sub paths,
rem       like "__pycache__/dummy" or "dummy/__pycache__".
rem   - -suffix_names: |-separated list of .pyc files suffix names.
rem       By default is empty. Can be, for example: ".cpython-36".
rem
rem Examples:
rem   1. mkdir "c:\Python36\Lib\site-packages.pycache_copy"
rem      call copy_pycache.bat "c:\Python36\Lib\site-packages" "c:\Python36\Lib\site-packages.pycache_copy"
rem   2. mkdir "c:\Python36\Lib\site-packages.pycache_copy"
rem      call copy_pycache.bat -prefix_dirs "__pycache__|__pycache__/37" -suffix_names ".cpython-37" "c:\Python36\Lib\site-packages" "c:\Python36\Lib\site-packages.pycache_copy"
rem   3. mkdir "c:\Python36\Lib\site-packages.pycache_copy"
rem      call copy_pycache.bat -prefix_dirs "" -suffix_names "" "c:\Python36\Lib\site-packages" "c:\Python36\Lib\site-packages.pycache_copy"
rem
:DOC_END

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem script flags
set "FLAG_VALUE_PREFIX_DIRS="
set "FLAG_VALUE_SUFFIX_NAMES="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-prefix_dirs" (
    set "FLAG_VALUE_PREFIX_DIRS=%~2"
    shift
    shift
  ) else if "%FLAG%" == "-suffix_names" (
    set "FLAG_VALUE_SUFFIX_NAMES=%~2"
    shift
    shift
  ) else (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

if not defined FLAG_VALUE_PREFIX_DIRS set "FLAG_VALUE_PREFIX_DIRS=__pycache__"
if not defined FLAG_VALUE_SUFFIX_NAMES set "FLAG_VALUE_SUFFIX_NAMES=.cpython-39|.cpython-38|.cpython-37|.cpython-36|.cpython-35|.cpython-34|.cpython-33|.cpython-32|.cpython-31|.cpython-30"

set "SOURCE_DIR=%~1"
set "SOURCE_DIR_ABS=%~f1"
set "TARGET_DIR=%~2"
set "TARGET_DIR_ABS=%~f2"

if not defined SOURCE_DIR goto NO_SOURCE_DIR
if not exist "%SOURCE_DIR%\*" goto NO_SOURCE_DIR

goto NO_SOURCE_DIR_END
:NO_SOURCE_DIR
(
  echo;%?~%: error: source directory does not exist: "%SOURCE_DIR%".
  exit /b 1
) >&2
:NO_SOURCE_DIR_END

if not defined TARGET_DIR goto NO_TARGET_DIR
if not exist "%TARGET_DIR%\*" goto NO_TARGET_DIR

goto NO_TARGET_DIR_END
:NO_TARGET_DIR
(
  echo;%?~%: error: target directory does not exist: "%TARGET_DIR%".
  exit /b 2
) >&2
:NO_TARGET_DIR_END

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
set ?.=@dir "%SOURCE_DIR%\*.pyc." /A:-D /B /O:N /S 2^>nul

for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
  set FILE_PATH=%%i
  call :COPY_FILE_PATH || exit /b
)

exit /b 0

:COPY_FILE_PATH
call set "FILE_PATH_FROM=%%FILE_PATH:%SOURCE_DIR_ABS%=%%"
set "FILE_PATH_FROM=%FILE_PATH_FROM:\=/%"
set "FILE_PATH_FROM=%FILE_PATH_FROM:~1%"

call :SPLIT_PATHSTR "%%FILE_PATH_FROM%%"
set "DIR_PATH_TO=%DIR_PATH%"
set "FILE_PATH_TO=%FILE_PATH%"

if not defined DIR_PATH_TO goto PREFIX_DIRS_END

:PREFIX_DIRS
set "NEXT_PREFIX_DIR=%FLAG_VALUE_PREFIX_DIRS%"
:PREFIX_DIRS_LOOP
set "PREFIX_DIR="
for /F "tokens=1,* delims=|"eol^= %%i in ("%NEXT_PREFIX_DIR%") do (
  set PREFIX_DIR=%%i
  set NEXT_PREFIX_DIR=%%j
)
if not defined PREFIX_DIR goto PREFIX_DIRS_END
call :PREPROCESS_PREFIX_DIR && goto PREFIX_DIRS_END
goto PREFIX_DIRS_LOOP
:PREFIX_DIRS_END

if defined DIR_PATH_TO set "DIR_PATH_TO=%DIR_PATH_TO:/=\%\"

if not defined FILE_PATH_TO goto SUFFIX_NAMES_END

:SUFFIX_NAMES
set "NEXT_SUFFIX_NAME=%FLAG_VALUE_SUFFIX_NAMES%"
:SUFFIX_NAMES_LOOP
set "SUFFIX_NAME="
for /F "tokens=1,* delims=|"eol^= %%i in ("%NEXT_SUFFIX_NAME%") do (
  set SUFFIX_NAME=%%i
  set NEXT_SUFFIX_NAME=%%j
)
if not defined SUFFIX_NAME goto SUFFIX_NAMES_END
call :PREPROCESS_SUFFIX_NAME && goto SUFFIX_NAMES_END
goto SUFFIX_NAMES_LOOP
:SUFFIX_NAMES_END

:CREATE_DIR_PATH_TO
if not exist "%TARGET_DIR_ABS%\%DIR_PATH_TO%" mkdir "%TARGET_DIR_ABS%\%DIR_PATH_TO%"
echo "%SOURCE_DIR%\%FILE_PATH_FROM:/=\%" -^> "%TARGET_DIR%\%DIR_PATH_TO%%FILE_PATH_TO%"
copy /B /Y "%SOURCE_DIR%\%FILE_PATH_FROM:/=\%" "%TARGET_DIR%\%DIR_PATH_TO%%FILE_PATH_TO%" >nul
exit /b

:PREPROCESS_SUFFIX_NAME
call set "FILE_PATH_TO_PREFIX=%%FILE_PATH_TO:%SUFFIX_NAME%.pyc=%%"
if not defined FILE_PATH_TO_PREFIX exit /b 1
if not "%FILE_PATH_TO_PREFIX%%SUFFIX_NAME%.pyc" == "%FILE_PATH_TO%" exit /b 1
set "FILE_PATH_TO=%FILE_PATH_TO_PREFIX%.pyc"
exit /b 0

:PREPROCESS_PREFIX_DIR
call set "DIR_PATH_TO_PREFIX=%%DIR_PATH_TO:%PREFIX_DIR%=%%"
if not defined DIR_PATH_TO_PREFIX set "DIR_PATH_TO=" & exit /b 0
if not "%DIR_PATH_TO_PREFIX%%PREFIX_DIR%" == "%DIR_PATH_TO%" exit /b 1
if not "%DIR_PATH_TO_PREFIX:~-1%" == "/" exit /b 1
set "DIR_PATH_TO=%DIR_PATH_TO_PREFIX:~0,-1%"
exit /b 0

:SPLIT_PATHSTR
set "DIR_PATH="
set "FILE_PATH=%~1"
set "NEXT_FILE_PATH=%FILE_PATH%"

:SPLIT_PATHSTR_LOOP
set "PREV_DIR="
for /F "tokens=1,* delims=/"eol^= %%i in ("%NEXT_FILE_PATH%") do (
  set PREV_DIR_PATH=%%i
  set NEXT_FILE_PATH=%%j
)
if not defined NEXT_FILE_PATH exit /b 0

set "FILE_PATH=%NEXT_FILE_PATH%"

if defined DIR_PATH (
  set "DIR_PATH=%DIR_PATH%/%PREV_DIR_PATH%"
) else (
  set "DIR_PATH=%PREV_DIR_PATH%"
)
goto SPLIT_PATHSTR_LOOP
