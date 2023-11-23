@echo off

rem USAGE:
rem   reset_shortcut_from_dir.bat [<Flags>] [--] <LINKS_DIR>

rem <Flags>:
rem   --
rem     Stop flags parse.
rem   -chcp <CodePage>
rem     Set explicit code page.
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
rem   -allow-auto-recover
rem     Allow to auto detect and recover broken shortcuts.
rem     Can not be used together with `-ignore-unexist` flag.
rem   -allow-target-path-reassign
rem     Allow TargetPath reassign if not been assigned.
rem     Has no effect if TargetPath is already resetted.
rem   -allow-wd-reassign
rem     Allow WorkingDirectory reassign if not been assigned.
rem     Has no effect if WorkingDirectory is already resetted.
rem
rem   -allow-dos-target-path
rem     Reread target path and if it is truncated, then reset it by a reduced
rem     DOS path version.
rem     It is useful when you want to create not truncated shortcut target file
rem     path to open it by an old version application which does not support
rem     long paths or UNC paths, but supports open target paths by a shortcut
rem     file.
rem
rem   -p[rint-assign]
rem     Print property assignment.

rem <LINKS_DIR>:
rem   Directory to search shortcut files from.

rem NOTE:
rem   For detailed parameters description see `reset_shortcut.vbs` script.

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
set FLAG_RESET_WORKINGDIR_FROM_TARGET_PATH=0
set FLAG_RESET_TARGET_PATH_FROM_WORKINGDIR=0
set FLAG_RESET_TARGET_PATH_FROM_DESC=0
set FLAG_RESET_TARGET_NAME_FROM_FILE_PATH=0
set FLAG_RESET_TARGET_DRIVE_FROM_FILE_PATH=0
set FLAG_ALLOW_AUTO_RECOVER=0
set FLAG_ALLOW_TARGET_PATH_REASSIGN=0
set FLAG_ALLOW_WORKINGDIR_REASSIGN=0
set FLAG_ALLOW_DOS_TARGET_PATH=0
set FLAG_PRINT_ASSIGN=0
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
  ) else if "%FLAG%" == "-reset-wd-from-target-path" (
    if %FLAG_RESET_WORKINGDIR_FROM_TARGET_PATH% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -reset-wd-from-target-path
    set FLAG_RESET_WORKINGDIR_FROM_TARGET_PATH=1
  ) else if "%FLAG%" == "-reset-wd" (
    if %FLAG_RESET_WORKINGDIR_FROM_TARGET_PATH% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -reset-wd-from-target-path
    set FLAG_RESET_WORKINGDIR_FROM_TARGET_PATH=1
  ) else if "%FLAG%" == "-reset-target-path-from-wd" (
    if %FLAG_RESET_TARGET_PATH_FROM_WORKINGDIR% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -reset-target-path-from-wd
    set FLAG_RESET_TARGET_PATH_FROM_WORKINGDIR=1
  ) else if "%FLAG%" == "-reset-target-path-from-desc" (
    if %FLAG_RESET_TARGET_PATH_FROM_DESC% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -reset-target-path-from-desc
    set FLAG_RESET_TARGET_PATH_FROM_DESC=1
  ) else if "%FLAG%" == "-reset-target-name-from-file" (
    if %FLAG_RESET_TARGET_NAME_FROM_FILE_PATH% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -reset-target-name-from-file
    set FLAG_RESET_TARGET_NAME_FROM_FILE_PATH=1
  ) else if "%FLAG%" == "-reset-target-drive-from-file-path" (
    if %FLAG_RESET_TARGET_DRIVE_FROM_FILE_PATH% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -reset-target-drive-from-file-path
    set FLAG_RESET_TARGET_DRIVE_FROM_FILE_PATH=1
  ) else if "%FLAG%" == "-allow-auto-recover" (
    if %FLAG_ALLOW_AUTO_RECOVER% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -allow-auto-recover
    set FLAG_ALLOW_AUTO_RECOVER=1
  ) else if "%FLAG%" == "-allow-target-path-reassign" (
    if %FLAG_ALLOW_TARGET_PATH_REASSIGN% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -allow-target-path-reassign
    set FLAG_ALLOW_TARGET_PATH_REASSIGN=1
  ) else if "%FLAG%" == "-allow-wd-reassign" (
    if %FLAG_ALLOW_WORKINGDIR_REASSIGN% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -allow-wd-reassign
    set FLAG_ALLOW_WORKINGDIR_REASSIGN=1
  ) else if "%FLAG%" == "-allow-dos-target-path" (
    set BARE_FLAGS=%BARE_FLAGS% -allow-dos-target-path
    set FLAG_ALLOW_DOS_TARGET_PATH=1
  ) else if "%FLAG%" == "-print-assign" (
    if %FLAG_PRINT_ASSIGN% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -p
    set FLAG_PRINT_ASSIGN=1
  ) else if "%FLAG%" == "-p" (
    if %FLAG_PRINT_ASSIGN% EQU 0 set BARE_FLAGS=%BARE_FLAGS% -p
    set FLAG_PRINT_ASSIGN=1
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
