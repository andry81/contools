@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || exit /b

rem script flags
set "BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  set BARE_FLAGS=%BARE_FLAGS% %1

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "FILE_IN=%~1"
set "FILE_OUT=%~fx2"
set "FILE_OUT_DIR=%~dp2"

if defined FFMPEG_TOOL_EXE goto IGNORE_SEARCH_IN_PATH

if not exist "ffmpeg.exe" (
  echo.%?~nx0%: error: ffmpeg.exe is not found in the PATH variable.
  exit /b 255
) >&2

set "FFMPEG_TOOL_EXE=ffmpeg.exe"

:IGNORE_SEARCH_IN_PATH

if not exist "%FILE_OUT_DIR%" (
  echo.%?~nx0%: error: file output parent directory does not exist: "%FILE_OUT_DIR%".
  exit /b 254
) >&2

if exist "%FILE_OUT%" (
  echo.%?~nx0%: error: output file already exist: "%FILE_OUT%".
  exit /b 253
) >&2

call :RECODE
set LAST_ERROR=%ERRORLEVEL%

exit /b %LAST_ERROR%

:RECODE
call :CMD start /B /WAIT "" "%%FFMPEG_TOOL_EXE%%" -err_detect ignore_err -i "%%FILE_IN%%" -c copy%%BARE_FLAGS%% "%%FILE_OUT%%"

exit /b

:CMD
echo.^>%*
(%*)
