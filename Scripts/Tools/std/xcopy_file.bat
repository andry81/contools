@echo off

rem USAGE:
rem   xcopy_file.bat [<flags>] [--] <from-path> <from-file-pttn> <to-path> [<xcopy-flags>...]

rem Description:
rem   The `xcopy.exe`/`robocopy.exe` seemless wrapper script with xcopy
rem   compatible command line flags/excludes, echo and some conditions check
rem   before call to copy a file or file pattern in a directory to another
rem   directory.

rem CAUTION:
rem   `xcopy.exe` has a file path limit up to 260 characters in a path. To
rem   bypass that limitation we have to use `robocopy.exe` instead
rem   (Windows Vista and higher ONLY).
rem
rem   `robocopy.exe` will copy hidden and archive files by default.

rem <flags>:
rem   -chcp <CodePage>
rem     Set explicit code page.
rem
rem   -use_xcopy
rem     Use `xcopy` executable utility.

rem --:
rem   Separator to stop parse flags.

rem <from-path>:
rem   From directory path.

rem <from-file-pttn>:
rem   From file pattern.

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
set "FLAG_CHCP="
rem Force `xcopy.exe` instead of `robocopy.exe` usage.
rem CAUTION: Copy can fail with that flag in case of a long path.
set FLAG_USE_XCOPY=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else if "%FLAG%" == "-use_xcopy" (
    set FLAG_USE_XCOPY=1
  ) else if not "%FLAG%" == "--" (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

set "FROM_PATH=%~1"
set "FROM_FILE=%~2"
set "TO_PATH=%~3"

if not defined FROM_PATH (
  echo.%?~nx0%: error: input directory path argument must be defined.
  exit /b -255
) >&2

if not defined FROM_FILE (
  echo.%?~nx0%: error: input file argument must be defined.
  exit /b -254
) >&2

if not defined TO_PATH (
  echo.%?~nx0%: error: output directory path argument must be defined.
  exit /b -253
) >&2

set "FROM_PATH=%FROM_PATH:/=\%"
set "FROM_FILE=%FROM_FILE:/=\%"
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
  echo.  FROM_FILE="%FROM_FILE%"
  echo.  TO_PATH  ="%TO_PATH%"
  exit /b -248
) >&2

:FROM_PATH_OK

rem check on missed components...

rem check on invalid characters in file pattern
if not "%FROM_FILE%" == "%FROM_FILE:\=%" goto FROM_FILE_ERROR

goto FROM_FILE_OK

:FROM_FILE_ERROR
(
  echo.%?~nx0%: error: input file is invalid: FROM_PATH="%FROM_PATH%" FROM_FILE="%FROM_FILE%" TO_PATH="%TO_PATH%".
  exit /b -248
) >&2

:FROM_FILE_OK

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
  echo.  FROM_FILE="%FROM_FILE%"
  echo.  TO_PATH  ="%TO_PATH%"
  exit /b -249
) >&2

:TO_PATH_OK

for /F "eol= tokens=* delims=" %%i in ("%FROM_PATH%\.") do set "FROM_DIR_PATH_ABS=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%TO_PATH%\.") do set "TO_PATH_ABS=%%~fi"

if not exist "\\?\%FROM_DIR_PATH_ABS%\*" (
  echo.%?~nx0%: error: input directory does not exist:
  echo.  FROM_PATH="%FROM_PATH%"
  exit /b -248
) >&2

set "FROM_FILE_PATH_ABS=%FROM_DIR_PATH_ABS%\%FROM_FILE%"

rem check on glob characters in file name
if not "%FROM_FILE%" == "%FROM_FILE:**=%" goto SKIP_FROM_FILE_CHECK
if not "%FROM_FILE%" == "%FROM_FILE:?=%" goto SKIP_FROM_FILE_CHECK

rem check on input file existence
if not exist "\\?\%FROM_FILE_PATH_ABS%" (
  echo.%?~nx0%: error: input file path does not exist:
  echo.  FROM_FILE_PATH="%FROM_PATH%\%FROM_FILE%"
  exit /b -248
) >&2

rem check on input file as directory existence
if exist "\\?\%FROM_FILE_PATH_ABS%\*" (
  echo.%?~nx0%: error: input file is a directory:
  echo.  FROM_FILE_PATH="%FROM_PATH%\%FROM_FILE%"
  exit /b -248
) >&2

:SKIP_FROM_FILE_CHECK

if not exist "\\?\%TO_PATH_ABS%\*" (
  echo.%?~nx0%: error: output directory does not exist:
  echo.  TO_PATH="%TO_PATH%"
  exit /b -247
) >&2

call "%%?~dp0%%__init__.bat" || exit /b

call "%%?~dp0%%setshift.bat" 3 XCOPY_FLAGS_ %%*

if %FLAG_USE_XCOPY% NEQ 0 goto USE_XCOPY
if exist "%SystemRoot%\System32\robocopy.exe" goto USE_ROBOCOPY

:USE_XCOPY
set "XCOPY_FLAGS="
for %%i in (%XCOPY_FLAGS_%) do (
  set XCOPY_FLAG=%%i
  call :ROBOCOPY_FLAGS_CONVERT %%XCOPY_FLAG%% || exit /b -250
)

rem CAUTION:
rem   You must switch code page into english compatible locale.
rem
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%FLAG_CHCP%%

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

rem echo.F will ONLY work if locale is compatible with english !!!
echo.^>^>"%SystemRoot%\System32\xcopy.exe" "%FROM_FILE_PATH_ABS%" "%TO_PATH_ABS%" %XCOPY_FLAGS% %XCOPY_EXCLUDES_CMD%%XCOPY_FILE_BARE_FLAGS%
echo.F|"%SystemRoot%\System32\xcopy.exe" "%FROM_FILE_PATH_ABS%" "%TO_PATH_ABS%" %XCOPY_FLAGS% %XCOPY_EXCLUDES_CMD%%XCOPY_FILE_BARE_FLAGS%

set LAST_ERROR=%ERRORLEVEL%

:EXIT
if defined XCOPY_EXCLUDES_LIST_TMP (
  rem cleanup temporary files
  call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"
)

rem restore locale
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b %LAST_ERROR%

:ROBOCOPY_FLAGS_CONVERT
set "XCOPY_FLAG=%~1"
if not defined XCOPY_FLAG exit /b 0
set XCOPY_FLAG_PARSED=0
if "%XCOPY_FLAG:~0,4%" == "/MOV" (
  echo.%?~nx0%: error: /MOV and /MOVE parameters is not accepted to copy a file.
  exit /b 1
) >&2
if %XCOPY_FLAG_PARSED% EQU 0 set "XCOPY_FLAGS=%XCOPY_FLAGS% %XCOPY_FLAG%"
exit /b 0

:USE_ROBOCOPY
set "ROBOCOPY_FLAGS= "
set "ROBOCOPY_ATTR_COPY=0"
set "ROBOCOPY_COPY_FLAGS=DAT"
set "ROBOCOPY_DCOPY_FLAGS=DAT"
set "ROBOCOPY_Y_FLAG_PARSED=0"
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

if %ROBOCOPY_Y_FLAG_PARSED% EQU 0 (
  if "%ROBOCOPY_FLAGS:/XO=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XO"
  if "%ROBOCOPY_FLAGS:/XC=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XC"
  if "%ROBOCOPY_FLAGS:/XN=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /XN"
)

if "%ROBOCOPY_FLAGS:/COPY=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /COPY:%ROBOCOPY_COPY_FLAGS%"
if "%ROBOCOPY_FLAGS:/DCOPY=%" == "%ROBOCOPY_FLAGS%" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS% /DCOPY:%ROBOCOPY_DCOPY_FLAGS%"

echo.^>^>"%SystemRoot%\System32\robocopy.exe" "%FROM_DIR_PATH_ABS%" "%TO_PATH_ABS%" "%FROM_FILE%" /R:0 /W:0 /NP /TEE /NJH /NS /NC /XX%ROBOCOPY_FLAGS:~1% %ROBOCOPY_EXCLUDES_CMD%%ROBOCOPY_FILE_BARE_FLAGS%
"%SystemRoot%\System32\robocopy.exe" "%FROM_DIR_PATH_ABS%" "%TO_PATH_ABS%" "%FROM_FILE%" /R:0 /W:0 /NP /TEE /NJH /NS /NC /XX%ROBOCOPY_FLAGS:~1% %ROBOCOPY_EXCLUDES_CMD%%ROBOCOPY_FILE_BARE_FLAGS%
if %ERRORLEVEL% LSS 8 exit /b 0
exit /b

:XCOPY_FLAGS_CONVERT
set "XCOPY_FLAG=%~1"
if not defined XCOPY_FLAG exit /b 0
set XCOPY_FLAG_PARSED=0
if "%XCOPY_FLAG%" == "/Y" (
  set ROBOCOPY_Y_FLAG_PARSED=1
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
