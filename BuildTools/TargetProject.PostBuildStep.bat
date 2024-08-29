@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

set "TARGET_PATH=%~1"
set "BINARY_DIR=%~2"

set "TARGET_DIR=%~dp1"
set "TARGET_FILE=%~nx1"

rem switch locale into english compatible locale
call "%%CONTOOLS_ROOT%%/std/chcp.bat" 65001

rem sanitize trailing slash character
if "%TARGET_DIR:~-1%" == "\" set "TARGET_DIR=%TARGET_DIR:~0,-1%"
if "%BINARY_DIR:~-1%" == "\" set "BINARY_DIR=%BINARY_DIR:~0,-1%"

rem WORKAROUND:
rem   Run script using `cmd.exe` to bypass echo suppression from Visual Studio (`cmd.exe /Q` option).
rem
"%SystemRoot%\System32\cmd.exe" /c @"%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%TARGET_DIR%%" "%%TARGET_FILE%%" "%%BINARY_DIR%%" /Y /H /R

set LAST_ERROR=%ERRORLEVEL%

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

rem avoid output of this sequence: "error:"
echo Last return code: %LAST_ERROR%

exit /b %LAST_ERROR%
