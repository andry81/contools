
(
  endlocal
  for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%") do ( set "__?VALUE=%%j" & if defined __?VALUE ( call :PARSE_EXPR %%i ) else set "%%i=" )
  set "__?VALUE="
)

exit /b 0

:PARSE_EXPR
if ^/ == ^%__?VALUE:~1,1%/ ( set "%~1=" & exit /b 0 )
if ^"/ == ^%__?VALUE:~0,1%/ (
  if ^"/ == ^%__?VALUE:~-1%/ ( call set %%1=%__?VALUE:~1,-1%
  ) else call set %%1=%__?VALUE%
) else call set %%1=%__?VALUE%
