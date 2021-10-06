@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script prepends UTF BOM sequence to an input text file if file does not
rem   have it yet.

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%*

rem script flags
set RESTORE_LOCALE=0

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem restore locale
if %RESTORE_LOCALE% NEQ 0 call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%

:MAIN
rem script flags
set "FLAG_CHCP="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "INPUT_FILE_PATH=%~1"
set "BOM_FILE_TOKEN=%~2"
set "OUTPUT_FILE_PATH=%~3"
set "OUTPUT_FILE_DIR=%~dp3"

if not exist "%INPUT_FILE_PATH%" (
  echo.%~nx0%: error: INPUT_FILE_PATH does not exist: "%INPUT_FILE_PATH%".
  exit /b 1
) >&2

set "BOM_FILE_PATH=%CONTOOLS_ROOT%/encoding/boms/%BOM_FILE_TOKEN%.bin"

if not exist "%BOM_FILE_PATH%" (
  echo.%~nx0%: error: BOM_FILE_TOKEN token file does not exist: "%BOM_FILE_PATH%".
  exit /b 2
) >&2

if not exist "%OUTPUT_FILE_DIR%" (
  echo.%~nx0%: error: OUTPUT_FILE_DIR does not exist: "%OUTPUT_FILE_DIR%".
  exit /b 3
) >&2

set "INPUT_FILE_PATH=%~f1"
set "OUTPUT_FILE_PATH=%~f3"

set "INTERMEDIATE_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\intermediate_file.txt"
set "INPUT_FILE_BOM_PREFIX_TMP=%SCRIPT_TEMP_CURRENT_DIR%\input_file_bom_prefix.bin"

if defined FLAG_CHCP (
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" "%%FLAG_CHCP%%"
  set RESTORE_LOCALE=1
)

rem an UTF16LE file automatically checked for the BOM by the copy utility
if /i "%BOM_FILE_TOKEN%" == "fffe" goto COPY_AS_TEXT_FILES

if not "%CURRENT_CP%" == "437" (
  rem to avoid an unicode code page
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" 437
  set /A RESTORE_LOCALE+=1
)

rem read BOM from input file
set /P INPUT_FILE_BOM_STR=< "%INPUT_FILE_PATH%"

if not defined INPUT_FILE_BOM_STR goto IGNORE_BOM_CHECK

for /F "eol= tokens=* delims=" %%i in ("%BOM_FILE_PATH%") do set "BOM_FILE_SIZE=%%~zi"

rem avoid quote characters
set "INPUT_FILE_BOM_STR=%INPUT_FILE_BOM_STR:"=%"

rem trim BOM sequence by file size
if defined INPUT_FILE_BOM_STR call set "INPUT_FILE_BOM_STR=%%INPUT_FILE_BOM_STR:~0,%BOM_FILE_SIZE%%%"

if not defined INPUT_FILE_BOM_STR goto IGNORE_BOM_CHECK

for /F "eol= tokens=* delims=" %%i in ("%INPUT_FILE_BOM_STR%") do (echo.|set /P __DUMMY__=%%i) > "%INPUT_FILE_BOM_PREFIX_TMP%"
"%SystemRoot%\System32\fc.exe" "%INPUT_FILE_BOM_PREFIX_TMP%" "%BOM_FILE_PATH%" > nul
if %ERRORLEVEL% NEQ 0 goto IGNORE_BOM_CHECK

if %RESTORE_LOCALE% GTR 1 (
  call "%%CONTOOLS_ROOT%%/std/restorecp.bat"
  set /A RESTORE_LOCALE-=1
)

if /i not "%INPUT_FILE_PATH%" == "%OUTPUT_FILE_PATH%" (
  call :COPY_FILE "%%INPUT_FILE_PATH%%" "%%OUTPUT_FILE_PATH%%" >nul 2>nul || (
    echo.%~nx0%: error: could not copy to the output file: "%OUTPUT_FILE_PATH%".
    exit /b 10
  ) >&2
)

exit /b 0

:IGNORE_BOM_CHECK

if %RESTORE_LOCALE% GTR 1 (
  call "%%CONTOOLS_ROOT%%/std/restorecp.bat"
  set /A RESTORE_LOCALE-=1
)

:COPY_AS_BIN_FILES

call :COPY_TWO_BIN_FILES "%%BOM_FILE_PATH%%" "%%INPUT_FILE_PATH%%" "%%INTERMEDIATE_FILE_TMP%%" >nul 2>nul || (
  echo.%~nx0%: error: could not copy to the intermediate file: "%INTERMEDIATE_FILE_TMP%".
  exit /b 20
) >&2

call :COPY_FILE "%%INTERMEDIATE_FILE_TMP%%" "%%OUTPUT_FILE_PATH%%" >nul 2>nul || (
  echo.%~nx0%: error: could not copy to the output file: "%OUTPUT_FILE_PATH%".
  exit /b 21
) >&2

exit /b

:COPY_AS_TEXT_FILES

call :COPY_TWO_TEXT_FILES "%%BOM_FILE_PATH%%" "%%INPUT_FILE_PATH%%" "%%INTERMEDIATE_FILE_TMP%%" >nul 2>nul || (
  echo.%~nx0%: error: could not copy to the intermediate file: "%INTERMEDIATE_FILE_TMP%".
  exit /b 30
) >&2

call :COPY_FILE "%%INTERMEDIATE_FILE_TMP%%" "%%OUTPUT_FILE_PATH%%" >nul 2>nul || (
  echo.%~nx0%: error: could not copy to the output file: "%OUTPUT_FILE_PATH%".
  exit /b 31
) >&2

exit /b

:COPY_FILE
copy "%~f1" "%~f2" /B /Y || exit /b
exit /b 0

:COPY_TWO_TEXT_FILES
copy "%~f1" /A + "%~f2" /A "%~f3" /B /Y || exit /b
exit /b 0

:COPY_TWO_BIN_FILES
copy "%~f1" /B + "%~f2" /B "%~f3" /B /Y || exit /b
exit /b 0
