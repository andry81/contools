@echo off
rem echo;%*
(call)
if %* <nul ( exit /b 0 )
exit /b 255
