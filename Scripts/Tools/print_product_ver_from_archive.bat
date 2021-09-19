@echo off

setlocal

set "ARCHIVE_PATH=%~f1"
set "FILE_PATH=%~2"

if not exist "%~1" (
  echo.%~nx0: error: Archive path does not exist: "%~1"
  exit /b 1
) >&2

call "%%~dp0__init__.bat" || exit /b

rem add EULA acception into registry to avoid EULA acception GUI dialog in the build process
reg add HKCU\Software\Sysinternals\SigCheck /v EulaAccepted /t REG_DWORD /d 0x00000001 /f >nul 2>nul

call "%%CONTOOLS_ROOT%%/uuidgen.bat"
set "TEMP_EXTRACT_DIR_PATH=%TEMP%\%~n0.%RETURN_VALUE%"

mkdir "%TEMP_EXTRACT_DIR_PATH%" || (
  echo.%~nx0: error: could not create temporary extraction directory: "%TEMP_EXTRACT_DIR_PATH%".
  exit /b 2
) >&2

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/extract_files_from_archive.bat" "%%TEMP_EXTRACT_DIR_PATH%%" "%%FILE_PATH%%" "%%ARCHIVE_PATH%%" -y >nul || ( set LASTERROR=3 & goto EXIT )

"%CONTOOLS_UTILITIES_BIN_ROOT%/sysinternals/sigcheck.exe" -n "%TEMP_EXTRACT_DIR_PATH%\%FILE_PATH%" 2>nul || ( set LASTERROR=0 & goto EXIT )

:EXIT
rmdir /S /Q "%TEMP_EXTRACT_DIR_PATH%" 2>nul

exit /b %LASTERROR%
