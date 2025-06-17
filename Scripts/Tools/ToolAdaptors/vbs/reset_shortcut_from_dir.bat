@echo off & goto DOC_END

rem USAGE:
rem   reset_shortcut_from_dir.bat [<Flags>] [--] <LINKS_DIR>

rem <Flags>:
rem   --
rem     Stop flags parse.
rem   -chcp <CodePage>
rem     Set explicit code page.
rem
rem   -reset-wd[-from-target-path]
rem     Reset WorkingDirectory from TargetPath.
rem     Does not apply if TargetPath is empty.
rem   -reset-target-path-from-wd
rem     Reset TargetPath from WorkingDirectory leaving the file name as is.
rem     Does not apply if WorkingDirectory or TargetPath is empty.
rem   -reset-target-path-from-desc
rem     Reset TargetPath from Description.
rem     Does not apply if Description is empty or not a path.
rem     Has no effect if TargetPath is already resetted.
rem   -reset-target-name-from-file-path
rem     Reset TargetPath name from shortcut file name without `.lnk` extension.
rem   -reset-target-drive-from-file-path
rem     Reset TargetPath drive from shortcut file drive.
rem
rem   -allow-auto-recover
rem     Allow to auto detect and recover broken shortcuts.
rem     Can not be used together with `-ignore-unexist` flag.
rem
rem   -allow-target-path-reassign
rem     Allow `TargetPath` property reassign if has not been assigned.
rem     Has no effect if `TargetPath` is already resetted.
rem
rem   -allow-dos-target-path
rem     Reread target path after assign and if it does not exist, then reassign
rem     it by a reduced DOS path version.
rem     It is useful when you want to create not truncated shortcut target file
rem     path to open it by an old version application which does not support
rem     long paths or Win32 Namespace paths, but supports open target paths by
rem     a shortcut file.
rem     Has no effect if path does not exist.
rem   -allow-dos-wd
rem     Reread working directory after assign and if it does not exist, then
rem     reassign it by a reduced DOS path version.
rem     Has no effect if path does not exist.
rem   -allow-dos-paths
rem     Implies all `-allow-dos-*` flags.
rem
rem   -use-getlink | -g
rem     Use `GetLink` property instead of `CreateShortcut` method.
rem     Alternative interface to assign path properties with Unicode
rem     characters.
rem   -print-remapped-names | -k
rem     Print remapped key names instead of `CreateShortcut` method object
rem     names.
rem     Has no effect if `-use-getlink` flag is not used.
rem
rem   -p[rint-assign]
rem     Print property assign before assign.
rem   -print-assigned | -pd
rem     Reread property after assign and print.
rem

rem <LINKS_DIR>:
rem   Directory to search shortcut files from.

rem NOTE:
rem   For detailed parameters description see `reset_shortcut.vbs` script.

rem CAUTION:
rem   Base `CreateShortcut` method does not support all Unicode characters nor
rem   `search-ms` Windows Explorer moniker path for the filter field.
rem   Use `GetLink` property (`-use-getlink` flag) instead to workaround that.
:DOC_END

setlocal

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

rem script flags
set FLAG_SHIFT=0
set "FLAG_CHCP="
set "RESET_SHORTCUT_BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
    set /A FLAG_SHIFT+=1
  ) else if "%FLAG%" == "-reset-wd-from-target-path" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-reset-wd" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-reset-target-path-from-wd" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-reset-target-path-from-desc" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-reset-target-name-from-file" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-reset-target-drive-from-file-path" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-allow-auto-recover" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-allow-target-path-reassign" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-allow-dos-target-path" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-use-getlink" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-print-assign" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-p" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-print-assigned" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if "%FLAG%" == "-pd" (
    set RESET_SHORTCUT_BARE_FLAGS=%RESET_SHORTCUT_BARE_FLAGS% %FLAG%
  ) else if not "%FLAG%" == "--" (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

if defined FLAG_CHCP (
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" "%%FLAG_CHCP%%"
) else call "%%CONTOOLS_ROOT%%/std/getcp.bat"

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem restore locale
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

:FREE_TEMP_DIR
rem clean up temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LAST_ERROR%

:MAIN
if FLAG_SHIFT GTR 0 for /L %%i in (1,1,%FLAG_SHIFT%) do shift

set "LINKS_DIR=%~1"

if defined LINKS_DIR (
  if not exist "%LINKS_DIR%\*" (
    echo;%?~%: error: LINKS_DIR does not exist: "%LINKS_DIR%".
    exit /b 255
  ) >&2
) else set "LINKS_DIR=."

:LINKS_DIR_EXIST

for /F "tokens=* delims="eol^= %%i in ("%LINKS_DIR%\.") do set "LINKS_DIR=%%~fi"

if not "%LINKS_DIR:~-1%" == "\" set "LINKS_DIR=%LINKS_DIR%\"

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
set ?.=@dir "%LINKS_DIR%*.lnk" /A:-D /B /O:N /S 2^>nul

for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
  set "LINK_FILE_PATH=%%i"
  call :UPDATE_LINK
)

echo;

exit /b 0

:UPDATE_LINK
echo;"%LINK_FILE_PATH%"

"%SystemRoot%\System32\cscript.exe" //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/reset_shortcut.vbs"%RESET_SHORTCUT_BARE_FLAGS% -- "%LINK_FILE_PATH%"

echo;
