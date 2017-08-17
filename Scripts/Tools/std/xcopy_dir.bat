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

set "FROM_PATH=%~1"
set "TO_PATH=%~2"

if not defined FROM_PATH (
  echo.%~nx0: error: input durectory path argument must be defined.
  exit /b -255
) >&2

if not defined TO_PATH (
  echo.%~nx0: error: output durectory path argument must be defined.
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
  echo.%~nx0: error: input directory path is invalid: FROM_PATH="%FROM_PATH%" TO_PATH="%TO_PATH%".
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
  echo.%~nx0: error: output directory path is invalid: FROM_PATH="%FROM_PATH%" TO_PATH="%TO_PATH%".
  exit /b -252
) >&2

:TO_PATH_OK

if not exist "%FROM_PATH%\" (
  echo.%~nx0: error: input directory does not exist: "%FROM_PATH%\"
  exit /b -251
) >&2

if not exist "%TO_PATH%\" (
  echo.%~nx0: error: output directory does not exist: "%TO_PATH%\"
  exit /b -250
) >&2

set "FROM_PATH=%~dpf1"
set "TO_PATH=%~dpf2"
set XCOPY_FLAGS=%3 %4 %5 %6 %7 %8 %9

if exist "%WINDIR%\system32\robocopy.exe" goto USE_ROBOCOPY

rem switch code page into english compatible locale
call "%%CONTOOLS_ROOT%%/std/chcp.bat" 65001

set "XCOPY_EXCLUDES_CMD="
call "%%CONTOOLS_ROOT%%/xcopy/xcopy_convert_excludes.bat" "%%XCOPY_EXCLUDE_DIRS_LIST%%"
if %ERRORLEVEL% EQU 0 set "XCOPY_EXCLUDES_CMD=/EXCLUDE:%RETURN_VALUE%"

call "%%CONTOOLS_ROOT%%/xcopy/xcopy_convert_excludes.bat" "%%XCOPY_EXCLUDE_FILES_LIST%%"
if %ERRORLEVEL% EQU 0 (
  if defined XCOPY_EXCLUDES_CMD (
    set "XCOPY_EXCLUDES_CMD=%XCOPY_EXCLUDES_CMD%+%RETURN_VALUE%"
  ) else (
    set "XCOPY_EXCLUDES_CMD=/EXCLUDE:%RETURN_VALUE%"
  )
)

rem echo.D will only work if locale is in english !!!
echo.D|xcopy.exe "%FROM_PATH%" "%TO_PATH%\" %XCOPY_FLAGS% %XCOPY_EXCLUDES_CMD%

set LASTERROR=%ERRORLEVEL%

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b %LASTERROR%

:USE_ROBOCOPY
set "ROBOCOPY_FLAGS="
for %%i in (%XCOPY_FLAGS%) do (
  set XCOPY_FLAG=%%i
  call :XCOPY_FLAGS_CONVERT %%XCOPY_FLAG%%
)

set "ROBOCOPY_EXCLUDE_DIRS_CMD="
call "%%CONTOOLS_ROOT%%/xcopy/xcopy_convert_excludes.bat" "%%XCOPY_EXCLUDE_DIRS_LIST%%"
if %ERRORLEVEL% EQU 0 for %%i in (%RETURN_VALUE%) do (
  set XCOPY_EXCLUDE_DIR=%%i
  call :SET_ROBOCOPY_EXCLUDE_DIRS_CMD %%XCOPY_EXCLUDE_DIR%%
)

goto SET_ROBOCOPY_EXCLUDE_DIRS_CMD_END

:SET_ROBOCOPY_EXCLUDE_DIRS_CMD
set "XCOPY_EXCLUDE_DIR=%~1"
set ROBOCOPY_EXCLUDE_DIRS_CMD=%ROBOCOPY_EXCLUDE_DIRS_CMD%/XD "%XCOPY_EXCLUDE_DIR%" 
exit /b 0

:SET_ROBOCOPY_EXCLUDE_DIRS_CMD_END

set "ROBOCOPY_EXCLUDE_FILES_CMD="
call "%%CONTOOLS_ROOT%%/xcopy/xcopy_convert_excludes.bat" "%%XCOPY_EXCLUDE_FILES_LIST%%"
if %ERRORLEVEL% EQU 0 for %%i in (%RETURN_VALUE%) do (
  set XCOPY_EXCLUDE_FILE=%%i
  call :SET_ROBOCOPY_EXCLUDE_FILES_CMD %%XCOPY_EXCLUDE_FILE%%
)

goto SET_ROBOCOPY_EXCLUDE_FILES_CMD_END

:SET_ROBOCOPY_EXCLUDE_FILES_CMD
set "XCOPY_EXCLUDE_FILE=%~1"
rem post process files
if "%XCOPY_EXCLUDE_FILE:~0,1%" == "." set "XCOPY_EXCLUDE_FILE=*%XCOPY_EXCLUDE_FILE%"
set ROBOCOPY_EXCLUDE_FILES_CMD=%ROBOCOPY_EXCLUDE_FILES_CMD%/XF "%XCOPY_EXCLUDE_FILE%" 
exit /b 0

:SET_ROBOCOPY_EXCLUDE_FILES_CMD_END

echo.^>^>robocopy.exe "%FROM_PATH%\\" "%TO_PATH%\\" /R:0 /NP /TEE /NJH /NS /NC /XX %ROBOCOPY_FLAGS% %ROBOCOPY_EXCLUDE_DIRS_CMD% %ROBOCOPY_EXCLUDE_FILES_CMD%
robocopy.exe "%FROM_PATH%\\" "%TO_PATH%\\" /R:0 /NP /TEE /NJH /NS /NC /XX %ROBOCOPY_FLAGS% %ROBOCOPY_EXCLUDE_DIRS_CMD% %ROBOCOPY_EXCLUDE_FILES_CMD%
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
