@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%*

for %%i in (CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

set "INIT_VARS_FILE=%PROJECT_LOG_DIR%\init.vars"

rem register all environment variables
set 2>nul > "%INIT_VARS_FILE%"

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /pause-on-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
  /v IMPL_MODE 1 /v INIT_VARS_FILE "%INIT_VARS_FILE%" ^
  /ra "%%" "%%?01%%" /v "?01" "%%" ^
  "${COMSPEC}" "/c \"@\"${?~f0}\" {*}\"" %* || exit /b

exit /b 0

:IMPL
rem load initialization environment variables
for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%INIT_VARS_FILE%") do set "%%i=%%j"

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || (
  echo.%?~nx0%: error: could not allocate temporary directory: "%SCRIPT_TEMP_CURRENT_DIR%"
  set LASTERROR=255
  goto FREE_TEMP_DIR
) >&2

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%

:MAIN
rem ex: "TargetPath|Arguments|WorkingDirectory"
set "PROPS_LIST=%~1"
set "LINKS_DIR=%~2"
set "REPLACE_FROM=%~3"
set "REPLACE_TO=%~4"

if not defined PROPS_LIST (
  echo.%~nx0: error: PROPS_LIST is not defined.
  exit /b 255
) >&2

if defined LINKS_DIR if exist "%LINKS_DIR%\" goto LINKS_DIR_EXIST

(
  echo.%~nx0: error: LINKS_DIR does not exist: `%LINKS_DIR%`.
  exit /b 255
) >&2

:LINKS_DIR_EXIST

if not defined REPLACE_FROM (
  echo.%~nx0: error: REPLACE_FROM is not defined.
  exit /b 255
) >&2

if not defined REPLACE_TO (
  echo.%~nx0: error: REPLACE_TO is not defined.
  exit /b 255
) >&2

if "%REPLACE_FROM%" == "%REPLACE_TO%" (
  echo.%~nx0: error: REPLACE_FROM is equal to REPLACE_TO: REPLACE_FROM="%REPLACE_FROM%".
  exit /b 255
) >&2

rem default props list
if "%PROPS_LIST%" == "." set "PROPS_LIST=TargetPath|WorkingDirectory"

for /F "eol= tokens=* delims=" %%i in ("%LINKS_DIR%\.") do set "LINKS_DIR=%%~fi"

for /F "usebackq eol= tokens=* delims=" %%i in (`dir /A:-D /B /S "%LINKS_DIR%\*.lnk"`) do (
  set "LINK_FILE_PATH=%%i"
  call :UPDATE_LINK
)

exit /b 0

:UPDATE_LINK
echo.%LINK_FILE_PATH%

"%SystemRoot%\System32\cscript.exe" //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/read_shortcut.vbs" -p "%PROPS_LIST%" -- "%LINK_FILE_PATH%" > "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst"

set "UPDATE_SHORTCUT_CMDLINE="

for /F "usebackq eol= tokens=1,* delims==" %%i in ("%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst") do (
  set "PROP_NAME=%%i"
  set "PROP_VALUE=%%j"
  call :UPDATE_SHORTCUT_CMDLINE
)

echo.

if defined UPDATE_SHORTCUT_CMDLINE "%SystemRoot%\System32\cscript.exe" //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/update_shortcut.vbs"%UPDATE_SHORTCUT_CMDLINE% -- "%LINK_FILE_PATH%"

exit /b

:UPDATE_SHORTCUT_CMDLINE
rem remove quotes at first
set "PROP_VALUE=%PROP_VALUE:"=%"

call set "PROP_VALUE=%%PROP_VALUE:%REPLACE_FROM%=%REPLACE_TO%%%

set "PROP_LINE=%PROP_NAME%=%PROP_VALUE%"

if /i "%PROP_NAME%" == "TargetPath" (
  call "%%CONTOOLS_ROOT%%/std/echo_var.bat" PROP_LINE
  set UPDATE_SHORTCUT_CMDLINE=%UPDATE_SHORTCUT_CMDLINE% -t "%PROP_VALUE%"
)
if /i "%PROP_NAME%" == "WorkingDirectory" (
  call "%%CONTOOLS_ROOT%%/std/echo_var.bat" PROP_LINE
  set UPDATE_SHORTCUT_CMDLINE=%UPDATE_SHORTCUT_CMDLINE% -WD "%PROP_VALUE%"
)
