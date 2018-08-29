@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || goto :EOF

call "%%?~dp0%%loadvars.bat" "%%?~dp0%%profile.vars" || goto :EOF

rem script flags
set FLAG_WAIT_EXIT=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-wait" (
    set FLAG_WAIT_EXIT=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  )

  rem read until no flags
  goto FLAGS_LOOP
)

set "PWD=%~1"
shift

set "FILES_LIST="
set NUM_FILES=0

if not defined PWD goto NOPWD
cd /d "%PWD%" || exit /b 1

:NOPWD

rem read selected file paths from file
for /F "usebackq eol=	 tokens=* delims=" %%i in ("%~1") do (
  set FILE_PATH=%%i
  call :PROCESS_FILE_PATH || goto PROCESS_COMPARE
)

rem only 2 first files from the list are accepted
exit /b 0

:PROCESS_FILE_PATH
if not defined FILE_PATH exit /b 0
rem must be files, not sub directories
if exist "%FILE_PATH%\" exit /b 0
set FILES_LIST=%FILES_LIST% "%FILE_PATH%"

set /A NUM_FILES+=1

if %NUM_FILES% GEQ 2 exit /b 1

exit /b 0

:PROCESS_COMPARE

if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" "%%COMPARE_TOOL%%" /wait %%FILES_LIST%%
) else (
  call :CMD start /B "" "%%COMPARE_TOOL%%" /nowait %%FILES_LIST%%
)

exit /b 0

:CMD
echo.^>%*
(%*)
