* README_EN.txt
* 2022.09.05
* contools--utilities--contools

1. DESCRIPTION
2. LICENSE
3. REPOSITORIES
4. PREREQUISITES
5. FEATURES
5.1. callf
5.2. clearcache
6. KNOWN ISSUES

6.1. With `cmd.exe`
6.1.1. Interactive input autocompletion disable.
6.1.2. The `set /p DUMMY=` cmd.exe command ignores the input after the `callf`
       call.
6.1.3. The `type con | callf "" "cmd.exe /k"` command makes `cmd.exe` left
       behind waiting the last input while the neighbor `callf.exe` process is
       already exited.
6.1.4. The `start "" /WAIT /B cmd.exe /k` does not wait a child process.
6.1.5. The `callf "" "cmd.exe /c callf \"\" \"cmd.exe /k\""` command losing
       arrows key interactive input (command history traverse).

6.2. With `callf.exe`/`callfg.exe`
6.2.1. Console output in particular case prints as untranslated (line feed and
       return characters become printable)
6.2.2. The `callf /pipe-inout-child "" "cmd.exe /k"` command is blocked on
       input while a child process is terminated externally.
6.2.3. The `callf /tee-stdin 0.log /pipe-child-stdout-to-stdout "" "cmd.exe /k"`
       command is blocked on input while a child process is terminated
       externally.

6.3. With `callf.exe`/`callfg.exe` under VirtualBox
6.3.1. The `callf /elevate ...` shows system dialog
       `The specified path does not exist.`

6.4. With `bash.exe`
6.4.1. The GNU Bash shell executable throws an error:
       `select_stuff::wait: WaitForMultipleObjects failed, Win32 error 6`.

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

* Skip pause on detached console.

  Examples:
  >
  start "" /B /WAIT callfg /pause-on-exit /skip-pause-on-detached-console "" "cmd.exe /k"

-------------------------------------------------------------------------------
5.2. clearcache
-------------------------------------------------------------------------------

Clears a drive or volume cache including the swap file mapping.
Must be run under the Administrator permissions to take effect.

To test:

1. Open Windows Explorer properties dialog for a big sized folder. Observe the
   fast size calculation.
2. Clear the cache of the driver where the folder is located.
3. Reopen Windows Explorer properties dialog for the same folder. Observe the
   folder size calculation slowdown.

-------------------------------------------------------------------------------
6. KNOWN ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
6.1. With `cmd.exe`
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
6.1.1. Interactive input autocompletion disable.
-------------------------------------------------------------------------------

If at least stdin or stdout (but not stderr) is redirected, then the
interactive input in the child `cmd.exe` process does disable autocompletion
feature.

Examples:

>
callf /tee-stdin 0.log /pipe-stdin-to-child-stdin "" "cmd.exe /k"

>
callf /tee-stdout 1.log /pipe-child-stdout-to-stdout "" "cmd.exe /k"

The issue is attached to the stdin/stdout handle type inside the `cmd.exe`
process.

If the stdin or stdout handle has not a character device type
(ex: GetFileType(GetStdHandle(STD_INPUT_HANDLE)) != FILE_TYPE_CHAR), then the
autocompletion feature is turned off and all characters including a tab
character processes as is. Otherwise the tab button press triggers the
autocompletion feature.

A standard handle changes its type from the `FILE_TYPE_CHAR`, for example, if
a process standard handle is redirected.

The fix can be made portably between different Windows versions, for example,
through the code injection into a child process and interception of the
`ReadConsole`/`WriteConsole` calls.

-------------------------------------------------------------------------------
6.1.2. The `set /p DUMMY=` cmd.exe command ignores the input after the `callf`
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
6.1.3. The `type con | callf "" "cmd.exe /k"` command makes `cmd.exe` left
       behind waiting the last input while the neighbor `callf.exe` process is
       already exited.
-------------------------------------------------------------------------------

To reproduce do execute the command and terminate the last `cmd.exe` child
process.
The neighbor `cmd.exe` process to already exited `callf.exe` process will not
exit until the line return character would be entered.

-------------------------------------------------------------------------------
6.1.4. The `start "" /WAIT /B cmd.exe /k` does not wait a child process.
-------------------------------------------------------------------------------

The command does not wait the `cmd.exe` child process.

To reproduce:

  >
  set A=111
  set A=222
  echo %A%
  111
  echo %A%
  222

To fix:

  >
  start "" /B /WAIT cmd.exe /k

-------------------------------------------------------------------------------
6.1.5. The `callf "" "cmd.exe /c callf \"\" \"cmd.exe /k\""` command losing
       arrows key interactive input (command history traverse).
-------------------------------------------------------------------------------

NOTE:
  Has been workarounded in the version 1.21.1.58.

The command loses arrow keys interactive input and can not traverse command
line input history.

To fix:

  >
  callf /detach-inherited-console-on-wait "" "cmd.exe /c callf \"\" \"cmd.exe /k\""

NOTE:
  In some cases above fix does not work because of a race condition inside
  the `cmd.exe` inner parent console window search logic.

  You can use wait timeout to increase the chances:

  >
  callf /detach-inherited-console-on-wait /wait-child-first-time-timeout 300 "" "cmd.exe /c callf \"\" \"cmd.exe /k\""

-------------------------------------------------------------------------------
6.2. With `callf.exe`/`callfg.exe`
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
6.2.1. Console output in particular case prints as untranslated (line feed and
       return characters become printable)
-------------------------------------------------------------------------------

This issue is related to reattachment of a parent console.

Can be fixed only through the parent process injection being used for console
window attachment and directly call `GetStdHandle` functions to read standard
handle addresses layout to update the standard handles (call `StdStdHandle`) in
the process, where console is attached.

-------------------------------------------------------------------------------
6.2.2. The `callf /pipe-inout-child "" "cmd.exe /k"` command is blocked on
       input while a child process is terminated externally.
-------------------------------------------------------------------------------

NOTE:
  Has been workarounded in the version 1.20.0.54.

To reproduce do execute the command and terminate the `cmd.exe` child process.
The parent process will not exit until the line return character would be
entered.

-------------------------------------------------------------------------------
6.2.3. The `callf /tee-stdin 0.log /pipe-child-stdout-to-stdout "" "cmd.exe /k"`
       command is blocked on input while a child process is terminated
       externally.
-------------------------------------------------------------------------------

To reproduce do execute the command and terminate the `cmd.exe` child process.
The parent process will not exit until the line return character would be
entered.

-------------------------------------------------------------------------------
6.3. With `callf.exe`/`callfg.exe` under VirtualBox
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
6.3.1. The `callf /elevate ...` shows system dialog
       `The specified path does not exist.`
-------------------------------------------------------------------------------

The ShellExecute API can not run an executable from the VirtualBox Shared
Folder because it is not a fixed volume but a Network Drive.

-------------------------------------------------------------------------------
6.4. With `bash.exe`
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
6.4.1. The GNU Bash shell executable throws an error:
       `select_stuff::wait: WaitForMultipleObjects failed, Win32 error 6`.
-------------------------------------------------------------------------------

If try to run the Bash shell executable, then it may throw an error after a
console window reallocation in the `callf` utility.

To workaround that you can use `callfg` utility instead with the
`/create-console` flag. This will avoid a need to reallocate a console window,
for example, in the elevated child process in case if elevation is required
(`/attach-parent-console` flag).

-------------------------------------------------------------------------------
7. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
