@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script converts input XML into XPATH list by appling bundled XSLT file.

rem Flags:
rem  -noprops - do not print properties
rem  -lnodes - print leaf ancestor XPATHs (leaf nodes) before a leaf

rem Drop last error level
type nul>nul

setlocal

call "%%~dp0__init__.bat" || exit /b

set "?~nx0=%~nx0"
set "?~dp0=%~dp0"

rem script flags
set FLAG_NOPROPS=0
set FLAG_LNODES=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-noprops" (
    set FLAG_NOPROPS=1
    shift
  ) else if "%FLAG%" == "-lnodes" (
    set FLAG_LNODES=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b 255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

set "XML_FILE=%~1"

if not defined XML_FILE (
  echo.%?~nx0%: error: xml file is no set.
  exit /b 254
) >&2

if not exist "%XML_FILE%" (
  echo.%?~nx0%: error: xml file is not found: "%XML_FILE%".
  exit /b 253
) >&2

rem [FLAG_LNODES,FLAG_NOPROPS]
set XSLT_FILE[0,0]=xml_to_xpath_leaf_list.xslt
set XSLT_FILE[0,1]=xml_to_xpath_leaf_list_no_props.xslt
set XSLT_FILE[1,0]=xml_to_xpath_node_list.xslt
set XSLT_FILE[1,1]=xml_to_xpath_node_list_no_props.xslt

call "%%XML_TOOLS_ROOT%%/xml.exe" tr "%%XML_TOOLS_ROOT%%/xslt/%%XSLT_FILE[%FLAG_LNODES%,%FLAG_NOPROPS%]%%" "%%XML_FILE%%"
