Flag combinations and child `cmd.exe` process reaction while waiting on `choice.exe` call:

<none>
  CTRL+C      Terminate batch job (Y/N)? Terminate batch job (Y/N)? y y
  CTRL+BREAK  Terminate batch job (Y/N)? Terminate batch job (Y/N)? y y

/disable-ctrl-c-signal-no-inherit
  CTRL+C      Terminate batch job (Y/N)? y Press any key to continue . . . Terminate batch job (Y/N)? y
  CTRL+BREAK  Terminate batch job (Y/N)? Terminate batch job (Y/N)? y y

/disable-ctrl-c-signal
  CTRL+C      - Press any key to continue . . . Terminate batch job (Y/N)? y
  CTRL+BREAK  Terminate batch job (Y/N)? Terminate batch job (Y/N)? y y

/disable-ctrl-signals
  CTRL+C      Terminate batch job (Y/N)? y Press any key to continue . . . Terminate batch job (Y/N)? y
  CTRL+BREAK  Terminate batch job (Y/N)? y Press any key to continue . . . Terminate batch job (Y/N)? y

/disable-ctrl-signals /disable-ctrl-c-signal-no-inherit
  CTRL+C      Terminate batch job (Y/N)? y Press any key to continue . . . Terminate batch job (Y/N)? y
  CTRL+BREAK  Terminate batch job (Y/N)? y Press any key to continue . . . Terminate batch job (Y/N)? y

/disable-ctrl-signals /disable-ctrl-c-signal
  CTRL+C      - Press any key to continue . . . Terminate batch job (Y/N)? y
  CTRL+BREAK  Terminate batch job (Y/N)? y Press any key to continue . . . Terminate batch job (Y/N)? y

---

rem to generate CTRL-BREAK
rem cmd.exe /c exit -1073741510
