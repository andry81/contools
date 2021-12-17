@echo off

rem drop return values
set "CMAKE_CMD_LINE.CONFIGURE="
set "CMAKE_CMD_LINE.MAKE="
set "CMAKE_CMD_LINE.INSTALL="

setlocal DISABLEDELAYEDEXPANSION

set "CONFIG_ROOT=%~1"

if defined CONFIG_ROOT (
  if "\" == "%CONFIG_ROOT:~0,1%" exit /b 1
  if "\" == "%CONFIG_ROOT:~-1%" set "CONFIG_ROOT=%CONFIG_ROOT:~0,-1%"
)

if not defined CONFIG_ROOT exit /b 1

set "?~nx0=%~nx0"

set CMD_LINE_FILES_LIST=.cmake\00_configure.lst .cmake\01_make.lst .cmake\02_install.lst

for %%i in (%CMD_LINE_FILES_LIST%) do (
  set "CMD_LINE_FILE=%%i"
  call :PROCESS_CMD_LINE_FILE
)

rem special variable return trick to return variables with special characters
setlocal ENABLEDELAYEDEXPANSION

set "RETURN_EXEC_LINE=call;"
if defined CMAKE_CMD_LINE.CONFIGURE set RETURN_EXEC_LINE=!RETURN_EXEC_LINE! ^& set "CMAKE_CMD_LINE.CONFIGURE=%%i"
if defined CMAKE_CMD_LINE.MAKE set RETURN_EXEC_LINE=!RETURN_EXEC_LINE! ^& set "CMAKE_CMD_LINE.MAKE=%%j"
if defined CMAKE_CMD_LINE.INSTALL set RETURN_EXEC_LINE=!RETURN_EXEC_LINE! ^& set "CMAKE_CMD_LINE.INSTALL=%%k"

if defined CMAKE_CMD_LINE.CONFIGURE for /F tokens^=^*^ delims^=^ eol^= %%i in ("!CMAKE_CMD_LINE.CONFIGURE!") do (
  if defined CMAKE_CMD_LINE.MAKE for /F tokens^=^*^ delims^=^ eol^= %%j in ("!CMAKE_CMD_LINE.MAKE!") do (
    if defined CMAKE_CMD_LINE.INSTALL for /F tokens^=^*^ delims^=^ eol^= %%k in ("!CMAKE_CMD_LINE.INSTALL!") do (
      endlocal
      endlocal
      %RETURN_EXEC_LINE%
    ) else (
      endlocal
      endlocal
      %RETURN_EXEC_LINE%
    )
  ) else if defined CMAKE_CMD_LINE.INSTALL for /F tokens^=^*^ delims^=^ eol^= %%k in ("!CMAKE_CMD_LINE.INSTALL!") do (
    endlocal
    endlocal
    %RETURN_EXEC_LINE%
  ) else (
    endlocal
    endlocal
    %RETURN_EXEC_LINE%
  )
) else if defined CMAKE_CMD_LINE.MAKE for /F tokens^=^*^ delims^=^ eol^= %%j in ("!CMAKE_CMD_LINE.MAKE!") do (
  if defined CMAKE_CMD_LINE.INSTALL for /F tokens^=^*^ delims^=^ eol^= %%k in ("!CMAKE_CMD_LINE.INSTALL!") do (
    endlocal
    endlocal
    %RETURN_EXEC_LINE%
  ) else (
    endlocal
    endlocal
    %RETURN_EXEC_LINE%
  )
) else if defined CMAKE_CMD_LINE.INSTALL for /F tokens^=^*^ delims^=^ eol^= %%k in ("!CMAKE_CMD_LINE.INSTALL!") do (
  endlocal
  endlocal
  %RETURN_EXEC_LINE%
)

exit /b 0

:PROCESS_CMD_LINE_FILE
if "%CMD_LINE_FILE:_install.=%" == "%CMD_LINE_FILE%" (
  if not exist "%CONFIG_ROOT%\%CMD_LINE_FILE%" (
    echo.%?~nx0%: error: cmake command line file must exist: "%CONFIG_ROOT%\%CMD_LINE_FILE%"
    exit /b 2
  )
) else if not exist "%CONFIG_ROOT%\%CMD_LINE_FILE%" exit /b 0

set "CMD_LINE_VAR_NAME="
if not "%CMD_LINE_FILE:_configure.=%" == "%CMD_LINE_FILE%" (
  set "CMD_LINE_VAR_NAME=CMAKE_CMD_LINE.CONFIGURE"
) else if not "%CMD_LINE_FILE:_make.=%" == "%CMD_LINE_FILE%" (
  set "CMD_LINE_VAR_NAME=CMAKE_CMD_LINE.MAKE"
) else if not "%CMD_LINE_FILE:_install.=%" == "%CMD_LINE_FILE%" (
  set "CMD_LINE_VAR_NAME=CMAKE_CMD_LINE.INSTALL"
)

call "%%CONTOOLS_ROOT%%/joinvars.bat" %%CMD_LINE_VAR_NAME%% "%CONFIG_ROOT%\%CMD_LINE_FILE%" " "

if not "%CMD_LINE_VAR_NAME%" == "CMAKE_CMD_LINE.INSTALL" (
  if not defined %CMD_LINE_VAR_NAME% (
    echo.%?~nx0%: error: cmake command line file must not be empty: "%CONFIG_ROOT%\%CMD_LINE_FILE%"
    exit /b 3
  )
)
