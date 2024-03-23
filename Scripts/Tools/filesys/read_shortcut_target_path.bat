@echo off

rem Description:
rem   Script reads a shortcut target path property.
rem   OS: Windows XP+

rem USAGE:
rem   read_shortcut_target_path.bat [<Flags>] [--] <ShortcutFile>

rem <Flags>:
rem   --
rem     Stop flags parse.
rem
rem   -use_extended_property
rem     Use `ExtendedProperty` method through the `read_path_props.vbs` script
rem     instead of `read_shortcut.vbs` script.
rem
rem   -retry_extended_property
rem     Retry on `ExtendedProperty` method through the `read_path_props.vbs`
rem     script if `read_shortcut.vbs` script is returted empty result or an
rem     error.

rem <ShortcutFile>:
rem   Path to shortcut file.

rem drop return value
set "RETURN_VALUE="

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem script flags
set FLAG_SHIFT=0
set FLAG_USE_EXTENDED_PROPERTY=0
set FLAG_RETRY_EXTENDED_PROPERTY=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-use_extended_property" (
    set FLAG_USE_EXTENDED_PROPERTY=1
  ) else if "%FLAG%" == "-retry_extended_property" (
    set FLAG_RETRY_EXTENDED_PROPERTY=1
  ) else if "%FLAG%" == "--" (
    shift
    set "FLAG="
    goto FLAGS_LOOP_END
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  goto FLAGS_LOOP
)

:FLAGS_LOOP_END

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

if defined TARGET_PATH_TEMP_STDOUT_FILE del /F /Q /A:-D "%TARGET_PATH_TEMP_STDOUT_FILE%" >nul 2>nul
if defined TARGET_PATH_TEMP_STDERR_FILE del /F /Q /A:-D "%TARGET_PATH_TEMP_STDERR_FILE%" >nul 2>nul

if defined RETURN_VALUE ( endlocal & set "RETURN_VALUE=%RETURN_VALUE%" & exit /b 0 )

exit /b 1

:MAIN
rem UTF-16LE BOM
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%TARGET_PATH_STDOUT_FILE%" /B /Y >nul 2>nul
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%TARGET_PATH_STDERR_FILE%" /B /Y >nul 2>nul
rem UTF-8 BOM
rem set /P =﻿<nul > "%TARGET_PATH_STDOUT_FILE%"

(
  if %FLAG_USE_EXTENDED_PROPERTY% EQU 0 (
    call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 6 "%%FLAG_SHIFT%%" "%%SystemRoot%%\System32\cscript.exe" //NOLOGO //U "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_shortcut.vbs" -p TargetPath -- %%* || if %FLAG_RETRY_EXTENDED_PROPERTY% EQU 0 exit /b
  ) else call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 8 "%%FLAG_SHIFT%%" "%%SystemRoot%%\System32\cscript.exe" //NOLOGO //U "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_path_props.vbs" -v -x -lr -- LinkTarget %%* || exit /b
) >> "%TARGET_PATH_STDOUT_FILE%" 2>> "%TARGET_PATH_STDERR_FILE%"

rem NOTE: `type` respects UTF-16LE file with BOM header
type "%TARGET_PATH_STDERR_FILE%" >&2

if %FLAG_USE_EXTENDED_PROPERTY% EQU 0 (
  for /F "usebackq eol= tokens=1,* delims==" %%i in (`@type "%TARGET_PATH_STDOUT_FILE%"`) do set "RETURN_VALUE=%%j"
) else for /F "usebackq eol= tokens=* delims=" %%i in (`@type "%TARGET_PATH_STDOUT_FILE%"`) do set "RETURN_VALUE=%%i"

if %FLAG_USE_EXTENDED_PROPERTY% NEQ 0 exit /b
if %FLAG_RETRY_EXTENDED_PROPERTY% EQU 0 exit /b
if defined RETURN_VALUE exit /b

rem Retry on `ExtendedProperty` method.

rem UTF-16LE BOM
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%TARGET_PATH_STDOUT_FILE%" /B /Y >nul 2>nul
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%TARGET_PATH_STDERR_FILE%" /B /Y >nul 2>nul

(
  call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 8 "%%FLAG_SHIFT%%" "%%SystemRoot%%\System32\cscript.exe" //NOLOGO //U "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_path_props.vbs" -v -x -lr -- LinkTarget %%* || exit /b
) >> "%TARGET_PATH_STDOUT_FILE%" 2>> "%TARGET_PATH_STDERR_FILE%"

rem NOTE: `type` respects UTF-16LE file with BOM header
type "%TARGET_PATH_STDERR_FILE%" >&2

for /F "usebackq eol= tokens=* delims=" %%i in (`@type "%TARGET_PATH_STDOUT_FILE%"`) do set "RETURN_VALUE=%%i"
