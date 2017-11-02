* README_EN.txt
* 2017.11.02
* Toolbar buttons configuration for the Total Commander.

1. Open standalone notepad window for selected files.
1.1. Method #1. On left mouse button.
1.2. Method #2. On left mouse button.
2. Open selected files in existing Notepad++ window.
2.1. Method #1. On left mouse button.
2.2. Method #2. On left mouse button.
3. Open Administator console window in current directory.
3.1. Method #1. On left mouse button. Total Commander bitness independent.
3.2. Method #2. On left mouse button. Total Commander bitness dependent.
3.3. Method #3. On right mouse button -> As Administrator.
3.4. Method #4. On left mouse button.
3.5. Method #5. Call command cmda.bat and Administrator password after.
4. Edit SVN externals (SVN properties).
4.1 Method #1 (Main). For selected files and directories together over SVN GUI.
4.2 Method #2. For selected files and directores one after one over external editor.
5. Open SVN Log for selected files and directories together.
6. Open TortoiseSVN status dialog for a set of WC directories (always opens to show unversioned changes).
6.1. Method #1. (By default if no -window-per-*/-all-in-one flags) One window for all WC directories with or without versioned changes.
6.2. Method #2. Window per unique repository root with or without versioned changes in respective WC directory.
6.3. Method #3. Window per command line WC directory with or without versioned changes.
6.4. Method #4. Window per WC root directory with or without versioned changes.
7. Open TortoiseSVN commit dialogs for a set of WC directories.
7.1. Method #1. (By default if no -window-per-*/-all-in-one flags) Window per unique repository root with changes in respective WC directory.
7.2. Method #2. One window for all WC directories with changes.
7.3. Method #3. Window per command line WC directory with changes.
7.4. Method #4. Window per WC root directory with changes.
8. One pane comparison for 2 selected files.
8.1. Method #1. By path list from ANSI text file.
8.2. Method #2. By path list from command line.
9. One pane comparison for 2 selected files with sorted content.
9.1. Method #1. By path list from ANSI text file.
9.2. Method #2. By path list from command line.
10. AUTHOR

------------------------------------------------------------------------------
1. Open standalone notepad window for selected files.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
1.1. Method #1 On left mouse button.
------------------------------------------------------------------------------
(Console window is hidden (no flickering))

For Notepad++:

call_nowindow.vbs
notepad_edit_files.bat -wait -npp -nosession -multiInst "%P" %S

For Windows Notepad:

call_nowindow.vbs
notepad_edit_files.bat "%P" %S

------------------------------------------------------------------------------
1.2. Method #2. On left mouse button.
------------------------------------------------------------------------------
(Console window appears on a moment (flickering))

For Notepad++:

notepad_edit_files.bat
-npp -nosession -multiInst "%P" %S

For Windows Notepad:

notepad_edit_files.bat
"%P" %S

------------------------------------------------------------------------------
2. Open selected files in existing Notepad++ window.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
2.1. Method #1. On left mouse button.
------------------------------------------------------------------------------
(Console window is hidden (no flickering))

call_nowindow.vbs
notepad_edit_files.bat -wait -npp -nosession "%P" %S

------------------------------------------------------------------------------
2.2. Method #2. On left mouse button.
------------------------------------------------------------------------------
(Console window appears on a moment (flickering))

notepad_edit_files.bat
-npp -nosession "%P" %S

------------------------------------------------------------------------------
3. Open Administator console window in current directory.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.1. Method #1. On left mouse button. Total Commander bitness independent.
------------------------------------------------------------------------------
(may be in some cases it won't work, for example, command "pip install pip --upgrade" in Python 3.5 in Windows 7 x86 responds as "access denided")
(correction: may be the error is an error of Python, the internet advises to run command as: "python -m pip install --upgrade")

In the Windows x64 open 64-bit console window in the Administrative mode and type:
  mklink /D "%SystemRoot%\Sysnative" "%SystemRoot%\System32"

This will create the directory link to 64-bit cmd.exe available from the 32-bit
process.

For 64-bit cmd.exe button under Windows x64 in the Administrative mode:

cmd_sysnative_admin.lnk
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

For 32-bit cmd.exe button under Windows x64 in the Administrative mode:

cmd_wow64_admin.lnk
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

For 64-bit cmd.exe button under Windows x64 in a user mode:

cmd_sysnative.lnk
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

For 32-bit cmd.exe button under Windows x64 in a user mode:

cmd_wow64.lnk
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

------------------------------------------------------------------------------
3.2. Method #2. On left mouse button. Total Commander bitness dependent.
------------------------------------------------------------------------------
(In Window x64 will open cmd.exe which bitness will be dependent on
Total Commander bitness)
(may be in some cases it won't work, for example, command "pip install pip --upgrade" in Python 3.5 in Windows 7 x86 responds as "access denided")
(correction: may be the error is an error of Python, the internet advises to run command as: "python -m pip install --upgrade")

cmd_admin.lnk
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

------------------------------------------------------------------------------
3.3. Method #2. On right mouse button -> As Administrator.
------------------------------------------------------------------------------

cmd.exe
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

------------------------------------------------------------------------------
3.4. Method #3. On left mouse button.
------------------------------------------------------------------------------
(may be in some cases it won't work, for example, command "netsh winhttp reset proxy" in Windows 7 x86 responds as "access denided")
(in not english version of Windows instead of the "Administrator" you have to use a localized name)

runas
/user:Administrator "cmd.exe /K set \"PWD=%P\\"&call %%PWD:~0,2%%&call cd \"%%PWD%%\"&title User: ^<Administrator^>"

or

cmd_as_user.bat
Administrator "%P"

------------------------------------------------------------------------------
3.5. Method #4. Call command cmda.bat and Administrator password after.
------------------------------------------------------------------------------
(cmda.user.bat by default cantains a localized group name of Administrators which uses to take first Administrator name for the console
if cmda.bat didn't have that name at first argument)

cmda.bat
"<Administrator name>"

------------------------------------------------------------------------------
4. Edit SVN externals (SVN properties).
------------------------------------------------------------------------------

------------------------------------------------------------------------------
4.1 Method #1 (Main). For selected files and directories together over SVN GUI.
------------------------------------------------------------------------------
(all windows together)

call_nowindow.vbs
tortoisesvn\TortoiseProc.bat /command:properties "%P" %S

------------------------------------------------------------------------------
4.2 Method #2. For selected files and directores one after one over external editor.
------------------------------------------------------------------------------
(one notepad window at a time)

cmd.exe
/C set SVN_EDITOR="c:\Program Files\Notepad++\notepad++.exe" -multiInst -nosession&svn pe svn:externals %S&echo.Waiting 10 sec or press any key...&timeout /t 10 > nul

or

externals_edit.bat
%S

------------------------------------------------------------------------------
5. Open SVN Log for selected files and directories together.
------------------------------------------------------------------------------
(all windows together)

call_nowindow.vbs
tortoisesvn\TortoiseProc.bat /command:log "%P" %S

------------------------------------------------------------------------------
6. Open TortoiseSVN status dialog for a set of WC directories (always opens to show unversioned changes).
------------------------------------------------------------------------------

------------------------------------------------------------------------------
6.1. Method #1. (By default if no -window-per-*/-all-in-one flags) One window for all WC directories with or without versioned changes.
------------------------------------------------------------------------------
call_nowindow.vbs
tortoisesvn\TortoiseProcByNestedWC.bat -all-in-one /command:repostatus "%P" %S

or

call_nowindow.vbs
tortoisesvn\TortoiseProcByNestedWC.bat /command:repostatus "%P" %S

------------------------------------------------------------------------------
6.2. Method #2. Window per unique repository root with or without versioned changes in respective WC directory.
------------------------------------------------------------------------------
call_nowindow.vbs
tortoisesvn\TortoiseProcByNestedWC.bat -window-per-reporoot /command:repostatus "%P" %S

------------------------------------------------------------------------------
6.3. Method #3. Window per command line WC directory with or without versioned changes.
------------------------------------------------------------------------------
call_nowindow.vbs
tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcdir /command:repostatus "%P" %S

------------------------------------------------------------------------------
6.4. Method #4. Window per WC root directory with or without versioned changes.
------------------------------------------------------------------------------
call_nowindow.vbs
tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcroot /command:repostatus "%P" %S

------------------------------------------------------------------------------
7. Open TortoiseSVN commit dialogs for a set of WC directories (opens only if has not empty versioned changes).
------------------------------------------------------------------------------

------------------------------------------------------------------------------
7.1. Method #1. (By default if no -window-per-*/-all-in-one flags) Window per unique repository root with changes in respective WC directory.
------------------------------------------------------------------------------
call_nowindow.vbs
tortoisesvn\TortoiseProcByNestedWC.bat -window-per-reporoot /command:commit "%P" %S

or

call_nowindow.vbs
tortoisesvn\TortoiseProcByNestedWC.bat /command:commit "%P" %S

------------------------------------------------------------------------------
7.2. Method #2. One window for all WC directories with changes.
------------------------------------------------------------------------------
call_nowindow.vbs
tortoisesvn\TortoiseProcByNestedWC.bat -all-in-one /command:commit "%P" %S

------------------------------------------------------------------------------
7.3. Method #3. Window per command line WC directory with changes.
------------------------------------------------------------------------------
call_nowindow.vbs
tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcdir /command:commit "%P" %S

------------------------------------------------------------------------------
7.4. Method #4. Window per WC root directory with changes.
------------------------------------------------------------------------------
call_nowindow.vbs
tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcroot /command:commit "%P" %S

------------------------------------------------------------------------------
8. One pane comparison for 2 selected files.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
8.1. Method #1. By path list from ANSI text file.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_files_by_list.bat -wait "%P" %L

------------------------------------------------------------------------------
8.2. Method #2. By path list from command line.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_files.bat -wait "%P" %S

------------------------------------------------------------------------------
9. One pane comparison for 2 selected files with sorted content.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
9.1. Method #1. By path list from ANSI text file.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_sorted_files_by_list.bat -wait "%P" %L

------------------------------------------------------------------------------
9.2. Method #2. By path list from command line.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_sorted_files.bat -wait "%P" %S

------------------------------------------------------------------------------
10. AUTHOR
------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
