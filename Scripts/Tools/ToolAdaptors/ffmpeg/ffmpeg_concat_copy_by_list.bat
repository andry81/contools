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

set "FILE_LIST_IN=%~1"
set "FILE_OUT=%~fx2"
set "FILE_OUT_DIR=%~dp2"

if defined FFMPEG_TOOL_EXE goto IGNORE_SEARCH_IN_PATH

if not exist "ffmpeg.exe" (
  echo;%?~%: error: ffmpeg.exe is not found in the PATH variable.
  exit /b 255
) >&2

set "FFMPEG_TOOL_EXE=ffmpeg.exe"

:IGNORE_SEARCH_IN_PATH

if not exist "%FILE_OUT_DIR%" (
  echo;%?~%: error: file output parent directory does not exist: "%FILE_OUT_DIR%".
  exit /b 254
) >&2

if exist "%FILE_OUT%" (
  echo;%?~%: error: output file already exist: "%FILE_OUT%".
  exit /b 253
) >&2

rem temporary list
if defined SCRIPT_TEMP_CURRENT_DIR (
  set "TEMP_FILE_LIST=%SCRIPT_TEMP_CURRENT_DIR%\tmp_list.%RANDOM%-%RANDOM%.txt"
) else set "TEMP_FILE_LIST=%TEMP%\tmp_list.%RANDOM%-%RANDOM%.txt"

type nul > "%TEMP_FILE_LIST%"

rem check on all files existence at first
for /f "usebackq eol=# tokens=* delims=" %%i in ("%FILE_LIST_IN:/=\%") do (
  set "FILE_PATH=%%i"
  if defined FILE_PATH call :CHECK_PATH || exit /b
)

call :ENCODE
set LAST_ERROR=%ERRORLEVEL%

del /F /Q /A:-D "%TEMP_FILE_LIST%"

exit /b %LAST_ERROR%

:CHECK_PATH
if not exist "%FILE_PATH%" (
  echo;%?~%: error: file not found: "%FILE_PATH%"
  exit /b 252
) >&2

set "FILE_PATH=%FILE_PATH:\=/%"

rem escape characters
set "FILE_PATH=%FILE_PATH:'='\''%"

for /f "tokens=* delims="eol^= %%i in ("%FILE_PATH%") do (
  echo;file '%%i'
) >> "%TEMP_FILE_LIST%"

exit /b

:ENCODE
if %NO_DEFAULT_FLAGS% NEQ 0 (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" start /B /WAIT "" "%%FFMPEG_TOOL_EXE%%" -f concat -i "%%TEMP_FILE_LIST%%"%%BARE_FLAGS%% "%%FILE_OUT%%"
) else if %ENABLE_REENCODE% NEQ 0 (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" start /B /WAIT "" "%%FFMPEG_TOOL_EXE%%" -f concat -safe 0 -i "%%TEMP_FILE_LIST%%" -bsf:a aac_adtstoasc%%BARE_FLAGS%% "%%FILE_OUT%%"
) else call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" start /B /WAIT "" "%%FFMPEG_TOOL_EXE%%" -f concat -safe 0 -i "%%TEMP_FILE_LIST%%" -c copy -bsf:a aac_adtstoasc%%BARE_FLAGS%% "%%FILE_OUT%%"

exit /b
