* README_EN.txt
* 2019.06.27
* Toolbar buttons configuration for the Total Commander.

1. Open a notepad window independently to selected files.

2. Open standalone notepad window for selected files.
2.1. Method #1. On left mouse button.
2.2. Method #2. On left mouse button.

3. Open selected files in existing Notepad++ window.
3.1. Method #1. On left mouse button.
3.2. Method #2. On left mouse button.

4. Open Administator console window in current directory.
4.1. Method #1. On left mouse button. Total Commander bitness independent.
4.2. Method #2. On left mouse button. Total Commander bitness dependent.
4.3. Method #3. On right mouse button -> As Administrator.
4.4. Method #4. On left mouse button.
4.5. Method #5. Call command cmda.bat and Administrator password after.

5. Edit SVN externals (SVN properties).
5.1 Method #1 (Main). For selected files and directories together over SVN GUI.
5.2 Method #2. For selected files and directores one after one over external editor.

6. Open SVN Log for selected files and directories together.

7. Open TortoiseSVN status dialog for a set of WC directories (always opens to show unversioned changes).
7.1. Method #1. (By default if no -window-per-*/-all-in-one flags) One window for all WC directories with or without versioned changes.
7.2. Method #2. Window per unique repository root with or without versioned changes in respective WC directory.
7.3. Method #3. Window per command line WC directory with or without versioned changes.
7.4. Method #4. Window per WC root directory with or without versioned changes.

8. Open TortoiseSVN commit dialogs for a set of WC directories.
8.1. Method #1. (By default if no -window-per-*/-all-in-one flags) Window per unique repository root with changes in respective WC directory.
8.2. Method #2. One window for all WC directories with changes.
8.3. Method #3. Window per command line WC directory with changes.
8.4. Method #4. Window per WC root directory with changes.

9. One pane comparison for 2 selected files.
9.1. Method #1. By path list from ANSI text file.
9.2. Method #2. By path list from command line.

10. One pane comparison for 2 selected files with sorted content.
10.1. Method #1. By path list from ANSI text file.
10.2. Method #2. By path list from command line.

11. Shell/SVN/GIT files batch move
11.1. Method #1. Move files by selection list from ANSI text file.
11.2. Method #2. Move files by selection list from UNICODE text file.

12. Shell/SVN/GIT files batch rename
12.1. Method #1. Rename files by selection list from ANSI text file.
12.2. Method #2. Rename files by selection list from UNICODE text file.

13. Shell/SVN/GIT files batch copy
13.1. Method #1. Copy files by selection list from ANSI text file.
13.2. Method #2. Copy files by selection list from UNICODE text file.

14. Create batch directories
14.1. Method #1. Create directories in current directory by list from ANSI text file.
14.2. Method #2. Create directories in selected directories by list from ANSI text file.
14.3. Method #3. Create directories in current directory by list from UNICODE text file.
14.4. Method #4. Create directories in selected directories by list from UNICODE text file.

15. Create batch empty files
15.1. Method #1. Create directories in current directory by list from ANSI text file.
15.2. Method #2. Create directories in selected directories by list from ANSI text file.
15.3. Method #3. Create directories in current directory by list from UNICODE text file.
15.4. Method #4. Create directories in selected directories by list from UNICODE text file.

17. Concatenate video files

18. AUTHOR

------------------------------------------------------------------------------
1. Open a notepad window independently to selected files.
------------------------------------------------------------------------------

For Notepad++:

call_nowindow.vbs
notepad_edit_files.bat -wait -npp -multiInst -nosession "%P"

For Windows Notepad:

call_nowindow.vbs
notepad_edit_files.bat "%P"

------------------------------------------------------------------------------
2. Open standalone notepad window for selected files.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
2.1. Method #1 On left mouse button.
------------------------------------------------------------------------------
(Console window is hidden (no flickering))

For Notepad++:

call_nowindow.vbs
notepad_edit_files.bat -wait -npp -nosession -multiInst "%P" %S

For Windows Notepad:

call_nowindow.vbs
notepad_edit_files.bat "%P" %S

------------------------------------------------------------------------------
2.2. Method #2. On left mouse button.
------------------------------------------------------------------------------
(Console window appears on a moment (flickering))

For Notepad++, ANSI only files (limited by command line length):

call_nowindow.vbs
notepad_edit_files.bat -npp -nosession -multiInst "%P" %S

For Notepad++, ANSI only files (not limited by command line length):

call_nowindow.vbs
notepad_edit_files_by_list.bat -npp -nosession -multiInst "%P" %L

For Notepad++, any files (not limited by command line length, but slower):

call_nowindow.vbs
notepad_edit_files_by_list.bat -npp -paths_to_u16cp -nosession -multiInst "%P" %WL

For Windows Notepad:

call_nowindow.vbs
notepad_edit_files.bat "%P" %S

------------------------------------------------------------------------------
3. Open selected files in existing Notepad++ window.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.1. Method #1. On left mouse button.
------------------------------------------------------------------------------
(Console window is hidden (no flickering))

ANSI only files (limited by command line length):

call_nowindow.vbs
notepad_edit_files.bat -wait -npp -nosession "%P" %S

ANSI only files (not limited by command line length):

call_nowindow.vbs
notepad_edit_files_by_list.bat -wait -npp -nosession "%P" %L

Any files (not limited by command line length, but slower):

call_nowindow.vbs
notepad_edit_files_by_list.bat -wait -npp -paths_to_u16cp -nosession "%P" %WL

------------------------------------------------------------------------------
3.2. Method #2. On left mouse button.
------------------------------------------------------------------------------
(Console window appears on a moment (flickering))

call_nowindow.vbs
notepad_edit_files.bat -npp -nosession "%P" %S

------------------------------------------------------------------------------
4. Open Administator console window in current directory.
------------------------------------------------------------------------------
CAUTION:
1. Windows can create virtualized `sysnative` directory itself after install or after update rollup with reduced privilege rights, where, for example,
   we can not start `sysnative/cmd.exe` under administrator user.
2. Virtualized `sysnative` directory visible ONLY from 32-bit applications.

For above reasons we should create another directory may be additionally to the `sysnative` one which is:

1. Visible from any application bitness mode.
2. No specific privilege rights restriction by the system and cmd.exe executable from there can be run under administrator user w/o any additional manipulations.

------------------------------------------------------------------------------
4.1. Method #1. On left mouse button. Total Commander bitness independent.
------------------------------------------------------------------------------
(may be in some cases it won't work, for example, command "pip install pip --upgrade" in Python 3.5 in Windows 7 x86 responds as "access denided")
(correction: may be the error is an error of Python, the internet advises to run command as: "python -m pip install --upgrade")

In the Windows x64 open 64-bit console window as Administrator user and type:
  mklink /D "%SystemRoot%\System64" "%SystemRoot%\System32"

This will create the directory link to 64-bit cmd.exe available from any bitness process.

For 64-bit cmd.exe button under any mode in the Administrative mode:

cmd_system64_admin.lnk
/K set "PWD=%P"&call cd /d "%%PWD%%"

For 32-bit cmd.exe button under any mode in the Administrative mode:

cmd_wow64_admin.lnk
/K set "PWD=%P"&call cd /d "%%PWD%%"

For 64-bit cmd.exe button under any mode in a user mode:

cmd_system64.lnk
/K set "PWD=%P"&call cd /d "%%PWD%%"

For 32-bit cmd.exe button under any mode in a user mode:

cmd_wow64.lnk
/K set "PWD=%P"&call cd /d "%%PWD%%"

------------------------------------------------------------------------------
4.2. Method #2. On left mouse button. Total Commander bitness dependent.
------------------------------------------------------------------------------
(In Window x64 will open cmd.exe which bitness will be dependent on
Total Commander bitness)
(may be in some cases it won't work, for example, command "pip install pip --upgrade" in Python 3.5 in Windows 7 x86 responds as "access denided")
(correction: may be the error is an error of Python, the internet advises to run command as: "python -m pip install --upgrade")

cmd_admin.lnk
/K set "PWD=%P"&call cd /d "%%PWD%%"

------------------------------------------------------------------------------
4.3. Method #2. On right mouse button -> As Administrator.
------------------------------------------------------------------------------

cmd.exe
/K set "PWD=%P"&call cd /d "%%PWD%%"

------------------------------------------------------------------------------
4.4. Method #3. On left mouse button.
------------------------------------------------------------------------------
(may be in some cases it won't work, for example, command "netsh winhttp reset proxy" in Windows 7 x86 responds as "access denided")
(in not english version of Windows instead of the "Administrator" you have to use a localized name)

runas
/user:Administrator "cmd.exe /K set \"PWD=%P\\"&call cd /d \"%%PWD%%\"&title User: ^<Administrator^>"

or

cmd_as_user.bat
Administrator "%P"

------------------------------------------------------------------------------
4.5. Method #4. Call command cmda.bat and Administrator password after.
------------------------------------------------------------------------------
(cmda.user.bat by default cantains a localized group name of Administrators which uses to take first Administrator name for the console
if cmda.bat didn't have that name at first argument)

cmda.bat
"<Administrator name>"

------------------------------------------------------------------------------
5. Edit SVN externals (SVN properties).
------------------------------------------------------------------------------

------------------------------------------------------------------------------
5.1 Method #1 (Main). For selected files and directories together over SVN GUI.
------------------------------------------------------------------------------
(all windows together)

call_nowindow.vbs
scm\tortoisesvn\TortoiseProc.bat /command:properties "%P" %S

------------------------------------------------------------------------------
5.2 Method #2. For selected files and directores one after one over external editor.
------------------------------------------------------------------------------
(one notepad window at a time)

cmd.exe
/C set SVN_EDITOR="c:\Program Files\Notepad++\notepad++.exe" -multiInst -nosession&svn pe svn:externals %S&echo.Waiting 10 sec or press any key...&timeout /t 10 > nul

or

externals_edit.bat
%S

------------------------------------------------------------------------------
6. Open SVN Log for selected files and directories together.
------------------------------------------------------------------------------
(all windows together)

call_nowindow.vbs
scm\tortoisesvn\TortoiseProc.bat /command:log "%P" %S

------------------------------------------------------------------------------
7. Open TortoiseSVN status dialog for a set of WC directories (always opens to show unversioned changes).
------------------------------------------------------------------------------

------------------------------------------------------------------------------
7.1. Method #1. (By default if no -window-per-*/-all-in-one flags) One window for all WC directories with or without versioned changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -all-in-one /command:repostatus "%P" %S

or

call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat /command:repostatus "%P" %S

------------------------------------------------------------------------------
7.2. Method #2. Window per unique repository root with or without versioned changes in respective WC directory.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-reporoot /command:repostatus "%P" %S

------------------------------------------------------------------------------
7.3. Method #3. Window per command line WC directory with or without versioned changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcdir /command:repostatus "%P" %S

------------------------------------------------------------------------------
7.4. Method #4. Window per WC root directory with or without versioned changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcroot /command:repostatus "%P" %S

------------------------------------------------------------------------------
8. Open TortoiseSVN commit dialogs for a set of WC directories (opens only if has not empty versioned changes).
------------------------------------------------------------------------------

------------------------------------------------------------------------------
8.1. Method #1. (By default if no -window-per-*/-all-in-one flags) Window per unique repository root with changes in respective WC directory.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-reporoot /command:commit "%P" %S

or

call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat /command:commit "%P" %S

------------------------------------------------------------------------------
8.2. Method #2. One window for all WC directories with changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -all-in-one /command:commit "%P" %S

------------------------------------------------------------------------------
8.3. Method #3. Window per command line WC directory with changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcdir /command:commit "%P" %S

------------------------------------------------------------------------------
8.4. Method #4. Window per WC root directory with changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcroot /command:commit "%P" %S

------------------------------------------------------------------------------
9. One pane comparison for 2 selected files.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
9.1. Method #1. By path list from ANSI text file.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_files_by_list.bat -wait "%P" %L

------------------------------------------------------------------------------
9.2. Method #2. By path list from command line.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_files.bat -wait "%P" %S

------------------------------------------------------------------------------
10. One pane comparison for 2 selected files with sorted content.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
10.1. Method #1. By path list from ANSI text file.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_sorted_files_by_list.bat -wait "%P" %L

------------------------------------------------------------------------------
10.2. Method #2. By path list from command line.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_sorted_files.bat -wait "%P" %S

------------------------------------------------------------------------------
11. Shell/SVN/GIT files batch move
------------------------------------------------------------------------------

------------------------------------------------------------------------------
11.1. Method #1. Move files by selection list from ANSI text file.
------------------------------------------------------------------------------

For Shell:

call.vbs
scm\shell\shell_move_files_by_list.bat "%P" %L

For SVN:

call.vbs
scm\svn\svn_move_files_by_list.bat "%P" %L

For GIT:

call.vbs
scm\git\git_move_files_by_list.bat "%P" %L

------------------------------------------------------------------------------
11.2. Method #2. Move files by selection list from UNICODE text file.
------------------------------------------------------------------------------

For Shell:

call.vbs
scm\shell\shell_move_files_by_list.bat -from_utf16 "%P" %WL

For SVN:

call.vbs
scm\svn\svn_move_files_by_list.bat -from_utf16 "%P" %WL

For GIT:

call.vbs
scm\git\git_move_files_by_list.bat -from_utf16 "%P" %WL

------------------------------------------------------------------------------
12. Shell/SVN/GIT files batch rename
------------------------------------------------------------------------------

------------------------------------------------------------------------------
12.1. Method #1. Rename files by selection list from ANSI text file.
------------------------------------------------------------------------------

For Shell:

call.vbs
scm\shell\shell_rename_files_by_list.bat "%P" %L

For SVN:

call.vbs
scm\svn\svn_rename_files_by_list.bat "%P" %L

For GIT:

call.vbs
scm\git\git_rename_files_by_list.bat "%P" %L

------------------------------------------------------------------------------
12.2. Method #2. Rename files by selection list from UNICODE text file.
------------------------------------------------------------------------------

For Shell:

call.vbs
scm\shell\shell_rename_files_by_list.bat -from_utf16 "%P" %WL

For SVN:

call.vbs
scm\svn\svn_rename_files_by_list.bat -from_utf16 "%P" %WL

For GIT:

call.vbs
scm\git\git_rename_files_by_list.bat -from_utf16 "%P" %WL

------------------------------------------------------------------------------
13. Shell/SVN/GIT files batch copy
------------------------------------------------------------------------------

------------------------------------------------------------------------------
13.1. Method #1. Copy files by selection list from ANSI text file.
------------------------------------------------------------------------------

For Shell:

call.vbs
scm\shell\shell_copy_files_by_list.bat "%P" %L

For SVN:

call.vbs
scm\svn\svn_copy_files_by_list.bat "%P" %L

For GIT:

call.vbs
scm\git\git_copy_files_by_list.bat "%P" %L

------------------------------------------------------------------------------
13.2. Method #2. Copy files by selection list from UNICODE text file.
------------------------------------------------------------------------------

For Shell:

call.vbs
scm\shell\shell_copy_files_by_list.bat -from_utf16 "%P" %WL

For SVN:

call.vbs
scm\svn\svn_copy_files_by_list.bat -from_utf16 "%P" %WL

For GIT:

call.vbs
scm\git\git_copy_files_by_list.bat -from_utf16 "%P" %WL

------------------------------------------------------------------------------
14. Create batch directories
------------------------------------------------------------------------------

------------------------------------------------------------------------------
14.1. Method #1. Create directories in current directory by list from ANSI text file.
------------------------------------------------------------------------------

call.vbs
create_dirs_by_list.bat "%P"

------------------------------------------------------------------------------
14.2. Method #2. Create directories in selected directories by list from ANSI text file.
------------------------------------------------------------------------------

call.vbs
create_dirs_by_list.bat "%P" %L

------------------------------------------------------------------------------
14.3. Method #3. Create directories in current directory by list from UNICODE text file.
------------------------------------------------------------------------------

call.vbs
create_dirs_by_list.bat -from_utf16 "%P"

------------------------------------------------------------------------------
14.4. Method #4. Create directories in selected directories by list from UNICODE text file.
------------------------------------------------------------------------------

call.vbs
create_dirs_by_list.bat -from_utf16 "%P" %WL

------------------------------------------------------------------------------
15. Create batch empty files
------------------------------------------------------------------------------

------------------------------------------------------------------------------
15.1. Method #1. Create empty files in current directory by list from ANSI text file.
------------------------------------------------------------------------------

call.vbs
create_empty_files_by_list.bat "%P"

------------------------------------------------------------------------------
15.2. Method #2. Create empty files in selected directories by list from ANSI text file.
------------------------------------------------------------------------------

call.vbs
create_empty_files_by_list.bat "%P" %L

------------------------------------------------------------------------------
15.3. Method #3. Create empty files in current directory by list from UNICODE text file.
------------------------------------------------------------------------------

call.vbs
create_empty_files_by_list.bat -from_utf16 "%P"

------------------------------------------------------------------------------
15.4. Method #4. Create empty files in selected directories by list from UNICODE text file.
------------------------------------------------------------------------------

call.vbs
create_empty_files_by_list.bat -from_utf16 "%P" %WL

------------------------------------------------------------------------------
16. Concatenate video files
------------------------------------------------------------------------------

call.vbs
converters\ffmpeg\ffmpeg_convert_by_list.bat -wait -pause_on_exit %L "%T"

------------------------------------------------------------------------------
17. AUTHOR
------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
