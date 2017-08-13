@echo off

if "%CONTOOLS_ROOT%" == "" set "CONTOOLS_ROOT=w:/Work/MyProjects/_contools/sf~contools/Scripts/Tools"
set "CONTOOLS_ROOT=%CONTOOLS_ROOT:\=/%"
if "%CONTOOLS_ROOT:~-1%" == "/" set "CONTOOLS_ROOT=%CONTOOLS_ROOT:~0,-1%"

if "%GNUWIN32_ROOT%" == "" set "GNUWIN32_ROOT=%CONTOOLS_ROOT%/gnuwin32"
set "GNUWIN32_ROOT=%GNUWIN32_ROOT:\=/%"
if "%GNUWIN32_ROOT:~-1%" == "/" set "GNUWIN32_ROOT=%GNUWIN32_ROOT:~0,-1%"

if "%SVNCMD_TOOLS_ROOT%" == "" set "SVNCMD_TOOLS_ROOT=%CONTOOLS_ROOT%/scm/svn"
set "SVNCMD_TOOLS_ROOT=%SVNCMD_TOOLS_ROOT:\=/%"
if "%SVNCMD_TOOLS_ROOT:~-1%" == "/" set "SVNCMD_TOOLS_ROOT=%SVNCMD_TOOLS_ROOT:~0,-1%"

if "%SQLITE_TOOLS_ROOT%" == "" set "SQLITE_TOOLS_ROOT=%CONTOOLS_ROOT%/sqlite"
set "SQLITE_TOOLS_ROOT=%SQLITE_TOOLS_ROOT:\=/%"
if "%SQLITE_TOOLS_ROOT:~-1%" == "/" set "SQLITE_TOOLS_ROOT=%SQLITE_TOOLS_ROOT:~0,-1%"

if "%XML_TOOLS_ROOT%" == "" set "XML_TOOLS_ROOT=%CONTOOLS_ROOT%/xml"
set "XML_TOOLS_ROOT=%XML_TOOLS_ROOT:\=/%"
if "%XML_TOOLS_ROOT:~-1%" == "/" set "XML_TOOLS_ROOT=%XML_TOOLS_ROOT:~0,-1%"

if "%VARS_ROOT%" == "" set "VARS_ROOT=%CONTOOLS_ROOT%/vars"
set "VARS_ROOT=%VARS_ROOT:\=/%"
if "%VARS_ROOT:~-1%" == "/" set "VARS_ROOT=%VARS_ROOT:~0,-1%"
