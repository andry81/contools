@echo off

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

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

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
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b 1
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

set "XPATH_LIST_FILE_IN=%~1"
set "XPATH_LIST_FILE_FILTER=%~2"

if not defined XPATH_LIST_FILE_IN (
  echo;%?~%: error: input xpath file is no set.
  exit /b 2
) >&2

if not exist "%XPATH_LIST_FILE_IN%" (
  echo;%?~%: error: input xpath file is not found: "%XPATH_LIST_FILE_IN%".
  exit /b 3
) >&2

if not defined XPATH_LIST_FILE_FILTER (
  echo;%?~%: error: xpath filter file is no set.
  exit /b 4
) >&2

if not exist "%XPATH_LIST_FILE_FILTER%" (
  echo;%?~%: error: xpath filter file is not found: "%XPATH_LIST_FILE_FILTER%".
  exit /b 5
) >&2


call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

set "XPATH_LIST_FILE_IN_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\xpath_in.lst"
set "XPATH_LIST_FILE_FILTER_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\xpath_filter.lst"

call :MAIN
set LAST_ERROR=%ERRORLEVEL%

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LAST_ERROR%

:MAIN
rem create filter list, append "/" to end of each xpath for exact/subdir match
if %FLAG_IGNORE_PROPS% NEQ 0 (
  set SED_FILTER_PREFIX_CMD_LINE=-e "/^#/ !{ /[^\/\r]\[@/ { s/\([^\/\r]\)\[@/\1\/[@/; }; /\/\[@/ !{ /[^[:space:]\r]/ { /\/\r\?$/ !{ s/\(\r\?\)$/\/\1/; } } }; /\[@[^\r]*/ { s/\[@[^\r]*//; } }"
) else (
  set SED_FILTER_PREFIX_CMD_LINE=-e "/^#/ !{ /[^\/\r]\[@/ { s/\([^\/\r]\)\[@/\1\/[@/; }; /\/\[@/ !{ /[^[:space:]\r]/ { /\/\r\?$/ !{ s/\(\r\?\)$/\/\1/; } } } }"
)

if %FLAG_EXACT% NEQ 0 (
  set "SED_FILTER_SUFFIX_CMD_FILE=convert_xpath_filter_list_to_flat_findstr_pttn_exact_list.sed"
) else (
  set "SED_FILTER_SUFFIX_CMD_FILE=convert_xpath_filter_list_to_flat_findstr_pttn_list.sed"
)

"%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe" -n -b %SED_FILTER_PREFIX_CMD_LINE% ^
  -f "%CONTOOLS_XML_TOOLS_ROOT%/sed/%SED_FILTER_SUFFIX_CMD_FILE%" "%XPATH_LIST_FILE_FILTER%" > "%XPATH_LIST_FILE_FILTER_TEMP_FILE%" || exit /b

rem create search list, append "/" to end of each xpath for exact/subdir match
"%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe" -n -b -e "/^#/ !{ /[^\/\r]\[@/ { s/\([^\/\r]\)\[@/\1\/[@/; }; /\/\[@/ !{ /[^[:space:]\r]/ { /\/\(\r\?\)$/ !{ s/\(\r\?\)$/\/\1/; } } } }" ^
  -f "%CONTOOLS_XML_TOOLS_ROOT%/sed/convert_xpath_search_list_to_flat_findstr_search_list.sed" "%XPATH_LIST_FILE_IN%" > "%XPATH_LIST_FILE_IN_TEMP_FILE%" || exit /b

rem apply filter list to search list and remove flat list prefixes, convert empty lines to special comments to save them in output, remove "/" from end of each xpath
"%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe" -b -e "/[^\r]/ !{ s/^\(\r\?\)$/# :EOL\1/ }" "%XPATH_LIST_FILE_IN_TEMP_FILE%" ^
  | "%SystemRoot%\System32\findstr.exe" /R /B /G:"%XPATH_LIST_FILE_FILTER_TEMP_FILE%" /C:"#" ^
  | "%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe" -b -e "/^#/ { s/^# :EOL\(\r\?\)$/\1/; }; /^#/ !{ /[^\r]/ { s/[^\r]*|//; } }; /\/\[@/ { s/\/\[@/[@/; }; /\/\[@/ !{ s/\/\(\r\?\)$/\1/; }"
