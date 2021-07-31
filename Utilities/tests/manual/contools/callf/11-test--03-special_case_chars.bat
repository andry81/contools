@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

rem Internal `CommandLineToArgv` Win32 API parser passes (https://docs.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-commandlinetoargvw ):
rem
rem Pass #0:    "/c \"echo.Special case characters: ^^^|^^^&\"|& ^ |&\"^^^|^^^& ^^^^ ^^^|^^^&\"|& ^ |&\"^^^|^^^& ^& echo.\""
rem
rem Pass #1:    /c "echo.Special case characters: ^^^|^^^&"|& ^ |&"^^^|^^^& ^^^^ ^^^|^^^&"|& ^ |&"^^^|^^^& ^& echo."
rem
rem Internal `cmd.exe` parser passes:
rem
rem Pass #2:    /c echo.Special case characters: ^^^|^^^&"|& ^ |&"^^^|^^^& ^^^^ ^^^|^^^&"|& ^ |&"^^^|^^^& ^& echo.
rem
rem Pass #3:    /c echo.Special case characters: ^|^&"|& ^ |&"^|^& ^^ ^|^&"|& ^ |&"^|^& & echo.
rem
rem Pass #4:
rem   Command #1: echo.Special case characters: ^|^&"|& ^ |&"^|^& ^^ ^|^&"|& ^ |&"^|^&
rem   Command #2: echo.
rem
rem The `cmd.exe` parser command rules:
rem
rem 1. The `""` character sequence changes escaping rules and does replace itself by a single quote.
rem 2. The `^` character inside a string behaves like not escape character, but outside a string like escape character.
rem 3. The `|` and `&` characters inside a string behaves like usual character, but outside a string - special command characters.
rem

"%CALLF_EXE_PATH%" "${COMSPEC}" "/c \"echo.Special case characters: ^^^|^^^&\"|& ^ |&\"^^^|^^^& ^^^^ ^^^|^^^&\"|& ^ |&\"^^^|^^^& ^& echo.\""

pause
