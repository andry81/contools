@echo off

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "?~nx0=%~nx0"

rem script flags
set FLAG_USE_BOM=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  if "%FLAG%" == "-bom" (
    set FLAG_USE_BOM=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

set "INPUT_CHARSET=%~1"
set "OUTPUT_CHARSET=%~2"
set "INPUT_FILE=%~3"

if "%OUTPUT_CHARSET%" == "" (
  echo.%?~nx0%: error: OUTPUT_CHARSET is not set.
  exit /b 1
)

if not exist "%INPUT_FILE%" (
  echo.%?~nx0%: error: INPUT_FILE does not exist: INPUT_FILE="%INPUT_FILE%".
  exit /b 2
) >&2

if "%INPUT_CHARSET%" == "" call :GET_CURRENT_CODE_PAGE

if %FLAG_USE_BOM% NEQ 0 call :OUTPUT_BOM

"%GNUWIN32_ROOT%/bin/iconv.exe" -c -f "%INPUT_CHARSET%" -t "%OUTPUT_CHARSET%" "%INPUT_FILE%"
exit /b

:GET_CURRENT_CODE_PAGE
for /F "usebackq eol=	 tokens=2 delims=:" %%i in (`chcp 2^>nul`) do set CURRENT_CODE_PAGE=%%i
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
