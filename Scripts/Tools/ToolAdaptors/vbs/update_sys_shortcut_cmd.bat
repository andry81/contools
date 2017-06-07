@echo off

rem Script to update the Windows shortcut file to the "COMSPEC <cmdline>" in
rem the "%SYSTEMROOT%\system32" directory (specific run under
rem Windows XP only).
rem Creating a shortcut in the "%SYSTEMROOT%" directory under Windows XP avoids
rem parasite path prefixes in the output shortcut file.

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

if not exist "%SYSTEMROOT%\system32\%SC_NAME%" (
  echo %~nx0: error: Shortcut file is not exist
  exit /b 2
) >&2

call :SET "%%SYSTEMROOT%%\system32\"
goto :EOF

:SET
%~d1
pushd "%~dp1" && (
  call echo.Current directory: "%%CD:\=/%%"
  call :CMD "%%~dp0update_shortcut.vbs" "%%SC_NAME%%" "%%WD%%" "%%%%COMSPEC%%%%" "%%CMD_LINE%%"
)

goto :EOF

:CMD
echo.^>%*
(%*)
