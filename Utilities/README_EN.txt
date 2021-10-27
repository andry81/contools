* README_EN.txt
* 2021.10.28
* contools--utilities

1. DESCRIPTION
2. USAGE
2.1. callf
3. KNOWN ISSUES
3.1. cmd.exe autocompletion breakage
3.2. console output in particular cases prints as untranslated (line feed and
     return characters become printable)

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Set of contools utilities.

-------------------------------------------------------------------------------
2. USAGE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
2.1. callf
-------------------------------------------------------------------------------

>
callf.exe /?

-------------------------------------------------------------------------------
3. KNWON ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
3.1. cmd.exe autocompletion breakage
-------------------------------------------------------------------------------

Simultenious stdin or stdout ot stderr redirection and interactive input in the
child `cmd.exe` process does break autocompletion feature.

Example:

>
callf /tee-stdin 0.log /pipe-stdin-to-child-stdin "" "cmd.exe /k"

The issue is attached to the stdin handle type inside the `cmd.exe` process.
If the stdin handle has not a character device type
(GetFileType(GetStdHandle(STD_INPUT_HANDLE)) != FILE_TYPE_CHAR), then the
autocompletion feature is turned off and all characters including a tab
character processes as is. Otherwise the tab button press triggers the
autocompletionn feature.

The stdin handle changes its type from the `FILE_TYPE_CHAR`, for example, if
the process input is redirected.

The fix can be made portably between different Windows versions, for example,
through the code injection into a child process and interception of the
`ReadConsole`/`WriteConsole` calls.

-------------------------------------------------------------------------------
3.2. console output in particular case prints as untranslated (line feed and
     return characters become printable)
-------------------------------------------------------------------------------

This issue is related to reattachment of a parent console.

Can be fixed only through the parent process injection being used for console
window attachment and directly call `GetStdHandle` functions to read standard
handle addresses layout to update the standard handles (call `StdStdHandle`) in
the process, where console is attached.
