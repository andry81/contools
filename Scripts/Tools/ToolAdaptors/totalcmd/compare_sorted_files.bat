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

set RANDOM_VALUE=%RANDOM%_%RANDOM%

set "PWD=%~1"
shift

if not defined PWD goto NOPWD
( %PWD:~0,2% && cd "%PWD%" ) || exit /b 1

:NOPWD

set "FILE_IN_1=%~1"
set "FILE_IN_2=%~2"
set "FILE_OUT_1=%~dpn1.~%RANDOM_VALUE%%~x1"
set "FILE_OUT_2=%~dpn2.~%RANDOM_VALUE%%~x2"

set "FILES_LIST="
set NUM_FILES=0

rem read selected file names into variable
:CURDIR_FILTER_LOOP
if "%~1" == "" goto CURDIR_FILTER_LOOP_END
rem must be files, not sub directories
if exist "%~1\" exit /b 2
set FILES_LIST=%FILES_LIST% "%~dpn1.~%RANDOM_VALUE%%~x1"

set /A NUM_FILES+=1

rem only 2 first files from the list are accepted
if %NUM_FILES% GEQ 2 goto CURDIR_FILTER_LOOP_END

shift

goto CURDIR_FILTER_LOOP

:CURDIR_FILTER_LOOP_END

if %NUM_FILES% EQU 0 exit /b 0

if exist "%FILE_IN_1%" sort "%FILE_IN_1%" > "%FILE_OUT_1%"
if exist "%FILE_IN_2%" sort "%FILE_IN_2%" > "%FILE_OUT_2%"

if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" "%%CONSOLE_COMPARE_TOOL%%" /wait %%FILES_LIST%%
) else (
  call :CMD start /B "" "%%CONSOLE_COMPARE_TOOL%%" /nowait %%FILES_LIST%%
)

if exist "%FILE_OUT_1%" del /F /Q /A:-D "%FILE_OUT_1%"
if exist "%FILE_OUT_2%" del /F /Q /A:-D "%FILE_OUT_2%"

exit /b 0

:CMD
echo.^>%*
(%*)
