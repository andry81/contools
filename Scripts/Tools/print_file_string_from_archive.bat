@echo off

setlocal

set "ARCHIVE_PATH=%~dpf1"
set "FILE_PATH=%~2"
set "STRING_PREFIX=%~3"

if not exist "%~1" (
  echo.%~nx0: error: Archive path does not exist: "%~1"
  exit /b 1
) >&2

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0"
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

rem add EULA acception into registry to avoid EULA acception GUI dialog in the build process
reg add HKCU\Software\Sysinternals\Strings /v EulaAccepted /t REG_DWORD /d 0x00000001 /f >nul 2>nul

call "%%TOOLS_PATH%%/uuidgen.bat"
set "TEMP_EXTRACT_DIR_PATH=%TEMP%\%~n0.%RETURN_VALUE%"

mkdir "%TEMP_EXTRACT_DIR_PATH%" || (
  echo.%~nx0: error: could not create temporary extraction directory: "%TEMP_EXTRACT_DIR_PATH%".
  exit /b 2
) >&2

call "%%TOOLS_PATH%%/build/extract_files_from_archive.bat" "%%TEMP_EXTRACT_DIR_PATH%%" "%%FILE_PATH%%" "%%ARCHIVE_PATH%%" -y >nul || ( set LASTERROR=3 & goto EXIT )

call "%%TOOLS_PATH%%/get_newest_file.bat" "%%TEMP_EXTRACT_DIR_PATH%%\%%FILE_PATH%%"

"%TOOLS_PATH%\strings.exe" "%FOUND_PATH%" | findstr "%STRING_PREFIX%"

:EXIT
rmdir /S /Q "%TEMP_EXTRACT_DIR_PATH%" 2>nul

exit /b %LASTERROR%
