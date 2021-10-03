@echo off

setlocal

set "?~nx0=%~nx0"

call "%%~dp0__init__.bat" || exit /b

rem script flags
set RESTORE_LOCALE=0

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem restore locale
if %RESTORE_LOCALE% NEQ 0 call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b %LASTERROR%

:MAIN
rem script flags
set "FLAG_CHCP="
set FLAG_USE_BOM=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else if "%FLAG%" == "-bom" (
    set FLAG_USE_BOM=1
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "INPUT_CHARSET=%~1"
set "OUTPUT_CHARSET=%~2"
set "INPUT_FILE=%~3"

if not defined OUTPUT_CHARSET (
  echo.%?~nx0%: error: OUTPUT_CHARSET is not set.
  exit /b 1
) >&2

if not exist "%INPUT_FILE%" (
  echo.%?~nx0%: error: INPUT_FILE does not exist: INPUT_FILE="%INPUT_FILE%".
  exit /b 2
) >&2

if defined FLAG_CHCP (
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" "%%FLAG_CHCP%%"
  set RESTORE_LOCALE=1
  if not defined INPUT_CHARSET set "INPUT_CHARSET=CP%FLAG_CHCP%"
) else if not defined INPUT_CHARSET call :GET_CURRENT_CODE_PAGE

if %FLAG_USE_BOM% NEQ 0 call :OUTPUT_BOM

rem workaround for `conversion from CP65001 unsupported`
if "%INPUT_CHARSET%" == "CP65001" (
  "%CONTOOLS_GNUWIN32_ROOT%/bin/iconv.exe" -c -f UTF-8 -t "%OUTPUT_CHARSET%" "%INPUT_FILE%"
) else (
  "%CONTOOLS_GNUWIN32_ROOT%/bin/iconv.exe" -c -f "%INPUT_CHARSET%" -t "%OUTPUT_CHARSET%" "%INPUT_FILE%"
)
exit /b

:GET_CURRENT_CODE_PAGE
for /F "usebackq eol= tokens=2 delims=:" %%i in (`chcp 2^>nul`) do set CURRENT_CODE_PAGE=%%i
rem convert chcp codepage into iconv namespace
set INPUT_CHARSET=CP%CURRENT_CODE_PAGE: =%
exit /b 0

:OUTPUT_BOM
rem UTF-8 by default
set BOM_FILE_NAME=efbbbf.bin
if not "%OUTPUT_CHARSET:-2LE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=fffe.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-2BE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=feff.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-4LE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=fffe.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-4BE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=feff.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-16LE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=fffe.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-16BE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=feff.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-32LE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=fffe.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-32BE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=feff.bin" & goto COPY_BOM

:COPY_BOM
type "%CONTOOLS_ROOT:/=\%\encoding\boms\%BOM_FILE_NAME%"
