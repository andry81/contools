@echo off & goto DOC_END

rem Description:
rem   Script to print corrupted part files printed in the log file.
:DOC_END

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

set IS_FOUND=0
set IS_NOEXT_FOUND=0

(for /F "usebackq tokens=1,* delims=("eol^= %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\System32\findstr.exe" /R /I /C:"Failed to open part.met file! ([0-9][0-9]*.part.met.bak "`) do ^
for /F "tokens=1,* delims= "eol^= %%k in ("%%j") do set "IS_FOUND=1" & echo;%%k) >> "%CORRUPTED_EMULE_PART_FILE_LIST%"

(for /F "usebackq tokens=1,2,3,4,* delims= "eol^= %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\System32\findstr.exe" /R /I /C:"[0-9][0-9]*.part.met.bak () is corrupt"`) do ^
set "IS_FOUND=1" & echo;%%l) >> "%CORRUPTED_EMULE_PART_FILE_LIST%"

(for /F "usebackq tokens=1,* delims=("eol^= %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\System32\findstr.exe" /R /I /C:"Invalid part.met file version! ([0-9][0-9]*.part.met.bak "`) do ^
for /F "tokens=1,* delims= "eol^= %%k in ("%%j") do set "IS_FOUND=1" & echo;%%k) >> "%CORRUPTED_EMULE_PART_FILE_LIST%"

for /F "usebackq tokens=1,2,3,4,* delims= "eol^= %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\System32\findstr.exe" /R /I /C:"[0-9][0-9]*.part.met () is corrupt"`) do (^
set "IS_FOUND=1" & ((echo;%%l) >> "%CORRUPTED_EMULE_PART_FILE_LIST%") & set "IS_NOEXT_FOUND=0" & ((echo;%%~nl) >> "%CORRUPTED_EMULE_PART_FILE_NOEXT_LIST%"))

for /F "usebackq tokens=1,* delims=("eol^= %%i in (`type "%LOG_FILE%" ^| "%SystemRoot%\System32\findstr.exe" /R /I /C:"Invalid part.met file version! ([0-9][0-9]*.part.met "`) do ^
for /F "tokens=1,* delims= "eol^= %%k in ("%%j") do (^
set "IS_FOUND=1" & ((echo;%%k) >> "%CORRUPTED_EMULE_PART_FILE_LIST%") & set "IS_NOEXT_FOUND=0" & ((echo;%%~nk) >> "%CORRUPTED_EMULE_PART_FILE_NOEXT_LIST%"))

rem CAUTION:
rem   See https://stackoverflow.com/questions/8844868/what-are-the-undocumented-features-and-limitations-of-the-windows-findstr-comman
rem   for details about `findstr.exe` bizarre escape logic around `/G` together with `/R` parameter.
rem
rem   TODO TO FIX:
rem     1. Added `/I` flag to workaround a case, where a specific line of the list file under `/G` option does not match properly.
rem     2. File under `/G` option has to be escaped for `\` and `.` characters. This avoids another search lines invalid match around `/V` parameter.
rem        This is due to a guess logic around the file content under `/G` option, which content can be treated as regex only strings if a regex character is found in the first line of the file!

if %IS_FOUND% EQU 0 (
  echo;Not found.
  exit /b 1
)

if %IS_NOEXT_FOUND% NEQ 0 ^
type "%EMULE_CONFIG_DIR%\downloads.txt" | "%SystemRoot%\System32\findstr.exe" /B /L /I /G:"%CORRUPTED_EMULE_PART_FILE_NOEXT_LIST%"

echo;---

for /F "usebackq tokens=* delims="eol^= %%i in ("%CORRUPTED_EMULE_PART_FILE_LIST%") do call :PRINT "%%i"

exit /b 0

:PRINT
if not exist "%EMULE_TEMP_DIR%\%~1" exit /b 0
echo;%~1

exit /b 0
