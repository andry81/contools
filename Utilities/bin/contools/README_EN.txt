* README_EN.txt
* 2022.01.03
* contools--utilities--contools

1. DESCRIPTION
2. LICENSE
3. REPOSITORIES
4. PREREQUISITES
5. FEATURES
5.1. callf
6. KNOWN ISSUES
6.1. The GNU Bash shell executable throws an error:
     `select_stuff::wait: WaitForMultipleObjects failed, Win32 error 6`.
6.2. The `set /p DUMMY=` cmd.exe command ignores the input after the `callf`
     call.
6.3. The `callf /pipe-inout-child "" "cmd.exe /k"` command is blocked on input
     while a child process is terminated externally.
6.4. The `type con | callf "" "cmd.exe /k"` command makes `cmd.exe` left behind
     waiting the last input while the neighbor `callf.exe` process is already
     exited.
7. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Set of Windows command line (console) utilites.

WARNING:
  Use the SVN access to find out latest functionality and bug fixes.
  See the REPOSITORIES section.

-------------------------------------------------------------------------------
2. LICENSE
-------------------------------------------------------------------------------
The MIT license (see included text file "license.txt" or
https://en.wikipedia.org/wiki/MIT_License)

-------------------------------------------------------------------------------
3. REPOSITORIES
-------------------------------------------------------------------------------
Primary:
  * https://sf.net/p/contools/contools/HEAD/tree/trunk/Utilities
    https://svn.code.sf.net/p/contools/contools/trunk/Utilities
First mirror:
  * https://github.com/andry81/contools/tree/trunk/Utilities
    https://github.com/andry81/contools.git
Second mirror:
  * https://bitbucket.org/andry81/contools/src/trunk/Utilities
    https://bitbucket.org/andry81/contools.git

-------------------------------------------------------------------------------
4. PREREQUISITES
-------------------------------------------------------------------------------

Currently used these set of OS platforms, compilers, interpreters, modules,
IDE's, applications and patches to run with or from:

1. OS platforms:

* Windows 7

2. C++11 compilers:

* (primary) Microsoft Visual C++ 2015 Update 3 or Microsoft Visual C++ 2017

3. IDE's.

* Microsoft Visual Studio 2015 Update 3
* Microsoft Visual Studio 2017

To build GUI utilities is required the wxWidgets library at least of version
3.1.3.

CAUTION:
  You have to build wxwidgets before build GUI utilities.

-------------------------------------------------------------------------------
5. FEATURES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
5.1. callf
-------------------------------------------------------------------------------

Create process or Shell execute in style of c-function printf.

* Command line variadic variables substitution in style of c-function printf
  with the python placeholders.

  Examples:
  >
  callf.exe "" "cmd.exe /c echo.\"{0} {1}\"" "1 2" "3 4"

* Environment variables expansion.

  Examples:
  >
  callf.exe "" "\"${COMSPEC}\" /c echo.\"{0} {1}\"" "1 2" "3 4"

* Execute with elevation.

  ** Use new console.

     Examples:
     >
     callf.exe /shell-exec runas /no-sys-dialog-ui "${COMSPEC}" "/c echo.\"{0} {1}\" & pause" "1 2" "3 4"
     >
     callf.exe /elevate "" "\"${COMSPEC}\" /c echo.\"{0} {1}\" & pause" "1 2" "3 4"
     >
     callfg.exe /elevate /create-console "" "\"${COMSPEC}\" /c echo.\"{0} {1}\" & pause" "1 2" "3 4"

  ** Use existing console.

     Examples:
     >
     callf.exe /shell-exec runas /no-sys-dialog-ui /no-window "callf.exe" "/attach-parent-console \"\" \"\\\"${COMSPEC}\\\" /c \\\"echo.\\\"{0} {1}\\\"\\\"\" \"1 2\" \"3 4\""
     >
     callf.exe /elevate{ /no-window }{ /attach-parent-console } "" "\"${COMSPEC}\" /c echo.\"{0} {1}\"" "1 2" "3 4"
     >
     start "" /WAIT callfg.exe /elevate /attach-parent-console "" "\"${COMSPEC}\" /c echo.\"{0} {1}\"" "1 2" "3 4"

* Backslash escaping.

  Examples:
  >
  callf.exe /e2 "${COMSPEC}" "/c echo.\"{0}\"" "Hello\tWorld!\a"

* Text replacing.

  Examples:
  >
  callf /r2 "{LR}" "\n" "" "printf /e \"Hello{0}World!{0}\"" "{LR}"
  >
  callf /ra "{LR}" "\n" "" "printf /e \"Hello{LR}World!{0}\"" "{LR}"

* Set environment variable.

  Examples:
  >
  callf /v "TEST" "123" "" "cmd.exe /c echo.TEST=${TEST}"
  >
  callf /v "TEST" "123" "" "cmd.exe /c echo.TEST=%TEST%"

* File print.

  Examples:
  >
  callf /reopen-stdin 0.in .

* Process input redirection.

  Examples:
  >
  callf.exe /reopen-stdin 0.in "" "cmd.exe /k"

* Output duplication into a file.

  Examples:
  >
  callf.exe /reopen-stdin 0.in /tee-stdout out.log /tee-stderr-dup 1 "" "cmd.exe /k"

* Simple escaping in recursion (escaping for the `cmd.exe` is different).

  Examples:
  >
  callf.exe "" "\"${COMSPEC}\" /c echo.{0}" "%TIME%"
  >
  callf.exe "" "callf.exe \"\" \"\\\"$\{COMSPEC}\\\" /c echo.{0}\" \"%TIME%\""
  >
  callf.exe "" "callf.exe \"\" \"callf.exe \\\"\\\" \\\"\\\\\\\"$\\{COMSPEC}\\\\\\\" /c echo.{0}\\\" \\\"%TIME%\\\"\""

* Connects a named pipe from stdout to a child process stdin with the same
  privileges.

  Examples:
  >
  callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout "" "callf.exe /reopen-stdin-as-client-pipe test123_{ppid} ."
  >
  callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout "" "callf.exe /reopen-stdin-as-client-pipe test123_{ppid} \"\" \"cmd.exe /k\""

* Connects a named pipe from stdout to a child process stdin with the
  Administrator privileges.

  Examples:
  >
  callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout /shell-exec runas /no-sys-dialog-ui /no-window "callf.exe" "/attach-parent-console /reopen-stdin-as-client-pipe test123_{ppid} ."
  >
  callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout /shell-exec runas /no-sys-dialog-ui /no-window "callf.exe" "/attach-parent-console /reopen-stdin-as-client-pipe test123_{ppid} \"\" \"cmd.exe /k\""

* In case of elevation is executed, connects a named pipe to stdin and from
  stdout of a child process with the Administrator privileges isolation,
  otherwise fallbacks to a generic piping.

  Examples:
  >
  callf /promote-parent{ /reopen-stdin 0.in } /elevate{ /no-window /create-outbound-server-pipe-from-stdin test0_{pid} /create-inbound-server-pipe-to-stdout test1_{pid} }{ /attach-parent-console /reopen-stdin-as-client-pipe test0_{ppid} /reopen-stdout-as-client-pipe test1_{ppid} } .
  >
  callf /promote-parent{ /reopen-stdin 0.in } /elevate{ /no-window /create-outbound-server-pipe-from-stdin test0_{pid} /create-inbound-server-pipe-to-stdout test1_{pid} }{ /attach-parent-console /reopen-stdin-as-client-pipe test0_{ppid} /reopen-stdout-as-client-pipe test1_{ppid} } "" "cmd.exe /k"

* Loads ancestor `callf` process environment variables block to reset all
  variables in between of 2 closest `callf` processes in process inheritence
  chain.

  Examples:
  >
  callf /v XXX 111 "" "callf /load-parent-proc-init-env-vars /v YYY 222 \"\" \"cmd.exe /c set\""
  >
  callf /v XXX 111 "" "callf /load-parent-proc-init-env-vars /v YYY 222 \"\" \"callf /load-parent-proc-init-env-vars /v ZZZ 333 \\\"\\\" \\\"cmd.exe /c set\\\"\""

-------------------------------------------------------------------------------
6. KNOWN ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
6.1. The GNU Bash shell executable throws an error:
     `select_stuff::wait: WaitForMultipleObjects failed, Win32 error 6`.
-------------------------------------------------------------------------------

If try to run the Bash shell executable, then it may throw an error after a
console window reallocation in the `callf` utility.

To workaround that you can use `callfg` utility instead with the
`/create-console` flag. This will avoid a need to reallocate a console window,
for example, in the elevated child process in case if elevation is required
(`/attach-parent-console` flag).

-------------------------------------------------------------------------------
6.2. The `set /p DUMMY=` cmd.exe command ignores the input after the `callf`
     call.
-------------------------------------------------------------------------------

NOTE:
  To reproduce the console terminal window must be reopened.

Reproduction example:

```
@echo off

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL

rem bugged:
call <nul >nul & call <nul >nul

rem workarounded:
rem ( call >nul & call >nul ) <nul

callf.exe ^
  /promote-parent{ /pause-on-exit } ^
  /elevate{ /no-window /create-inbound-server-pipe-to-stdout test_stdout_{pid} /create-inbound-server-pipe-to-stderr test_stderr_{pid} ^
  }{ /attach-parent-console /reopen-stdout-as-client-pipe test_stdout_{ppid} /reopen-stderr-as-client-pipe test_stderr_{ppid} } ^
  /v IMPL_MODE 1 "" "cmd.exe /c %0 %*"
exit /b

:IMPL
rem all input can be ignored here
set /P X=AAA
set /P X=BBB
set /P X=CCC
set /P X=DDD
```

To fix that use the `workarounded` call example line.

-------------------------------------------------------------------------------
6.3. The `callf /pipe-inout-child "" "cmd.exe /k"` command is blocked on input
     while a child process is terminated externally.
-------------------------------------------------------------------------------

NOTE:
  Has been workarounded in the version 1.20.0.54.

To reproduce do execute the command and terminate the `cmd.exe` child process.
The parent process will not exit until the line return character would be
entered.

-------------------------------------------------------------------------------
6.4. The `type con | callf "" "cmd.exe /k"` command makes `cmd.exe` left behind
     waiting the last input while the neighbor `callf.exe` process is already
     exited.
-------------------------------------------------------------------------------

To reproduce do execute the command and terminate the last `cmd.exe` child
process.
The neighbor `cmd.exe` process to already exited `callf.exe` process will not
exit until the line return character would be entered.

-------------------------------------------------------------------------------
7. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
