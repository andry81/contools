
for /F "usebackq eol=# tokens=* delims=" %%i in ("%__?CONFIG_FILE_DIR%/%__?CONFIG_FILE%") do (
  endlocal
  setlocal DISABLEDELAYEDEXPANSION
  for /F "eol=# tokens=1,* delims==" %%j in ("%%i") do (
    set "__?VAR=%%j"
    set "__?VALUE=%%k"
    call "%%~dp0load_config.fast_parse.parse_expr.bat" %%* && (
      setlocal ENABLEDELAYEDEXPANSION
      if defined __?VALUE for /F "tokens=* delims=" %%l in ("!__?VAR!") do for /F "tokens=* delims=" %%m in ("!__?VALUE!") do for /F "tokens=* delims=" %%n in ("!__?UPATH!") do for /F "tokens=* delims=" %%o in ("%%m") do (
        endlocal
        endlocal
        set "%%l=%%o"
        if %%n0 NEQ 0 set "__?VALUE=%%o" & setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%p in ("!__?VALUE:\=/!") do for /F "eol= tokens=* delims=" %%q in ("%%p") do ( endlocal & set "%%l=%%q" )
      ) else for /F "tokens=* delims=" %%l in ("!__?VAR!") do (
        endlocal
        endlocal
        set "%%l="
      )
      call;
    ) || endlocal
  )
)

exit /b 0
