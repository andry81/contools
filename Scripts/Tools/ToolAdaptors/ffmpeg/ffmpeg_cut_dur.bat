@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

if exist "%?~dp0%__init__.bat" ( call "%?~dp0%__init__.bat" || goto :EOF )

rem script flags
set ENABLE_REENCODE=0
set "BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-enable_reencode" (
    set ENABLE_REENCODE=1
  ) else if "%FLAG%" == "-crf" (
    set BARE_FLAGS=%BARE_FLAGS% %1 %2
    shift
  ) else (
    set BARE_FLAGS=%BARE_FLAGS% %1
  )

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "FILE_IN=%~1"
set "FILE_OUT=%~2"
rem 00:00:30.0
set "TIME_START=%~3"
rem 00:00:10.0
set "TIME_DUR=%~4"

if defined FFMPEG_TOOL_EXE goto IGNORE_SEARCH_IN_PATH

if not exist "ffmpeg.exe" (
  echo.%?~nx0%: error: ffmpeg.exe is not found in the PATH variable.
  exit /b 255
) >&2

set "FFMPEG_TOOL_EXE=ffmpeg.exe"

:IGNORE_SEARCH_IN_PATH

if not exist "%FILE_IN%" (
  echo.%?~nx0%: error: input file does not exist: "%FILE_IN%".
  exit /b 254
) >&2

if %ENABLE_REENCODE% NEQ 0 (
  call :CMD start /B /WAIT "" "%%FFMPEG_TOOL_EXE%%" -i "%%FILE_IN%%" -ss "%%TIME_START%%" -t "%%TIME_DUR%%"%%BARE_FLAGS%% "%%FILE_OUT%%"
) else call :CMD start /B /WAIT "" "%%FFMPEG_TOOL_EXE%%" -i "%%FILE_IN%%" -c copy -ss "%%TIME_START%%" -t "%%TIME_DUR%%"%%BARE_FLAGS%% "%%FILE_OUT%%"
exit /b

:CMD
echo.^>%*
(%*)
