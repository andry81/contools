* README_EN.txt
* 2017.06.07
* Toolbar buttons configuration for the Total Commander.

1. Open standalone notepad window for selected files.
2.1. Method #1. On left mouse button.
2.2. Method #2. On left mouse button.
2. Open Administator console window in current directory.
2.1. Method #1. On left mouse button. Total Commander bitness independent.
2.2. Method #2. On left mouse button. Total Commander bitness dependent.
2.3. Method #3. On right mouse button -> As Administrator.
2.4. Method #4. On left mouse button.
2.5. Method #5. Call command cmda.bat and Administrator password after.
3. Edit SVN externals (SVN properties).
3.1 Method #1 (Main). For selected files and directories together over SVN GUI.
3.2 Method #2. For selected files and directores one after one over external editor.
4. Open SVN Log for selected files and directories together.
5. Open TortoiseSVN commit dialogs for a directory separately for all nested versioned directories.
5.1. Method #1. One windows for all nested directories with changes.
5.2. Method #2. Window per each nested directory with changes.
6. Open TortoiseSVN status dialog for a directory including all nested versioned directories.
6.1. Method #1. One windows for all nested directories.
6.2. Method #2. Window per each nested directory.
7. One pane comparison for 2 selected files.
8. One pane comparison for 2 selected files with sorted content.

------------------------------------------------------------------------------
1. Open standalone notepad window for selected files.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
2.1. Method #1 On left mouse button.
------------------------------------------------------------------------------
(Console window is hidden (no flickering))

For Notepad++:

cmd_noconsole.vbs
notepad_edit_files.bat -wait -npp -nosession "%P" %S

For Windows Notepad:

cmd_noconsole.vbs
notepad_edit_files.bat "%P" %S

------------------------------------------------------------------------------
2.2. Method #2. On left mouse button.
------------------------------------------------------------------------------
(Console window appears on a moment (flickering))

For Notepad++:

notepad_edit_files.bat -npp -nosession
"%P" %S

For Windows Notepad:

notepad_edit_files.bat
"%P" %S

------------------------------------------------------------------------------
2. Open Administator console window in current directory.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
2.1. Method #1. On left mouse button. Total Commander bitness independent.
------------------------------------------------------------------------------
(may be in some cases it won't work, for example, command "pip install pip --upgrade" in Python 3.5 in Windows 7 x86 responds as "access denided")
(correction: may be the error is an error of Python, the internet advises to run command as: "python -m pip install --upgrade")

In the Window x64 open 64-bit console window and type:
  mklink /D "%SystemRoot%\Sysnative\cmd.exe" "%COMSPEC%"

This will create the directory link to 64-bit cmd.exe available from the 32-bit
process.

For 64-bit cmd.exe button under Windows x64:

cmd_sysnative_admin.lnk
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

For 32-bit cmd.exe button under Windows x64:

cmd_syswow64_admin.lnk
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

For cmd.exe button under Windows x32:

cmd_admin.lnk
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

------------------------------------------------------------------------------
2.2. Method #2. On left mouse button. Total Commander bitness dependent.
------------------------------------------------------------------------------
(In Window x64 will open cmd.exe which bitness will be dependent on
Total Commander bitness)
(may be in some cases it won't work, for example, command "pip install pip --upgrade" in Python 3.5 in Windows 7 x86 responds as "access denided")
(correction: may be the error is an error of Python, the internet advises to run command as: "python -m pip install --upgrade")

cmd_admin.lnk
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

------------------------------------------------------------------------------
2.3. Method #2. On right mouse button -> As Administrator.
------------------------------------------------------------------------------

cmd.exe
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

------------------------------------------------------------------------------
2.4. Method #3. On left mouse button.
------------------------------------------------------------------------------
(may be in some cases it won't work, for example, command "netsh winhttp reset proxy" in Windows 7 x86 responds as "access denided")
(in not english version of Windows instead of the "Administrator" you have to use a localized name)

runas
/user:Administrator "cmd.exe /K set \"PWD=%P\\"&call %%PWD:~0,2%%&call cd \"%%PWD%%\"&title User: ^<Administrator^>"

or

cmd_as_user.bat
Administrator "%P"

------------------------------------------------------------------------------
2.5. Method #4. Call command cmda.bat and Administrator password after.
------------------------------------------------------------------------------
(cmda.user.bat by default cantains a localized group name of Administrators which uses to take first Administrator name for the console
if cmda.bat didn't have that name at first argument)

cmda.bat
"<Administrator name>"

------------------------------------------------------------------------------
3. Edit SVN externals (SVN properties).
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.1 Method #1 (Main). For selected files and directories together over SVN GUI.
------------------------------------------------------------------------------
(all windows together)

tortoisesvn\TortoiseProc.bat
/command:properties "%P" %S

------------------------------------------------------------------------------
3.2 Method #2. For selected files and directores one after one over external editor.
------------------------------------------------------------------------------
(one notepad window at a time)

cmd.exe
/C set SVN_EDITOR="c:\Program Files\Notepad++\notepad++.exe" -multiInst -nosession&svn pe svn:externals %S&echo.Waiting 10 sec or press any key...&timeout /t 10 > nul

or

externals_edit.bat
%S

------------------------------------------------------------------------------
4. Open SVN Log for selected files and directories together.
------------------------------------------------------------------------------
(all windows together)

tortoisesvn\TortoiseProc.bat
/command:log "%P" %S

------------------------------------------------------------------------------
5. Open TortoiseSVN commit dialogs for a directory separately for all nested versioned directories.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
5.1. Method #1. One windows for all nested directories with changes.
------------------------------------------------------------------------------
tortoisesvn\TortoiseProcByNestedWC.bat
-all-in-one /command:commit "%P" %S

------------------------------------------------------------------------------
5.2. Method #2. Window per each nested directory with changes.
------------------------------------------------------------------------------
tortoisesvn\TortoiseProcByNestedWC.bat
-window-per-wcroot /command:commit "%P" %S

------------------------------------------------------------------------------
6. Open TortoiseSVN status dialog for a directory including all nested versioned directories.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
6.1. Method #1. One windows for all nested directories.
------------------------------------------------------------------------------
tortoisesvn\TortoiseProcByNestedWC.bat
-all-in-one /command:repostatus "%P" %S

------------------------------------------------------------------------------
6.2. Method #2. Window per each nested directory.
------------------------------------------------------------------------------
tortoisesvn\TortoiseProcByNestedWC.bat
-window-per-wcroot /command:repostatus "%P" %S

------------------------------------------------------------------------------
7. One pane comparison for 2 selected files.
------------------------------------------------------------------------------

cmd_noconsole.vbs
compare_files.bat -wait "%P" %S

------------------------------------------------------------------------------
8. One pane comparison for 2 selected files with sorted content.
------------------------------------------------------------------------------

cmd_noconsole.vbs
compare_sorted_files.bat -wait "%P" %S
