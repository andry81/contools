@echo off & goto DOC_END

rem USAGE:
rem   update_shortcut_props_from_dir.bat [<Flags>] -m[atch] <MATCH_STRING> [--] <LINKS_DIR> <PROPS_LIST> <REPLACE_FROM> <REPLACE_TO> [<REPLACE_FROM> <REPLACE_TO>]...
rem   update_shortcut_props_from_dir.bat [<Flags>] -d[elete] -m[atch] <MATCH_STRING> [--] <LINKS_DIR> <PROPS_LIST> <REPLACE_FROM> ["" [<REPLACE_FROM>]...]

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
rem
rem   -no-skip-on-empty-assign
rem     Do not skip on property empty value assignment.
rem     By default skips any property assignment by an empty value.
rem     Has effect only if a value become empty after the replace.
rem     Has no effect if a value was already empty.
rem   -no-allow-dos-target-path
rem     Do not allow target path reset by a reduced DOS path version.
rem   -no-allow-dos-wd
rem     Do not allow working directory reset by a reduced DOS path version.
rem
rem   -allow-target-path-reassign
rem     Allow `TargetPath` property reassign if has the same path.
rem     Path comparison depends on `-use-case-compare` flag.
rem   -allow-wd-reassign
rem     Allow `WorkingDirectory` property reassign if has the same path.
rem     Path comparison depends on `-use-case-compare` flag.
rem   -allow-paths-reassign
rem     Implies all `-allow-*-reassign` flags.
rem
rem   -use-case-compare
rem     Use case sensitive compare instead of the case insensitive as by
rem     default.
rem     Has effect only for `TargetPath` and `WorkingDirectory` properties.
rem     Has effect only for a replaced value to test on empty change.
rem   -use-getlink | -g
rem     Use `GetLink` property instead of `CreateShortcut` method.
rem     Alternative interface to assign path properties with Unicode
rem     characters.
rem   -print-remapped-names | -k
rem     Print remapped key names instead of `CreateShortcut` method object
rem     names.
rem     Has no effect if `-use-getlink` flag is not used.
rem
rem   -print-read | -pr
rem     Print property read.
rem   -p[rint-assign]
rem     Print property assign before assign.
rem   -print-assigned | -pd
rem     Reread property after assign and print.
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

rem CAUTION:
rem   Base `CreateShortcut` method does not support all Unicode characters nor
rem   `search-ms` Windows Explorer moniker path for the filter field.
rem   Use `GetLink` property (`-use-getlink` flag) instead to workaround that.
:DOC_END

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

rem script flags
set FLAG_SHIFT=0
set FLAG_MATCH_STRING=0
set FLAG_DELETE=0
set "FLAG_MATCH_STRING_VALUE="
set "FLAG_CHCP="
set FLAG_NO_BACKUP=0
set FLAG_NO_SKIP_ON_EMPTY_ASSIGN=0
set FLAG_NO_ALLOW_DOS_TARGET_PATH=0
set FLAG_NO_ALLOW_DOS_WORKING_DIR=0
set FLAG_ALLOW_TARGET_PATH_REASSIGN=0
set FLAG_ALLOW_WORKING_DIR_REASSIGN=0
set FLAG_ALLOW_PATHS_REASSIGN=0
set FLAG_USE_CASE_COMPARE=0
set FLAG_PRINT_READ=0
set "READ_SHORTCUT_BARE_FLAGS="
set "UPDATE_SHORTCUT_BARE_FLAGS="

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
    set /A FLAG_SHIFT+=1
  ) else if "%FLAG%" == "-m" (
    set "FLAG_MATCH_STRING_VALUE=%~2"
    set FLAG_MATCH_STRING=1
    shift
    set /A FLAG_SHIFT+=1
  ) else if "%FLAG%" == "-delete" (
    set FLAG_DELETE=1
  ) else if "%FLAG%" == "-d" (
    set FLAG_DELETE=1
  ) else if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
    set /A FLAG_SHIFT+=1
  ) else if "%FLAG%" == "-no-backup" (
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
    set FLAG_NO_BACKUP=1
  ) else if "%FLAG%" == "-ignore-unexist" (
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-no-skip-on-empty-assign" (
    set FLAG_NO_SKIP_ON_EMPTY_ASSIGN=1
  ) else if "%FLAG%" == "-no-allow-dos-target-path" (
    set FLAG_NO_ALLOW_DOS_TARGET_PATH=1
  ) else if "%FLAG%" == "-no-allow-dos-wd" (
    set FLAG_NO_ALLOW_DOS_WORKING_DIR=1
  ) else if "%FLAG%" == "-allow-target-path-reassign" (
    set FLAG_ALLOW_TARGET_PATH_REASSIGN=1
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-allow-wd-reassign" (
    set FLAG_ALLOW_WORKING_DIR_REASSIGN=1
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-allow-paths-reassign" (
    set FLAG_ALLOW_PATHS_REASSIGN=1
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-use-case-compare" (
    set FLAG_USE_CASE_COMPARE=1
  ) else if "%FLAG%" == "-use-getlink" (
    set READ_SHORTCUT_BARE_FLAGS=%READ_SHORTCUT_BARE_FLAGS% %FLAG%
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-g" (
    set READ_SHORTCUT_BARE_FLAGS=%READ_SHORTCUT_BARE_FLAGS% %FLAG%
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "--print-remapped-names" (
    set READ_SHORTCUT_BARE_FLAGS=%READ_SHORTCUT_BARE_FLAGS% %FLAG%
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-k" (
    set READ_SHORTCUT_BARE_FLAGS=%READ_SHORTCUT_BARE_FLAGS% %FLAG%
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-print-read" (
    set FLAG_PRINT_READ=1
  ) else if "%FLAG%" == "-pr" (
    set FLAG_PRINT_READ=1
  ) else if "%FLAG%" == "-print-assign" (
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-p" (
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-print-assigned" (
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-pd" (
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-t-suffix" (
    set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% %FLAG% %2
    shift
    set /A FLAG_SHIFT+=1
  ) else if not "%FLAG%" == "--" (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

if %FLAG_MATCH_STRING% NEQ 0 ^
if not defined FLAG_MATCH_STRING_VALUE (
  echo;%?~%: error: MATCH_STRING must be defined.
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

if defined FLAG_CHCP (
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" "%%FLAG_CHCP%%"
) else call "%%CONTOOLS_ROOT%%/std/getcp.bat"

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem restore locale
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LAST_ERROR%

:MAIN
if FLAG_SHIFT GTR 0 for /L %%i in (1,1,%FLAG_SHIFT%) do shift

set "LINKS_DIR=%~1"
set "PROPS_LIST=%~2"
set "REPLACE_FROM=%~3"
set "REPLACE_TO=%~4"

if defined LINKS_DIR if exist "%LINKS_DIR%\*" goto LINKS_DIR_EXIST

(
  echo;%?~%: error: LINKS_DIR does not exist: `%LINKS_DIR%`.
  exit /b 255
) >&2

:LINKS_DIR_EXIST

if not defined PROPS_LIST (
  echo;%?~%: error: PROPS_LIST is not defined.
  exit /b 255
) >&2

if not defined REPLACE_FROM (
  echo;%?~%: error: REPLACE_FROM is not defined.
  exit /b 255
) >&2

if %FLAG_DELETE% EQU 0 (
  if not defined REPLACE_TO (
    echo;%?~%: error: REPLACE_TO is not defined.
    exit /b 255
  ) >&2

  if "%REPLACE_FROM%" == "%REPLACE_TO%" (
    echo;%?~%: error: REPLACE_FROM must be not equal to REPLACE_TO: REPLACE_FROM="%REPLACE_FROM%".
    exit /b 255
  ) >&2
) else if defined REPLACE_TO (
  echo;%?~%: error: REPLACE_TO must be not defined.
  exit /b 255
) >&2

rem reread CURRENT_CP variable from current code page value
call "%%CONTOOLS_ROOT%%/std/getcp.bat"

rem default props list
if "%PROPS_LIST%" == "." set "PROPS_LIST=TargetPath|WorkingDirectory"

set "PROPS_LIST_FILTERED="
if defined PROPS_LIST set "PROPS_LIST_FILTERED=%PROPS_LIST:|=%"

if not defined PROPS_LIST_FILTERED (
  echo;%?~%: error: PROPS_LIST is empty or not applied: PROPS_LIST="%PROPS_LIST%".
  exit /b 255
) >&2

if %FLAG_NO_ALLOW_DOS_TARGET_PATH% EQU 0 set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% -allow-dos-target-path
if %FLAG_NO_ALLOW_DOS_WORKING_DIR% EQU 0 set UPDATE_SHORTCUT_BARE_FLAGS=%UPDATE_SHORTCUT_BARE_FLAGS% -allow-dos-wd

if %FLAG_ALLOW_PATHS_REASSIGN% NEQ 0 set "FLAG_ALLOW_TARGET_PATH_REASSIGN=1"
if %FLAG_ALLOW_PATHS_REASSIGN% NEQ 0 set "FLAG_ALLOW_WORKING_DIR_REASSIGN=1"

for /F "tokens=* delims="eol^= %%i in ("%LINKS_DIR%\.") do set "LINKS_DIR=%%~fi"

if not "%LINKS_DIR:~-1%" == "\" set "LINKS_DIR=%LINKS_DIR%\"

set "BACKUP_DIR="

if %FLAG_NO_BACKUP% NEQ 0 goto SKIP_BACKUP_DIR

set "BACKUP_DIR=%LINKS_DIR%"

rem escape for `findstr.exe`
set "BACKUP_DIR=%BACKUP_DIR:\=\\%"
set "BACKUP_DIR=%BACKUP_DIR:^=\^%"
set "BACKUP_DIR=%BACKUP_DIR:$=\$%"
set "BACKUP_DIR=%BACKUP_DIR:.=\.%"
set "BACKUP_DIR=%BACKUP_DIR:[=\[%"
set "BACKUP_DIR=%BACKUP_DIR:]=\]%"

set "BACKUP_DIR=%BACKUP_DIR%[0-9][0-9][0-9][0-9]'[0-9][0-9]'[0-9][0-9]\.backup\\"

:SKIP_BACKUP_DIR

set /A CMDLINE_SHIFT=%FLAG_SHIFT%+4

call "%%CONTOOLS_ROOT%%\std\setshift.bat" %%CMDLINE_SHIFT%% CMDLINE_SHIFTED %%*

set "READ_SHORTCUT_PROP_TEMP_STDOUT_FILE=%SCRIPT_TEMP_CURRENT_DIR%\shortcut_props_to_match-utf-16le.lst"
set "READ_SHORTCUT_PROP_TEMP_STDERR_FILE=%SCRIPT_TEMP_CURRENT_DIR%\shortcut_props_to_match-utf-16le.stderr.txt"

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
if defined BACKUP_DIR (
  set ?.=@dir "%LINKS_DIR%*.lnk" /A:-D /B /O:N /S 2^>nul ^| "%SystemRoot%\System32\findstr.exe" /B /R /I /V /C:"%BACKUP_DIR%\\"
) else set ?.=@dir "%LINKS_DIR%*.lnk" /A:-D /B /O:N /S 2^>nul

for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
  set "LINK_FILE_PATH=%%i"
  call :UPDATE_LINK
)

exit /b 0

:UPDATE_LINK
echo;"%LINK_FILE_PATH%"

rem Read shortcut PROPS_LIST to match

rem CAUTION:
rem   Below lines of code has a copy in the `read_shortcut_target_path.bat` script.
rem   In case of change must be merged between copies.
rem

rem UTF-16LE BOM
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%READ_SHORTCUT_PROP_TEMP_STDOUT_FILE%" /B /Y >nul 2>nul
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%READ_SHORTCUT_PROP_TEMP_STDERR_FILE%" /B /Y >nul 2>nul
rem UTF-8 BOM
rem set /P =﻿<nul > "%READ_SHORTCUT_PROP_TEMP_STDOUT_FILE%"

"%SystemRoot%\System32\cscript.exe" //NOLOGO //U "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/read_shortcut.vbs"%READ_SHORTCUT_BARE_FLAGS% -p "%PROPS_LIST%" -- "%LINK_FILE_PATH%" >> "%READ_SHORTCUT_PROP_TEMP_STDOUT_FILE%" 2>> "%READ_SHORTCUT_PROP_TEMP_STDERR_FILE%"

rem NOTE: `type` respects UTF-16LE file with BOM header
type "%READ_SHORTCUT_PROP_TEMP_STDERR_FILE%" >&2

if %FLAG_MATCH_STRING% NEQ 0 (
  if "%CURRENT_CP%" == "65001" (
    type "%CONTOOLS_ROOT:/=\%\encoding\boms\efbbbf.bin" > "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst"
  ) else (
    type nul > "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst"
  )

  for /F "usebackq tokens=1,* delims=="eol^= %%i in (`@type "%%READ_SHORTCUT_PROP_TEMP_STDOUT_FILE%%"`) do (
    set "PROP_NAME=%%i"
    set "PROP_VALUE=%%j"
    call :MATCH_SHORTCUT
  )
) else (
  rem NOTE: `type` respects UTF-16LE file with BOM header
  type "%READ_SHORTCUT_PROP_TEMP_STDOUT_FILE%" > "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst"
)

goto MATCH_SHORTCUT_END

:MATCH_SHORTCUT

rem skip on empty value, except for `TargetPath` property to retry using an alternative method
if defined PROP_VALUE goto SKIP_PROP_VALUE_RETRY
if not "%PROP_NAME%" == "TargetPath" exit /b 0

rem Retry on `ExtendedProperty` method.

rem UTF-16LE BOM
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%READ_SHORTCUT_PROP_TEMP_STDOUT_FILE%" /B /Y >nul 2>nul
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%READ_SHORTCUT_PROP_TEMP_STDERR_FILE%" /B /Y >nul 2>nul

"%SystemRoot%\System32\cscript.exe" //NOLOGO //U "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/read_path_props.vbs" -v -x -lr -- LinkTarget "%LINK_FILE_PATH%" >> "%READ_SHORTCUT_PROP_TEMP_STDOUT_FILE%" 2>> "%READ_SHORTCUT_PROP_TEMP_STDERR_FILE%"

rem NOTE: `type` respects UTF-16LE file with BOM header
type "%READ_SHORTCUT_PROP_TEMP_STDERR_FILE%" >&2

set "PROP_VALUE="
for /F "usebackq tokens=* delims="eol^= %%i in (`@type "%READ_SHORTCUT_PROP_TEMP_STDOUT_FILE%"`) do set "PROP_VALUE=%%i"

rem skip on empty value
if not defined PROP_VALUE exit /b 0

:SKIP_PROP_VALUE_RETRY

rem remove quotes at first
set "PROP_PREV_VALUE=%PROP_VALUE:"=%"

rem skip on empty value again
if not defined PROP_PREV_VALUE exit /b 0

call set "PROP_NEXT_VALUE=%%PROP_PREV_VALUE:%FLAG_MATCH_STRING_VALUE%="

rem skip on no match
if "%PROP_PREV_VALUE%" == "%PROP_NEXT_VALUE%" exit /b 0

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=1,* delims=="eol^= %%i in ("!PROP_NAME!=!PROP_VALUE!") do endlocal & (echo %%i=%%j) >> "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst"

exit /b 0

:MATCH_SHORTCUT_END

rem Read shortcut PROPS_LIST to replace

set UPDATE_SHORTCUT=0
set "UPDATE_SHORTCUT_PROP_FLAGS="

for /F "usebackq tokens=1,* delims=="eol^= %%i in ("%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst") do (
  set "PROP_NAME=%%i"
  set "PROP_VALUE=%%j"
  call :UPDATE_SHORTCUT_TO_REPLACE
)

if %UPDATE_SHORTCUT% NEQ 0 ^
"%SystemRoot%\System32\cscript.exe" //NOLOGO "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/update_shortcut.vbs"%UPDATE_SHORTCUT_BARE_FLAGS%%UPDATE_SHORTCUT_PROP_FLAGS% -- "%LINK_FILE_PATH%"

echo;

exit /b

:UPDATE_SHORTCUT_TO_REPLACE

rem skip on empty value, except for `TargetPath` property to retry by `ShellFolderItem::ExtendedProperty` method
if defined PROP_VALUE goto SKIP_PROP_VALUE_RETRY
if not "%PROP_NAME%" == "TargetPath" exit /b 0

rem the match variant already has a builtin retry
if %FLAG_MATCH_STRING% NEQ 0 goto SKIP_PROP_VALUE_RETRY

rem Retry on `ExtendedProperty` method.

rem UTF-16LE BOM
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%READ_SHORTCUT_PROP_TEMP_STDOUT_FILE%" /B /Y >nul 2>nul
copy "%CONTOOLS_ROOT%\encoding\boms\fffe.bin" "%READ_SHORTCUT_PROP_TEMP_STDERR_FILE%" /B /Y >nul 2>nul

"%SystemRoot%\System32\cscript.exe" //NOLOGO //U "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/read_path_props.vbs" -v -x -lr -- LinkTarget "%LINK_FILE_PATH%" >> "%READ_SHORTCUT_PROP_TEMP_STDOUT_FILE%" 2>> "%READ_SHORTCUT_PROP_TEMP_STDERR_FILE%"

rem NOTE: `type` respects UTF-16LE file with BOM header
type "%READ_SHORTCUT_PROP_TEMP_STDERR_FILE%" >&2

for /F "usebackq tokens=* delims="eol^= %%i in (`@type "%READ_SHORTCUT_PROP_TEMP_STDOUT_FILE%"`) do set "PROP_VALUE=%%i"

rem skip on empty value
if not defined PROP_VALUE exit /b 0

:SKIP_PROP_VALUE_RETRY

rem remove quotes at first
set "PROP_PREV_VALUE=%PROP_VALUE:"=%"

rem skip on empty value again
if not defined PROP_PREV_VALUE exit /b 0

set "PROP_LINE=%PROP_NAME%(read)=%PROP_PREV_VALUE%"

if %FLAG_PRINT_READ% NEQ 0 call "%%CONTOOLS_ROOT%%/std/echo_var.bat" PROP_LINE

call "%%?~dp0%%.%%?~n0%%\%%?~n0%%.replace.bat" %%CMDLINE_SHIFTED%%

if %UPDATE_SHORTCUT% EQU 0 exit /b 0

if /i "%PROP_NAME%" == "TargetPath" (
  set UPDATE_SHORTCUT_PROP_FLAGS=%UPDATE_SHORTCUT_PROP_FLAGS% -t "%PROP_NEXT_VALUE%"
) else if /i "%PROP_NAME%" == "Arguments" (
  set UPDATE_SHORTCUT_PROP_FLAGS=%UPDATE_SHORTCUT_PROP_FLAGS% -args "%PROP_NEXT_VALUE%"
) else if /i "%PROP_NAME%" == "WorkingDirectory" (
  set UPDATE_SHORTCUT_PROP_FLAGS=%UPDATE_SHORTCUT_PROP_FLAGS% -wd "%PROP_NEXT_VALUE%"
)
