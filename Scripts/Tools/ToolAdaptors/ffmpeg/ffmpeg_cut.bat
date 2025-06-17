@echo off & goto DOC_END

rem Examples:
rem
rem For details: https://superuser.com/questions/1056599/ffmpeg-re-encode-a-video-keeping-settings-similar/1056632#1056632
rem
rem * re-encode with better quality (default: `-crf 23`):
rem
rem   -enable_reencode -c:v -/ <encoder> -crf -/ 18 -preset -/ slow -q:v -/ 0 -c:a -/ copy ...
rem
rem * re-encode with maximum quality (slower and bigger output file):
rem
rem   -enable_reencode -c:v -/ <encoder> -crf -/ 0 -preset -/ slow -q:v -/ 0 -c:a -/ copy ...
rem
rem <encoder> variants:
rem
rem * libx264
rem * libx265
rem * mjpeg
rem * mpeg1video
rem * mpeg2video
rem * mpeg4
rem
:DOC_END

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem script flags
set NO_DEFAULT_FLAGS=0
set ENABLE_REENCODE=0
set "BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not defined FLAG goto FLAGS_END

if "%FLAG%" == "-no_default_flags" (
  set NO_DEFAULT_FLAGS=1
) else if "%FLAG%" == "-enable_reencode" (
  set ENABLE_REENCODE=1
) else if "%FLAG%" == "-/" ( rem pass on to ffmpeg command line
  set BARE_FLAGS=%BARE_FLAGS% %2
  shift
) else if "%FLAG%" == "--" ( rem stop flags parser
  shift
  goto FLAGS_END
) else (
  set BARE_FLAGS=%BARE_FLAGS% %1
)

shift

rem read until no flags
goto FLAGS_LOOP

:FLAGS_END

set "FILE_IN=%~1"
set "FILE_OUT=%~2"
rem 00:00:30.0
set "TIME_START=%~3"
rem 00:00:40.0
set "TIME_END=%~4"

if defined FFMPEG_TOOL_EXE goto IGNORE_SEARCH_IN_PATH

if not exist "ffmpeg.exe" (
  echo;%?~%: error: ffmpeg.exe is not found in the PATH variable.
  exit /b 255
) >&2

set "FFMPEG_TOOL_EXE=ffmpeg.exe"

:IGNORE_SEARCH_IN_PATH

if not exist "%FILE_IN%" (
  echo;%?~%: error: input file does not exist: "%FILE_IN%".
  exit /b 254
) >&2

if %ENABLE_REENCODE% NEQ 0 set NO_DEFAULT_FLAGS=1

if %NO_DEFAULT_FLAGS% NEQ 0 (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" start /B /WAIT "" "%%FFMPEG_TOOL_EXE%%" -i "%%FILE_IN%%" -ss "%%TIME_START%%" -to "%%TIME_END%%"%%BARE_FLAGS%% "%%FILE_OUT%%"
) else call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" start /B /WAIT "" "%%FFMPEG_TOOL_EXE%%" -i "%%FILE_IN%%" -c copy -ss "%%TIME_START%%" -to "%%TIME_END%%"%%BARE_FLAGS%% "%%FILE_OUT%%"

exit /b
