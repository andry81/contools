@echo off & goto DOC_END

rem <FROM_PATH> = <RETURN_VALUE> + <FROM_PATH_SUFFIX>
rem <TO_PATH>   = <RETURN_VALUE> + <TO_PATH_SUFFIX>
:DOC_END

rem drop return value
set "RETURN_VALUE="

setlocal

call "%%~dp0__init__.bat" || exit /b

set "FROM_PATH=%~f1"
set "TO_PATH=%~f2"

rem the drive must be the same before subtraction
if /i not "%FROM_PATH:~0,1%" == "%TO_PATH:~0,1%" exit /b 1

rem drop last slash character
if "%FROM_PATH:~-1%" == "\" set "FROM_PATH=%FROM_PATH:~0,-1%"
if "%TO_PATH:~-1%" == "\" set "TO_PATH=%TO_PATH:~0,-1%"

call "%%CONTOOLS_ROOT%%/filesys/index_pathstr.bat" FROM_PATH_ARR \ "%%FROM_PATH%%"
set FROM_PATH_ARR_SIZE=%RETURN_VALUE%

call "%%CONTOOLS_ROOT%%/filesys/index_pathstr.bat" TO_PATH_ARR \ "%%TO_PATH%%"
set TO_PATH_ARR_SIZE=%RETURN_VALUE%

if %FROM_PATH_ARR_SIZE% EQU 0 exit /b 1
if %TO_PATH_ARR_SIZE% EQU 0 exit /b 1

set FROM_PATH_INDEX=1
set TO_PATH_INDEX=1

call set "FROM_PATH_PREFIX=%%FROM_PATH_ARR%FROM_PATH_INDEX%%%"
call set "TO_PATH_PREFIX=%%TO_PATH_ARR%TO_PATH_INDEX%%%"

if /i not "%FROM_PATH_PREFIX%" == "%TO_PATH_PREFIX%" exit /b 1

set "RETURN_VALUE=%FROM_PATH_PREFIX%"

:PATH_LOOP
set /A FROM_PATH_INDEX+=1
set /A TO_PATH_INDEX+=1

if %FROM_PATH_INDEX% GTR %FROM_PATH_ARR_SIZE% goto EXIT
if %TO_PATH_INDEX% GTR %TO_PATH_ARR_SIZE% goto EXIT

call set "FROM_PATH_PREFIX=%%FROM_PATH_ARR%FROM_PATH_INDEX%%%"
call set "TO_PATH_PREFIX=%%TO_PATH_ARR%TO_PATH_INDEX%%%"

if /i not "%FROM_PATH_PREFIX%" == "%TO_PATH_PREFIX%" goto EXIT

set "RETURN_VALUE=%FROM_PATH_PREFIX%"

goto PATH_LOOP

exit /b 0

:EXIT
endlocal & set "RETURN_VALUE=%RETURN_VALUE:/=\%"
