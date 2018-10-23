@echo off

setlocal

set "FILE_LIST_IN=%~1"
set "FILE_OUT=%~fx2"
set "FILE_OUT_DIR=%~dp2"

if not exist "ffmpeg.exe" (
  echo.%~nx0: error: ffmpeg.exe is not found in the PATH variable.
  exit /b 255
) >&2

if not exist "%FILE_OUT_DIR%" (
  echo.%~nx0: error: file output parent directory does not exist: "%FILE_OUT_DIR%".
  exit /b 254
) >&2

if exist "%FILE_OUT%" (
  echo.%~nx0: error: output file already exist: "%FILE_OUT%".
  exit /b 253
) >&2

rem temporary list
type nul > tmp_list.txt

rem check on all files existance at first
for /f "usebackq eol=# tokens=* delims=" %%i in ("%FILE_LIST_IN%") do (
  set "FILE_PATH=%%i"
  if defined FILE_PATH (
    call :CHECK_PATH || exit /b
  )
)

call :ENCODE
set LAST_ERROR=%ERRORLEVEL%

del /F /Q /A:-D "tmp_list.txt"

exit /b %LAST_ERROR%

:CHECK_PATH
if not exist "%FILE_PATH%" (
  echo.%~nx0: error: file not found: "%FILE_PATH%"
  exit /b 252
) >&2

(echo.file '%FILE_PATH:\=/%')>> tmp_list.txt

exit /b

:ENCODE
call :CMD ffmpeg.exe -f concat -safe 0 -i tmp_list.txt -c copy -bsf:a aac_adtstoasc "%%FILE_OUT%%"

exit /b

:CMD
echo.^>%*
(%*)
