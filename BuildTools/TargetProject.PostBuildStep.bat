@echo off

setlocal

rem Drop last error code
cd .

set "TARGET_PATH=%~1"
set "BINARY_DIR=%~2"

for /F "usebackq tokens=1,* delims=:" %%i in (`chcp 2^>nul`) do set LAST_CODE_PAGE=%%j
set LAST_CODE_PAGE=%LAST_CODE_PAGE: =%

rem switch locale into english compatible locale
chcp 65001 >nul

call :CMD xcopy "%%TARGET_PATH%%" "%%BINARY_DIR%%" /Y /H /R

set LASTERROR=%ERRORLEVEL%

rem restore locale
if not "%LAST_CODE_PAGE%" == "65001" chcp %LAST_CODE_PAGE% >nul

rem avoid output of this sequence: "error:"
echo Last return code: %LASTERROR%

exit /b %LASTERROR%

:CMD
echo.^>%*
rem echo.F will only work if locale is in english !!!
echo.F|(%*)
exit /b
