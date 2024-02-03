@echo off

rem USAGE:
rem   update_shortcut_props_from_dir.bat [<Flags>] [--] <LINKS_DIR> <PROPS_LIST> <REPLACE_FROM> <REPLACE_TO>
rem   update_shortcut_props_from_dir.bat [<Flags>] -m[atch] <MATCH_STRING> [--] <LINKS_DIR> <PROPS_LIST> <REPLACE_FROM> <REPLACE_TO>
rem   update_shortcut_props_from_dir.bat [<Flags>] -d[elete] [-m[atch] <MATCH_STRING>] [--] <LINKS_DIR> <PROPS_LIST> <REPLACE_FROM>

rem <Flags>:
rem   --
rem     Stop flags parse.
rem   -m[atch] <MATCH_STRING>
rem     String to case sensitive match a portion of property value before the
rem     replace. If not defined, then does match all.
rem   -d[elete]
rem     Remove `<REPLACE_FROM>` string from a property value.
rem     The `<REPLACE_TO>` must be not defined.
rem   -chcp <CodePage>
rem     Set explicit code page.
rem   -ignore-unexist
rem     By default TargetPath and WorkingDirectory does check on existence.
rem     Use this flag to skip the check.
rem   -no-skip-on-empty-assign
rem     Do not skip on property empty value assignment.
rem     By default skips any property assignment by an empty value.
rem     Has effect only if a value become empty after the replace.
rem     Has no effect if a value was already empty.
rem   -no-allow-dos-target-path
rem     Do not allow target path reset by a reduced DOS path version.
rem   -allow-target-path-reassign
rem     Allow TargetPath reassign if has the same path.
rem   -use-case-compare
rem     Use case sensitive compare instead of the case insensitive as by
rem     default.
rem     Has effect only for a replaced value to test on empty change.
rem   -p[rint-assign]
rem     Print assign.
rem   -t-suffix <ShortcutTargetSuffix>
rem     Shortcut target suffix value to append if <ShortcutTarget> does not
rem     exist. Has no effect if `-ignore-unexist` is used.

rem <LINKS_DIR>:
rem   Directory to search shortcut files from.

rem <PROPS_LIST>:
rem   TargetPath|Arguments|WorkingDirectory
rem   If equals `.`, then `TargetPath|WorkingDirectory` is used.

rem <REPLACE_FROM>:
rem   String to replace from.

rem <REPLACE_TO>:
rem   String to replace by.

rem NOTE:
rem   For detailed parameters description see `update_shortcut.vbs` script.

rem CAUTION:
rem   <MATCH_STRING> and <REPLACE_FROM> must not contain invalid characters
rem   including `=` character!

rem NOTE:
rem   By default empty value assignment is skipped with a warning.
rem   Use `-no-skip-on-empty-assign` to force assignment of an empty value to
rem   a property.
rem

rem CAUTION:
rem   If there is a replace to the same value, then the operation must not even
rem   perform, because a shortcut reassign can bring shortcut reformat under
rem   may be different Windows Shell component version. So to reset/reassign
rem   only, you must use `reset_shortcut_from_dir.bat` script instead.
rem

rem NOTE:
rem   You can use `-delete` together with `-match` to update only matched
rem   property values.
rem

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%~dp0__init__\__init__.bat" || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%* || exit /b

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
rem CAUTION: We must to reinit the builtin variables in case if `IMPL_MODE` was already setup outside.
call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem script flags
set RESTORE_LOCALE=0
set FLAG_MATCH_STRING=0
set FLAG_DELETE=0
set "FLAG_MATCH_STRING_VALUE="
set "FLAG_CHCP="
set FLAG_NO_SKIP_ON_EMPTY_ASSIGN=0
set FLAG_NO_ALLOW_DOS_TARGET_PATH=0
set FLAG_USE_CASE_COMPARE=0
set FLAG_PRINT_ASSIGN=0
set "BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-match" (
    set "FLAG_MATCH_STRING_VALUE=%~2"
    set FLAG_MATCH_STRING=1
    shift
  ) else if "%FLAG%" == "-m" (
    set "FLAG_MATCH_STRING_VALUE=%~2"
    set FLAG_MATCH_STRING=1
    shift
  ) else if "%FLAG%" == "-delete" (
    set FLAG_DELETE=1
  ) else if "%FLAG%" == "-d" (
    set FLAG_DELETE=1
  ) else if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else if "%FLAG%" == "-no-backup" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-ignore-unexist" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-no-skip-on-empty-assign" (
    set FLAG_NO_SKIP_ON_EMPTY_ASSIGN=1
  ) else if "%FLAG%" == "-no-allow-dos-target-path" (
    set FLAG_NO_ALLOW_DOS_TARGET_PATH=1
  ) else if "%FLAG%" == "-allow-target-path-reassign" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-use-case-compare" (
    set FLAG_USE_CASE_COMPARE=1
  ) else if "%FLAG%" == "-print-assign" (
    set FLAG_PRINT_ASSIGN=1
    set BARE_FLAGS=%BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-p" (
    set FLAG_PRINT_ASSIGN=1
    set BARE_FLAGS=%BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-t-suffix" (
    set BARE_FLAGS=%BARE_FLAGS% %FLAG% %2
    shift
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

if %FLAG_MATCH_STRING% NEQ 0 ^
if not defined FLAG_MATCH_STRING_VALUE (
  echo.%~nx0: error: MATCH_STRING must be defined.
  exit /b 255
) >&2

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
set "PROPS_LIST=%~2"
set "REPLACE_FROM=%~3"
set "REPLACE_TO=%~4"

if defined LINKS_DIR if exist "%LINKS_DIR%\*" goto LINKS_DIR_EXIST

(
  echo.%~nx0: error: LINKS_DIR does not exist: `%LINKS_DIR%`.
  exit /b 255
) >&2

:LINKS_DIR_EXIST

if not defined PROPS_LIST (
  echo.%~nx0: error: PROPS_LIST is not defined.
  exit /b 255
) >&2

if not defined REPLACE_FROM (
  echo.%~nx0: error: REPLACE_FROM is not defined.
  exit /b 255
) >&2

if %FLAG_DELETE% EQU 0 (
  if not defined REPLACE_TO (
    echo.%~nx0: error: REPLACE_TO is not defined.
    exit /b 255
  ) >&2

  if "%REPLACE_FROM%" == "%REPLACE_TO%" (
    echo.%~nx0: error: REPLACE_FROM must be not equal to REPLACE_TO: REPLACE_FROM="%REPLACE_FROM%".
    exit /b 255
  ) >&2
) else if defined REPLACE_TO (
  echo.%~nx0: error: REPLACE_TO must be not defined.
  exit /b 255
) >&2

rem reread CURRENT_CP variable from current code page value
call "%%CONTOOLS_ROOT%%/std/getcp.bat"

rem default props list
if "%PROPS_LIST%" == "." set "PROPS_LIST=TargetPath|WorkingDirectory"

set "PROPS_LIST_FILTERED="
if defined PROPS_LIST set "PROPS_LIST_FILTERED=%PROPS_LIST:|=%"

if not defined PROPS_LIST_FILTERED (
  echo.%~nx0: error: PROPS_LIST is empty or not applied: PROPS_LIST="%PROPS_LIST%".
  exit /b 255
) >&2

if %FLAG_NO_ALLOW_DOS_TARGET_PATH% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -allow-dos-target-path

for /F "eol= tokens=* delims=" %%i in ("%LINKS_DIR%\.") do set "LINKS_DIR=%%~fi"

if not "%LINKS_DIR:~-1%" == "\" set "LINKS_DIR=%LINKS_DIR%\"

for /F "usebackq eol= tokens=* delims=" %%i in (`dir /A:-D /B /S /O:N "%LINKS_DIR%*.lnk"`) do (
  set "LINK_FILE_PATH=%%i"
  call :UPDATE_LINK
)

exit /b 0

:UPDATE_LINK
echo."%LINK_FILE_PATH%"

set LASTERROR=0

if not defined PROPS_LIST_FILTERED goto SKIP_PROP_LIST_REPLACE

rem Read shortcut PROPS_LIST to match

if "%CURRENT_CP%" == "65001" (
  type "%CONTOOLS_ROOT:/=\%\encoding\boms\efbbbf.bin" > "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props_to_match.lst"

  rem CAUTION:
  rem   Print in UTF-16LE to save Unicode characters which does print in the vbs script.
  rem
  "%SystemRoot%\System32\cscript.exe" //U //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/read_shortcut.vbs" -p "%PROPS_LIST%" -- "%LINK_FILE_PATH%" > "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props_to_match-utf-16le.lst"

  call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" UTF-16LE UTF-8 "%%SCRIPT_TEMP_CURRENT_DIR%%/shortcut_props_to_match-utf-16le.lst" >> "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props_to_match.lst"
) else (
  "%SystemRoot%\System32\cscript.exe" //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/read_shortcut.vbs" -p "%PROPS_LIST%" -- "%LINK_FILE_PATH%" > "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props_to_match.lst"
)

if %FLAG_MATCH_STRING% NEQ 0 (
  if "%CURRENT_CP%" == "65001" (
    type "%CONTOOLS_ROOT:/=\%\encoding\boms\efbbbf.bin" > "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst"
  ) else (
    type nul > "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst"
  )

  for /F "usebackq eol= tokens=1,* delims==" %%i in ("%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props_to_match.lst") do (
    set "PROP_NAME=%%i"
    set "PROP_VALUE=%%j"
    call :MATCH_SHORTCUT
  )
) else (
  del /F /Q /A:-D "%SCRIPT_TEMP_CURRENT_DIR%\shortcut_props.lst" 2> nul
  rename "%SCRIPT_TEMP_CURRENT_DIR%\shortcut_props_to_match.lst" "shortcut_props.lst"
)

goto MATCH_SHORTCUT_END

:MATCH_SHORTCUT

rem skip on empty value
if not defined PROP_VALUE exit /b 0

rem remove quotes at first
set "PROP_PREV_VALUE=%PROP_VALUE:"=%"

rem skip on empty value again
if not defined PROP_PREV_VALUE exit /b 0

call set "PROP_NEXT_VALUE=%%PROP_PREV_VALUE:%FLAG_MATCH_STRING_VALUE%="

rem skip on not match
if "%PROP_PREV_VALUE%" == "%PROP_NEXT_VALUE%" exit /b 0

setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=1,* delims==" %%i in ("!PROP_NAME!=!PROP_VALUE!") do (
  endlocal
  echo %%i=%%j
) >> "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst"

exit /b 0

:MATCH_SHORTCUT_END

rem Read shortcut PROPS_LIST to replace

rem We must skip update WorkingDirectory from TargetPath if TargetPath is failed to update.
set IS_TARGET_PATH_UPDATE_ERROR=0

for /F "usebackq eol= tokens=1,* delims==" %%i in ("%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst") do (
  set "PROP_NAME=%%i"
  set "PROP_VALUE=%%j"
  call :UPDATE_SHORTCUT_TO_REPLACE
)

echo.

exit /b %LASTERROR%

:UPDATE_SHORTCUT_TO_REPLACE

rem skip on empty value
if not defined PROP_VALUE exit /b 0

rem remove quotes at first
set "PROP_PREV_VALUE=%PROP_VALUE:"=%"

rem skip on empty value again
if not defined PROP_PREV_VALUE exit /b 0

rem remove BOM prefix (CAUTION: byte sequence here might be not visible in an editor and not copyable in a text merger)
set "PROP_NAME=%PROP_NAME:﻿=%"

call set "PROP_NEXT_VALUE=%%PROP_PREV_VALUE:%REPLACE_FROM%=%REPLACE_TO%%%"

rem skip on empty assign
if %FLAG_NO_SKIP_ON_EMPTY_ASSIGN% EQU 0 (
  if not defined PROP_NEXT_VALUE (
    echo.%?~nx0%: warning: property empty value assignment: "%PROP_NAME%"
    exit /b 0
  ) >&2
) else (
  rem skip on empty change
  if %FLAG_USE_CASE_COMPARE% NEQ 0 (
    if "%PROP_PREV_VALUE%" == "%PROP_NEXT_VALUE%" exit /b 0
  ) else if /i "%PROP_PREV_VALUE%" == "%PROP_NEXT_VALUE%" exit /b 0
)

set "PROP_LINE=%PROP_NAME%=%PROP_NEXT_VALUE%"

if %FLAG_PRINT_ASSIGN% EQU 0 call "%%CONTOOLS_ROOT%%/std/echo_var.bat" PROP_LINE

if /i "%PROP_NAME%" == "TargetPath" (
  "%SystemRoot%\System32\cscript.exe" //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/update_shortcut.vbs"%BARE_FLAGS% -t "%PROP_NEXT_VALUE%" -- "%LINK_FILE_PATH%"
) else if /i "%PROP_NAME%" == "Arguments" (
  "%SystemRoot%\System32\cscript.exe" //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/update_shortcut.vbs"%BARE_FLAGS% -args "%PROP_NEXT_VALUE%" -- "%LINK_FILE_PATH%"
) else if /i "%PROP_NAME%" == "WorkingDirectory" (
  "%SystemRoot%\System32\cscript.exe" //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/update_shortcut.vbs"%BARE_FLAGS% -wd "%PROP_NEXT_VALUE%" -- "%LINK_FILE_PATH%"
)
