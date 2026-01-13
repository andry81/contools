@echo off & goto DOC_END

rem Description:
rem   Script to print orphan part files not in the current download list.
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
set "EMULE_PART_FILE_LIST=%SCRIPT_TEMP_CURRENT_DIR%\emule_part_file_list.lst"

set "EMULE_DOWNLOAD_PART_FILE_LIST=%SCRIPT_TEMP_CURRENT_DIR%\emule_download_part_file_list.lst"

set HAS_FILES=0

pushd "%EMULE_TEMP_DIR%" && (
  (for %%i in ("*.part") do set "HAS_FILES=1" & echo;%%i) >> "%EMULE_PART_FILE_LIST%"
  popd
)

(
  for /F "usebackq tokens=1 delims=	"eol^= %%i in (`@type "%EMULE_CONFIG_DIR%\downloads.txt" ^| "%SystemRoot%\System32\findstr.exe" /B /R /I /C:"[0-9][0-9]*\.part"`) do echo;%%i
) > "%EMULE_DOWNLOAD_PART_FILE_LIST%"

rem CAUTION:
rem   See https://stackoverflow.com/questions/8844868/what-are-the-undocumented-features-and-limitations-of-the-windows-findstr-comman
rem   for details about `findstr.exe` bizarre escape logic around `/G` together with `/R` parameter.
rem
rem   TODO TO FIX:
rem     1. Added `/I` flag to workaround a case, where a specific line of the list file under `/G` option does not match properly.
rem     2. File under `/G` option has to be escaped for `\` and `.` characters. This avoids another search lines invalid match around `/V` parameter.
rem        This is due to a guess logic around the file content under `/G` option, which content can be treated as regex only strings if a regex character is found in the first line of the file!

if %HAS_FILES% NEQ 0 ^
type "%EMULE_PART_FILE_LIST%" | "%SystemRoot%\System32\findstr.exe" /B /L /V /G:"%EMULE_DOWNLOAD_PART_FILE_LIST%"

if %HAS_FILES% NEQ 0 exit /b 0

exit /b 1
