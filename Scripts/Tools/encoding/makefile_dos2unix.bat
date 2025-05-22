@echo off & goto DOC_END

rem Description:
rem   Script converts all files in directory with script by wildcards
rem   "*.*sh.;configure.*.;makefile.*." from the Dos text format to the Unix
rem   text format using the dos2unix utility.
:DOC_END

rem Create local variable's stack
setlocal

set "__SEARCH_FILTER=*.*sh.;configure.*.;makefile.*."

call :STAGE1 dos2unix.exe
if %ERRORLEVEL% NEQ 0 (
  echo %~nx0: error: "dos2unix.exe" not found to be run for conversion!
  exit /b 1
) >&2

echo Converting all shell and make files in the DOS format to the UNIX format...
set __CONVERTED_COUNTER=0
set __OVERALL_COUNTER=0
if "%OSTYPE%" == "cygwin" (
  for /R "%~dp0" %%i in (%__SEARCH_FILTER%) do call :PROCESS_CYGWIN "%%i"
) else (
  for /R "%~dp0" %%i in (%__SEARCH_FILTER%) do call :PROCESS_MINGW "%%i"
)

echo;
echo;%__CONVERTED_COUNTER% of %__OVERALL_COUNTER% files converted.

goto EXIT

:PROCESS_CYGWIN
for /F "usebackq tokens=*" %%i in (`cygpath.exe -u "%~1"`) do (
  if not "%%i" == "" set "CONVERSION_PATH=%%i"
)
if defined CONVERSION_PATH (
  call :EXEC "%%CONVERSION_PATH%%"
  set CONVERSION_PATH=
) else (
  echo %~nx0: warning: "%~1": invalid file path.
)
set /A __OVERALL_COUNTER+=1

exit /b

:PROCESS_MINGW
call :EXEC "%%~1"
set /A __OVERALL_COUNTER+=1

exit /b

:EXEC
dos2unix.exe -U %*
if %ERRORLEVEL% EQU 0 set /A __CONVERTED_COUNTER+=1

exit /b

:STAGE1
if exist "%~$PATH:1" (
  rem Environment variable OSTYPE=cygwin is not set if cmd runs under cygwin,
  rem so we need to check it out explicitly here
  if not defined OSTYPE (
    if "%TERM%" == "cygwin" (
      if exist "%~dp$PATH:1cygwin1.dll" set OSTYPE=cygwin
    )
  )
  exit /b 0
)
exit /b 1

:EXIT
exit /b 0
