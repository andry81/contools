@echo off

if exist "%~dp0..\configure.user.bat" ( call "%~dp0..\configure.user.bat" || goto :EOF )
if not "%CONTOOLS_ROOT_TO%" == "" set "CONTOOLS_ROOT=%CONTOOLS_ROOT_TO%"

call "%%~dp0..\Tools\__init__.bat" || goto :EOF
