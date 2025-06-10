@echo off
rem echo;%*
:LOOP
(call)
if %~1 <nul ( exit /b 0 ) else shift
( if not "%~1" == "" goto LOOP ) & exit /b 255
