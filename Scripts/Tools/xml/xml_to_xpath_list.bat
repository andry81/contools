@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script converts input XML into XPATH list by appling bundled XSLT file.

rem Flags:
rem  -noprops - do not print properties
rem  -lnodes - print leaf ancestor XPATHs (leaf nodes) before a leaf

rem Drop last error level
cd .

setlocal

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0.."
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

set "?~nx0=%~nx0"
set "?~dp0=%~dp0"

rem script flags
set FLAG_NOPROPS=0
set FLAG_LNODES=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
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

if "%XML_FILE%" == "" (
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

call "%%TOOLS_PATH%%/xml/xml.exe" tr "%%TOOLS_PATH%%/xml/xslt/%%XSLT_FILE[%FLAG_LNODES%,%FLAG_NOPROPS%]%%" "%%XML_FILE%%"
