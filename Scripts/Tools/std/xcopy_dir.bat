@echo off

rem USAGE:
rem   xcopy_dir.bat [<flags>] [--] <from-path> <to-path> [<xcopy-flags>...]

rem Description:
rem   The `xcopy.exe`/`robocopy.exe` seemless wrapper script with xcopy
rem   compatible command line flags/excludes, echo and some conditions check
rem   before call to copy a directory to a directory.

rem CAUTION:
rem   `xcopy.exe` has a file path limit up to 260 characters in a path. To
rem   bypass that limitation we use `robocopy.exe` instead if existed
rem   (Windows Vista and higher ONLY), otherwise falls back to `xcopy.exe`.
rem
rem   `robocopy.exe` will copy hidden and archive files by default.
rem
rem   `robocopy` does not overwrite files with the same timestamp and size,
rem   even if content is different and `/IS` and/or `/IT` flags are used.
rem   See details:
rem     https://superuser.com/questions/1114377/does-robocopy-skip-copying-existing-files-by-default/1114381#1114381
rem     https://superuser.com/questions/1114377/does-robocopy-skip-copying-existing-files-by-default/1347329#1347329
rem   To avoid that you have to use `-touch_file` and/or `-touch_dir` flags to
rem   touch the output before the copy.

rem <flags>:
rem   -chcp <CodePage>
rem     Set explicit code page.
rem
rem   -use_xcopy
rem     Use `xcopy` executable utility instead of `robocopy` executable
rem     utility.
rem     Has no effect if `-use_robocopy` flag is used.
rem     CAUTION:
rem       Copy can fail with that flag in case of a long path.
rem
rem   -use_robocopy
rem     Use `robocopy` executable utility instead of `xcopy` executable
rem     utility.
rem     Can not be used if `robocopy.exe` is not found.
rem     NOTE:
rem       Movement is emulated by copy+delete `robocopy.exe` internal logic.
rem
rem   -ignore_unexist
rem     By default `<to-path>` does check on directory existence and throw
rem     an error if not exists.
rem     Use this flag to ignore unexisted target directory.
rem
rem   -touch_dir
rem     Use `touch_dir.bat` script to touch the output directories before the
rem     copy.
rem
rem   -touch_file
rem     Use `touch_file.bat` script to touch the output files before the copy.

rem --:
rem   Separator to stop parse flags.

rem <from-path>:
rem   From directory path.

rem <to-path>:
rem   To directory path.

rem <xcopy-flags>:
rem   Command line flags to pass into subsequent utilities.

echo.^>%~nx0 %*

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

rem script flags
set FLAG_SHIFT=0
set "FLAG_CHCP="
set FLAG_USE_XCOPY=0
set FLAG_USE_ROBOCOPY=0
set FLAG_IGNORE_UNEXIST=0
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
  ) else if "%FLAG%" == "-use_xcopy" (
    set FLAG_USE_XCOPY=1
  ) else if "%FLAG%" == "-use_robocopy" (
    set FLAG_USE_ROBOCOPY=1
  ) else if "%FLAG%" == "-ignore_unexist" (
    set FLAG_IGNORE_UNEXIST=1
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

for /F "eol= tokens=* delims=" %%i in ("%FROM_PATH%\.") do set "FROM_PATH_ABS=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%TO_PATH%\.") do set "TO_PATH_ABS=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%TO_PATH_ABS%") do for /F "eol= tokens=* delims=" %%j in ("%%~dpi.") do set "TO_PARENT_DIR_ABS=%%~fj"

if not exist "\\?\%FROM_PATH_ABS%\*" (
  echo.%?~nx0%: error: input directory does not exist:
  echo.  FROM_PATH="%FROM_PATH%"
  exit /b -248
) >&2

if %FLAG_IGNORE_UNEXIST% NEQ 0 goto IGNORE_TO_PATH_UNEXIST

if not exist "\\?\%TO_PATH_ABS%\*" (
  echo.%?~nx0%: error: output directory does not exist:
  echo.  TO_PATH="%TO_PATH%"
  exit /b -247
) >&2

goto INIT

:IGNORE_TO_PATH_UNEXIST

if not exist "\\?\%TO_PARENT_DIR_ABS%\*" (
  echo.%?~nx0%: error: output parent directory does not exist:
  echo.  TO_PARENT_DIR_ABS="%TO_PARENT_DIR_ABS%"
  exit /b -249
) >&2

:INIT
call "%%?~dp0%%__init__.bat" || exit /b

set /A FLAG_SHIFT+=2

call "%%?~dp0%%setshift.bat" %%FLAG_SHIFT%% XCOPY_FLAGS_ %%*

rem CAUTION:
rem   You must switch code page into english compatible locale.
rem
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%FLAG_CHCP%%

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem restore locale
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b %LASTERROR%

:MAIN
if %FLAG_USE_XCOPY% EQU 0 (
  if not exist "%SystemRoot%\System32\robocopy.exe" (
    if %FLAG_USE_ROBOCOPY% NEQ 0 (
      echo.%?~nx0%: error: `robocopy.exe` is not found.
      exit /b -240
    ) >&2
    set FLAG_USE_XCOPY=1
  )
) else if %FLAG_USE_ROBOCOPY% NEQ 0 (
  if not exist "%SystemRoot%\System32\robocopy.exe" (
    echo.%?~nx0%: error: `robocopy.exe` is not found.
    exit /b -240
  ) >&2
)

if %FLAG_USE_XCOPY% NEQ 0 goto USE_XCOPY
if %FLAG_USE_ROBOCOPY% NEQ 0 goto USE_ROBOCOPY
goto USE_ROBOCOPY

:USE_XCOPY
set "XCOPY_FLAGS= "
for %%i in (%XCOPY_FLAGS_%) do (
  set XCOPY_FLAG=%%i
  call :ROBOCOPY_FLAGS_CONVERT %%XCOPY_FLAG%% || exit /b -250
)

set "XCOPY_EXCLUDES_CMD="
set "XCOPY_EXCLUDES_LIST_TMP="

if not defined XCOPY_EXCLUDE_FILES_LIST if not defined XCOPY_EXCLUDE_DIRS_LIST goto IGNORE_XCOPY_EXCLUDES

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || ( set "LAST_ERROR=255" & goto EXIT )

set "XCOPY_EXCLUDES_LIST_TMP=%SCRIPT_TEMP_CURRENT_DIR%\$xcopy_excludes.lst"

call "%%CONTOOLS_ROOT%%/xcopy/convert_excludes_to_xcopy.bat" "%%XCOPY_EXCLUDE_FILES_LIST%%" "%%XCOPY_EXCLUDE_DIRS_LIST%%" "%%XCOPY_EXCLUDES_LIST_TMP%%" || (
  echo.%?~nx0%: error: xcopy excludes list is invalid:
  echo.  XCOPY_EXCLUDE_FILES_LIST="%XCOPY_EXCLUDE_FILES_LIST%"
  echo.  XCOPY_EXCLUDES_LIST_TMP ="%XCOPY_EXCLUDES_LIST_TMP%"
  set LAST_ERROR=-250
  goto EXIT
) >&2
if %ERRORLEVEL% EQU 0 set "XCOPY_EXCLUDES_CMD=/EXCLUDE:%XCOPY_EXCLUDES_LIST_TMP%"

:IGNORE_XCOPY_EXCLUDES

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
  for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
    set "TO_PATH=%%i"
    call "%%?~dp0%%touch_file.bat" "%%TO_PATH%%"
  )
) else if %FLAG_TOUCH_FILE% EQU 0 (
  for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
    set "TO_PATH=%%i"
    call "%%?~dp0%%touch_dir.bat" "%%TO_PATH%%"
  )
) else for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
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

rem echo.D will ONLY work if locale is compatible with english !!!
echo.^>^>"%SystemRoot%\System32\xcopy.exe" "%FROM_PATH_ABS%" "%TO_PATH_ABS%"%XCOPY_FLAGS:~1% %XCOPY_EXCLUDES_CMD%%XCOPY_DIR_BARE_FLAGS%
echo.D|"%SystemRoot%\System32\xcopy.exe" "%FROM_PATH_ABS%" "%TO_PATH_ABS%"%XCOPY_FLAGS:~1% %XCOPY_EXCLUDES_CMD%%XCOPY_DIR_BARE_FLAGS%

set LAST_ERROR=%ERRORLEVEL%

:EXIT
if defined XCOPY_EXCLUDES_LIST_TMP (
  rem cleanup temporary files
  call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"
)

exit /b %LAST_ERROR%

:ROBOCOPY_FLAGS_CONVERT
set "XCOPY_FLAG=%~1"
if not defined XCOPY_FLAG exit /b 0
set XCOPY_FLAG_PARSED=0
if "%XCOPY_FLAG:~0,4%" == "/MOV" (
  echo.%?~nx0%: error: /MOV and /MOVE parameters is not accepted to copy a directory.
  exit /b 1
) >&2
if %XCOPY_FLAG_PARSED% EQU 0 set "XCOPY_FLAGS=%XCOPY_FLAGS% %XCOPY_FLAG%"
exit /b 0

:USE_ROBOCOPY
set "ROBOCOPY_FLAGS= "
set "ROBOCOPY_ATTR_COPY=0"
set "ROBOCOPY_COPY_FLAGS=DAT"
set "ROBOCOPY_DCOPY_FLAGS=DAT"
set "XCOPY_Y_FLAG_PARSED=0"
for %%i in (%XCOPY_FLAGS_%) do (
  set XCOPY_FLAG=%%i
  call :XCOPY_FLAGS_CONVERT %%XCOPY_FLAG%% || exit /b -250
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
if %XCOPY_Y_FLAG_PARSED% EQU 0 if "%ROBOCOPY_FLAGS:/XO=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XO"
if %XCOPY_Y_FLAG_PARSED% EQU 0 if "%ROBOCOPY_FLAGS:/XC=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XC"
if %XCOPY_Y_FLAG_PARSED% EQU 0 if "%ROBOCOPY_FLAGS:/XN=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XN"

if %XCOPY_Y_FLAG_PARSED% NEQ 0 if "%ROBOCOPY_FLAGS:/IS=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /IS"
if %XCOPY_Y_FLAG_PARSED% NEQ 0 if "%ROBOCOPY_FLAGS:/IT=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /IT"

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
  for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
    set "TO_PATH=%%i"
    call "%%?~dp0%%touch_file.bat" "%%TO_PATH%%"
  )
) else if %FLAG_TOUCH_FILE% EQU 0 (
  for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
    set "TO_PATH=%%i"
    call "%%?~dp0%%touch_dir.bat" "%%TO_PATH%%"
  )
) else for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
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

echo.^>^>"%SystemRoot%\System32\robocopy.exe" "%FROM_PATH_ABS%" "%TO_PATH_ABS%" /R:0 /W:0 /NP /NJH /NS /NC /XX%ROBOCOPY_FLAGS:~1% %ROBOCOPY_EXCLUDES_CMD%%ROBOCOPY_DIR_BARE_FLAGS%
"%SystemRoot%\System32\robocopy.exe" "%FROM_PATH_ABS%" "%TO_PATH_ABS%" /R:0 /W:0 /NP /NJH /NS /NC /XX%ROBOCOPY_FLAGS:~1% %ROBOCOPY_EXCLUDES_CMD%%ROBOCOPY_DIR_BARE_FLAGS%
if %ERRORLEVEL% LSS 8 exit /b 0
exit /b

:XCOPY_FLAGS_CONVERT
set "XCOPY_FLAG=%~1"
if not defined XCOPY_FLAG exit /b 0
set XCOPY_FLAG_PARSED=0
if "%XCOPY_FLAG%" == "/Y" (
  set XCOPY_Y_FLAG_PARSED=1
  exit /b 0
)
if "%XCOPY_FLAG%" == "/R" exit /b 0
if "%XCOPY_FLAG%" == "/D" (
  if "%ROBOCOPY_FLAGS:/XO=%" == "%ROBOCOPY_FLAGS%" set ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XO
  set XCOPY_FLAG_PARSED=1
)
rem CAUTION:
rem   DO NOT USE "/IA" flag because:
rem   1. It does implicitly exclude those files which were not included (implicit exclude).
rem   2. It does ignore files without any attribute even if all attribute set is used: `/IA:RASHCNETO`.
rem
rem if %ROBOCOPY_ATTR_COPY% EQU 0 if "%XCOPY_FLAG%" == "/H" ( set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /IA:RASHCNETO" & set "XCOPY_FLAG_PARSED=1" & set "ROBOCOPY_ATTR_COPY=1" )
rem if %ROBOCOPY_ATTR_COPY% EQU 0 if "%XCOPY_FLAG%" == "/K" ( set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /IA:RASHCNETO" & set "XCOPY_FLAG_PARSED=1" & set "ROBOCOPY_ATTR_COPY=1" )
if %ROBOCOPY_ATTR_COPY% EQU 0 if "%XCOPY_FLAG%" == "/H" ( set "XCOPY_FLAG_PARSED=1" & set "ROBOCOPY_ATTR_COPY=1" )
if %ROBOCOPY_ATTR_COPY% EQU 0 if "%XCOPY_FLAG%" == "/K" ( set "XCOPY_FLAG_PARSED=1" & set "ROBOCOPY_ATTR_COPY=1" )
if "%XCOPY_FLAG%" == "/O" call :SET_ROBOCOPY_SO_FLAGS
rem NOTE: in case of `robocopy` - use lowercase `/x`
if "%XCOPY_FLAG%" == "/X" call :SET_ROBOCOPY_U_FLAG
if %XCOPY_FLAG_PARSED% EQU 0 set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% %XCOPY_FLAG%"
exit /b 0

:SET_ROBOCOPY_SO_FLAGS
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS:S=%"
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS:O=%"
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS%SO"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS:S=%"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS:O=%"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS%SO"
set XCOPY_FLAG_PARSED=1
exit /b 0

:SET_ROBOCOPY_U_FLAG
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS:U=%"
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS%U"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS:U=%"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS%U"
set XCOPY_FLAG_PARSED=1
exit /b 0
