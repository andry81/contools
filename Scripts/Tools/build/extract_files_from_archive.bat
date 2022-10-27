@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script extracts files/directories from 7zip archive. Archive should
rem   contain relative path inside archive in %2 variable.

rem Command arguments:
rem %1 - Path to directory with going to be extracted files.
rem %2 - Relative path with pattern inside archive.
rem %3 - Path where archive file is.
rem %4 - Additional arguments for 7zip utility.

rem Examples:
rem 1. call extract_files_from_archive.bat c:\path_for_unpack\app release\x86\app.exe c:\path_of_archives\app_release_x86.7z

setlocal

set "DIR=%~f1"
set "REL_PATH=%~2"
set "ARCHIVE_PATH=%~f3"
set "_7ZIP_SWITCHES=%~4"

rem Drop last error level
call;

call "%%~dp0__init__.bat" || exit /b

if not defined REL_PATH (
  echo.%~nx0: error: Relative path is no set.
  exit /b 1
) >&2

pushd "%DIR%" || (
  echo.%~nx0: error: could not switch current directory: "%DIR%".
  exit /b 2
) >&2

echo.  "%REL_PATH%" -^> "%DIR%"

rem CAUTION:
rem   Explicitly use temporary directory for 7zip. This is required in some cases where 7zip can't create temporary
rem   archive file around being updated archive file.
rem   For example: pushd c:\ && ( 7z.exe a -r <PathToArchive> "<SomeRelativePath>" & popd )

call "%%CONTOOLS_ROOT%%/uuidgen.bat"
set "TEMP_DIR_PATH=%TEMP%\%~n0.%RETURN_VALUE%"

mkdir "%TEMP_DIR_PATH%" || (
  popd
  echo.%~nx0: error: could not create temporary directory: "%TEMP_DIR_PATH%".
  exit /b 3
) >&2

call :EXTRACT
set LASTERROR=%ERRORLEVEL%

popd

rmdir /S /Q "%TEMP_DIR_PATH%"

exit /b %LASTERROR%

:EXTRACT
rem remove arguments trailing back slashes to avoid exe command line parse old bug
if "%ARCHIVE_PATH:~-1%" == "\" set "ARCHIVE_PATH=%ARCHIVE_PATH:~0,-1%"
if "%REL_PATH:~-1%" == "\" set "REL_PATH=%REL_PATH:~0,-1%"

if exist "%ARCHIVE_PATH%\" (
  call :EXTRACT_FROM_DIR || exit /b 4
) else (
  call :EXTRACT_FROM_FILE || exit /b 5
)

exit /b 0

:EXTRACT_FROM_DIR
for /F "usebackq eol= tokens=* delims=" %%i in (`dir /S /B /A:-D "%ARCHIVE_PATH%\*.7z"`) do (
  set "ARCHIVE_FILE=%%i"
  call :EXTRACT_FROM_FILE
)
exit /b

:EXTRACT_FROM_FILE
"%CONTOOLS_ROOT%/arc/7zip/7z.bat" x %_7ZIP_SWITCHES% "%ARCHIVE_FILE%" "%REL_PATH%" "-w%TEMP_DIR_PATH%"
