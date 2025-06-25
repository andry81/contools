@echo off
rem echo;%*
:LOOP
(call)
if %~1 <nul ( shift ) else exit /b 255
( if not "%~1" == "" goto LOOP ) & exit /b 0
