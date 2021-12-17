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
call;

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%*

rem script flags
set FLAG_EXACT=0
set FLAG_IGNORE_PROPS=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
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

if not defined XPATH_LIST_FILE_IN (
  echo.%?~nx0%: error: input xpath file is no set.
  exit /b 2
) >&2

if not exist "%XPATH_LIST_FILE_IN%" (
  echo.%?~nx0%: error: input xpath file is not found: "%XPATH_LIST_FILE_IN%".
  exit /b 3
) >&2

if not defined XPATH_LIST_FILE_FILTER (
  echo.%?~nx0%: error: xpath filter file is no set.
  exit /b 4
) >&2

if not exist "%XPATH_LIST_FILE_FILTER%" (
  echo.%?~nx0%: error: xpath filter file is not found: "%XPATH_LIST_FILE_FILTER%".
  exit /b 5
) >&2


call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

set "XPATH_LIST_FILE_IN_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\xpath_in.lst"
set "XPATH_LIST_FILE_FILTER_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\xpath_filter.lst"

call :MAIN
set LASTERROR=%ERRORLEVEL%

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

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
"%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" -n %SED_FILTER_PREFIX_CMD_LINE% -f "%CONTOOLS_XML_TOOLS_ROOT%/sed/%SED_FILTER_SUFFIX_CMD_FILE%" "%XPATH_LIST_FILE_FILTER%" > "%XPATH_LIST_FILE_FILTER_TEMP_FILE%" || exit /b

rem create search list, append "/" to end of each xpath for exact/subdir match
set SED_SEARCH_PREFIX_CMD_LINE=-e "/^#/ !{ /[^\/]\[@/ { s/\([^\/]\)\[@/\1\/[@/; }; /\/\[@/ !{ /[^[[:space:]]]/ { /\/$/ !{ s/$/\//; } } } }"
"%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" -n %SED_SEARCH_PREFIX_CMD_LINE% -f "%CONTOOLS_XML_TOOLS_ROOT%/sed/convert_xpath_search_list_to_flat_findstr_search_list.sed" %SED_SEARCH_LAST_CMD_LINE% "%XPATH_LIST_FILE_IN%" > "%XPATH_LIST_FILE_IN_TEMP_FILE%" || exit /b

rem apply filter list to search list and remove flat list prefixes, convert empty lines to special comments to save them in output, remove "/" from end of each xpath
set SED_CLEANUP_LAST_CMD_LINE=-e "/^#/ { s/^# :EOL$//; }; /^#/ !{ /./ { s/.*|//; } }; /\/\[@/ { s/\/\[@/[@/; }; /\/\[@/ !{ s/\/$//; }"
"%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" -e "/./ !{ s/^$/# :EOL/ }" "%XPATH_LIST_FILE_IN_TEMP_FILE%" | findstr.exe /R /B /G:"%XPATH_LIST_FILE_FILTER_TEMP_FILE%" /C:"#" | "%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" %SED_CLEANUP_LAST_CMD_LINE%
