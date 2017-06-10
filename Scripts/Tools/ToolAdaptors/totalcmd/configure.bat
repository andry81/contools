@echo off

setlocal

if exist "%~dp0configure.user.bat" ( call "%~dp0configure.user.bat" || goto :EOF )
if not "%CONTOOLS_ROOT_FROM%" == "" set "CONTOOLS_ROOT=%CONTOOLS_ROOT_FROM%"

if not "%CONTOOLS_ROOT%" == "" ^
if exist "%CONTOOLS_ROOT%\" goto IGNORE_CONTOOLS_ROOT_INPUT

set /P CONTOOLS_ROOT=Input the root path to the tools directory to copy: 

:IGNORE_CONTOOLS_ROOT_INPUT
if "%CONTOOLS_ROOT%" == "" goto CONTOOLS_ROOT_ERROR
if not exist "%CONTOOLS_ROOT%\__init__.bat" goto CONTOOLS_ROOT_ERROR

rem initialize "module" tools
call "%%CONTOOLS_ROOT%%/__init__.bat" || goto CONTOOLS_ROOT_ERROR

if "%SVNCMD_TOOLS_ROOT%" == "" goto SVNCMD_TOOLS_ROOT_ERROR
if not exist "%SVNCMD_TOOLS_ROOT%\__init__.bat" goto SVNCMD_TOOLS_ROOT_ERROR

set "CONTOOLS_ROOT_COPY=%~dp0Tools"

(
  echo.@echo off
  echo.
  echo.set "CONTOOLS_ROOT_FROM=%CONTOOLS_ROOT%"
  echo.set "CONTOOLS_ROOT_TO=%CONTOOLS_ROOT_COPY%"
) > "%~dp0configure.user.bat"

call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "__init__.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || goto :EOF
call :XCOPY_DIR "%%CONTOOLS_ROOT%%/std" "%%CONTOOLS_ROOT_COPY%%/std" /E /Y /D || goto :EOF
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "get_datetime.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || goto :EOF
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "get_filesize.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || goto :EOF
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "reduce_relative_path.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || goto :EOF
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "subtract_path.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || goto :EOF
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "split_pathstr.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || goto :EOF
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "strlen.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || goto :EOF
call :XCOPY_DIR "%%CONTOOLS_ROOT%%/encoding" "%%CONTOOLS_ROOT_COPY%%/encoding" /E /Y /D || goto :EOF

call :XCOPY_DIR "%%GNUWIN32_ROOT%%" "%%CONTOOLS_ROOT_COPY%%/gnuwin32" /E /Y /D || goto :EOF

call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "__init__.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || goto :EOF
call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "svn_has_changes.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || goto :EOF
call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "extract_info_param.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || goto :EOF

pause

exit /b

:XCOPY_FILE
if not exist "%CONTOOLS_ROOT%\xcopy_file.bat" (
  echo.%~nx0: error: xcopy_file.bat is not found: "%CONTOOLS_ROOT%\xcopy_file.bat".
  exit /b 1
) >&2
if not exist "%~3" mkdir "%~3"
call "%%CONTOOLS_ROOT%%\xcopy_file.bat" %%* || goto :EOF
exit /b 0

:XCOPY_DIR
if not exist "%CONTOOLS_ROOT%\xcopy_dir.bat" (
  echo.%~nx0: error: xcopy_dir.bat is not found: "%CONTOOLS_ROOT%\xcopy_dir.bat".
  exit /b 1
) >&2
if not exist "%~2" mkdir "%~2"
call "%%CONTOOLS_ROOT%%\xcopy_dir.bat" %%* || goto :EOF
exit /b 0

:CONTOOLS_ROOT_ERROR
(
  echo.%~nx0: error: CONTOOLS_ROOT path is invalid or does not have the required set of utilities: "%CONTOOLS_ROOT%".
  echo.%~nx0: info: execute the configure.bat from the contools WC root to update modules.
  exit /b 2
) >&2

:SVNCMD_TOOLS_ROOT_ERROR
(
  echo.%~nx0: error: SVNCMD_TOOLS_ROOT path is invalid or does not have the required set of utilities: "%SVNCMD_TOOLS_ROOT%".
  echo.%~nx0: info: execute the configure.bat from the contools WC root to update modules.
  exit /b 3
) >&2
