@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script converts Jenkins svn update xml file into convenient text list
rem   representation.

rem Examples:
rem 1. call convert_svn_changeset_xml_to_lst.bat //svn_changeset/changeSet/revision svn_changeset.xml .
rem    type svn_changeset.lst

setlocal

rem //svn_changeset/changeSet/revision
set "XPATH_ROOT=%~1"
set "XML_PATH=%~2"
set "OUTPUT_DIR=%~3"

if not exist "%XML_PATH%" (
  echo.%~nx0: error: xml file does not exist: "%XML_PATH%"
  exit /b -128
) >&2

rem Drop last error level
cd .

call "%%~dp0..\__init__.bat" || goto :EOF

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

call :XMLSTARLET ^
  sel -T -t -m "%XPATH_ROOT%" ^
  --var linebreak -n --break -v "concat(translate(module, $linebreak, ''), '|', revision, $linebreak)" "%XML_PATH%" || goto :EOF

exit /b 0

:XMLSTARLET
echo.^>^> "%XML_TOOLS_ROOT%/xml.exe" %* ^> "%OUTPUT_DIR%\svn_changeset.lst"
"%XML_TOOLS_ROOT%/xml.exe" %* > "%OUTPUT_DIR%\svn_changeset.lst"
goto :EOF
