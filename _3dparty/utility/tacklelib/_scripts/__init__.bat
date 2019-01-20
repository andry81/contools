@echo off

call :CANONICAL_PATH "%%~dp0.."
set "PROJECT_ROOT=%PATH_VALUE%"

exit /b 0

:CANONICAL_PATH
set "PATH_VALUE=%~dpf1"
set "PATH_VALUE=%PATH_VALUE:\=/%"
exit /b 0
