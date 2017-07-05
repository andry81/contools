@echo off

setlocal

set "CODE_PAGE=%~1"

if not "%CURRENT_CP%" == "" goto INIT_END

for /F "usebackq eol=	 tokens=1,* delims=:" %%i in (`chcp.com 2^>nul`) do (
  set "CURRENT_CP=%%j"
  call :INIT
)

goto INIT_END

:INIT
set "CURRENT_CP=%CURRENT_CP: =%"
set "LAST_CP=%CURRENT_CP%"
set "CP_LIST="
rem echo.chcp init "%CURRENT_CP%" >&2
:INIT_END

if not "%CODE_PAGE%" == "" ^
if not "%CURRENT_CP%" == "%CODE_PAGE%" (
  chcp.com %CODE_PAGE% >nul
  rem echo.chcp set "%CODE_PAGE%" ^<- "%CURRENT_CP%" >&2
  set "CP_LIST=%CURRENT_CP%|"
  set "LAST_CP=%CURRENT_CP%"
  set "CURRENT_CP=%CODE_PAGE%"
)

(
  endlocal
  set "CP_LIST=%CP_LIST%"
  set "LAST_CP=%LAST_CP%"
  set "CURRENT_CP=%CURRENT_CP%"
)
