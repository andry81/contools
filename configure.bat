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
  echo.if "%%CONTOOLS_ROOT%%" == "" set "CONTOOLS_ROOT=%%~dp0"
  echo.set "CONTOOLS_ROOT=%%CONTOOLS_ROOT:\=/%%"
  echo.if "%%CONTOOLS_ROOT:~-1%%" == "/" set "CONTOOLS_ROOT=%%CONTOOLS_ROOT:~0,-1%%"
  echo.
  echo.if "%%GNUWIN32_ROOT%%" == "" set "GNUWIN32_ROOT=%%CONTOOLS_ROOT%%/gnuwin32"
  echo.set "GNUWIN32_ROOT=%%GNUWIN32_ROOT:\=/%%"
  echo.if "%%GNUWIN32_ROOT:~-1%%" == "/" set "GNUWIN32_ROOT=%%GNUWIN32_ROOT:~0,-1%%"
  echo.
  echo.if "%%SVNCMD_TOOLS_ROOT%%" == "" set "SVNCMD_TOOLS_ROOT=%%CONTOOLS_ROOT%%/scm/svn"
  echo.set "SVNCMD_TOOLS_ROOT=%%SVNCMD_TOOLS_ROOT:\=/%%"
  echo.if "%%SVNCMD_TOOLS_ROOT:~-1%%" == "/" set "SVNCMD_TOOLS_ROOT=%%SVNCMD_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if "%%SQLITE_TOOLS_ROOT%%" == "" set "SQLITE_TOOLS_ROOT=%%CONTOOLS_ROOT%%/sqlite"
  echo.set "SQLITE_TOOLS_ROOT=%%SQLITE_TOOLS_ROOT:\=/%%"
  echo.if "%%SQLITE_TOOLS_ROOT:~-1%%" == "/" set "SQLITE_TOOLS_ROOT=%%SQLITE_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if "%%XML_TOOLS_ROOT%%" == "" set "XML_TOOLS_ROOT=%%CONTOOLS_ROOT%%/xml"
  echo.set "XML_TOOLS_ROOT=%%XML_TOOLS_ROOT:\=/%%"
  echo.if "%%XML_TOOLS_ROOT:~-1%%" == "/" set "XML_TOOLS_ROOT=%%XML_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if "%%VARS_ROOT%%" == "" set "VARS_ROOT=%%CONTOOLS_ROOT%%/vars"
  echo.set "VARS_ROOT=%%VARS_ROOT:\=/%%"
  echo.if "%%VARS_ROOT:~-1%%" == "/" set "VARS_ROOT=%%VARS_ROOT:~0,-1%%"
) > "%CONFIGURE_ROOT%/Scripts/Tools/__init__.bat"

rem generate __init__.bat in "%CONFIGURE_ROOT%/Scripts/Tools/scm/svn"
echo "%CONFIGURE_ROOT%/Scripts/Tools/scm/svn/__init__.bat"
(
  echo.@echo off
  echo.
  echo.call "%%%%~dp0..\..\__init__.bat" ^|^| goto :EOF
) > "%CONFIGURE_ROOT%/Scripts/Tools/scm/svn/__init__.bat"

goto CONFIGURE_SVNCMD_END

:CONFIGURE_SVNCMD
rem generate __init__.bat in "%CONFIGURE_ROOT%/Tools"
echo."%CONFIGURE_ROOT%/Tools/__init__.bat"
(
  echo.@echo off
  echo.
  echo.if "%%CONTOOLS_ROOT%%" == "" set "CONTOOLS_ROOT=%%~dp0"
  echo.set "CONTOOLS_ROOT=%%CONTOOLS_ROOT:\=/%%"
  echo.if "%%CONTOOLS_ROOT:~-1%%" == "/" set "CONTOOLS_ROOT=%%CONTOOLS_ROOT:~0,-1%%"
  echo.
  echo.if "%%GNUWIN32_ROOT%%" == "" set "GNUWIN32_ROOT=%%CONTOOLS_ROOT%%/gnuwin32"
  echo.set "GNUWIN32_ROOT=%%GNUWIN32_ROOT:\=/%%"
  echo.if "%%GNUWIN32_ROOT:~-1%%" == "/" set "GNUWIN32_ROOT=%%GNUWIN32_ROOT:~0,-1%%"
  echo.
  echo.if "%%SVNCMD_TOOLS_ROOT%%" == "" set "SVNCMD_TOOLS_ROOT=%%CONTOOLS_ROOT%%/../Scripts"
  echo.set "SVNCMD_TOOLS_ROOT=%%SVNCMD_TOOLS_ROOT:\=/%%"
  echo.if "%%SVNCMD_TOOLS_ROOT:~-1%%" == "/" set "SVNCMD_TOOLS_ROOT=%%SVNCMD_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if "%%SQLITE_TOOLS_ROOT%%" == "" set "SQLITE_TOOLS_ROOT=%%CONTOOLS_ROOT%%/sqlite"
  echo.set "SQLITE_TOOLS_ROOT=%%SQLITE_TOOLS_ROOT:\=/%%"
  echo.if "%%SQLITE_TOOLS_ROOT:~-1%%" == "/" set "SQLITE_TOOLS_ROOT=%%SQLITE_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if "%%XML_TOOLS_ROOT%%" == "" set "XML_TOOLS_ROOT=%%CONTOOLS_ROOT%%/xml"
  echo.set "XML_TOOLS_ROOT=%%XML_TOOLS_ROOT:\=/%%"
  echo.if "%%XML_TOOLS_ROOT:~-1%%" == "/" set "XML_TOOLS_ROOT=%%XML_TOOLS_ROOT:~0,-1%%"
  echo.
  echo.if "%%VARS_ROOT%%" == "" set "VARS_ROOT=%%CONTOOLS_ROOT%%/vars"
  echo.set "VARS_ROOT=%%VARS_ROOT:\=/%%"
  echo.if "%%VARS_ROOT:~-1%%" == "/" set "VARS_ROOT=%%VARS_ROOT:~0,-1%%"
) > "%CONFIGURE_ROOT%/Tools/__init__.bat"

rem generate __init__.bat in "%CONFIGURE_ROOT%/Scripts"
echo "%CONFIGURE_ROOT%/Scripts/__init__.bat"
(
  echo.@echo off
  echo.
  echo.call "%%%%~dp0..\Tools\__init__.bat" ^|^| goto :EOF
) > "%CONFIGURE_ROOT%/Scripts/__init__.bat"

:CONFIGURE_SVNCMD_END

if exist "%CONFIGURE_ROOT%/svncmd.tag" goto DEPLOY_TOOLS_EXTERNAL
goto END

:DEPLOY_TOOLS_EXTERNAL
rem initialize Tools "module"
call "%%CONFIGURE_ROOT%%/Tools/__init__.bat" || goto :EOF

rem deploy Windows UCRT dependencies
for %%i in (%WINDOWS_UCRT_X86_DEPLOY_DIR_LIST%) do (
  call :CMD "%%CONTOOLS_ROOT%%/xcopy_dir.bat" "%%CONFIGURE_ROOT%%/ToolsExternal/deps/Windows Kits/10/Redist/ucrt/DLLs/x86" "%%CONFIGURE_ROOT%%/%%i" || goto :EOF
)

exit /b 0

:CMD
echo.^>%*
(%*)
exit /b

:END

pause

exit /b 0
