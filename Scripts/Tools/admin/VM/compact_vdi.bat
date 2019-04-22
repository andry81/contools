@echo off

setlocal

set "VDI_DIR=%~1"
set "VBOX_MANAGE_EXE=%~2"

if not defined VBOX_MANAGE_EXE set "VBOX_MANAGE_EXE=c:\Program Files\VirtualBox\VBoxManage.exe"

if not defined VDI_DIR (
  echo.%~nx0: error: VDI_DIR not defined
  exit /b 255
) >&2

if not exist "%VDI_DIR%\" (
  echo.%~nx0: error: VDI_DIR not exist: VDI_DIR="%VDI_DIR%"
  exit /b 254
) >&2

if not exist "%VBOX_MANAGE_EXE%" (
  echo.%~nx0: error: VBOX_MANAGE_EXE not exist: VBOX_MANAGE_EXE="%VBOX_MANAGE_EXE%"
  exit /b 253
) >&2

set "VDI_DIR=%~f1"

for /F "usebackq eol=| tokens=* delims=" %%i in (`dir /A:-D /B /S "%VDI_DIR%\*.vdi" 2^>nul`) do (
  set "VDI_FILE=%%i"
  call :COMPACT_VDI_FILE
)

exit /b

:COMPACT_VDI_FILE
call :CMD "%%VBOX_MANAGE_EXE%%" modifymedium --compact "%%VDI_FILE%%"
exit /b

:CMD
echo.^>%*
(
  %*
)
exit /b
