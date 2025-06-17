@echo off

rem Description:
rem   Script converts input XML into XPATH list by applying bundled XSLT file.

rem Flags:
rem  -noprops - do not print properties
rem  -lnodes - print leaf ancestor XPATHs (leaf nodes) before a leaf

setlocal

call "%%~dp0__init__.bat" || exit /b

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

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
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b 255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

set "XML_FILE=%~1"

if not defined XML_FILE (
  echo;%?~%: error: xml file is no set.
  exit /b 254
) >&2

if not exist "%XML_FILE%" (
  echo;%?~%: error: xml file is not found: "%XML_FILE%".
  exit /b 253
) >&2

rem [FLAG_LNODES,FLAG_NOPROPS]
set XSLT_FILE[0,0]=xml_to_xpath_leaf_list.xslt
set XSLT_FILE[0,1]=xml_to_xpath_leaf_list_no_props.xslt
set XSLT_FILE[1,0]=xml_to_xpath_node_list.xslt
set XSLT_FILE[1,1]=xml_to_xpath_node_list_no_props.xslt

call "%%CONTOOLS_XMLSTARLET_ROOT%%/xml.exe" tr "%%CONTOOLS_XML_TOOLS_ROOT%%/xslt/%%XSLT_FILE[%FLAG_LNODES%,%FLAG_NOPROPS%]%%" "%%XML_FILE%%"
