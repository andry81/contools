@echo off

setlocal

call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /skms kms7.MSGuides.com && ^
call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ato

exit /b 0

:CMD
echo.^>%*
(
  %*
)
