@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

set /A NEST_LVL+=1
call :MAIN %%*
set /A NEST_LVL-=1

if %NEST_LVL% EQU 0 if defined OEMCP ( call "%%CONTOOLS_ROOT%%/std/pause.bat" -chcp "%%OEMCP%%" ) else call "%%CONTOOLS_ROOT%%/std/pause.bat"

exit /b 0

:MAIN
set "WINDOWS_UCRT_X86_DEPLOY_DIR_LIST=ToolsExternal/python/python-win32/3.6.1"

rem universal configuration script by tags
if exist "%CONTOOLS_PROJECT_ROOT%/contools.tag" goto CONFIGURE_CONTOOLS
if exist "%CONTOOLS_PROJECT_ROOT%/svncmd.tag" goto CONFIGURE_SVNCMD

(
  echo.%~nx0: error: unknown configuration environment.
  exit /b 1
) >&2

:CONFIGURE_CONTOOLS
if exist "%CONTOOLS_PROJECT_ROOT%/_3dparty\" call :DEPLOY_3DPARTY || exit /b

goto CONFIGURE_SVNCMD_END

:CONFIGURE_SVNCMD
:CONFIGURE_SVNCMD_END

if exist "%CONTOOLS_PROJECT_ROOT%/svncmd.tag" call :DEPLOY_TOOLS_EXTERNAL
exit /b

:DEPLOY_TOOLS_EXTERNAL
rem initialize Tools "module"
call :CMD "%%CONTOOLS_PROJECT_ROOT%%/Scripts/Tools/__init__.bat" || exit /b

rem deploy Windows UCRT dependencies
for %%i in (%WINDOWS_UCRT_X86_DEPLOY_DIR_LIST%) do (
  call :XCOPY_DIR "%%CONTOOLS_PROJECT_ROOT%%/ToolsExternal/deps/Windows Kits/10/Redist/ucrt/DLLs/x86" "%%CONTOOLS_PROJECT_ROOT%%/%%i" || exit /b
)

exit /b 0

:DEPLOY_3DPARTY
rem initialize Tools "module"
call :CMD "%%CONTOOLS_PROJECT_ROOT%%/Scripts/Tools/__init__.bat" || exit /b

rem search recursively for a `*configure_src.bat` script inside the `_3dparty` directory and call it
echo.Searching for "%CONTOOLS_PROJECT_ROOT%/_3dparty/*configure_src.bat"...
for /f "usebackq eol= tokens=* delims=" %%i in (`dir /A:-D /B /S "%CONTOOLS_PROJECT_ROOT%/_3dparty\*configure_src.bat" 2^>nul`) do (
  echo."%%i"
  call :CMD "%%i"
)

rem search recursively for a `*generate_src.bat` script inside the `_3dparty` directory and call it
echo.Searching for "%CONTOOLS_PROJECT_ROOT%/_3dparty/*generate_src.bat"...
for /f "usebackq eol= tokens=* delims=" %%i in (`dir /A:-D /B /S "%CONTOOLS_PROJECT_ROOT%/_3dparty\*generate_src.bat" 2^>nul`) do (
  echo."%%i"
  call :CMD "%%i"
)

exit /b 0

:XCOPY_DIR
if not exist "%CONTOOLS_ROOT%/std/xcopy_dir.bat" (
  echo.%~nx0: error: xcopy_dir.bat is not found: "%CONTOOLS_ROOT%/std/xcopy_dir.bat".
  exit /b 1
) >&2
if not exist "%~2" mkdir "%~2"
call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" %%* || exit /b
exit /b 0

:CMD
echo.^>%*
(%*)
exit /b

