@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   The `xcopy.exe`/`robocopy.exe` seemless wrapper script with xcopy
rem   compatible command line flags/excludes, echo and some conditions check
rem   before call to copy a directory to a directory.

rem CAUTION:
rem   `xcopy.exe` has a file path limit up to 260 characters in a path. To
rem   bypass that limitation we have to use `robocopy.exe` instead
rem   (Windows Vista and higher ONLY).
rem
rem   `robocopy.exe` will copy hidden and archive files by default.

echo.^>%~nx0 %*

setlocal

set "?~n0=%~nx0"

set "FROM_PATH=%~1"
set "TO_PATH=%~2"

if not defined FROM_PATH (
  echo.%?~n0%: error: input directory path argument must be defined.
  exit /b -255
) >&2

if not defined TO_PATH (
  echo.%?~n0%: error: output directory path argument must be defined.
  exit /b -254
) >&2

set "FROM_PATH=%FROM_PATH:/=\%"
set "TO_PATH=%TO_PATH:/=\%"

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%FROM_PATH:~0,1%" goto FROM_PATH_ERROR

rem ...double `\\` character
if not "%FROM_PATH%" == "%FROM_PATH:\\=\%" goto FROM_PATH_ERROR

rem ...trailing `\` character
if "\" == "%FROM_PATH:~-1%" goto FROM_PATH_ERROR

rem check on invalid characters in path
if not "%FROM_PATH%" == "%FROM_PATH:**=%" goto FROM_PATH_ERROR
if not "%FROM_PATH%" == "%FROM_PATH:?=%" goto FROM_PATH_ERROR

goto FROM_PATH_OK

:FROM_PATH_ERROR
(
  echo.%?~n0%: error: input directory path is invalid: FROM_PATH="%FROM_PATH%" TO_PATH="%TO_PATH%".
  exit /b -253
) >&2

:FROM_PATH_OK

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%TO_PATH:~0,1%" goto TO_PATH_ERROR

rem ...double `\\` character
if not "%TO_PATH%" == "%TO_PATH:\\=\%" goto TO_PATH_ERROR

rem ...trailing `\` character
if "\" == "%TO_PATH:~-1%" goto TO_PATH_ERROR

rem check on invalid characters in path
if not "%TO_PATH%" == "%TO_PATH:**=%" goto TO_PATH_ERROR
if not "%TO_PATH%" == "%TO_PATH:?=%" goto TO_PATH_ERROR

if "\" == "%TO_PATH:~0,1%" goto TO_PATH_ERROR

goto TO_PATH_OK

:TO_PATH_ERROR
(
  echo.%?~n0%: error: output directory path is invalid: FROM_PATH="%FROM_PATH%" TO_PATH="%TO_PATH%".
  exit /b -252
) >&2

:TO_PATH_OK

if not exist "%FROM_PATH%\" (
  echo.%?~n0%: error: input directory does not exist: "%FROM_PATH%\"
  exit /b -251
) >&2

if not exist "%TO_PATH%\" (
  echo.%?~n0%: error: output directory does not exist: "%TO_PATH%\"
  exit /b -250
) >&2

call "%%~dp0__init__.bat" || exit /b

set "FROM_PATH=%~dpf1"
set "TO_PATH=%~dpf2"
set XCOPY_FLAGS=%3 %4 %5 %6 %7 %8 %9

if exist "%WINDIR%\system32\robocopy.exe" goto USE_ROBOCOPY

rem switch code page into english compatible locale
call "%%CONTOOLS_ROOT%%/std/chcp.bat" 65001
set RESTORE_LOCALE=1

set "XCOPY_EXCLUDES_CMD="
set "XCOPY_EXCLUDES_LIST_TMP="

if not defined XCOPY_EXCLUDE_FILES_LIST if not defined XCOPY_EXCLUDE_DIRS_LIST goto IGNORE_XCOPY_EXCLUDES

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"
set "XCOPY_EXCLUDES_LIST_TMP=%SCRIPT_TEMP_CURRENT_DIR%\$xcopy_excludes.lst"

call "%%CONTOOLS_ROOT%%/xcopy/convert_excludes_to_xcopy.bat" "%%XCOPY_EXCLUDE_FILES_LIST%%" "%%XCOPY_EXCLUDE_DIRS_LIST%%" "%%XCOPY_EXCLUDES_LIST_TMP%%" || (
  echo.%?~n0%: error: xcopy excludes list is invalid: XCOPY_EXCLUDE_FILES_LIST="%XCOPY_EXCLUDE_FILES_LIST%" XCOPY_EXCLUDES_LIST_TMP="%XCOPY_EXCLUDES_LIST_TMP%"
  exit /b -247
) >&2
if %ERRORLEVEL% EQU 0 set "XCOPY_EXCLUDES_CMD=/EXCLUDE:%XCOPY_EXCLUDES_LIST_TMP%"

:IGNORE_XCOPY_EXCLUDES

rem echo.D will ONLY work if locale is compatible with english !!!
echo.D|xcopy.exe "%FROM_PATH%" "%TO_PATH%\" %XCOPY_FLAGS% %XCOPY_EXCLUDES_CMD%
set LASTERROR=%ERRORLEVEL%

if defined XCOPY_EXCLUDES_LIST_TMP (
  rem cleanup temporary files
  call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"
)

rem restore locale
if %RESTORE_LOCALE% NEQ 0 call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b %LASTERROR%

:USE_ROBOCOPY
set "ROBOCOPY_FLAGS="
for %%i in (%XCOPY_FLAGS%) do (
  set XCOPY_FLAG=%%i
  call :XCOPY_FLAGS_CONVERT %%XCOPY_FLAG%%
)

set "ROBOCOPY_EXCLUDES_CMD="

if not defined XCOPY_EXCLUDE_FILES_LIST if not defined XCOPY_EXCLUDE_DIRS_LIST goto IGNORE_ROBOCOPY_EXCLUDES

call "%%CONTOOLS_ROOT%%/xcopy/convert_excludes_to_robocopy.bat" "%%XCOPY_EXCLUDE_FILES_LIST%%" "%%XCOPY_EXCLUDE_DIRS_LIST%%" || (
  echo.%?~n0%: error: robocopy excludes list is invalid: XCOPY_EXCLUDE_FILES_LIST="%XCOPY_EXCLUDE_FILES_LIST%" XCOPY_EXCLUDES_LIST_TMP="%XCOPY_EXCLUDES_LIST_TMP%"
  exit /b -246
) >&2
if %ERRORLEVEL% EQU 0 set ROBOCOPY_EXCLUDES_CMD=%RETURN_VALUE%

:IGNORE_ROBOCOPY_EXCLUDES

echo.^>^>robocopy.exe "%FROM_PATH%\\" "%TO_PATH%\\" /R:0 /NP /TEE /NJH /NS /NC /XX %ROBOCOPY_FLAGS%%ROBOCOPY_EXCLUDES_CMD%
robocopy.exe "%FROM_PATH%\\" "%TO_PATH%\\" /R:0 /NP /TEE /NJH /NS /NC /XX %ROBOCOPY_FLAGS%%ROBOCOPY_EXCLUDES_CMD%
if %ERRORLEVEL% LSS 8 exit /b 0
exit /b

:XCOPY_FLAGS_CONVERT
set "XCOPY_FLAG=%~1"
set XCOPY_FLAG_PARSED=0
if "%XCOPY_FLAG%" == "/Y" exit /b 1
if "%XCOPY_FLAG%" == "/R" exit /b 1
if "%XCOPY_FLAG%" == "/D" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS%/XO " & set XCOPY_FLAG_PARSED=1
if "%XCOPY_FLAG%" == "/H" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS%/IA:AH " & set XCOPY_FLAG_PARSED=1
if %XCOPY_FLAG_PARSED% EQU 0 set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS%%XCOPY_FLAG% "
exit /b 0
