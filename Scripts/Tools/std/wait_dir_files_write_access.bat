@echo off

rem USAGE:
rem   wait_dir_files_write_access.bat <dir-path> [<wait-timeout-msec>|-1]

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
  if exist "%~1\*" ( move /Y "%~1\*" "%~1" >nul 2>nul & exit /b )
  exit /b 0
)

:FILE_WRITE_LOPP
( type nul > "%~1\%DIR_FILE_TMP%" ) 2>nul || ( call "%%~dp0sleep.bat" %2 & goto FILE_WRITE_LOPP )

rem check all directory files on write access
:FILE_RENAME_LOOP
if exist "%~1\*" move /Y "%~1\*" "%~1\" >nul 2>nul || ( call "%%~dp0sleep.bat" %2 & goto FILE_RENAME_LOOP )
exit /b 0
