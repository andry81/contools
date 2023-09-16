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

call "%%CONTOOLS_ROOT%%/build/init_vars_file.bat" || exit /b

call "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat" -X /pause-on-exit -- %%* || exit /b

exit /b 0

:IMPL

rem load initialization environment variables
if defined INIT_VARS_FILE call "%%CONTOOLS_ROOT%%/std/set_vars_from_file.bat" "%%INIT_VARS_FILE%%"

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

set "LOG_FILE=%~1"

if not defined LOG_FILE goto USE_EMULE_LOG_DIR

set "LOG_FILE=%~f1"

goto USE_EMULE_LOG_DIR_END

:USE_EMULE_LOG_DIR

set "LOG_FILE=%EMULE_LOG_DIR%\eMule.log"

:USE_EMULE_LOG_DIR_END

if not exist "%LOG_FILE%" (
  echo.%?~nx0%: error: LOG_FILE does not exist: "%LOG_FILE%".
  exit /b 255
) >&2

echo "LOG_FILE=%LOG_FILE%"
echo.

set "CORRUPTED_EMULE_PART_FILE_LIST=%SCRIPT_TEMP_CURRENT_DIR%\corrupted_emule_part_file_list.lst"
set "CORRUPTED_EMULE_PART_FILE_NOEXT_LIST=%SCRIPT_TEMP_CURRENT_DIR%\corrupted_emule_part_file_list.noext.lst"

(for /F "usebackq eol= tokens=1,* delims=(" %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\system32\findstr.exe" /R /I /C:"Failed to open part.met file! ([0-9][0-9]*.part.met.bak "`) do ^
for /F "eol= tokens=1,* delims= " %%k in ("%%j") do echo.%%k) >> "%CORRUPTED_EMULE_PART_FILE_LIST%"

(for /F "usebackq eol= tokens=1,2,3,4,* delims= " %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\system32\findstr.exe" /R /I /C:"[0-9][0-9]*.part.met.bak () is corrupt"`) do echo.%%l) >> "%CORRUPTED_EMULE_PART_FILE_LIST%"

(for /F "usebackq eol= tokens=1,* delims=(" %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\system32\findstr.exe" /R /I /C:"Invalid part.met file version! ([0-9][0-9]*.part.met.bak "`) do ^
for /F "eol= tokens=1,* delims= " %%k in ("%%j") do echo.%%k) >> "%CORRUPTED_EMULE_PART_FILE_LIST%"

for /F "usebackq eol= tokens=1,2,3,4,* delims= " %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\system32\findstr.exe" /R /I /C:"[0-9][0-9]*.part.met () is corrupt"`) do (^
((echo.%%l) >> "%CORRUPTED_EMULE_PART_FILE_LIST%") & ((echo.%%~nl) >> "%CORRUPTED_EMULE_PART_FILE_NOEXT_LIST%"))

for /F "usebackq eol= tokens=1,* delims=(" %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\system32\findstr.exe" /R /I /C:"Invalid part.met file version! ([0-9][0-9]*.part.met "`) do ^
for /F "eol= tokens=1,* delims= " %%k in ("%%j") do (^
((echo.%%k) >> "%CORRUPTED_EMULE_PART_FILE_LIST%") & ((echo.%%~nk) >> "%CORRUPTED_EMULE_PART_FILE_NOEXT_LIST%"))

type "%EMULE_CONFIG_DIR%\downloads.txt" | "%SystemRoot%\system32\findstr.exe" /B /L /G:"%CORRUPTED_EMULE_PART_FILE_NOEXT_LIST%"

echo.
echo.Deleting...

for /F "eol= tokens=* delims=" %%i in ("%CORRUPTED_EMULE_PART_FILE_LIST%") do call :DEL "%%i"

exit /b 0

:DEL
if not exist "%EMULE_PENDING_DIR%\%~1" exit /b 0
echo.- %~1
del /F /Q /A:-D "%EMULE_PENDING_DIR%\%~1"
