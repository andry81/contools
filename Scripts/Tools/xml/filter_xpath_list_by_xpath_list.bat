@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Filters xpath through another xpath.
rem   Xpath list must be in predefined format, where the "# File: " sequence
rem   can define a specific section to process. In that case specific section
rem   will applied ONLY to the same section at input xpath list, otherwise
rem   everything if filter does not declare any sections.

rem Flags:
rem  -exact - filter by exact xpath equality. By default, filters by xpath tag
rem           path as prefix path.
rem      For example, if search list is:
rem      1.  "/tag1"
rem      2.  "/tag1[@val=VALUE]"
rem      3.  "/tag1/tag2"
rem      4.  "/tag1/tag2[@val=VALUE]"
rem      5.  "/tag1/tag2/tag3"
rem      6.  "/tag1/tag2/tag3[@val=VALUE]"
rem      and filter is "/tag1/tag2", then for -exact match only 3d
rem      and 4th lines will be filtered, otherwise - from 3d to 6th.
rem      If filter is "/tag1/tag2[@val=VALUE]", then exactly 4th
rem      line will be filtered no matter does flag set or not.
rem  -ignore-props - ignore `[@...]' suffix while matching xpaths.

rem Drop last error level
cd .

setlocal

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0.."
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

set "?~n0=%~n0"
set "?~nx0=%~nx0"
set "?~dp0=%~dp0"

rem script flags
set FLAG_EXACT=0
set FLAG_IGNORE_PROPS=1

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  if "%FLAG%" == "-exact" (
    set FLAG_EXACT=1
    shift
  ) else if "%FLAG%" == "-ignore-props" (
    set FLAG_IGNORE_PROPS=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b 1
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

set "XPATH_LIST_FILE_IN=%~1"
set "XPATH_LIST_FILE_FILTER=%~2"

if "%XPATH_LIST_FILE_IN%" == "" (
  echo.%?~nx0%: error: input xpath file is no set.
  exit /b 2
) >&2

if not exist "%XPATH_LIST_FILE_IN%" (
  echo.%?~nx0%: error: input xpath file is not found: "%XPATH_LIST_FILE_IN%".
  exit /b 3
) >&2

if "%XPATH_LIST_FILE_FILTER%" == "" (
  echo.%?~nx0%: error: xpath filter file is no set.
  exit /b 4
) >&2

if not exist "%XPATH_LIST_FILE_FILTER%" (
  echo.%?~nx0%: error: xpath filter file is not found: "%XPATH_LIST_FILE_FILTER%".
  exit /b 5
) >&2

call "%%TOOLS_PATH%%/get_datetime.bat"
set "TEMP_DATE=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%"
set "TEMP_TIME=%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"

set "TEMP_FILE_DIR=%TEMP%\%?~n0%.%TEMP_DATE%.%TEMP_TIME%"
set "XPATH_LIST_FILE_IN_TEMP_FILE=%TEMP_FILE_DIR%\xpath_in.lst"
set "XPATH_LIST_FILE_FILTER_TEMP_FILE=%TEMP_FILE_DIR%\xpath_filter.lst"

rem create temporary files to store local context output
if exist "%TEMP_FILE_DIR%" (
  echo.%?~nx0%: error: temporary generated directory TEMP_FILE_DIR is already exist: "%TEMP_FILE_DIR%"
  exit /b 6
)

mkdir "%TEMP_FILE_DIR%"

call :MAIN
set LASTERROR=%ERRORLEVEL%

rem cleanup temporary files
rmdir /S /Q "%TEMP_FILE_DIR%"

exit /b %LASTERROR%

:MAIN
rem create filter list, append "/" to end of each xpath for exact/subdir match
if %FLAG_IGNORE_PROPS% NEQ 0 (
  set SED_FILTER_PREFIX_CMD_LINE=-e "/^#/ !{ /[^\/]\[@/ { s/\([^\/]\)\[@/\1\/[@/; }; /\/\[@/ !{ /[^[[:space:]]]/ { /\/$/ !{ s/$/\//; } } }; /\[@.*/ { s/\[@.*//; } }"
) else (
  set SED_FILTER_PREFIX_CMD_LINE=-e "/^#/ !{ /[^\/]\[@/ { s/\([^\/]\)\[@/\1\/[@/; }; /\/\[@/ !{ /[^[[:space:]]]/ { /\/$/ !{ s/$/\//; } } } }"
)
if %FLAG_EXACT% NEQ 0 (
  set "SED_FILTER_SUFFIX_CMD_FILE=convert_xpath_filter_list_to_flat_findstr_pttn_exact_list.sed"
) else (
  set "SED_FILTER_SUFFIX_CMD_FILE=convert_xpath_filter_list_to_flat_findstr_pttn_list.sed"
)
"%TOOLS_PATH%/gnuwin32/bin/sed.exe" -n %SED_FILTER_PREFIX_CMD_LINE% -f "%TOOLS_PATH%/xml/sed/%SED_FILTER_SUFFIX_CMD_FILE%" "%XPATH_LIST_FILE_FILTER%" > "%XPATH_LIST_FILE_FILTER_TEMP_FILE%" || goto :EOF

rem create search list, append "/" to end of each xpath for exact/subdir match
set SED_SEARCH_PREFIX_CMD_LINE=-e "/^#/ !{ /[^\/]\[@/ { s/\([^\/]\)\[@/\1\/[@/; }; /\/\[@/ !{ /[^[[:space:]]]/ { /\/$/ !{ s/$/\//; } } } }"
"%TOOLS_PATH%/gnuwin32/bin/sed.exe" -n %SED_SEARCH_PREFIX_CMD_LINE% -f "%TOOLS_PATH%/xml/sed/convert_xpath_search_list_to_flat_findstr_search_list.sed" %SED_SEARCH_LAST_CMD_LINE% "%XPATH_LIST_FILE_IN%" > "%XPATH_LIST_FILE_IN_TEMP_FILE%" || goto :EOF

rem apply filter list to search list and remove flat list prefixes, convert empty lines to special comments to save them in output, remove "/" from end of each xpath
set SED_CLEANUP_LAST_CMD_LINE=-e "/^#/ { s/^# :EOL$//; }; /^#/ !{ /./ { s/.*|//; } }; /\/\[@/ { s/\/\[@/[@/; }; /\/\[@/ !{ s/\/$//; }"
"%TOOLS_PATH%/gnuwin32/bin/sed.exe" -e "/./ !{ s/^$/# :EOL/ }" "%XPATH_LIST_FILE_IN_TEMP_FILE%" | findstr /R /B /G:"%XPATH_LIST_FILE_FILTER_TEMP_FILE%" /C:"#" | "%TOOLS_PATH%/gnuwin32/bin/sed.exe" %SED_CLEANUP_LAST_CMD_LINE%
