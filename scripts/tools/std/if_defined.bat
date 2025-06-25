@echo off
(call)
if defined %~1 <nul ( exit /b 0 )
exit /b 255
