@echo off & goto DOC_END

rem USAGE:
rem   del_file_pttn.bat <dir> <name-pttn> <ext-pttn> [<del-flags>...]

rem Description:
rem   The `del` wrapper script with echo and some conditions check before call.
rem   Can remove a file by extended and separated patterns: dir+file+extension.
rem
rem   Does support long paths, but can not reach them from `<dir>` directory to
rem   delete.
rem
rem   NOTE:
rem     All input paths must be without `\\?\` prefix because:
rem       1. Can be directly used in commands which does not support long paths
rem          like built in `dir` command.
rem       2. Can be checked on absence of globbing characters which includes
rem          `?` character.
rem       3. The `%%~f` built in variables extension and other extensions does
rem          remove the prefix and then a path can be prefixed internally by
rem          the script.

rem <dir>
rem   Directory path.

rem <name-pttn>
rem   File name pattern.

rem <ext-pttn>
rem   File name extension pattern.

rem <del-flags>:
rem   Command line flags to pass into built in `del` command.
:DOC_END

echo;^>%~nx0 %*

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "FILE_DIR=%~1"
set "FILE_NAME_PTTN=%~2"
set "FILE_EXT_PTTN=%~3"

if not defined FILE_DIR (
  echo;%?~%: error: file directory argument must be defined.
  exit /b -255
) >&2

set "FILE_DIR=%FILE_DIR:/=\%"

if "%FILE_DIR:~0,4%" == "\\?\" set "FILE_DIR=%FILE_DIR:~4%"

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%FILE_DIR:~0,1%" goto FILE_DIR_ERROR

rem ...double `\\` character
if not "%FILE_DIR%" == "%FILE_DIR:\\=\%" goto FILE_DIR_ERROR

rem ...trailing `\` character
if "\" == "%FILE_DIR:~-1%" goto FILE_DIR_ERROR

rem check on invalid characters in path
if not "%FILE_DIR%" == "%FILE_DIR:**=%" goto FILE_DIR_ERROR
if not "%FILE_DIR%" == "%FILE_DIR:?=%" goto FILE_DIR_ERROR
if not "%FILE_DIR%" == "%FILE_DIR:<=%" goto FILE_DIR_ERROR
if not "%FILE_DIR%" == "%FILE_DIR:>=%" goto FILE_DIR_ERROR

goto FILE_DIR_OK

:FILE_DIR_ERROR
(
  echo;%?~%: error: file directory path is invalid: "%FILE_DIR%".
  exit /b -254
) >&2

:FILE_DIR_OK

for /F "tokens=* delims="eol^= %%i in ("%FILE_DIR%\.") do set "FILE_DIR=%%~fi"

if not exist "%FILE_DIR%\*" (
  echo;%?~%: error: file directory does not exist: "%FILE_DIR%"
  exit /b -253
) >&2

if defined FILE_EXT_PTTN if not "%FILE_EXT_PTTN:~0,1%" == "." set "FILE_EXT_PTTN=.%FILE_EXT_PTTN%"

rem CAUTION:
rem   1. If a variable is empty, then it would not be expanded in the `cmd.exe`
rem      command line or in the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement.
rem   2. The `cmd.exe` command line or the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement does expand twice.
rem
rem   We must expand the command line into a variable to avoid these above.
rem
set ?.=@dir "%FILE_DIR%\%FILE_NAME_PTTN%%FILE_EXT_PTTN%" /A:-D /B /O:N /S 2^>nul

for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do set "FILE_PATH=%%i" & call :DEL_FILE %%*
exit /b

:DEL_FILE
call :GET_FILE_EXT "%%FILE_PATH%%"
if defined FILE_EXT_PTTN if "%FILE_EXT_PTTN:~-1%" == "." if not "%FILE_EXT%" == "%FILE_EXT_PTTN:~0,-1%" exit /b

for /F "tokens=* delims="eol^= %%i in ("%FILE_PATH%\.") do set "FILE_PATH=%%~fi"

if not exist "\\?\%FILE_PATH%" (
  echo;%?~%: error: path does not exist: "%FILE_PATH%"
  exit /b 1
) >&2

rem CAUTION: we must override `/A` flag for a file removement ONLY
call "%%~dp0setshift.bat" 3 DEL_FLAGS_ %%* /A:-D

if %TOOLS_VERBOSE%0 NEQ 0 echo;^>^>del %DEL_FLAGS_% "%FILE_PATH%"
del %DEL_FLAGS_% "%FILE_PATH%"

exit /b

:GET_FILE_EXT
set "FILE_EXT=%~x1"
exit /b
