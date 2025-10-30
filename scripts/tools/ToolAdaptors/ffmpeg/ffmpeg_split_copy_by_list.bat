@echo off & goto DOC_END

rem USAGE:
rem   ffmpeg_split_copy_by_list.bat [<flags>] [--] <input-list-file> <output-dir>

rem Description:
rem   Video files split script. Uses a list of files as an input to split by a
rem   criteria.
rem
rem   By default avoids a recode using a copy method.
rem
rem   Uses either `FFMPEG_ROOT` or `PATH` variable to locate `ffmpeg` and
rem   `ffprobe` executables.
rem
rem   The output file name generates using the format:
rem
rem     `<input-list-file-name> (NNN).<input-list-file-ext>`
rem
rem   , where:
rem
rem     NNN - is a file chunk index beginning 0.
rem
rem   NOTE:
rem     If `-force` or `-ignore-existed` flags is not defined, then output
rem     chunk files existence checks before start a splitting loop or a command
rem     set. But if an output chunk file does not exist but is found existed
rem     after a loop or a command set is started to execute, then the output
rem     chunk file name will be tried to rename K times to:
rem
rem       `<input-list-file-name> (NNN)(M).<input-list-file-ext>`
rem
rem       , where:
rem
rem         M - new incremented index starting from 2.
rem
rem         For example, if file `out (123).ext` is found existed, then
rem         tries to rename to `out (123)(2).ext` if does not exist, otherwise
rem         tries to rename to `out (123)(3).ext` if does not exist, and so on.
rem
rem     The `K` can be changed by the `-output-rename-retry-count` option.
rem
rem   CAUTION:
rem     If the number of an output chunk file rename attempts is reached, then
rem     ignores the output chuck file, issues an error and continues the
rem     conversion of a current input file.
rem
rem   NOTE:
rem     If `ffmpeg` or `ffprobe` issues a not zero exit code, then an output
rem     chuck file write does ignore, issues an error and a current input file
rem     conversion continues.
rem     Use `-skip-current-on-ff-error` flag to continue with the next input
rem     file.

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
rem     https://superuser.com/questions/140899/ffmpeg-splitting-mp4-with-same-quality
rem     https://superuser.com/questions/650291/how-to-get-video-duration-in-seconds
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
rem   -mode | -m
rem     Split mode:
rem       * by-file-size-limit-using-ss-to
rem         Split by a file size limit using `-ss` and `-to` options.
rem         This requires mapping the whole file size (minus overhead) to the
rem         video stream time length to calculate a splitted chunk file size.
rem         The method is used exactly the same time value for a next chunk
rem         `-ss` option and a previous chunk `-to` option.
rem
rem       * by-file-size-limit-using-segment-time
rem         Split by a file size limit using `-f segment -segment_time <time>`
rem         ffmpeg muxer options.
rem         Faster than using `by-file-size-limit-using-ss-to` method because
rem         of a single call.
rem
rem         NOTE:
rem           The ffmpeg documentation has no information about the cut
rem           accuracy so the output result quality might differ.
rem
rem       NOTE:
rem         The method with the `-fs` option is known and is not used as it
rem         requires to use `ffprobe` to calculate the time length for each
rem         output file and might gain an inexact or rounded time value.
rem         For example, if a time length value is 1/3, then in the floating
rem         point representation it will be rounded to limited set of digits
rem         after the point - 0.333. Which leads to rounding error accumulation
rem         for each next `-ss` option.
rem
rem   -ignore-existed | -i
rem     Ignores existed output chuck files and so does not try to detect
rem     existence before the conversion and does not attempt to rename after
rem     the conversion is started.
rem
rem     If an output chuck file exists, then does ignore it with a warning
rem     instead of an error and continues the conversion of a current input
rem     file.
rem
rem     Does not imply `-force` flag.
rem
rem   -skip-current-on-ff-error | -s
rem     Skips a current input file conversion on `ffmpeg` or `ffprobe` not zero
rem     exit code, issues an error and continues conversion to the next input
rem     file.
rem
rem   -output-rename-retry-count <count> | -re <count>
rem     Controls the number of retries to rename the output chunk file name.
rem     By default is 3.
rem     Must be greater or equal than 0.
rem
rem     Has no effect if `-force` or `-ignore-existed` flags is defined.
rem
rem   -file-size-limit-mb <size>
rem     File size limit in megabytes.
rem
rem     Can not be less than `1` Mb.
rem
rem     By default is `4096` Mb.
rem
rem   -file-overhead-kb <size>
rem     An input file overhead in kilobytes which must be subtracted before
rem     the calculation using a file container time duration.
rem
rem     Can not be less than `4096` kb.
rem
rem     By default is `4096` Kb.
rem
rem   -file-overhead-percent <percent>
rem     An input file overhead in percentage which must be subtracted before
rem     the calculation using a file container time duration.
rem
rem     Must be greater than 0 and less than 100.
rem
rem     By default is `0.5%`, but in absolute is not less than value
rem     (or default value) of `-file-overhead-kb` option.
rem
rem   -no-default-flags
rem     Removes all default ffmpeg flags. You must pass all the required ffmpeg
rem     flags directly using `-/` option.
rem
rem     Affects mostly those options which are used as constants in the ffmpeg
rem     command line.
rem
rem     Has priority over `-enable-reencode` flag.
rem
rem     Does not affect functionality related to these options:
rem       -mode
rem       -ignore-existed
rem       -use-accurate-seek
rem       -no-copy-ts
rem       -force
rem
rem   -enable-reencode
rem     Enables a reencode method instead of a copy method.
rem     You may use `-/` option to define ffmpeg reencode options explicitly.
rem
rem     Has no effect if `-no-default-flags` is defined.
rem
rem   -use-accurate-seek
rem     Uses an accurate seek to split any where between key frames.
rem     By default only a fast seek to a nearest preceding key frame is used.
rem
rem     Has effect if `-no-default-flags` is defined.
rem
rem     CAUTION:
rem       This option can leave blank frames at the beginning of a video stream
rem       due to a first key frame absence in the beginning of a video stream
rem       of each output file. To avoid this you have to use
rem       `-enable-reencode` flag or explicitly use ffmpeg reencode options.
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
rem     Allows output file(s) overwrite.
rem
rem     Implies `-ignore-existed` flag.
rem
rem     Has effect if `-no-default-flags` is defined.

rem --:
rem   Separator to stop parse flags.
:DOC_END

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem script flags
set "FLAG_MODE="
set FLAG_IGNORE_EXISTED=0
set FLAG_SKIP_CURRENT_ON_FF_ERROR=0
set FLAG_OUTPUT_RENAME_RETRY_COUNT=3
set FLAG_FILE_SIZE_LIMIT_MB=4096
set FLAG_FILE_OVERHEAD_KB=4096
set FLAG_FORCE=0
set FLAG_NO_DEFAULT_FLAGS=0
set FLAG_ENABLE_REENCODE=0
set FLAG_USE_ACCURATE_SEEK=0
set FLAG_NO_COPY_TS=0
set "BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not defined FLAG goto FLAGS_END

if "%FLAG%" == "-mode" (
  set "FLAG_MODE=%~2"
  shift
) else if "%FLAG%" == "-m" (
  set "FLAG_MODE=%~2"
  shift
) else if "%FLAG%" == "-ignore-existed" (
  set FLAG_IGNORE_EXISTED=1
) else if "%FLAG%" == "-i" (
  set FLAG_IGNORE_EXISTED=1
) else if "%FLAG%" == "-skip-current-on-ff-error" (
  set FLAG_SKIP_CURRENT_ON_FF_ERROR=1
) else if "%FLAG%" == "-s" (
  set FLAG_SKIP_CURRENT_ON_FF_ERROR=1
) else if "%FLAG%" == "-output-rename-retry-count" (
  set "FLAG_OUTPUT_RENAME_RETRY_COUNT=%~2"
  shift
) else if "%FLAG%" == "-re" (
  set "FLAG_OUTPUT_RENAME_RETRY_COUNT=%~2"
  shift
) else if "%FLAG%" == "-file-size-limit-mb" (
  set "FLAG_FILE_SIZE_LIMIT_MB=%~2"
  shift
) else if "%FLAG%" == "-file-overhead-kb" (
  set "FLAG_FILE_OVERHEAD_KB=%~2"
  shift
) else if "%FLAG%" == "-force" (
  set FLAG_FORCE=1
) else if "%FLAG%" == "-f" (
  set FLAG_FORCE=1
) else if "%FLAG%" == "-no-default-flags" (
  set FLAG_NO_DEFAULT_FLAGS=1
) else if "%FLAG%" == "-enable-reencode" (
  set FLAG_ENABLE_REENCODE=1
) else if "%FLAG%" == "-use-accurate-seek" (
  set FLAG_USE_ACCURATE_SEEK=1
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

if not defined FLAG_MODE set "FLAG_MODE=by-file-size-limit-using-ss-to"

if not "%FLAG_MODE%" == "by-file-size-limit-using-ss-to" ^
if not "%FLAG_MODE%" == "by-file-size-limit-using-segment-time" (
  echo;%?~%: error: invalid mode: "%FLAG_MODE%".
  exit /b 255
) >&2

set "FFMPEG_ACCURATE_SEEK_FLAGS="

rem cast to integer
set /A FLAG_FILE_SIZE_LIMIT_MB+=0
set /A FLAG_FILE_OVERHEAD_KB+=0

if %FLAG_FILE_SIZE_LIMIT_MB% LSS 1 (
  echo;%?~%: error: invalid file size limit (Mb): "%FLAG_FILE_SIZE_LIMIT_MB%".
  exit /b 255
) >&2

if %FLAG_FILE_OVERHEAD_KB% LSS 1 (
  echo;%?~%: error: invalid input file overhead (Kb): "%FLAG_FILE_OVERHEAD_KB%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/math/ufoldpad6.bat"   FLAG_FILE_SIZE_LIMIT_MB_FN            FLAG_FILE_SIZE_LIMIT_MB || goto MATH_ERROR
call "%%CONTOOLS_ROOT%%/math/ufoldpad6.bat"   FLAG_FILE_OVERHEAD_KB_FN              FLAG_FILE_OVERHEAD_KB || goto MATH_ERROR

call "%%CONTOOLS_ROOT%%/math/umul.bat"        FLAG_FILE_SIZE_LIMIT_KB_FN            FLAG_FILE_SIZE_LIMIT_MB_FN 1024 || goto MATH_ERROR
call "%%CONTOOLS_ROOT%%/math/umul.bat"        FLAG_FILE_SIZE_LIMIT_FN               FLAG_FILE_SIZE_LIMIT_KB_FN 1024 || goto MATH_ERROR

call "%%CONTOOLS_ROOT%%/math/udiv.bat"        FLAG_FILE_SIZE_HALF_LIMIT_KB_FN       FLAG_FILE_SIZE_LIMIT_KB_FN 2 || goto MATH_ERROR

call "%%CONTOOLS_ROOT%%/math/ucmp_fnvar.bat"  FLAG_FILE_OVERHEAD_KB_FN GEQ FLAG_FILE_SIZE_HALF_LIMIT_KB_FN && (
  echo;%?~%: error: input file overhead must be less than a half of file size limit:
  echo;%?~%: info: Input overhead:  %FLAG_FILE_OVERHEAD_KB% Kb.
  echo;%?~%: info: File size limit: %FLAG_FILE_SIZE_LIMIT_MB% Mb.
  exit /b 255
) >&2

if defined FFMPEG_ROOT if exist "%FFMPEG_ROOT%/bin/ffmpeg.exe" set "FFMPEG_EXE=%FFMPEG_ROOT%/bin/ffmpeg.exe" & goto FFMPEG_EXE_OK
if not defined FFMPEG_ROOT for /F "tokens=* delims="eol^= %%i in ("ffmpeg.exe") do ^
for /F "tokens=* delims="eol^= %%j in ("%%~$PATH:i") do set "FFMPEG_EXE=%%j" & goto FFMPEG_EXE_OK

(
  echo;%?~%: error: `ffmpeg.exe` is not found in `FFMPEG_ROOT` nor `PATH` variable: FFMPEG_ROOT="%FFMPEG_ROOT%".
  exit /b 255
) >&2

:FFMPEG_EXE_OK

rem check `by-file-size-limit-using-ss-to` mode environment
if not "%FLAG_MODE%" == "by-file-size-limit-using-ss-to" ^
if not "%FLAG_MODE%" == "by-file-size-limit-using-segment-time" goto SKIP_CHECK_MODE_BY_FILE_SIZE_LIMIT

if defined FFMPEG_ROOT if exist "%FFMPEG_ROOT%/bin/ffprobe.exe" set "FFPROBE_EXE=%FFMPEG_ROOT%/bin/ffprobe.exe" & goto FFPROBE_EXE_OK
if not defined FFMPEG_ROOT for /F "tokens=* delims="eol^= %%i in ("ffprobe.exe") do ^
for /F "tokens=* delims="eol^= %%j in ("%%~$PATH:i") do set "FFPROBE_EXE=%%j" & goto FFPROBE_EXE_OK

(
  echo;%?~%: error: `ffprobe.exe` is not found in `FFMPEG_ROOT` nor `PATH` variable: FFMPEG_ROOT="%FFMPEG_ROOT%".
  exit /b 255
) >&2

:FFPROBE_EXE_OK
:SKIP_CHECK_MODE_BY_FILE_SIZE_LIMIT

set "LIST_FILE_PATH=%~1"
set "FILE_OUT_DIR=%~2"

if not defined LIST_FILE_PATH (
  echo;%?~%: error: list file path is not defined.
  exit /b 255
) >&2

if not defined FILE_OUT_DIR (
  echo;%?~%: error: file output directory is not defined.
  exit /b 255
) >&2

for /F "tokens=* delims="eol^= %%i in ("%LIST_FILE_PATH%\.") do set "LIST_FILE_PATH=%%~fi"
for /F "tokens=* delims="eol^= %%i in ("%FILE_OUT_DIR%\.") do set "FILE_OUT_DIR=%%~fi"

if not exist "\\?\%LIST_FILE_PATH%" (
  echo;%?~%: error: list file path does not exists: "%LIST_FILE_PATH%".
  exit /b 255
) >&2

if exist "\\?\%LIST_FILE_PATH%\*" (
  echo;%?~%: error: list file path is not a file path: "%LIST_FILE_PATH%".
  exit /b 255
) >&2

if not exist "\\?\%FILE_OUT_DIR%\*" (
  echo;%?~%: error: output file directory does not exists: "%FILE_OUT_DIR%".
  exit /b 255
) >&2

rem temporary list
if defined SCRIPT_TEMP_CURRENT_DIR (
  set "TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\%?~n0%.%RANDOM%-%RANDOM%"
) else set "TEMP_DIR=%TEMP%\%?~n0%.%RANDOM%-%RANDOM%"

mkdir "%TEMP_DIR%" >nul || exit /b 255

call :IMPL
set LAST_ERROR=%ERRORLEVEL%

if exist "%TEMP_DIR%\*" rmdir /S /Q "%TEMP_DIR%" >nul 2>nul

exit /b %LAST_ERROR%

:IMPL
rem check on all files existence at first
for /f "usebackq eol=# tokens=* delims=" %%i in ("%LIST_FILE_PATH:/=\%") do (
  set "FILE_PATH=%%i"
  call :PROCESS_PATH || exit /b
)

goto SPLIT_FILES

:PROCESS_PATH
if not exist "%FILE_PATH%" (
  echo;%?~%: error: file not found: "%FILE_PATH%"
  exit /b 255
) >&2

exit /b

:SPLIT_FILES
rem prevent from accidental overwrite
set "BARE_FORWARD_FLAGS="
if %FLAG_FORCE% EQU 0 (
  set BARE_FORWARD_FLAGS=%BARE_FORWARD_FLAGS% -n
) else set BARE_FORWARD_FLAGS=%BARE_FORWARD_FLAGS% -y

for /f "usebackq eol=# tokens=* delims=" %%i in ("%LIST_FILE_PATH%") do (
  set "FILE_PATH=%%i"
  call :PROCESS_PATH
  echo;
)

exit /b

:PROCESS_PATH
call "%%CONTOOLS_ROOT%%/std/echo_var.bat" FILE_PATH "> "

for /F "tokens=* delims="eol^= %%i in ("%FILE_PATH%") do set "FILE_SIZE=%%~zi" & set "FILE_NAME=%%~ni" & set "FILE_EXT=%%~xi"

call "%%CONTOOLS_ROOT%%/math/ufoldpad6.bat"   FILE_SIZE_FN FILE_SIZE || goto MATH_ERROR

call "%%CONTOOLS_ROOT%%/math/ucmp_fnvar.bat"  FILE_SIZE_FN GTR 0 || exit /b 0
call "%%CONTOOLS_ROOT%%/math/ucmp_fnvar.bat"  FLAG_FILE_SIZE_LIMIT_FN LSS FILE_SIZE_FN || exit /b 0

rem set /A FILE_SPLIT_SIZE_NUM=(FLAG_FILE_SIZE_LIMIT_KB - FLAG_FILE_OVERHEAD_KB) * 1024

call "%%CONTOOLS_ROOT%%/math/iadd.bat" FILE_SIZE_REDUCED_LIMIT_KB FILE_SIZE_REDUCED_LIMIT_KB || goto MATH_ERROR

set /A "FILE_SIZE_REDUCED_LIMIT_KB=FLAG_FILE_SIZE_LIMIT_KB - FLAG_FILE_OVERHEAD_KB"
call "%%CONTOOLS_ROOT%%/math/fold.bat" FILE_SIZE_REDUCED_LIMIT_KB FILE_SIZE_REDUCED_LIMIT_KB || goto MATH_ERROR
call "%%CONTOOLS_ROOT%%/math/umul.bat" FILE_SPLIT_SIZE_NUM FILE_SIZE_REDUCED_LIMIT_KB 1024 || goto MATH_ERROR

rem NOTE:
rem   The a fractional part of the duration time in seconds is not used to
rem   avoid excessive calculation when is required a more sophisticated version
rem   of the division operation, where a divisor must be a big integer too.
rem   If the fractional part is 0 (not used), then we can continue to use a
rem   divisor as a usual 32-bit unsigned integer.
rem
set "FILE_DUR_SEC=" & set "FILE_DUR_SEC_INT="
for /F "usebackq tokens=* delims="eol^= %%i in (`@"%FFPROBE_EXE%" -v error -show_entries "format=duration" -of "default=noprint_wrappers=1:nokey=1" "%FILE_PATH%"`) do ^
for /F "tokens=1,* delims=."eol^= %%j in ("%%i") do ^
set "FILE_DUR_SEC=%%i" & set "FILE_DUR_SEC_INT=%%j"

rem cast to integer with rounding to 0
set /A FILE_DUR_SEC_INT+=0

if %FILE_DUR_SEC_INT% GTR 0 goto FILE_DUR_OK

(
  echo;%?~%: error: file duration must be at least a second: "%FILE_DUR_SEC%".
  exit /b 255
) >&2

rem NOTE:
rem   The `-ss` before `-i` is used to fast search by a key frame.
rem   The `-ss` after `-i` is used to accurate search after a key frame.
rem   The `-copyts` is used to copy original timestamps.
rem   The `-noaccurate_seek` is used to prevent an accurate seeking in
rem   FFmpeg 2.1.
rem
rem   See details: https://trac.ffmpeg.org/wiki/Seeking#Seekingwhiledoingacodeccopy
rem
rem   The `-map 0` is used to select all streams.
rem
rem   See details: https://trac.ffmpeg.org/wiki/Map

:FILE_DUR_OK
rem integer arithmetic calculation with rounding to 0.001 sec
rem set /A FILE_SPLIT_DUR_SEC_INT=FILE_SPLIT_SIZE_NUM * FILE_DUR_SEC_INT / FILE_SIZE
rem set /A FILE_SIZE_MB=FILE_SIZE * 1048576

call "%%CONTOOLS_ROOT%%/math/umul.bat" FILE_SPLIT_DUR_SEC_INT FILE_SPLIT_SIZE_NUM "%%FILE_DUR_SEC_INT%%" || goto MATH_ERROR
call "%%CONTOOLS_ROOT%%/math/udiv.bat" FILE_SPLIT_SIZE_NUM FILE_SPLIT_SIZE_NUM 1000 || call "%%CONTOOLS_ROOT%%/std/if_.bat" %%ERRORLEVEL%% LSS 0 && goto MATH_ERROR

set "FILE_SPLIT_DUR_SEC=%FILE_SPLIT_DUR_SEC_INT%.%FILE_SPLIT_DUR_SEC_FRAC%"

echo size=%FILE_SIZE% (%FILE_SPLIT_SIZE_NUM% ) byte
echo dur=%FILE_DUR_SEC% (%FILE_DUR_SEC_INT%.%FILE_DUR_SEC_FRAC%) sec
echo split=%FILE_SPLIT_DUR_SEC% sec

pause
if %FILE_SPLIT_DUR_SEC_INT% LSS 1 (
  echo;%?~%: error: file split size is less than a second: "%FILE_SPLIT_DUR_SEC_INT%.%FILE_SPLIT_DUR_SEC_FRAC%".
  exit /b 255
) >&2

set "TIME_DUR=%FILE_SPLIT_DUR_SEC_INT%.%FILE_SPLIT_DUR_SEC_FRAC%"

set FILE_START_TIME_SEC_INT=0
set FILE_START_TIME_SEC_FRAC=0

set /A FILE_MAX_SPLIT_COUNT=(FILE_DUR_SEC_INT + FILE_SPLIT_DUR_SEC_INT + 1) / FILE_SPLIT_DUR_SEC_INT

for /L %%i in (1,1,%FILE_MAX_SPLIT_COUNT%) do set "FILE_SPLIT_INDEX=%%i" & call :SPLIT_FILE_BY_INDEX
exit /b

:SPLIT_FILE_BY_INDEX
set "FILE_OUT=%FILE_OUT_DIR%\%FILE_NAME% (%FILE_SPLIT_INDEX%)%FILE_EXT%"
set "TIME_START=%FILE_START_TIME_SEC_INT%.%FILE_START_TIME_SEC_FRAC%"

if %FLAG_USE_ACCURATE_SEEK% NEQ 0 (
  set FFMPEG_SS_AFTER_I_CMDLINE= -ss "%TIME_START%"
) else (
  set BARE_FORWARD_FLAGS=%BARE_FORWARD_FLAGS% -noaccurate_seek
  set "FFMPEG_SS_AFTER_I_CMDLINE="
)

if %FLAG_NO_COPY_TS% EQU 0 (
  set FFMPEG_COPYTS_CMDLINE= -copyts"
) else set FFMPEG_COPYTS_CMDLINE="

if %FLAG_NO_DEFAULT_FLAGS% NEQ 0 (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat"       echo start /B /WAIT "" "%%FFMPEG_EXE%%"%%BARE_FORWARD_FLAGS%% -ss "%%TIME_START%%" -i "%%FILE_PATH%%"%%FFMPEG_COPYTS_CMDLINE%%%%BARE_FLAGS%%%%FFMPEG_SS_AFTER_I_CMDLINE%% -t "%%TIME_DUR%%" "%%FILE_OUT%%"
) else if %FLAG_ENABLE_REENCODE% NEQ 0 (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat"       echo start /B /WAIT "" "%%FFMPEG_EXE%%"%%BARE_FORWARD_FLAGS%% -ss "%%TIME_START%%" -i "%%FILE_PATH%%" -map 0%%FFMPEG_COPYTS_CMDLINE%% -bsf:a aac_adtstoasc%%BARE_FLAGS%%%%FFMPEG_SS_AFTER_I_CMDLINE%% -t "%%TIME_DUR%%" "%%FILE_OUT%%"
) else call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat"  echo start /B /WAIT "" "%%FFMPEG_EXE%%"%%BARE_FORWARD_FLAGS%% -ss "%%TIME_START%%" -i "%%FILE_PATH%%" -map 0 -c copy%%FFMPEG_COPYTS_CMDLINE%% -bsf:a aac_adtstoasc%%BARE_FLAGS%%%%FFMPEG_SS_AFTER_I_CMDLINE%% -t "%%TIME_DUR%%" "%%FILE_OUT%%"

set LAST_ERROR=%ERRORLEVEL%

set /A FILE_START_TIME_SEC_INT+=FILE_SPLIT_DUR_SEC_INT
set /A FILE_START_TIME_SEC_FRAC+=FILE_SPLIT_DUR_SEC_FRAC

rem integer and fraction normalization
set /A FILE_START_DUR_SEC_INT+=FILE_START_TIME_SEC_FRAC / 1000
set /A FILE_START_DUR_SEC_FRAC-=(FILE_START_TIME_SEC_FRAC / 1000) * 1000

pause

exit /b %LAST_ERROR%

:MATH_ERROR
(
  echo;%?~%: error: calculation error.
  exit /b 255
) >&2
