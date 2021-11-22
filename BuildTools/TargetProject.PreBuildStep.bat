@echo off

setlocal

rem Drop last error code
type nul>nul

call "%%~dp0__init__\__init__.bat" || exit /b

set "PROJECT_NAME=%~1"
set "SOURCES_DIR=%~2"
set "UNICODE_ENABLED=%~3"

if not defined UNICODE_ENABLED set UNICODE_ENABLED=0

set "CONSOLE_HELP_FILE=%SOURCES_DIR%\help"

set "AUTOGEN_BARE_FLAGS="

if not defined AUTOGEN_DEFINITIONS goto AUTOGEN_DEFINITIONS_END

set AUTOGEN_DEF_INDEX=1

:AUTOGEN_DEFINITIONS_LOOP
set "AUTOGEN_DEF_VALUE="
for /F "eol= tokens=%AUTOGEN_DEF_INDEX% delims=;" %%i in ("%AUTOGEN_DEFINITIONS%") do set "AUTOGEN_DEF_VALUE=%%i"

if not defined AUTOGEN_DEF_VALUE goto AUTOGEN_DEFINITIONS_END

set AUTOGEN_BARE_FLAGS=%AUTOGEN_BARE_FLAGS% -D %AUTOGEN_DEF_VALUE%
set /A AUTOGEN_DEF_INDEX+=1

goto AUTOGEN_DEFINITIONS_LOOP

:AUTOGEN_DEFINITIONS_END

if not defined APP_MODULE_NAME set "APP_MODULE_NAME=%PROJECT_NAME%"

pushd "%SOURCES_DIR%" && (
  if exist "%SOURCES_DIR%\help.def" call :CMD "%%CONTOOLS_AUTOGEN_ROOT%%\bin\autogen.exe"%%AUTOGEN_BARE_FLAGS%% -L "%%SOURCES_DIR%%" help.def
  call :CMD "%%CONTOOLS_AUTOGEN_ROOT%%\bin\autogen.exe"%%AUTOGEN_BARE_FLAGS%% -L "%%SOURCES_DIR%%" version.def
  popd
) || exit /b 255

set "THLIBAUTOCFG_BARE_FLAGS="
if %UNICODE_ENABLED% NEQ 0 set THLIBAUTOCFG_BARE_FLAGS=%THLIBAUTOCFG_BARE_FLAGS% -u

if exist "%CONSOLE_HELP_FILE%.txt" call :CMD "%%CONTOOLS_UTILITIES_BIN_ROOT%%/contools/thlibautocfg.exe"%%THLIBAUTOCFG_BARE_FLAGS%% -txt2c "%%CONSOLE_HELP_FILE%%.txt" "%%CONSOLE_HELP_FILE%%_inl.hpp"

rem avoid output of this sequence: "error:"
echo Last return code: %ERRORLEVEL%

exit /b %ERRORLEVEL%

:CMD
echo.^>%*
(
  %*
)
exit /b 0
