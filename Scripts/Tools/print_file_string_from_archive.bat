@echo off

setlocal

set "ARCHIVE_PATH=%~f1"
set "FILE_PATH=%~2"
set "STRING_PREFIX=%~3"

if not exist "%~1" (
  echo.%~nx0: error: Archive path does not exist: "%~1"
  exit /b 1
) >&2

call "%%~dp0__init__.bat" || exit /b

rem add EULA acception into registry to avoid EULA acception GUI dialog in the build process
reg add HKCU\Software\Sysinternals\Strings /v EulaAccepted /t REG_DWORD /d 0x00000001 /f >nul 2>nul

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "TEMP_EXTRACT_DIR_PATH=%SCRIPT_TEMP_CURRENT_DIR%\%~n0.%RANDOM%-%RANDOM%"
) else set "TEMP_EXTRACT_DIR_PATH=%TEMP%\%~n0.%RANDOM%-%RANDOM%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir.bat" "%%TEMP_EXTRACT_DIR_PATH%%" >nul || exit /b 2

set LAST_ERROR=0

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/extract_files_from_archive.bat" "%%TEMP_EXTRACT_DIR_PATH%%" "%%FILE_PATH%%" "%%ARCHIVE_PATH%%" -y >nul || ( set LAST_ERROR=3 & goto EXIT )

call "%%CONTOOLS_ROOT%%/filesys/get_newest_file.bat" "%%TEMP_EXTRACT_DIR_PATH%%\%%FILE_PATH%%"

"%CONTOOLS_SYSINTERNALS_ROOT%/strings.exe" "%FOUND_PATH%" | "%SystemRoot%\System32\findstr.exe" "%STRING_PREFIX%"

:EXIT
rmdir /S /Q "%TEMP_EXTRACT_DIR_PATH%" 2>nul

exit /b %LAST_ERROR%
