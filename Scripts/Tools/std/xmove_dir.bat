@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   The `move`/`robocopy.exe` seemless wrapper script with xcopy
rem   compatible command line flags/excludes, echo and some conditions check
rem   before call to move a directory to a directory.

rem CAUTION:
rem   `move` has a file path limit up to 260 characters in a path. To
rem   bypass that limitation we have to use `robocopy.exe` instead
rem   (Windows Vista and higher ONLY).
rem
rem   `move` has lower limit for long paths as, for example, for the `if`
rem    statement, so the `robocopy.exe` is unconditional fall back if the
rem   `move` fails.
rem
rem   In case of default command line the `robocopy.exe` will move files with
rem   all attributes, but not timestamps (`/COPY:DAT /DCOPY:DAT /MOVE`).
rem
rem   This happens because `robocopy.exe` can not move not empty directories
rem   without a directory modification timestamp change when it does shallow
rem   copy source directories hierarchy and then does copy files into it.
rem
rem   But we need to preserve timestamps and move all directories without
rem   any timestamp modification. So we use `move` command by default and if it
rem   has failed, then fall back to the `robocopy.exe` to copy and then delete.
rem

echo.^>%~nx0 %*

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

rem script flags
set "FLAG_CHCP="
rem Force `move` instead of `robocopy.exe` usage.
rem CAUTION: Movement can fail with that flag in case of a long path.
set FLAG_USE_BUILTIN_MOVE=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else if "%FLAG%" == "-use_builtin_move" (
    set FLAG_USE_BUILTIN_MOVE=1
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
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
  echo.%?~nx0%: error: input directory path is invalid: FROM_PATH="%FROM_PATH%" TO_PATH="%TO_PATH%".
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
  echo.%?~nx0%: error: output directory path is invalid: FROM_PATH="%FROM_PATH%" TO_PATH="%TO_PATH%".
  exit /b -249
) >&2

:TO_PATH_OK

for /F "eol= tokens=* delims=" %%i in ("%~f1\.") do set "FROM_PATH_ABS=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%~f2\.") do set "TO_PATH_ABS=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%TO_PATH_ABS%") do for /F "eol= tokens=* delims=" %%j in ("%%~dpi\.") do set "TO_PARENT_DIR_ABS=%%~fj"

if not exist "\\?\%FROM_PATH_ABS%\*" (
  echo.%?~n0%: error: input directory does not exist: "%FROM_PATH%\"
  exit /b -248
) >&2

rem CAUTION:
rem   We must always check on target path existence, because:
rem   1. Difference between `move` and `robocopy.exe` in case of existed path.
rem   2. To be able to rename the input directory.
rem
if exist "\\?\%TO_PATH_ABS%\*" (
  echo.%?~n0%: error: output directory does exist: "%TO_PATH%\"
  exit /b -247
) >&2

if not exist "\\?\%TO_PARENT_DIR_ABS%\*" (
  echo.%?~n0%: error: output parent directory does not exist: "%TO_PARENT_DIR_ABS%"
  exit /b -249
) >&2

call "%%?~dp0%%__init__.bat" || exit /b

set XMOVE_FLAGS_=%3 %4 %5 %6 %7 %8 %9

set "XMOVE_FLAGS="
for %%i in (%XMOVE_FLAGS_%) do (
  set XMOVE_FLAG=%%i
  call :ROBOCOPY_FLAGS_CONVERT %%XMOVE_FLAG%% || exit /b -250
)

rem CAUTION:
rem   You must switch code page into english compatible locale.
rem
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%FLAG_CHCP%%

if %FLAG_USE_BUILTIN_MOVE% EQU 0 ^
if not exist "%SystemRoot%\system32\robocopy.exe" set FLAG_USE_BUILTIN_MOVE=1

echo.^>^>move%XMOVE_FLAGS% "%FROM_PATH_ABS%" "%TO_PATH_ABS%"
move%XMOVE_FLAGS% "%FROM_PATH_ABS%" "%TO_PATH_ABS%"

set LASTERROR=%ERRORLEVEL%

rem restore locale
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

if %FLAG_USE_BUILTIN_MOVE% NEQ 0 exit /b %LASTERROR%

rem fall back to `robocopy.exe` usage
if %LASTERROR% NEQ 0 goto USE_ROBOCOPY

exit /b 0

:ROBOCOPY_FLAGS_CONVERT
set "XMOVE_FLAG=%~1"
if not defined XMOVE_FLAG exit /b 0
set XMOVE_FLAG_PARSED=0
if "%XMOVE_FLAG:~0,4%" == "/MOV" (
  echo.%?~n0%: error: /MOV and /MOVE parameters is not accepted to copy a directory.
  exit /b 1
) >&2
if %XMOVE_FLAG_PARSED% EQU 0 set "XMOVE_FLAGS=%XMOVE_FLAGS% %XMOVE_FLAG%"
exit /b 0

:USE_ROBOCOPY
set "ROBOCOPY_FLAGS="
set "ROBOCOPY_ATTR_COPY=0"
if not defined ROBOCOPY_COPY_FLAGS set "ROBOCOPY_COPY_FLAGS=DAT"
if not defined ROBOCOPY_DCOPY_FLAGS set "ROBOCOPY_DCOPY_FLAGS=DAT"
for %%i in (%XMOVE_FLAGS_%) do (
  set XMOVE_FLAG=%%i
  call :XMOVE_FLAGS_CONVERT %%XMOVE_FLAG%% || exit /b -250
)

set "ROBOCOPY_EXCLUDES_CMD="

if not defined XCOPY_EXCLUDE_FILES_LIST if not defined XCOPY_EXCLUDE_DIRS_LIST goto IGNORE_ROBOCOPY_EXCLUDES

call "%%CONTOOLS_ROOT%%/xcopy/convert_excludes_to_robocopy.bat" "%%XCOPY_EXCLUDE_FILES_LIST%%" "%%XCOPY_EXCLUDE_DIRS_LIST%%" || (
  echo.%?~n0%: error: robocopy excludes list is invalid: XCOPY_EXCLUDE_FILES_LIST="%XCOPY_EXCLUDE_FILES_LIST%" XCOPY_EXCLUDES_LIST_TMP="%XCOPY_EXCLUDES_LIST_TMP%"
  exit /b -246
) >&2
if %ERRORLEVEL% EQU 0 set ROBOCOPY_EXCLUDES_CMD=%RETURN_VALUE%

:IGNORE_ROBOCOPY_EXCLUDES

if not defined ROBOCOPY_FLAGS ( set "ROBOCOPY_FLAGS= /COPY:%ROBOCOPY_COPY_FLAGS% /DCOPY:%ROBOCOPY_DCOPY_FLAGS%" & goto SKIP_ROBOCOPY_FLAGS )
if "%ROBOCOPY_FLAGS:/COPY=%" == "%ROBOCOPY_FLAGS%"  set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /COPY:%ROBOCOPY_COPY_FLAGS%"
if "%ROBOCOPY_FLAGS:/DCOPY=%" == "%ROBOCOPY_FLAGS%"  set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /DCOPY:%ROBOCOPY_DCOPY_FLAGS%"

:SKIP_ROBOCOPY_FLAGS

echo.^>^>"%SystemRoot%\System32\robocopy.exe" "%FROM_PATH_ABS%" "%TO_PATH_ABS%" /R:0 /W:0 /NP /TEE /NJH /NS /NC /XX /E /MOVE%ROBOCOPY_FLAGS% %ROBOCOPY_EXCLUDES_CMD%%ROBOCOPY_DIR_BARE_FLAGS%
"%SystemRoot%\System32\robocopy.exe" "%FROM_PATH_ABS%" "%TO_PATH_ABS%" /R:0 /W:0 /NP /TEE /NJH /NS /NC /XX /E /MOVE%ROBOCOPY_FLAGS% %ROBOCOPY_EXCLUDES_CMD%%ROBOCOPY_DIR_BARE_FLAGS%
if %ERRORLEVEL% LSS 8 exit /b 0
exit /b

:XMOVE_FLAGS_CONVERT
set "XMOVE_FLAG=%~1"
if not defined XMOVE_FLAG exit /b 0
set XMOVE_FLAG_PARSED=0
if "%XMOVE_FLAG%" == "/Y" exit /b 0
if "%XMOVE_FLAG%" == "/R" exit /b 0
if "%XMOVE_FLAG%" == "/D" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XO" & set XMOVE_FLAG_PARSED=1
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
if "%XMOVE_FLAG%" == "/X" call :SET_ROBOCOPY_U_FLAG
if %XMOVE_FLAG_PARSED% EQU 0 set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% %XMOVE_FLAG%"
exit /b 0

:SET_ROBOCOPY_SO_FLAGS
if not defined ROBOCOPY_COPY_FLAGS ( set "ROBOCOPY_COPY_FLAGS=SO" & goto SET_DCOPY_FLAGS )
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS:S=%"
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS:O=%"
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS%SO"
:SET_DCOPY_FLAGS
if not defined ROBOCOPY_DCOPY_FLAGS ( set "ROBOCOPY_DCOPY_FLAGS=SO" & exit /b 0 )
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS:S=%"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS:O=%"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS%SO"
set XMOVE_FLAG_PARSED=1
exit /b 0

:SET_ROBOCOPY_U_FLAG
if not defined ROBOCOPY_COPY_FLAGS ( set "ROBOCOPY_COPY_FLAGS=U" & goto SET_DCOPY_FLAGS )
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS:U=%"
set "ROBOCOPY_COPY_FLAGS=%ROBOCOPY_COPY_FLAGS%U"
:SET_DCOPY_FLAGS
if not defined ROBOCOPY_DCOPY_FLAGS ( set "ROBOCOPY_DCOPY_FLAGS=U" & exit /b 0 )
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS:U=%"
set "ROBOCOPY_DCOPY_FLAGS=%ROBOCOPY_DCOPY_FLAGS%U"
set XMOVE_FLAG_PARSED=1
exit /b 0
