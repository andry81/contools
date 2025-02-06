@echo off

rem USAGE:
rem   xmove_dir.bat [<flags>] [--] <from-path> <to-path> [<xmove-flags>...]

rem Description:
rem   The `move`/`robocopy.exe` seemless wrapper script with xcopy
rem   compatible command line flags/excludes, echo and some conditions check
rem   before call to move a directory to a directory.

rem CAUTION:
rem   `move` has a file path limit up to 260 characters in a path. To
rem   bypass that limitation we falls back to use `robocopy.exe` instead
rem   (Windows Vista and higher ONLY) if the `move` fails.
rem
rem   In case of default command line the `robocopy.exe` will move files with
rem   all attributes, but not timestamps:
rem     Windows Vista+: `/COPY:DAT /DCOPY:T /MOVE` (`/DCOPY` is limited)
rem     Windows 8+:     `/COPY:DAT /DCOPY:DAT /MOVE`
rem
rem   This happens because `robocopy.exe` can not move not empty directories
rem   without a directory modification timestamp change when it does shallow
rem   copy source directories hierarchy and then does copy files into it.
rem
rem   But we need to preserve timestamps and move all directories without
rem   any timestamp modification. So we use `move` command by default and if it
rem   has failed, then fall back to the `robocopy.exe` to copy and then delete.
rem
rem   `robocopy` does not overwrite files with the same timestamp and size,
rem   even if content is different and `/IS` and/or `/IT` flags are used.
rem   See details:
rem     https://superuser.com/questions/1114377/does-robocopy-skip-copying-existing-files-by-default/1114381#1114381
rem     https://superuser.com/questions/1114377/does-robocopy-skip-copying-existing-files-by-default/1347329#1347329
rem   To avoid that you have to use `-touch_file` and/or `-touch_dir` flags to
rem   touch the output before the move.

rem <flags>:
rem   -chcp <CodePage>
rem     Set explicit code page.
rem
rem   -use_builtin_move
rem     Use builtin `move` command instead of `robocopy` executable utility.
rem     CAUTION:
rem       Movement can fail with that flag in case of a long path.
rem
rem   -use_robocopy
rem     Use `robocopy` executable utility instead of builtin `move` command.
rem     Has no effect if `-use_builtin_move` flag is used.
rem     Can not be used if `robocopy.exe` is not found.
rem     NOTE:
rem       Movement is emulated by copy+delete `robocopy.exe` internal logic.
rem
rem   -ignore_existed
rem     By default `<to-path>` does check on directory existence and throw
rem     an error if exists.
rem     Use this flag to ignore existed target directory and use `robocopy.exe`
rem     if existed in case of a directory move-to-merge, otherwise fallback to
rem     builtin `move` command if `-use_robocopy` flag is not used.
rem     Has no effect if `-use_builtin_move` flag is used.
rem
rem   -touch_dir
rem     Use `touch_dir.bat` script to touch the output directories before the
rem     move.
rem
rem   -touch_file
rem     Use `touch_file.bat` script to touch the output files before the move.

rem --:
rem   Separator to stop parse flags.

rem <from-path>:
rem   From directory path.

rem <to-path>:
rem   To directory path.

rem <xmove-flags>:
rem   Command line flags to pass into subsequent commands and utilities.

echo.^>%~nx0 %*

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

rem script flags
set FLAG_SHIFT=0
set "FLAG_CHCP="
set FLAG_USE_BUILTIN_MOVE=0
set FLAG_USE_ROBOCOPY=0
set FLAG_IGNORE_EXISTED=0
set FLAG_TOUCH_DIR=0
set FLAG_TOUCH_FILE=0

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
  ) else if "%FLAG%" == "-use_builtin_move" (
    set FLAG_USE_BUILTIN_MOVE=1
  ) else if "%FLAG%" == "-use_robocopy" (
    set FLAG_USE_ROBOCOPY=1
  ) else if "%FLAG%" == "-ignore_existed" (
    set FLAG_IGNORE_EXISTED=1
  ) else if "%FLAG%" == "-touch_dir" (
    set FLAG_TOUCH_DIR=1
  ) else if "%FLAG%" == "-touch_file" (
    set FLAG_TOUCH_FILE=1
  ) else if not "%FLAG%" == "--" (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

set "FROM_PATH=%~1"
set "TO_PATH=%~2"

if not defined FROM_PATH (
  echo.%?~nx0%: error: input directory path argument must be defined.
  exit /b -255
) >&2

if not defined TO_PATH (
  echo.%?~nx0%: error: output directory path argument must be defined.
  exit /b -253
) >&2

set "FROM_PATH=%FROM_PATH:/=\%"
set "TO_PATH=%TO_PATH:/=\%"

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%FROM_PATH:~0,1%" goto FROM_PATH_ERROR

rem ...double `\\` character
if not "%FROM_PATH%" == "%FROM_PATH:\\=\%" goto FROM_PATH_ERROR

rem ...trailing `\` character
rem if "\" == "%FROM_PATH:~-1%" goto FROM_PATH_ERROR

rem check on invalid characters in path
if not "%FROM_PATH%" == "%FROM_PATH:**=%" goto FROM_PATH_ERROR
if not "%FROM_PATH%" == "%FROM_PATH:?=%" goto FROM_PATH_ERROR

goto FROM_PATH_OK

:FROM_PATH_ERROR
(
  echo.%?~nx0%: error: input directory path is invalid:
  echo.  FROM_PATH="%FROM_PATH%"
  echo.  TO_PATH  ="%TO_PATH%"
  exit /b -248
) >&2

:FROM_PATH_OK

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%TO_PATH:~0,1%" goto TO_PATH_ERROR

rem ...double `\\` character
if not "%TO_PATH%" == "%TO_PATH:\\=\%" goto TO_PATH_ERROR

rem ...trailing `\` character
rem if "\" == "%TO_PATH:~-1%" goto TO_PATH_ERROR

rem check on invalid characters in path
if not "%TO_PATH%" == "%TO_PATH:**=%" goto TO_PATH_ERROR
if not "%TO_PATH%" == "%TO_PATH:?=%" goto TO_PATH_ERROR

if "\" == "%TO_PATH:~0,1%" goto TO_PATH_ERROR

goto TO_PATH_OK

:TO_PATH_ERROR
(
  echo.%?~nx0%: error: output directory path is invalid:
  echo.  FROM_PATH="%FROM_PATH%"
  echo.  TO_PATH  ="%TO_PATH%"
  exit /b -249
) >&2

:TO_PATH_OK

for /F "tokens=* delims="eol^= %%i in ("%FROM_PATH%\.") do set "FROM_PATH_ABS=%%~fi"
for /F "tokens=* delims="eol^= %%i in ("%TO_PATH%\.") do set "TO_PATH_ABS=%%~fi"
for /F "tokens=* delims="eol^= %%i in ("%TO_PATH_ABS%") do for /F "tokens=* delims="eol^= %%j in ("%%~dpi.") do set "TO_PARENT_DIR_ABS=%%~fj"

if not exist "\\?\%FROM_PATH_ABS%\*" (
  echo.%?~nx0%: error: input directory does not exist:
  echo.  FROM_PATH="%FROM_PATH%"
  exit /b -248
) >&2

set TO_PATH_AS_DIR_EXISTS=0
if exist "\\?\%TO_PATH_ABS%\*" set TO_PATH_AS_DIR_EXISTS=1

rem CAUTION:
rem   We must always check on target path existence, because:
rem   1. Difference between `move` and `robocopy.exe` in case of existed path.
rem   2. To be able to rename the input directory.
rem
if %FLAG_IGNORE_EXISTED% EQU 0 if %TO_PATH_AS_DIR_EXISTS% NEQ 0 (
  echo.%?~nx0%: error: output directory does exist:
  echo.  TO_PATH="%TO_PATH%"
  exit /b -247
) >&2

if not exist "\\?\%TO_PARENT_DIR_ABS%\*" (
  echo.%?~nx0%: error: output parent directory does not exist:
  echo.  TO_PARENT_DIR_ABS="%TO_PARENT_DIR_ABS%"
  exit /b -249
) >&2

call "%%?~dp0%%__init__.bat" || exit /b

set /A FLAG_SHIFT+=2

call "%%?~dp0%%setshift.bat" %%FLAG_SHIFT%% XMOVE_FLAGS_ %%*

rem CAUTION:
rem   You must switch code page into english compatible locale.
rem
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%FLAG_CHCP%%

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem restore locale
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b %LAST_ERROR%

:MAIN
if %FLAG_USE_BUILTIN_MOVE% EQU 0 (
  if not exist "%SystemRoot%\System32\robocopy.exe" (
    if %FLAG_USE_ROBOCOPY% NEQ 0 (
      echo.%?~nx0%: error: `robocopy.exe` is not found.
      exit /b -240
    ) >&2
    set FLAG_USE_BUILTIN_MOVE=1
  )
)

if %FLAG_USE_BUILTIN_MOVE% NEQ 0 goto USE_BUILTIN_MOVE
if %FLAG_USE_ROBOCOPY% NEQ 0 goto USE_ROBOCOPY

rem use `robocopy.exe` if existed in case of a directory move-to-merge
if %FLAG_IGNORE_EXISTED% NEQ 0 if %TO_PATH_AS_DIR_EXISTS% NEQ 0 goto USE_ROBOCOPY

:USE_BUILTIN_MOVE
set "XMOVE_FLAGS= "
set XMOVE_Y_FLAG_PARSED=0
for %%i in (%XMOVE_FLAGS_%) do (
  set XMOVE_FLAG=%%i
  call :ROBOCOPY_FLAGS_CONVERT %%XMOVE_FLAG%% || exit /b -250
)

if %FLAG_TOUCH_DIR%%FLAG_TOUCH_FILE% EQU 0 goto SKIP_TOUCH

echo.^>^>touch "%TO_PATH_ABS%\*"

setlocal

set TOOLS_VERBOSE=0

set "BUILTIN_DIR_CMD_BARE_FLAGS="
if %FLAG_TOUCH_DIR% EQU 0 (
  set BUILTIN_DIR_CMD_BARE_FLAGS=%BUILTIN_DIR_CMD_BARE_FLAGS% /A:-D
) else if %FLAG_TOUCH_FILE% EQU 0 (
  set BUILTIN_DIR_CMD_BARE_FLAGS=%BUILTIN_DIR_CMD_BARE_FLAGS% /A:D
)

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
set ?.=@dir "%TO_PATH_ABS%"%BUILTIN_DIR_CMD_BARE_FLAGS% /B /O:N /S 2^>nul

if %FLAG_TOUCH_DIR% EQU 0 (
  for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
    set "TO_PATH=%%i"
    call "%%?~dp0%%touch_file.bat" "%%TO_PATH%%"
  )
) else if %FLAG_TOUCH_FILE% EQU 0 (
  for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
    set "TO_PATH=%%i"
    call "%%?~dp0%%touch_dir.bat" "%%TO_PATH%%"
  )
) else for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
  set "TO_PATH=%%i"
  if exist "\\?\%TO_PATH%\*" (
    if %FLAG_TOUCH_DIR% NEQ 0 (
      call "%%?~dp0%%touch_dir.bat" "%%TO_PATH%%"
    )
  ) else (
    if %FLAG_TOUCH_FILE% NEQ 0 (
      call "%%?~dp0%%touch_file.bat" "%%TO_PATH%%"
    )
  )
)

endlocal

:SKIP_TOUCH

echo.^>^>move%XMOVE_FLAGS:~1% "%FROM_PATH_ABS%" "%TO_PATH_ABS%"
move%XMOVE_FLAGS:~1% "%FROM_PATH_ABS%" "%TO_PATH_ABS%"
set LAST_ERROR=%ERRORLEVEL%

if %FLAG_USE_BUILTIN_MOVE% NEQ 0 exit /b %LAST_ERROR%

rem fall back to `robocopy.exe` usage
if %LAST_ERROR% NEQ 0 goto USE_ROBOCOPY

exit /b 0

:ROBOCOPY_FLAGS_CONVERT
set "XMOVE_FLAG=%~1"
if not defined XMOVE_FLAG exit /b 0
set XMOVE_FLAG_PARSED=0
if "%XMOVE_FLAG%" == "/S" (
  echo.%?~nx0%: error: /S flag is not supported.
  exit /b 1
) >&2
if "%XMOVE_FLAG%" == "/E" exit /b 0
if "%XMOVE_FLAG:~0,4%" == "/MOV" (
  echo.%?~nx0%: error: /MOV and /MOVE parameters is not accepted to move a directory.
  exit /b 1
) >&2
if %XMOVE_FLAG_PARSED% EQU 0 set "XMOVE_FLAGS=%XMOVE_FLAGS% %XMOVE_FLAG%"
exit /b 0

:USE_ROBOCOPY
call :GET_WINDOWS_VERSION

set "ROBOCOPY_FLAGS= "
set "ROBOCOPY_ATTR_COPY=0"
set "ROBOCOPY_COPY_FLAGS=DAT"
set "ROBOCOPY_DCOPY_FLAGS=T"
if %WINDOWS_MAJOR_VER% GTR 6 ( set "ROBOCOPY_DCOPY_FLAGS=DAT" ) else if %WINDOWS_MAJOR_VER% EQU 6 if %WINDOWS_MINOR_VER% GEQ 2 set "ROBOCOPY_DCOPY_FLAGS=DAT"
set "XMOVE_Y_FLAG_PARSED=0"
for %%i in (%XMOVE_FLAGS_%) do (
  set XMOVE_FLAG=%%i
  call :XMOVE_FLAGS_CONVERT %%XMOVE_FLAG%% || exit /b -250
)

set "ROBOCOPY_EXCLUDES_CMD="

if not defined XCOPY_EXCLUDE_FILES_LIST if not defined XCOPY_EXCLUDE_DIRS_LIST goto IGNORE_ROBOCOPY_EXCLUDES

call "%%CONTOOLS_ROOT%%/xcopy/convert_excludes_to_robocopy.bat" "%%XCOPY_EXCLUDE_FILES_LIST%%" "%%XCOPY_EXCLUDE_DIRS_LIST%%" || (
  echo.%?~nx0%: error: robocopy excludes list is invalid:
  echo.  XCOPY_EXCLUDE_FILES_LIST="%XCOPY_EXCLUDE_FILES_LIST%"
  echo.  XCOPY_EXCLUDES_LIST_TMP ="%XCOPY_EXCLUDES_LIST_TMP%"
  exit /b -246
) >&2
if %ERRORLEVEL% EQU 0 set ROBOCOPY_EXCLUDES_CMD=%RETURN_VALUE%

:IGNORE_ROBOCOPY_EXCLUDES

rem NOTE: does not copy a file in case of equal timestamps and size, even if `/IS` and/or `/IT` is used
if %XMOVE_Y_FLAG_PARSED% EQU 0 if "%ROBOCOPY_FLAGS:/XO=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XO"
if %XMOVE_Y_FLAG_PARSED% EQU 0 if "%ROBOCOPY_FLAGS:/XC=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XC"
if %XMOVE_Y_FLAG_PARSED% EQU 0 if "%ROBOCOPY_FLAGS:/XN=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XN"

if %XMOVE_Y_FLAG_PARSED% NEQ 0 if "%ROBOCOPY_FLAGS:/IS=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /IS"
if %XMOVE_Y_FLAG_PARSED% NEQ 0 if "%ROBOCOPY_FLAGS:/IT=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /IT"

if "%ROBOCOPY_FLAGS:/COPY=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /COPY:%ROBOCOPY_COPY_FLAGS%"
if "%ROBOCOPY_FLAGS:/DCOPY=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /DCOPY:%ROBOCOPY_DCOPY_FLAGS%"

if %FLAG_TOUCH_DIR%%FLAG_TOUCH_FILE% EQU 0 goto SKIP_TOUCH

echo.^>^>touch "%TO_PATH_ABS%\*"

setlocal

set TOOLS_VERBOSE=0

set "BUILTIN_DIR_CMD_BARE_FLAGS="
if %FLAG_TOUCH_DIR% EQU 0 (
  set BUILTIN_DIR_CMD_BARE_FLAGS=%BUILTIN_DIR_CMD_BARE_FLAGS% /A:-D
) else if %FLAG_TOUCH_FILE% EQU 0 (
  set BUILTIN_DIR_CMD_BARE_FLAGS=%BUILTIN_DIR_CMD_BARE_FLAGS% /A:D
)

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
set ?.=@dir "%TO_PATH_ABS%"%BUILTIN_DIR_CMD_BARE_FLAGS% /B /O:N /S 2^>nul

if %FLAG_TOUCH_DIR% EQU 0 (
  for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
    set "TO_PATH=%%i"
    call "%%?~dp0%%touch_file.bat" "%%TO_PATH%%"
  )
) else if %FLAG_TOUCH_FILE% EQU 0 (
  for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
    set "TO_PATH=%%i"
    call "%%?~dp0%%touch_dir.bat" "%%TO_PATH%%"
  )
) else for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
  set "TO_PATH=%%i"
  if exist "\\?\%TO_PATH%\*" (
    if %FLAG_TOUCH_DIR% NEQ 0 (
      call "%%?~dp0%%touch_dir.bat" "%%TO_PATH%%"
    )
  ) else (
    if %FLAG_TOUCH_FILE% NEQ 0 (
      call "%%?~dp0%%touch_file.bat" "%%TO_PATH%%"
    )
  )
)

endlocal

:SKIP_TOUCH

echo.^>^>"%SystemRoot%\System32\robocopy.exe" "%FROM_PATH_ABS%" "%TO_PATH_ABS%" /R:0 /W:0 /NP /NJH /NS /NC /E /MOVE /XX%ROBOCOPY_FLAGS:~1%%ROBOCOPY_EXCLUDES_CMD%%ROBOCOPY_DIR_BARE_FLAGS%
"%SystemRoot%\System32\robocopy.exe" "%FROM_PATH_ABS%" "%TO_PATH_ABS%" /R:0 /W:0 /NP /NJH /NS /NC /E /MOVE /XX%ROBOCOPY_FLAGS:~1%%ROBOCOPY_EXCLUDES_CMD%%ROBOCOPY_DIR_BARE_FLAGS%
if %ERRORLEVEL% LSS 8 exit /b 0
exit /b

:GET_WINDOWS_VERSION
rem `get_windows_version.bat` inline
set "WINDOWS_VER_STR="
for /F "usebackq tokens=1,* delims=[" %%i in (`@ver 2^>nul`) do for /F "tokens=1,* delims=]" %%k in ("%%j") do set "WINDOWS_VER_STR=%%k"
setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!WINDOWS_VER_STR:* =!"') do endlocal & set "WINDOWS_VER_STR=%%~i"
set WINDOWS_MAJOR_VER=0
set WINDOWS_MINOR_VER=0
for /F "tokens=1,2,* delims=."eol^= %%i in ("%WINDOWS_VER_STR%") do set "WINDOWS_MAJOR_VER=%%i" & set "WINDOWS_MINOR_VER=%%j"
exit /b 0

:XMOVE_FLAGS_CONVERT
set "XMOVE_FLAG=%~1"
if not defined XMOVE_FLAG exit /b 0
set XMOVE_FLAG_PARSED=0
if "%XMOVE_FLAG%" == "/Y" (
  set XMOVE_Y_FLAG_PARSED=1
  exit /b 0
)
if "%XMOVE_FLAG%" == "/R" exit /b 0
if "%XMOVE_FLAG%" == "/D" (
  if "%ROBOCOPY_FLAGS:/XO=%" == "%ROBOCOPY_FLAGS%" set ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XO
  set XMOVE_FLAG_PARSED=1
)
rem CAUTION:
rem   DO NOT USE "/IA" flag because:
rem   1. It does implicitly exclude those files which were not included (implicit exclude).
rem   2. It does ignore files without any attribute even if all attribute set is used: `/IA:RASHCNETO`.
rem
rem if %ROBOCOPY_ATTR_COPY% EQU 0 if "%XMOVE_FLAG%" == "/H" ( set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /IA:RASHCNETO" & set "XMOVE_FLAG_PARSED=1" & set "ROBOCOPY_ATTR_COPY=1" )
rem if %ROBOCOPY_ATTR_COPY% EQU 0 if "%XMOVE_FLAG%" == "/K" ( set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /IA:RASHCNETO" & set "XMOVE_FLAG_PARSED=1" & set "ROBOCOPY_ATTR_COPY=1" )
if %ROBOCOPY_ATTR_COPY% EQU 0 if "%XMOVE_FLAG%" == "/H" ( set "XMOVE_FLAG_PARSED=1" & set "ROBOCOPY_ATTR_COPY=1" )
if %ROBOCOPY_ATTR_COPY% EQU 0 if "%XMOVE_FLAG%" == "/K" ( set "XMOVE_FLAG_PARSED=1" & set "ROBOCOPY_ATTR_COPY=1" )
if "%XMOVE_FLAG%" == "/O" call :SET_ROBOCOPY_SO_FLAGS
rem NOTE: in case of `robocopy` - use lowercase `/x`
if "%XMOVE_FLAG%" == "/X" call :SET_ROBOCOPY_U_FLAG
if %XMOVE_FLAG_PARSED% EQU 0 set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% %XMOVE_FLAG%"
exit /b 0

:SET_ROBOCOPY_SO_FLAGS
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS:S=%"
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS:O=%"
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS%SO"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS:S=%"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS:O=%"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS%SO"
set XMOVE_FLAG_PARSED=1
exit /b 0

:SET_ROBOCOPY_U_FLAG
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS:U=%"
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS%U"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS:U=%"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS%U"
set XMOVE_FLAG_PARSED=1
exit /b 0
