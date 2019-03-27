@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || goto :EOF

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

rem script flags
set PAUSE_ON_EXIT=0

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

if %PAUSE_ON_EXIT% NEQ 0 pause

exit /b %LASTERROR%

:MAIN
rem script flags
set "BARE_FLAGS="
set FLAG_WAIT_EXIT=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-pause_on_exit" (
    set PAUSE_ON_EXIT=1
  ) else if "%FLAG%" == "-wait" (
    set FLAG_WAIT_EXIT=1
  ) else (
    set BARE_FLAGS=%BARE_FLAGS% %1
  )

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "LIST_FILE_PATH=%~1"
set "TARGET_PATH=%~2"

if not defined LIST_FILE_PATH exit /b 0
if not defined TARGET_PATH exit /b 0

set "LIST_FILE_PATH=%LIST_FILE_PATH:\=/%"
set "TARGET_PATH=%TARGET_PATH:\=/%"

rem select file
set "CONVERT_TO_FILE_PATH="
for /F "usebackq eol=	 tokens=* delims=" %%i in (`@"%CONTOOLS_ROOT%/wxSaveFileDialog.exe" "MP4 Video files (*.mp4)|*.mp4|All files|*.*" "%TARGET_PATH%" "Convert to a file"`) do (
  set "CONVERT_TO_FILE_PATH=%%i"
)
if %ERRORLEVEL% NEQ 0 exit /b 0
if not defined CONVERT_TO_FILE_PATH (
  echo.%?~nx0%: error: file path is not selected.
  exit /b 0
) >&2

if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" "%%COMSPEC%%" /C @"%%TOTALCMD_ROOT%%/converters/ffmpeg/ffmpeg_concat_copy_by_list.bat"%%BARE_FLAGS%% "%%LIST_FILE_PATH%%" "%%CONVERT_TO_FILE_PATH%%"
) else (
  call :CMD start /B "" "%%COMSPEC%%" /C @"%%TOTALCMD_ROOT%%/converters/ffmpeg/ffmpeg_concat_copy_by_list.bat"%%BARE_FLAGS%% "%%LIST_FILE_PATH%%" "%%CONVERT_TO_FILE_PATH%%"
)

exit /b 0

:CMD
echo.^>%*
(%*)