@echo off

setlocal

call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /skms kms9.MSGuides.com && ^
call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ato

exit /b 0

:CMD
echo.^>%*
(
  %*
)
