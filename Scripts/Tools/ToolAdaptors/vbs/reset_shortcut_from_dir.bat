@echo off

rem USAGE:
rem   reset_shortcut_from_dir.bat [<Flags>] [--] <LINKS_DIR>

rem DESCRIPTION:
rem   Script to reset shortcuts in a directory recursively without any
rem   standalone property value input.
rem
rem   To specifically update a shortcut property field with a value do use
rem   `update_shortcut.*` script instead.
rem
rem   By default without any flags does NOT save a shortcut to avoid trigger
rem   the Windows Shell component to validate all properties and rewrites the
rem   shortcut file even if nothing is changed reducing the shortcut content.
rem   This additionally avoids a shortcut accident corruption by the Windows
rem   Shell component internal guess logic (see `-ignore-unexist` option
rem   description).
rem
rem   The save does not apply if at least one property is changed.
rem   A path property assign does not apply if a path property does not exist
rem   and `-ignore-unexist` option is not used or a new not empty path property
rem   value already equal case insensitively to an old path property value.

rem <Flags>:
rem   --
rem     Separator between flags and positional arguments to explicitly stop the
rem     flags parser.
rem   -chcp <CodePage>
rem     Set explicit code page.
rem

rem <LINKS_DIR>:
rem   Directory to search shortcut files from.

rem NOTE:
rem   For other parameters description see `reset_shortcut.vbs` script.

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%*

for %%i in (CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

call "%%CONTOOLS_ROOT%%/build/init_vars_file.bat" || exit /b

call "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat" -X /pause-on-exit -- %%* || exit /b

exit /b 0

:IMPL
rem script flags
set RESTORE_LOCALE=0
set "FLAG_CHCP="
set "BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else if "%FLAG%" == "-no-backup" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-reset-target-path-by-rebase-to" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG% %2
    shift
  ) else if "%FLAG%" == "-allow-auto-recover-by-rebase-to" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG% %2
    shift
  ) else if "%FLAG:~0,7%" == "-reset-" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG%
  ) else if "%FLAG:~0,7%" == "-allow-" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-print-assign" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-p" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-q" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "--" (
    shift
    set "FLAG="
    goto FLAGS_LOOP_END
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

:FLAGS_LOOP_END

rem load initialization environment variables
if defined INIT_VARS_FILE call "%%CONTOOLS_ROOT%%/std/set_vars_from_file.bat" "%%INIT_VARS_FILE%%"

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || (
  echo.%?~nx0%: error: could not allocate temporary directory: "%SCRIPT_TEMP_CURRENT_DIR%"
  set LASTERROR=255
  goto FREE_TEMP_DIR
) >&2

if defined FLAG_CHCP (
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" "%%FLAG_CHCP%%"
  set RESTORE_LOCALE=1
) else call "%%CONTOOLS_ROOT%%/std/getcp.bat"

call :MAIN %%1 %%2 %%3 %%4 %%5 %%6 %%7 %%8 %%9
set LASTERROR=%ERRORLEVEL%

rem restore locale
if %RESTORE_LOCALE% NEQ 0 call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%

:MAIN
set "LINKS_DIR=%~1"

if defined LINKS_DIR (
  if not exist "%LINKS_DIR%\*" (
    echo.%~nx0: error: LINKS_DIR does not exist: "%LINKS_DIR%".
    exit /b 255
  ) >&2
) else set "LINKS_DIR=."

:LINKS_DIR_EXIST

for /F "eol= tokens=* delims=" %%i in ("%LINKS_DIR%\.") do set "LINKS_DIR=%%~fi"

if not "%LINKS_DIR:~-1%" == "\" set "LINKS_DIR=%LINKS_DIR%\"

for /F "usebackq eol= tokens=* delims=" %%i in (`dir /A:-D /B /S /O:N "%LINKS_DIR%*.lnk"`) do (
  set "LINK_FILE_PATH=%%i"
  call :UPDATE_LINK
)

exit /b 0

:UPDATE_LINK
echo."%LINK_FILE_PATH%"

"%SystemRoot%\System32\cscript.exe" //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/reset_shortcut.vbs"%BARE_FLAGS% -- "%LINK_FILE_PATH%"
