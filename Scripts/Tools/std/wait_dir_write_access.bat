@echo off

rem USAGE:
rem   wait_dir_write_access.bat <dir-path> [<wait-timeout-msec>|-1]

setlocal

if "%~1" == "" exit /b 0

set "DIR_FILE_TMP=.tmp-%RANDOM%-%RANDOM%"

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

del /F /Q /A:-D "%~1\%DIR_FILE_TMP%" >nul 2>nul

exit /b %LAST_ERROR%

:MAIN
if not "%~2" == "" if %~20 LSS 0 (
  ( type nul > "%~1\%DIR_FILE_TMP%" ) 2>nul || exit /b 1
  if exist "%~1\%DIR_FILE_TMP%" ( rename "%~1\%DIR_FILE_TMP%" "%DIR_FILE_TMP%" >nul 2>nul & exit /b )
  exit /b 1
)

rem check directory on file write access
:FILE_WRITE_LOoP
( type nul > "%~1\%DIR_FILE_TMP%" ) 2>nul || ( call "%%~dp0sleep.bat" %2 & goto FILE_WRITE_LOoP )

rem check directory on file rename access
:FILE_RENAME_LOOP
rename "%~1\%DIR_FILE_TMP%" "%DIR_FILE_TMP%" >nul 2>nul || ( call "%%~dp0sleep.bat" %2 & goto FILE_RENAME_LOOP )
exit /b 0

rem Check directory write access.
rem
rem Based on:
rem   https://stackoverflow.com/questions/1999988/how-to-check-whether-a-file-dir-is-writable-in-batch-scripts/59884789#59884789
rem
