@echo off

rem based on: https://superuser.com/questions/10426/windows-equivalent-of-the-linux-command-touch/764725#764725
rem

setlocal

if not exist "%~1" ( type nul >> "%~1" & exit /b )

set _ATTRIBUTES=%~a1
if "%~a1" == "%_ATTRIBUTES:r=%" (copy "%~1"+,, > nul) else ( attrib -r "%~1" & copy "%~1"+,, > nul & attrib +r "%~1" )
