@echo off

setlocal

set "VDI_DIR=%~1"

if not defined VBOX_MANAGE_EXE set "VBOX_MANAGE_EXE=%~2"

if not defined VBOX_MANAGE_EXE for /f "usebackq tokens=1,2,* delims=	 " %%i in (`@"%SystemRoot%\System32\reg.exe" query "HKEY_LOCAL_MACHINE\SOFTWARE\Oracle\VirtualBox" /v "InstallDir"`) do (
  if "%%i" == "InstallDir" set "VBOX_MANAGE_EXE=%%kVBoxManage.exe"
)

if not defined VBOX_MANAGE_EXE set "VBOX_MANAGE_EXE=c:\Program Files\VirtualBox\VBoxManage.exe"

if not defined VDI_DIR (
  echo.%~nx0: error: VDI_DIR is not defined.
  exit /b 255
) >&2

for /F "eol= tokens=* delims=" %%i in ("%VDI_DIR%\.") do set "VDI_DIR=%%~fi"

if not exist "%VDI_DIR%\*" (
  echo.%~nx0: error: VDI_DIR does not exist: VDI_DIR="%VDI_DIR%"
  exit /b 255
) >&2

if not exist "%VBOX_MANAGE_EXE%" (
  echo.%~nx0: error: VBOX_MANAGE_EXE not exist: VBOX_MANAGE_EXE="%VBOX_MANAGE_EXE%"
  exit /b 255
) >&2

rem CAUTION:
rem   If a variable is empty, then it would not be expanded in the `cmd.exe` command line or in case of `for /F ...`!
rem   We must expand the command line into a variable.
rem
set ?.=@dir "%VDI_DIR%\*.vdi" /A:-D /B /O:N /S

for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
  set "VDI_FILE=%%i"
  call :COMPACT_VDI_FILE
)

exit /b

:COMPACT_VDI_FILE
call :CMD "%%VBOX_MANAGE_EXE%%" modifymedium --compact "%%VDI_FILE%%"
echo.
exit /b

:CMD
echo.^>%*
(
  %*
)
exit /b
