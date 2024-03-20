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
rem   -extended_property
rem     Use `ExtendedProperty` method through the `read_path_props.vbs` script
rem     instead of `read_shortcut.vbs` script.

rem <ShortcutFile>:
rem   Path to shortcut file.

rem drop return value
set "RETURN_VALUE="

rem Drop last error level
call;

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%* || exit /b

rem script flags
set FLAG_SHIFT=0
set FLAG_EXTENDED_PROPERTY=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-extended_property" (
    set FLAG_EXTENDED_PROPERTY=1
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

rem CAUTION:
rem   We must use temporary file with BOM header to retain the Unicode encoding.
rem
set "TARGET_PATH_TEMP_FILE=%TEMP%\read_shortcut_target_path.%RANDOM%-%RANDOM%.txt"

call :MAIN %%*

del /F /Q "%TARGET_PATH_TEMP_FILE%" >nul 2>nul

if defined RETURN_VALUE ( endlocal & set "RETURN_VALUE=%RETURN_VALUE%" & exit /b 0 )

exit /b 1

:MAIN
copy "%CONTOOLS_ROOT%/encoding/boms\fffe.bin" "%TARGET_PATH_TEMP_FILE%" /B /Y >nul 2>nul
rem set /P =﻿<nul > "%TARGET_PATH_TEMP_FILE%"

(
  if %FLAG_EXTENDED_PROPERTY% EQU 0 (
    call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 5 "%%FLAG_SHIFT%%" "%%SystemRoot%%\System32\cscript.exe" //nologo //U "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_shortcut.vbs" -p TargetPath -- %%* || exit /b
  ) else call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 7 "%%FLAG_SHIFT%%" "%%SystemRoot%%\System32\cscript.exe" //nologo //U "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_path_props.vbs" -v -x -lr -- LinkTarget %%* || exit /b
) >> "%TARGET_PATH_TEMP_FILE%"

rem `type` respects a Unicode file with BOM header
if %FLAG_EXTENDED_PROPERTY% EQU 0 (
  for /F "usebackq eol= tokens=1,* delims==" %%i in (`@type "%TARGET_PATH_TEMP_FILE%"`) do set "RETURN_VALUE=%%j"
) else for /F "usebackq eol= tokens=* delims=" %%i in (`@type "%TARGET_PATH_TEMP_FILE%"`) do set "RETURN_VALUE=%%i"
