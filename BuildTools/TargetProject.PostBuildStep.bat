@echo off

setlocal

rem Drop last error code
call;

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

call :XCOPY_FILE "%%TARGET_DIR%%" "%%TARGET_FILE%%" "%%BINARY_DIR%%" /Y /H /R

set LASTERROR=%ERRORLEVEL%

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

rem avoid output of this sequence: "error:"
echo Last return code: %LASTERROR%

exit /b %LASTERROR%

:XCOPY_FILE
call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat" %%* || exit /b
exit /b 0
