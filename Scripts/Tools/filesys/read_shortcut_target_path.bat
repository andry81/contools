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

if %FLAG_EXTENDED_PROPERTY% EQU 0 (
  rem CAUTION:
  rem   `for /F` does not return a command error code
  for /F "usebackq eol= tokens=1,* delims==" %%i in (`@"%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 5 "%%FLAG_SHIFT%%" "%%SystemRoot%%\System32\cscript.exe" //nologo "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_shortcut.vbs" -p TargetPath -- %*`) do set "RETURN_VALUE=%%j"
) else (
  rem CAUTION:
  rem   `for /F` does not return a command error code
  for /F "usebackq eol= tokens=* delims=" %%i in (`@"%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 7 "%%FLAG_SHIFT%%" "%%SystemRoot%%\System32\cscript.exe" //nologo "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_path_props.vbs" -v -x -lr -- LinkTarget %*`) do set "RETURN_VALUE=%%i"
)

if defined RETURN_VALUE ( endlocal & set "RETURN_VALUE=%RETURN_VALUE%" & exit /b 0 )

exit /b 1
