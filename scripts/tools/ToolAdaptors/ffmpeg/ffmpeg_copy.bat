@echo off & goto DOC_END

rem USAGE:
rem   ffmpeg_copy.bat [<flags>] [--] <input-file> <output-file>

rem Description:
rem   Video file copy script. Uses a single file as an input to copy by a
rem   criteria.
rem
rem   By default avoids a recode using a copy method.
rem
rem   Uses either `FFMPEG_ROOT` or `PATH` variable to locate `ffmpeg`
rem   executables.

rem   CAUTION:
rem     A resulted output file can have has a beginning video freeze in case of
rem     split not by a key frame.
rem
rem     See details: https://trac.ffmpeg.org/wiki/Seeking#codec-copy

rem   ffmpeg command line reference:
rem
rem     https://ffmpeg.org/ffmpeg.html

rem   For details:
rem
rem     https://superuser.com/questions/1056599/ffmpeg-re-encode-a-video-keeping-settings-similar/1056632#1056632
rem     https://trac.ffmpeg.org/wiki/Seeking#Seekingwhiledoingacodeccopy

rem   Examples:
rem
rem     * re-encode with better quality (default: `-crf 23`):
rem
rem       -enable-reencode -c:v -/ <encoder> -crf -/ 18 -preset -/ slow -q:v -/ 0 -c:a -/ copy -copyts ...
rem
rem     * re-encode with maximum quality (slower and bigger output file):
rem
rem       -enable-reencode -c:v -/ <encoder> -crf -/ 0 -preset -/ slow -q:v -/ 0 -c:a -/ copy -copyts ...
rem
rem   <encoder> variants:
rem
rem     * libx264
rem     * libx265
rem     * mjpeg
rem     * mpeg1video
rem     * mpeg2video
rem     * mpeg4

rem <flags>:
rem   -no-default-flags
rem     Removes all default flags usage. You must pass all the required ffmpeg
rem     flags directly using `-/` option.
rem
rem     Affects mostly those options which are used as constants in the ffmpeg
rem     command line.
rem
rem     Has priority over `-enable-reencode` flag.
rem
rem     Does not affect functionality related to these options:
rem       -no-copy-ts
rem       -force
rem
rem   -enable-reencode
rem     Enables a reencode method instead of a copy method.
rem     You may use `-/` option to define it explicitly.
rem
rem     Has no effect if `-no-default-flags` is defined.
rem
rem   -no-copy-ts
rem     Avoids original timestamp coping and resets it for each output file.
rem
rem     Has effect if `-no-default-flags` is defined.
rem
rem   -/ <option>
rem     Pass an option through to the ffmpeg command line.
rem
rem     Has effect if `-no-default-flags` is defined.
rem
rem     NOTE:
rem       The `-y` and `-n` must not be passed as used implicitly by the
rem       `-force` flag.
rem
rem   -force | -f
rem     Allows output file overwrite.
rem
rem     Has effect if `-no-default-flags` is defined.

rem --:
rem   Separator to stop parse flags.
:DOC_END

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem script flags
set FLAG_FORCE=0
set FLAG_NO_DEFAULT_FLAGS=0
set FLAG_ENABLE_REENCODE=0
set FLAG_NO_COPY_TS=0
set "BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not defined FLAG goto FLAGS_END

if "%FLAG%" == "-force" (
  set FLAG_FORCE=1
) else if "%FLAG%" == "-f" (
  set FLAG_FORCE=1
) else if "%FLAG%" == "-no-default-flags" (
  set FLAG_NO_DEFAULT_FLAGS=1
) else if "%FLAG%" == "-enable-reencode" (
  set FLAG_ENABLE_REENCODE=1
) else if "%FLAG%" == "-no-copy-ts" (
  set FLAG_NO_COPY_TS=1
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

if defined FFMPEG_ROOT if exist "%FFMPEG_ROOT%/bin/ffmpeg.exe" set "FFMPEG_EXE=%FFMPEG_ROOT%/bin/ffmpeg.exe" & goto FFMPEG_EXE_OK
if not defined FFMPEG_ROOT for /F "tokens=* delims="eol^= %%i in ("ffmpeg.exe") do ^
for /F "tokens=* delims="eol^= %%j in ("%%~$PATH:i") do set "FFMPEG_EXE=%%j" & goto FFMPEG_EXE_OK

(
  echo;%?~%: error: `ffmpeg.exe` is not found in `FFMPEG_ROOT` or `PATH` variable: FFMPEG_ROOT="%FFMPEG_ROOT%".
  exit /b 255
) >&2

:FFMPEG_EXE_OK

set "FILE_IN=%~1"
set "FILE_OUT=%~2"

if not defined FILE_IN (
  echo;%?~%: error: input file is not defined.
  exit /b 255
) >&2

if not defined FILE_OUT (
  echo;%?~%: error: output file is not defined.
  exit /b 255
) >&2

for /F "tokens=* delims="eol^= %%i in ("%FILE_IN%\.") do set "FILE_IN=%%~fi"
for /F "tokens=* delims="eol^= %%i in ("%FILE_OUT%\.") do ^
for /F "tokens=* delims="eol^= %%j in ("%%~dpi.") do set "FILE_OUT=%%~fi" & set "FILE_OUT_DIR=%%~fj"

if not exist "\\?\%FILE_IN%" (
  echo;%?~%: error: input file does not exists: "%FILE_IN%".
  exit /b 255
) >&2

if exist "\\?\%FILE_IN%\*" (
  echo;%?~%: error: input file path is not a file path: "%FILE_IN%".
  exit /b 255
) >&2

if %FLAG_FORCE% EQU 0 ^
if exist "\\?\%FILE_OUT%" (
  echo;%?~%: error: output file does exists: "%FILE_OUT%".
  exit /b 255
) >&2

if not exist "\\?\%FILE_OUT_DIR%\*" (
  echo;%?~%: error: output file directory does not exists: "%FILE_OUT_DIR%".
  exit /b 255
) >&2

rem prevent from accidental overwrite
set "BARE_FORWARD_FLAGS="
if %FLAG_FORCE% EQU 0 (
  set BARE_FORWARD_FLAGS=%BARE_FORWARD_FLAGS% -n
) else set BARE_FORWARD_FLAGS=%BARE_FORWARD_FLAGS% -y

if %FLAG_NO_COPY_TS% EQU 0 (
  set FFMPEG_COPYTS_CMDLINE= -copyts"
) else set FFMPEG_COPYTS_CMDLINE="

rem NOTE:
rem   The `-copyts` is used to copy original timestamps.
rem
rem   See details: https://trac.ffmpeg.org/wiki/Seeking#Seekingwhiledoingacodeccopy
rem
rem   The `-map 0` is used to select all streams.
rem
rem   See details: https://trac.ffmpeg.org/wiki/Map

if %FLAG_NO_DEFAULT_FLAGS% NEQ 0 (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat"       start /B /WAIT "" "%%FFMPEG_EXE%%"%%BARE_FORWARD_FLAGS%% -i "%%FILE_IN%%"%%FFMPEG_COPYTS_CMDLINE%%%%BARE_FLAGS%% "%%FILE_OUT%%"
) else if %FLAG_ENABLE_REENCODE% NEQ 0 (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat"       start /B /WAIT "" "%%FFMPEG_EXE%%"%%BARE_FORWARD_FLAGS%% -err_detect ignore_err -i "%%FILE_IN%%" -map 0%%FFMPEG_COPYTS_CMDLINE%%%%BARE_FLAGS%% "%%FILE_OUT%%"
) else call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat"  start /B /WAIT "" "%%FFMPEG_EXE%%"%%BARE_FORWARD_FLAGS%% -err_detect ignore_err -i "%%FILE_IN%%" -map 0 -c copy%%FFMPEG_COPYTS_CMDLINE%%%%BARE_FLAGS%% "%%FILE_OUT%%"

exit /b
