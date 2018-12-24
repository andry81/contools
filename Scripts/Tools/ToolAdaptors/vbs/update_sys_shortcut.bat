@echo off

rem Script to update the Windows shortcut file to the "<cmdline>" in
rem the "%SYSTEMROOT%\system32" directory (specific run under
rem Windows XP only).
rem Creating a shortcut in the "%SYSTEMROOT%\system32" directory under Windows XP avoids
rem parasite path prefixes in the output shortcut file.

rem Drom last error level
type nul>nul

rem Save all variables to stack
setlocal

set "SC_NAME=%~1"
set "WD=%~2"
set "CMD=%~3"
set "ARGS=%~4"

if not defined SC_NAME (
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
pushd "%SYSTEMROOT%\system32\" && (
  call echo.Current directory: "%%CD:\=/%%"
  call :CMD "%%~dp0update_shortcut.vbs" "%%SC_NAME%%" "%%WD%%" "%%CMD%%" "%%ARGS%%"
  popd
)

goto :EOF

:CMD
echo.^>%*
(%*)
