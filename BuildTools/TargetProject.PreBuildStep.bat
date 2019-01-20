@echo off

setlocal

rem Drop last error code
type nul>nul

call "%%~dp0__init__.bat" || goto :EOF

set "SOLUTION_DIR=%~1"
set "PROJECT_DIR=%~2"
set "PROJECT_IN_SRC_DIR=%~3"
set "PROJECT_NAME=%~4"
set "UNICODE_ENABLED=%~5"

set "PROJECT_IN_SRC_DIR_PATH=%PROJECT_NAME%"

if defined PROJECT_IN_SRC_DIR set "PROJECT_IN_SRC_DIR_PATH=%PROJECT_IN_SRC_DIR%\%PROJECT_IN_SRC_DIR_PATH%"

if not defined UNICODE_ENABLED set UNICODE_ENABLED=0

set "BUILD_TOOLS_DIR=%SOLUTION_DIR%..\BuildTools"
set "SOURCES_DIR=%SOLUTION_DIR%..\Utilities\src\%PROJECT_IN_SRC_DIR_PATH%"
set "CONSOLE_HELP_FILE=%SOURCES_DIR%\help"

pushd "%SOURCES_DIR%" && (
  "%BUILD_TOOLS_DIR%\msys\bin\autogen.exe" -L "%SOURCES_DIR%" help.def
  "%BUILD_TOOLS_DIR%\msys\bin\autogen.exe" -L "%SOURCES_DIR%" version.def
  popd
) || exit /b 65534

set "THLIBAUTOCFG_CMD_LINE_FLAGS="
if %UNICODE_ENABLED% NEQ 0 set THLIBAUTOCFG_CMD_LINE_FLAGS=%THLIBAUTOCFG_CMD_LINE_FLAGS%u

set "THLIBAUTOCFG_CMD_LINE="
if defined THLIBAUTOCFG_CMD_LINE_FLAGS set "THLIBAUTOCFG_CMD_LINE=-%THLIBAUTOCFG_CMD_LINE_FLAGS% "

if exist "%CONSOLE_HELP_FILE%.txt" (
  echo   "%CONSOLE_HELP_FILE%_inl.hpp"
  call :CMD "%CONTOOLS_ROOT%/thlibautocfg.exe" -txt2c %THLIBAUTOCFG_CMD_LINE%"%CONSOLE_HELP_FILE%.txt" "%CONSOLE_HELP_FILE%_inl.hpp"
)

rem avoid output of this sequence: "error:"
echo Last return code: %ERRORLEVEL%

exit /b

:CMD
echo.^>%*
(%*)
exit /b 0
