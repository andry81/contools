@echo off

setlocal

rem remember current code page
call :GET_CURRENT_CODE_PAGE

rem set utf-8 code page for sqlite
chcp 65001 2>&1 >nul

"%~dp0sqlite3.exe" %*

rem restore code page
chcp %CURRENT_CODE_PAGE% 2>&1 >nul

:GET_CURRENT_CODE_PAGE
for /F "usebackq eol= tokens=2 delims=:" %%i in (`chcp 2^>nul`) do set CURRENT_CODE_PAGE=%%i
set CURRENT_CODE_PAGE=%CURRENT_CODE_PAGE: =%
