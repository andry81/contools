@echo off

setlocal

set "CONFIGURE_ROOT=%~dp0"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:~0,-1%"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:\=/%"

set "WINDOWS_UCRT_X86_DEPLOY_DIR_LIST=ToolsExternal/python/python-win32/3.6.1"

rem universal configuration script by tags
if exist "%CONFIGURE_ROOT%/contools.tag" goto CONFIGURE_CONTOOLS
if exist "%CONFIGURE_ROOT%/svncmd.tag" goto CONFIGURE_SVNCMD

(
  echo.%~nx0: error: unknown configuration environment.
  exit /b 1
) >&2

:CONFIGURE_CONTOOLS
rem generate __init__.bat in "%CONFIGURE_ROOT%/Scripts/Tools"
echo "%CONFIGURE_ROOT%/Scripts/Tools/__init__.bat"
(
  echo.@echo off
  echo.
  echo.if %%__CONTOOLS_INIT__%%0 NEQ 0 exit /b 0
  echo.
  echo.if not defined CONTOOLS_ROOT set "CONTOOLS_ROOT=%%~dp0"
  echo.set "CONTOOLS_ROOT=%%CONTOOLS_ROOT:\=/%%"
  echo.if "%%CONTOOLS_ROOT:~-1%%" == "/" set "CONTOOLS_ROOT=%%CONTOOLS_ROOT:~0,-1%%"
  echo.
  echo.if not defined BUILD_TOOLS_ROOT set "BUILD_TOOLS_ROOT=%%CONTOOLS_ROOT%%/build"
  echo.set "BUILD_TOOLS_ROOT=%%BUILD_TOOLS_ROOT:\=/%%"
  echo.if "%%BUILD_TOOLS_ROOT:~-1%%" == "/" set "BUILD_TOOLS_ROOT=%%BUILD_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if not defined GNUWIN32_ROOT set "GNUWIN32_ROOT=%%CONTOOLS_ROOT%%/gnuwin32"
  echo.set "GNUWIN32_ROOT=%%GNUWIN32_ROOT:\=/%%"
  echo.if "%%GNUWIN32_ROOT:~-1%%" == "/" set "GNUWIN32_ROOT=%%GNUWIN32_ROOT:~0,-1%%"
  echo.
  echo.if not defined SVNCMD_TOOLS_ROOT set "SVNCMD_TOOLS_ROOT=%%CONTOOLS_ROOT%%/scm/svn"
  echo.set "SVNCMD_TOOLS_ROOT=%%SVNCMD_TOOLS_ROOT:\=/%%"
  echo.if "%%SVNCMD_TOOLS_ROOT:~-1%%" == "/" set "SVNCMD_TOOLS_ROOT=%%SVNCMD_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if not defined SQLITE_TOOLS_ROOT set "SQLITE_TOOLS_ROOT=%%CONTOOLS_ROOT%%/sqlite"
  echo.set "SQLITE_TOOLS_ROOT=%%SQLITE_TOOLS_ROOT:\=/%%"
  echo.if "%%SQLITE_TOOLS_ROOT:~-1%%" == "/" set "SQLITE_TOOLS_ROOT=%%SQLITE_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if not defined XML_TOOLS_ROOT set "XML_TOOLS_ROOT=%%CONTOOLS_ROOT%%/xml"
  echo.set "XML_TOOLS_ROOT=%%XML_TOOLS_ROOT:\=/%%"
  echo.if "%%XML_TOOLS_ROOT:~-1%%" == "/" set "XML_TOOLS_ROOT=%%XML_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if not defined HASHDEEP_ROOT set "HASHDEEP_ROOT=%%CONTOOLS_ROOT%%/hash/hashdeep"
  echo.set "HASHDEEP_ROOT=%%HASHDEEP_ROOT:\=/%%"
  echo.if "%%HASHDEEP_ROOT:~-1%%" == "/" set "HASHDEEP_ROOT=%%HASHDEEP_ROOT:~0,-1%%"
  echo.
  echo.if not defined VARS_ROOT set "VARS_ROOT=%%CONTOOLS_ROOT%%/vars"
  echo.set "VARS_ROOT=%%VARS_ROOT:\=/%%"
  echo.if "%%VARS_ROOT:~-1%%" == "/" set "VARS_ROOT=%%VARS_ROOT:~0,-1%%"
  echo.
  echo.set __CONTOOLS_INIT__=1
  echo.
  echo.exit /b 0
) > "%CONFIGURE_ROOT%/Scripts/Tools/__init__.bat"

rem generate __init__.bat in "%CONFIGURE_ROOT%/Scripts/Tools/scm/svn"
echo "%CONFIGURE_ROOT%/Scripts/Tools/scm/svn/__init__.bat"
(
  echo.@echo off
  echo.
  echo.call "%%%%~dp0..\..\__init__.bat" ^|^| goto :EOF
) > "%CONFIGURE_ROOT%/Scripts/Tools/scm/svn/__init__.bat"

call :DEPLOY_UTILS

goto CONFIGURE_SVNCMD_END

:CONFIGURE_SVNCMD
rem generate __init__.bat in "%CONFIGURE_ROOT%/Tools"
echo."%CONFIGURE_ROOT%/Tools/__init__.bat"
(
  echo.@echo off
  echo.
  echo.if %%__CONTOOLS_INIT__%%0 NEQ 0 exit /b 0
  echo.
  echo.if not defined CONTOOLS_ROOT set "CONTOOLS_ROOT=%%~dp0"
  echo.set "CONTOOLS_ROOT=%%CONTOOLS_ROOT:\=/%%"
  echo.if "%%CONTOOLS_ROOT:~-1%%" == "/" set "CONTOOLS_ROOT=%%CONTOOLS_ROOT:~0,-1%%"
  echo.
  echo.if not defined BUILD_TOOLS_ROOT set "BUILD_TOOLS_ROOT=%%CONTOOLS_ROOT%%/build"
  echo.set "BUILD_TOOLS_ROOT=%%BUILD_TOOLS_ROOT:\=/%%"
  echo.if "%%BUILD_TOOLS_ROOT:~-1%%" == "/" set "BUILD_TOOLS_ROOT=%%BUILD_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if not defined GNUWIN32_ROOT set "GNUWIN32_ROOT=%%CONTOOLS_ROOT%%/gnuwin32"
  echo.set "GNUWIN32_ROOT=%%GNUWIN32_ROOT:\=/%%"
  echo.if "%%GNUWIN32_ROOT:~-1%%" == "/" set "GNUWIN32_ROOT=%%GNUWIN32_ROOT:~0,-1%%"
  echo.
  echo.if not defined SVNCMD_TOOLS_ROOT set "SVNCMD_TOOLS_ROOT=%%CONTOOLS_ROOT%%/../Scripts"
  echo.set "SVNCMD_TOOLS_ROOT=%%SVNCMD_TOOLS_ROOT:\=/%%"
  echo.if "%%SVNCMD_TOOLS_ROOT:~-1%%" == "/" set "SVNCMD_TOOLS_ROOT=%%SVNCMD_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if not defined SQLITE_TOOLS_ROOT set "SQLITE_TOOLS_ROOT=%%CONTOOLS_ROOT%%/sqlite"
  echo.set "SQLITE_TOOLS_ROOT=%%SQLITE_TOOLS_ROOT:\=/%%"
  echo.if "%%SQLITE_TOOLS_ROOT:~-1%%" == "/" set "SQLITE_TOOLS_ROOT=%%SQLITE_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if not defined XML_TOOLS_ROOT set "XML_TOOLS_ROOT=%%CONTOOLS_ROOT%%/xml"
  echo.set "XML_TOOLS_ROOT=%%XML_TOOLS_ROOT:\=/%%"
  echo.if "%%XML_TOOLS_ROOT:~-1%%" == "/" set "XML_TOOLS_ROOT=%%XML_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if not defined HASHDEEP_ROOT set "HASHDEEP_ROOT=%%CONTOOLS_ROOT%%/hash/hashdeep"
  echo.set "HASHDEEP_ROOT=%%HASHDEEP_ROOT:\=/%%"
  echo.if "%%HASHDEEP_ROOT:~-1%%" == "/" set "HASHDEEP_ROOT=%%HASHDEEP_ROOT:~0,-1%%"
  echo.
  echo.if not defined VARS_ROOT set "VARS_ROOT=%%CONTOOLS_ROOT%%/vars"
  echo.set "VARS_ROOT=%%VARS_ROOT:\=/%%"
  echo.if "%%VARS_ROOT:~-1%%" == "/" set "VARS_ROOT=%%VARS_ROOT:~0,-1%%"
  echo.
  echo.set __CONTOOLS_INIT__=1
  echo.
  echo.exit /b 0
) > "%CONFIGURE_ROOT%/Tools/__init__.bat"

rem generate __init__.bat in "%CONFIGURE_ROOT%/Scripts"
echo "%CONFIGURE_ROOT%/Scripts/__init__.bat"
(
  echo.@echo off
  echo.
  echo.call "%%%%~dp0..\Tools\__init__.bat" ^|^| goto :EOF
) > "%CONFIGURE_ROOT%/Scripts/__init__.bat"

:CONFIGURE_SVNCMD_END

if exist "%CONFIGURE_ROOT%/svncmd.tag" call :DEPLOY_TOOLS_EXTERNAL
goto END

:DEPLOY_TOOLS_EXTERNAL
rem initialize Tools "module"
call "%%CONFIGURE_ROOT%%/Scripts/Tools/__init__.bat" || goto :EOF

rem deploy Windows UCRT dependencies
for %%i in (%WINDOWS_UCRT_X86_DEPLOY_DIR_LIST%) do (
  call :XCOPY_DIR "%%CONFIGURE_ROOT%%/ToolsExternal/deps/Windows Kits/10/Redist/ucrt/DLLs/x86" "%%CONFIGURE_ROOT%%/%%i" || goto :EOF
)

exit /b 0

:DEPLOY_UTILS
rem initialize Tools "module"
call "%%CONFIGURE_ROOT%%/Scripts/Tools/__init__.bat" || goto :EOF

rem copy utilities into Tools
call :XCOPY_DIR "%%CONFIGURE_ROOT%%/Utilities/bin" "%%CONFIGURE_ROOT%%/Scripts/Tools" /E /Y /D || goto :EOF

exit /b 0

:XCOPY_DIR
if not exist "%CONTOOLS_ROOT%/std/xcopy_dir.bat" (
  echo.%~nx0: error: xcopy_dir.bat is not found: "%CONTOOLS_ROOT%/std/xcopy_dir.bat".
  exit /b 1
) >&2
if not exist "%~2" mkdir "%~2"
call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" %%* || goto :EOF
exit /b 0

:END

pause

exit /b 0
