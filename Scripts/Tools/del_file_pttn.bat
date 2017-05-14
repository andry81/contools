@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   The del wrapper script with echo and some conditions check before call.
rem   Can remove a file by extended and separated patterns: dir+file+extention.

setlocal

set "FILE_DIR=%~1"
set "FILE_DIR=%FILE_DIR:/=\%"
if not "%FILE_DIR%" == "" if not "%FILE_DIR:~-1%" == "\" set "FILE_DIR=%FILE_DIR%\"

if not exist "%FILE_DIR%" (
  echo.%~nx0: error: file directory does not exist: "%FILE_DIR%"
  exit /b 127
) >&2

set "FILE_NAME_PTTN=%~2"

set "FILE_EXT_PTTN=%~3"
if not "%FILE_EXT_PTTN%" == "" if not "%FILE_EXT_PTTN:~0,1%" == "." set "FILE_EXT_PTTN=.%FILE_EXT_PTTN%"

for /F "usebackq eol=	 tokens=* delims=" %%i in (`dir /B /A:-D /S "%FILE_DIR%%FILE_NAME_PTTN%%FILE_EXT_PTTN%" 2^>nul`) do (
  set "FILE_PATH=%%i"
  call :DEL_FILE %%*
)
goto :EOF

:DEL_FILE
call :GET_FILE_EXT "%%FILE_PATH%%"
if not "%FILE_EXT_PTTN%" == "" if "%FILE_EXT_PTTN:~-1%" == "." if not "%FILE_EXT%" == "%FILE_EXT_PTTN:~0,-1%" goto :EOF

echo.^>del %4 %5 %6 %7 %8 %9 "%FILE_PATH%"
del %4 %5 %6 %7 %8 %9 "%FILE_PATH%"
goto :EOF

:GET_FILE_EXT
set "FILE_EXT=%~x1"
goto :EOF
