* README_EN.txt
* 2016.10.29
* Command buttons configuration in the Total Commander v8.

1. Open standalone notepad window for selected files.
2.1. Method #1 (Main). On left mouse button.
2.2. Method #2. On left mouse button.
2. Open Administator console window in current directory.
2.1. Method #1 (Main). On left mouse button.
2.2. Method #2. On right mouse button -> As Administrator.
2.3. Method #3. On left mouse button.
2.4. Method #4. Call command cmda.bat and Administrator password after.
3. Edit SVN externals (SVN properties).
3.1 Method #1 (Main). For selected files and directories together over SVN GUI.
3.2 Method #2. For selected files and directores one after one over external editor.
4. Open SVN Log for selected files and directories together.
5. One pane comparison for 2 selected files.
6. One pane comparison for 2 selected files with sorted content.

------------------------------------------------------------------------------
1. Open standalone notepad window for selected files.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
2.1. Method #1 (Main). On left mouse button.
------------------------------------------------------------------------------
(Console window is hidden (no flickering))

cmd_noconsole.vbs
notepad_edit_files.bat -wait "%P" %S

------------------------------------------------------------------------------
2.2. Method #2. On left mouse button.
------------------------------------------------------------------------------
(Console window appears on a moment (flickering))

notepad_edit_files.bat
"%P" %S

------------------------------------------------------------------------------
2. Open Administator console window in current directory.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
2.1. Method #1 (Main). On left mouse button.
------------------------------------------------------------------------------
(may be in some cases it won't work, for example, command "pip install pip --upgrade" in Python 3.5 in Windows 7 x86 responds as "access denided")
(correction: may be the error is an error of Python, the internet advises to run command as: "python -m pip install --upgrade")

cmd_admin.lnk
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

------------------------------------------------------------------------------
2.2. Method #2. On right mouse button -> As Administrator.
------------------------------------------------------------------------------

cmd.exe
/K set "PWD=%P"&call %%PWD:~0,2%%&call cd "%%PWD%%"

------------------------------------------------------------------------------
2.3. Method #3. On left mouse button.
------------------------------------------------------------------------------
(may be in some cases it won't work, for example, command "netsh winhttp reset proxy" in Windows 7 x86 responds as "access denided")
(in not english version of Windows instead of the "Administrator" you have to use a localized name)

runas
/user:Administrator "cmd.exe /K set \"PWD=%P\\"&call %%PWD:~0,2%%&call cd \"%%PWD%%\"&title User: ^<Administrator^>"

or

cmd_as_user.bat
Administrator "%P"

------------------------------------------------------------------------------
2.4. Method #4. Call command cmda.bat and Administrator password after.
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

TortoiseProc.bat
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

TortoiseProc.bat
/command:log "%P" %S

------------------------------------------------------------------------------
5. One pane comparison for 2 selected files.
------------------------------------------------------------------------------

cmd_noconsole.vbs
compare_files.bat -wait "%P" %S

------------------------------------------------------------------------------
6. One pane comparison for 2 selected files with sorted content.
------------------------------------------------------------------------------

cmd_noconsole.vbs
compare_sorted_files.bat -wait "%P" %S
