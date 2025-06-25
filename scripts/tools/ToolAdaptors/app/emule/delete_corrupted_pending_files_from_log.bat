@echo off

setlocal

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LAST_ERROR%

:MAIN
set "LOG_FILE=%~1"

if not defined LOG_FILE goto USE_EMULE_LOG_DIR

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" LOG_FILE "%%LOG_FILE%%"

goto USE_EMULE_LOG_DIR_END

:USE_EMULE_LOG_DIR

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" LOG_FILE "%%EMULE_LOG_DIR%%\eMule.log"

:USE_EMULE_LOG_DIR_END

if not exist "%LOG_FILE%" (
  echo;%?~%: error: LOG_FILE does not exist: "%LOG_FILE%".
  exit /b 255
) >&2

echo "LOG_FILE=%LOG_FILE%"
echo;

set "CORRUPTED_EMULE_PART_FILE_LIST=%SCRIPT_TEMP_CURRENT_DIR%\corrupted_emule_part_file_list.lst"
set "CORRUPTED_EMULE_PART_FILE_NOEXT_LIST=%SCRIPT_TEMP_CURRENT_DIR%\corrupted_emule_part_file_list.noext.lst"

(for /F "usebackq tokens=1,* delims=("eol^= %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\System32\findstr.exe" /R /I /C:"Failed to open part.met file! ([0-9][0-9]*.part.met.bak "`) do ^
for /F "tokens=1,* delims= "eol^= %%k in ("%%j") do echo;%%k) >> "%CORRUPTED_EMULE_PART_FILE_LIST%"

(for /F "usebackq tokens=1,2,3,4,* delims= "eol^= %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\System32\findstr.exe" /R /I /C:"[0-9][0-9]*.part.met.bak () is corrupt"`) do echo;%%l) >> "%CORRUPTED_EMULE_PART_FILE_LIST%"

(for /F "usebackq tokens=1,* delims=("eol^= %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\System32\findstr.exe" /R /I /C:"Invalid part.met file version! ([0-9][0-9]*.part.met.bak "`) do ^
for /F "tokens=1,* delims= "eol^= %%k in ("%%j") do echo;%%k) >> "%CORRUPTED_EMULE_PART_FILE_LIST%"

for /F "usebackq tokens=1,2,3,4,* delims= "eol^= %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\System32\findstr.exe" /R /I /C:"[0-9][0-9]*.part.met () is corrupt"`) do (^
((echo;%%l) >> "%CORRUPTED_EMULE_PART_FILE_LIST%") & ((echo;%%~nl) >> "%CORRUPTED_EMULE_PART_FILE_NOEXT_LIST%"))

for /F "usebackq tokens=1,* delims=("eol^= %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\System32\findstr.exe" /R /I /C:"Invalid part.met file version! ([0-9][0-9]*.part.met "`) do ^
for /F "tokens=1,* delims= "eol^= %%k in ("%%j") do (^
((echo;%%k) >> "%CORRUPTED_EMULE_PART_FILE_LIST%") & ((echo;%%~nk) >> "%CORRUPTED_EMULE_PART_FILE_NOEXT_LIST%"))

type "%EMULE_CONFIG_DIR%\downloads.txt" | "%SystemRoot%\System32\findstr.exe" /B /L /G:"%CORRUPTED_EMULE_PART_FILE_NOEXT_LIST%"

echo;
echo;Deleting...

for /F "usebackq tokens=* delims="eol^= %%i in ("%CORRUPTED_EMULE_PART_FILE_LIST%") do call :DEL "%%i"

exit /b 0

:DEL
if not exist "%EMULE_TEMP_DIR%\%~1" exit /b 0
echo;- %~1
del /F /Q /A:-D "%EMULE_TEMP_DIR%\%~1"
