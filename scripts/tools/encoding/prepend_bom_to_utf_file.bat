@echo off & goto DOC_END

rem Description:
rem   Script prepends UTF BOM sequence to a text file if file does not
rem   have it yet and output the result into another text file.
:DOC_END

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem script flags
set RESTORE_LOCALE=0

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\%?~n0%.%RANDOM%-%RANDOM%"
) else set "TEMP_DIR=%TEMP%\%?~n0%.%RANDOM%-%RANDOM%"

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

if exist "%TEMP_DIR%\*" rmdir /S /Q "%TEMP_DIR%" >nul 2>nul

rem restore locale
if %RESTORE_LOCALE% NEQ 0 call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b %LAST_ERROR%

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
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "INPUT_FILE_PATH=%~1"
set "BOM_FILE_TOKEN=%~2"
set "OUTPUT_FILE_PATH=%~3"

if not defined INPUT_FILE_PATH (
  echo;%?~%: error: INPUT_FILE_PATH is not defined.
  exit /b 255
) >&2

if not defined BOM_FILE_TOKEN (
  echo;%?~%: error: BOM_FILE_TOKEN is not defined.
  exit /b 255
) >&2

if not defined OUTPUT_FILE_PATH (
  echo;%?~%: error: OUTPUT_FILE_PATH is not defined.
  exit /b 255
) >&2

set "BOM_FILE_PATH=%CONTOOLS_ROOT%/encoding/boms/%BOM_FILE_TOKEN%.bin"

for /f "tokens=* delims="eol^= %%i in ("%INPUT_FILE_PATH%\.") do set "INPUT_FILE_PATH=%%~fi"
for /f "tokens=* delims="eol^= %%i in ("%BOM_FILE_PATH%\.") do set "BOM_FILE_PATH=%%~fi"
for /f "tokens=* delims="eol^= %%i in ("%OUTPUT_FILE_PATH%\.") do set "OUTPUT_FILE_DIR=%%~dpi" & set "OUTPUT_FILE_PATH=%%~fi"

if not exist "%INPUT_FILE_PATH%" (
  echo;%?~%: error: INPUT_FILE_PATH does not exist: "%INPUT_FILE_PATH%".
  exit /b 255
) >&2

if not exist "%BOM_FILE_PATH%" (
  echo;%?~%: error: BOM_FILE_TOKEN token file does not exist: "%BOM_FILE_PATH%".
  exit /b 255
) >&2

if not exist "%OUTPUT_FILE_DIR%\*" (
  echo;%?~%: error: OUTPUT_FILE_DIR does not exist: "%OUTPUT_FILE_DIR%".
  exit /b 255
) >&2

if /i "%INPUT_FILE_PATH%" == "%OUTPUT_FILE_PATH%" (
  echo;%?~%: error: INPUT_FILE_PATH and OUTPUT_FILE_PATH must be different: "%INPUT_FILE_PATH%".
  exit /b 1
) >&2

set "INPUT_FILE_BOM_PREFIX_TMP=%TEMP_DIR%\input_file_bom_prefix.bin"

mkdir "%TEMP_DIR%" >nul 2>nul

if defined FLAG_CHCP (
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" "%%FLAG_CHCP%%"
  set RESTORE_LOCALE=1
) else call "%%CONTOOLS_ROOT%%/std/getcp.bat"

rem an UTF16LE file automatically checked for the BOM by the copy utility
if /i "%BOM_FILE_TOKEN%" == "fffe" (
  rem copy as text files
  copy "%BOM_FILE_PATH%" /A + "%INPUT_FILE_PATH%" /A "%OUTPUT_FILE_PATH%" /B /Y >nul 2>nul || (
    echo;%?~%: error: could not copy to the output file (1^): "%OUTPUT_FILE_PATH%".
    exit /b 2
  ) >&2

  exit /b
)

if not "%CURRENT_CP%" == "437" (
  rem to avoid an unicode code page
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" 437
  set /A RESTORE_LOCALE+=1
)

rem read BOM from input file
set /P INPUT_FILE_BOM_STR=< "%INPUT_FILE_PATH%"

if not defined INPUT_FILE_BOM_STR goto IGNORE_BOM_CHECK

for /F "tokens=* delims="eol^= %%i in ("%BOM_FILE_PATH%") do set "BOM_FILE_SIZE=%%~zi"

rem avoid quote characters
set "INPUT_FILE_BOM_STR=%INPUT_FILE_BOM_STR:"=%"

rem trim BOM sequence by file size
if defined INPUT_FILE_BOM_STR call set "INPUT_FILE_BOM_STR=%%INPUT_FILE_BOM_STR:~0,%BOM_FILE_SIZE%%%"

if not defined INPUT_FILE_BOM_STR goto IGNORE_BOM_CHECK

for /F "tokens=* delims="eol^= %%i in ("%INPUT_FILE_BOM_STR%") do set /P =%%i<nul > "%INPUT_FILE_BOM_PREFIX_TMP%"
"%SystemRoot%\System32\fc.exe" "%INPUT_FILE_BOM_PREFIX_TMP%" "%BOM_FILE_PATH%" >nul
if %ERRORLEVEL% NEQ 0 goto IGNORE_BOM_CHECK

if %RESTORE_LOCALE% GTR 1 (
  call "%%CONTOOLS_ROOT%%/std/restorecp.bat"
  set /A RESTORE_LOCALE-=1
)

copy "%INPUT_FILE_PATH%" "%OUTPUT_FILE_PATH%" /B /Y >nul 2>nul || (
  echo;%?~%: error: could not copy to the output file (2^): "%OUTPUT_FILE_PATH%".
  exit /b 2
) >&2

exit /b 0

:IGNORE_BOM_CHECK

if %RESTORE_LOCALE% GTR 1 (
  call "%%CONTOOLS_ROOT%%/std/restorecp.bat"
  set /A RESTORE_LOCALE-=1
)

rem copy as binary files
copy "%BOM_FILE_PATH%" /B + "%INPUT_FILE_PATH%" /B "%OUTPUT_FILE_PATH%" /B /Y >nul 2>nul || (
  echo;%?~%: error: could not copy to the output file (3^): "%OUTPUT_FILE_PATH%".
  exit /b 2
) >&2

exit /b
