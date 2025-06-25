@echo off & goto DOC_END

rem Description:
rem   Script reads a shortcut target path property.
rem   OS: Windows XP+

rem USAGE:
rem   read_shortcut_target_path.bat [<Flags>] [--] <ShortcutFile>

rem <Flags>:
rem   --
rem     Stop flags parse.
rem
rem   -use_extprop
rem     Use `ExtendedProperty` method through the `read_path_props.vbs` script
rem     instead of `read_shortcut.vbs` script.
rem     Can not be used together with `-use_getlink` flag.
rem
rem   -use_getlink
rem     Use `GetLink` property through the `read_shortcut.vbs` script instead
rem     of `CreateShortcut` method (same script).
rem     Can not be used together with `-use_extprop` flag.
rem
rem   -retry_extended_property
rem     Retry by `ExtendedProperty` method through the `read_path_props.vbs`
rem     script if `read_shortcut.vbs` script is returted empty result or an
rem     error.
rem
rem   -print-stdout| -p
rem     Print property `name=value` expression after each read from stdout of
rem     all inner script calls.

rem <ShortcutFile>:
rem   Path to shortcut file.

rem CAUTION:
rem   Base `CreateShortcut` method does not support all Unicode characters.
rem   Use `GetLink` property (`-use_getlink` flag) instead to workaround that.
:DOC_END

rem drop return value
set "RETURN_VALUE="

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem script flags
set FLAG_SHIFT=0
set FLAG_SKIP=0
set FLAG_USE_EXTENDED_PROPERTY=0
set FLAG_USE_GETLINK=0
set FLAG_RETRY_EXTENDED_PROPERTY=0
set FLAG_PRINT_STDOUT=0
set "READ_SHORTCUT_BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-use_extprop" (
    set FLAG_USE_EXTENDED_PROPERTY=1
  ) else if "%FLAG%" == "-use_getlink" (
    set FLAG_USE_GETLINK=1
    set READ_SHORTCUT_BARE_FLAGS=%READ_SHORTCUT_BARE_FLAGS% -g
    set /A FLAG_SKIP+=1
  ) else if "%FLAG%" == "-retry_extended_property" (
    set FLAG_RETRY_EXTENDED_PROPERTY=1
  ) else if "%FLAG%" == "-print-stdout" (
    set FLAG_PRINT_STDOUT=1
  ) else if "%FLAG%" == "-p" (
    set FLAG_PRINT_STDOUT=1
  ) else if not "%FLAG%" == "--" (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

if %FLAG_USE_EXTENDED_PROPERTY%%FLAG_USE_GETLINK% EQU 11 (
  echo;%?~%: error: `-use_extprop` flag is mixed with `-use_getlink` flag.
  exit /b 255
) >&2

rem CAUTION:
rem   Below lines of code has a copy in the `update_shortcut_props_from_dir.bat` script.
rem   In case of change must be merged between copies.
rem

set "TARGET_PATH_TEMP_STDOUT_FILE="
set "TARGET_PATH_TEMP_STDERR_FILE="

rem CAUTION:
rem   We must use temporary file with BOM header to retain the Unicode encoding.
rem
if defined SCRIPT_TEMP_CURRENT_DIR (
  if not defined TARGET_PATH_STDOUT_FILE set "TARGET_PATH_TEMP_STDOUT_FILE=%SCRIPT_TEMP_CURRENT_DIR%\read_shortcut_target_path.stdout.%RANDOM%-%RANDOM%.txt"
  if not defined TARGET_PATH_STDERR_FILE set "TARGET_PATH_TEMP_STDERR_FILE=%SCRIPT_TEMP_CURRENT_DIR%\read_shortcut_target_path.stderr.%RANDOM%-%RANDOM%.txt"
) else (
  if not defined TARGET_PATH_STDOUT_FILE set "TARGET_PATH_TEMP_STDOUT_FILE=%TEMP%\read_shortcut_target_path.stdout.%RANDOM%-%RANDOM%.txt"
  if not defined TARGET_PATH_STDERR_FILE set "TARGET_PATH_TEMP_STDERR_FILE=%TEMP%\read_shortcut_target_path.stderr.%RANDOM%-%RANDOM%.txt"
)

if not defined TARGET_PATH_STDOUT_FILE set "TARGET_PATH_STDOUT_FILE=%TARGET_PATH_TEMP_STDOUT_FILE%"
if not defined TARGET_PATH_STDERR_FILE set "TARGET_PATH_STDERR_FILE=%TARGET_PATH_TEMP_STDERR_FILE%"

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

if defined TARGET_PATH_TEMP_STDOUT_FILE del /F /Q /A:-D "%TARGET_PATH_TEMP_STDOUT_FILE%" >nul 2>nul
if defined TARGET_PATH_TEMP_STDERR_FILE del /F /Q /A:-D "%TARGET_PATH_TEMP_STDERR_FILE%" >nul 2>nul

if defined RETURN_VALUE endlocal & set "RETURN_VALUE=%RETURN_VALUE%" & exit /b 0

exit /b %LAST_ERROR%

:MAIN
rem UTF-16LE BOM
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%TARGET_PATH_STDOUT_FILE%" /B /Y >nul 2>nul
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%TARGET_PATH_STDERR_FILE%" /B /Y >nul 2>nul
rem UTF-8 BOM
rem set /P =﻿<nul > "%TARGET_PATH_STDOUT_FILE%"

if %FLAG_USE_EXTENDED_PROPERTY% NEQ 0 goto USE_EXTENDED_PROPERTY

set /A FLAG_SKIP+=6
call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip %%FLAG_SKIP%% "%%FLAG_SHIFT%%" "%%SystemRoot%%\System32\cscript.exe" //NOLOGO //U "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_shortcut.vbs"%%READ_SHORTCUT_BARE_FLAGS%% -p TargetPath -- %%* >> "%TARGET_PATH_STDOUT_FILE%" 2>> "%TARGET_PATH_STDERR_FILE%"

rem CAUTION:
rem   Exit code can be zero in case of empty TargetPath.
set LAST_ERROR=%ERRORLEVEL%

rem NOTE: `type` respects UTF-16LE file with BOM header

set IS_STDOUT_PRINTED=0
for /F "usebackq tokens=1,* delims=="eol^= %%i in (`@type "%%TARGET_PATH_STDOUT_FILE%%"`) do set "RETURN_VALUE=%%j" & if %FLAG_PRINT_STDOUT% NEQ 0 set "IS_STDOUT_PRINTED=1" & echo;%%i=%%j
if %FLAG_PRINT_STDOUT% NEQ 0 if %IS_STDOUT_PRINTED% EQU 0 echo;TargetPath=

type "%TARGET_PATH_STDERR_FILE%" >&2

if %FLAG_RETRY_EXTENDED_PROPERTY% EQU 0 exit /b %LAST_ERROR%
if defined RETURN_VALUE exit /b %LAST_ERROR%

rem Retry on `ExtendedProperty` method.

rem UTF-16LE BOM
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%TARGET_PATH_STDOUT_FILE%" /B /Y >nul 2>nul
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%TARGET_PATH_STDERR_FILE%" /B /Y >nul 2>nul

:USE_EXTENDED_PROPERTY
call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 8 "%%FLAG_SHIFT%%" "%%SystemRoot%%\System32\cscript.exe" //NOLOGO //U "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_path_props.vbs" -v -x -lr -- LinkTarget %%* >> "%TARGET_PATH_STDOUT_FILE%" 2>> "%TARGET_PATH_STDERR_FILE%"
set LAST_ERROR=%ERRORLEVEL%

rem NOTE: `type` respects UTF-16LE file with BOM header

set IS_STDOUT_PRINTED=0
for /F "usebackq tokens=* delims="eol^= %%i in (`@type "%%TARGET_PATH_STDOUT_FILE%%"`) do set "RETURN_VALUE=%%i" & if %FLAG_PRINT_STDOUT% NEQ 0 set "IS_STDOUT_PRINTED=1" & echo;LinkTarget=%%i
if %FLAG_PRINT_STDOUT% NEQ 0 if %IS_STDOUT_PRINTED% EQU 0 echo;LinkTarget=

type "%TARGET_PATH_STDERR_FILE%" >&2

exit /b %LAST_ERROR%
