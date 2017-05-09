@echo off

rem check on supported wc.db user version
set "WC_DB_USER_VERSION="
for /F "usebackq eol= tokens=1,* delims=:" %%i in (`@call "%%SQLITE_TOOLS_ROOT%%/sqlite.bat" -batch ".svn/wc.db" ".headers off" ".mode list" ".separator |" ".dbinfo"`) do (
  if "%%i" == "user version" set "WC_DB_USER_VERSION=%%j"  
)

call :TRIM_BEGINNING_SPACES "%%WC_DB_USER_VERSION%%"
set "WC_DB_USER_VERSION=%RETURN_VALUE%"

goto TRIM_BEGINNING_SPACES_END

:TRIM_BEGINNING_SPACES
rem drop return value
set "RETURN_VALUE="
for /F "eol= tokens=* delims=	 " %%i in ("%~1") do set "RETURN_VALUE=%%i"
exit /b 0

:TRIM_BEGINNING_SPACES_END
exit /b 0
