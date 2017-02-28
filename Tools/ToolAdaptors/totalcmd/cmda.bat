@echo off

set "USER=%~1"

if "%USER%" == "" call :GET_DEFAULT_ADMIN_NAME

runas /user:%USER% "\"%COMSPEC%\" /K %CD:~0,2%&call cd \"%CD%\"&title User: %USER%"

goto :EOF

:GET_DEFAULT_ADMIN_NAME
setlocal

call "%%~dp0cmda.user.bat"

:ADMIN_GROUPS_LOOP
set "ADMINS="
for /F "usebackq tokens=* delims=" %%i in (`net localgroup "%ADMINS_GROUP%" 2^>nul`) do (
  call set "ADMINS=%%ADMINS%%|%%%%i"
)

set "ADMINS=%ADMINS:*--|=%"

for /F "tokens=1 delims=|" %%i in ("%ADMINS%") do set "USER=%%i"

(
  endlocal
  set "USER=%USER%"
)

exit /b 0
