@echo off

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "FROM_LIST_FILE_HEX=%~1"
set "TO_LIST_FILE_HEX_UCP=%~2"
set "TO_LIST_FILE_DIR_HEX_UCP=%~dp2"

if not exist "%FROM_LIST_FILE_HEX%" (
  echo;%?~%: error: FROM_LIST_FILE_HEX file does not exist: "%FROM_LIST_FILE_HEX%".
  exit /b 1
) >&2

if not exist "%TO_LIST_FILE_DIR_HEX_UCP%" (
  echo;%?~%: error: TO_LIST_FILE_DIR_HEX_UCP directory does not exist: "%TO_LIST_FILE_DIR_HEX_UCP%".
  exit /b 2
) >&2

type nul > "%TO_LIST_FILE_HEX_UCP%"

setlocal ENABLEDELAYEDEXPANSION

set LINE_RETURN=0
set HEX_LINE_INDEX=0
for /F "usebackq tokens=1,* delims=	" %%i in ("%FROM_LIST_FILE_HEX%") do (
  set "HEX_LINE=%%j"

  if not defined HEX_LINE exit /b 0

  set "HEX_LINE=!HEX_LINE:~0,48!"
  set "HEX_LINE=!HEX_LINE: =!"

  set HEX_LINE_OFFSET=0

  rem exclude BOM characters
  if !HEX_LINE_INDEX! EQU 0 set /A HEX_LINE_OFFSET+=4

  for /L %%k in (!HEX_LINE_OFFSET!, 4, 32) do (
    set "UTF_16_CHAR=!HEX_LINE:~%%k,4!"

    if defined UTF_16_CHAR (
      if not "!UTF_16_CHAR!" == "0d00" (
        if not "!UTF_16_CHAR!" == "0a00" (
          if !LINE_RETURN! NEQ 0 (
            set LINE_RETURN=0
            echo;>> "!TO_LIST_FILE_HEX_UCP!"
          )
          rem echo w/o line return
          set /P =^&#x!UTF_16_CHAR:~2,2!!UTF_16_CHAR:~0,2!;<nul >> "!TO_LIST_FILE_HEX_UCP!"
        ) else set LINE_RETURN=1
      )
    )
  )

  set /A HEX_LINE_INDEX+=1
)

exit /b 0
