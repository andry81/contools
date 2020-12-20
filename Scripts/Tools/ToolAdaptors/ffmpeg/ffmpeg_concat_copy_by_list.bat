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

set "FILE_LIST_IN=%~1"
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

rem temporary list
if not defined SCRIPT_TEMP_CURRENT_DIR (
  set "TEMP_FILE_LIST=%TEMP%\tmp_list.%RANDOM%.txt"
) else (
  set "TEMP_FILE_LIST=%SCRIPT_TEMP_CURRENT_DIR%\tmp_list.%RANDOM%.txt"
)

type nul > "%TEMP_FILE_LIST%"

rem check on all files existance at first
for /f "usebackq eol=# tokens=* delims=" %%i in ("%FILE_LIST_IN:/=\%") do (
  set "FILE_PATH=%%i"
  if defined FILE_PATH ( call :CHECK_PATH || exit /b )
)

call :ENCODE
set LAST_ERROR=%ERRORLEVEL%

del /F /Q /A:-D "%TEMP_FILE_LIST%"

exit /b %LAST_ERROR%

:CHECK_PATH
if not exist "%FILE_PATH%" (
  echo.%?~nx0%: error: file not found: "%FILE_PATH%"
  exit /b 252
) >&2

set "FILE_PATH=%FILE_PATH:\=/%"

rem escape characters
set "FILE_PATH=%FILE_PATH:'='\''%"

for /f "eol= tokens=* delims=" %%i in ("%FILE_PATH%") do (
  echo.file '%%i'
) >> "%TEMP_FILE_LIST%"

exit /b

:ENCODE
call :CMD start /B /WAIT "" "%%FFMPEG_TOOL_EXE%%" -f concat -safe 0 -i "%%TEMP_FILE_LIST%%" -c copy -bsf:a aac_adtstoasc%%BARE_FLAGS%% "%%FILE_OUT%%"

exit /b

:CMD
echo.^>%*
(%*)
