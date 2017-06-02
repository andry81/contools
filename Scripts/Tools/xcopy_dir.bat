@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   The xcopy.exe/robocopy.exe seemless wrapper script with xcopy compatible
rem   command line flags/excludes, echo and some conditions check before call
rem   to copy a directory to a directory.

rem CAUTION:
rem   xcopy.exe has a file path limit up to 260 characters in a path. To bypass
rem   that limitation we have to use robocopy.exe instead
rem   (Windows Vista and higher ONLY).
rem
rem   robocopy.exe will copy hidden and archive files by default.

setlocal

set "FROM_PATH=%~dpf1"
set "TO_PATH=%~dpf2"
set XCOPY_FLAGS=%3 %4 %5 %6 %7 %8 %9

if not exist "%~2\" (
  echo.%~nx0: error: output directory does not exist: "%~2\"
  exit /b 127
) >&2

if exist "%WINDIR%\system32\robocopy.exe" goto USE_ROBOCOPY

for /F "usebackq tokens=1,* delims=:" %%i in (`chcp 2^>nul`) do set LAST_CODE_PAGE=%%j
set LAST_CODE_PAGE=%LAST_CODE_PAGE: =%

rem switch locale into english compatible locale
chcp 65001 >nul

set "XCOPY_EXCLUDES_CMD="
call "%%CONTOOLS_ROOT%%/xcopy/xcopy_convert_excludes.bat" "%%XCOPY_EXCLUDE_DIRS_LIST%%"
if %ERRORLEVEL% EQU 0 set "XCOPY_EXCLUDES_CMD=/EXCLUDE:%RETURN_VALUE%"

call "%%CONTOOLS_ROOT%%/xcopy/xcopy_convert_excludes.bat" "%%XCOPY_EXCLUDE_FILES_LIST%%"
if %ERRORLEVEL% EQU 0 (
  if not "%XCOPY_EXCLUDES_CMD%" == "" (
    set "XCOPY_EXCLUDES_CMD=%XCOPY_EXCLUDES_CMD%+%RETURN_VALUE%"
  ) else (
    set "XCOPY_EXCLUDES_CMD=/EXCLUDE:%RETURN_VALUE%"
  )
)

echo.^>xcopy "%FROM_PATH%" "%TO_PATH%\" %XCOPY_FLAGS% %XCOPY_EXCLUDES_CMD%
rem echo.D will only work if locale is in english !!!
echo.D|xcopy "%FROM_PATH%" "%TO_PATH%\" %XCOPY_FLAGS% %XCOPY_EXCLUDES_CMD%

set LASTERROR=%ERRORLEVEL%

rem restore locale
if not "%LAST_CODE_PAGE%" == "65001" chcp %LAST_CODE_PAGE% >nul

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

echo.^>robocopy "%FROM_PATH%\\" "%TO_PATH%\\" /R:0 /NP /TEE /NJH /NS /NC %ROBOCOPY_FLAGS% %ROBOCOPY_EXCLUDE_DIRS_CMD% %ROBOCOPY_EXCLUDE_FILES_CMD%
robocopy "%FROM_PATH%\\" "%TO_PATH%\\" /R:0 /NP /TEE /NJH /NS /NC %ROBOCOPY_FLAGS% %ROBOCOPY_EXCLUDE_DIRS_CMD% %ROBOCOPY_EXCLUDE_FILES_CMD%
if %ERRORLEVEL% LSS 8 exit /b 0
exit /b

:XCOPY_FLAGS_CONVERT
set "XCOPY_FLAG=%~1"
set XCOPY_FLAG_PARSED=0
if "%XCOPY_FLAG%" == "/Y" exit /b 1
if "%XCOPY_FLAG%" == "/D" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS%/XO " & set XCOPY_FLAG_PARSED=1
if "%XCOPY_FLAG%" == "/H" set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS%/IA:AH " & set XCOPY_FLAG_PARSED=1
if %XCOPY_FLAG_PARSED% EQU 0 set "ROBOCOPY_FLAGS=%ROBOCOPY_FLAGS%%XCOPY_FLAG% "
exit /b 0
