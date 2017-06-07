@echo off

rem Script to update the Windows shortcut file.

rem Drom last error level
cd .

rem Save all variables to stack
setlocal

set "SC_NAME=%~1"
set "WD=%~2"
set "CMD_LINE=%~3"

if "%SC_NAME%" == "" (
  echo %~nx0: error: Shortcut name is not defined
  exit /b 1
) >&2

if not exist "%SC_NAME%" (
  echo %~nx0: error: Shortcut file is not exist
  exit /b 2
) >&2

call :SET
goto :EOF

:SET
echo.Current directory: "%CD:\=/%"
call :CMD "%%~dp0update_shortcut.vbs" "%%SC_NAME%%" "%%WD%%" "%%%%COMSPEC%%%%" "%%CMD_LINE%%"

goto :EOF

:CMD
echo.^>%*
(%*)
