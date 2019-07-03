* README_EN.txt
* 2019.07.03
* Toolbar buttons configuration for the Total Commander.

1. CONFIGURE
1.1 Configure into outter directory
1.2 Configure into inner directory

2. CONFIGURATION STORAGE FILES

3. DESCRIPTION ON SCRIPTS USAGE

3.1 OPEN A NOTEPAD WINDOW INDEPENDENTLY TO SELECTED FILES

3.2. Open standalone notepad window for selected files
3.2.1. Method #1. On left mouse button.
3.2.2. Method #2. On left mouse button.

3.3. Open selected files in existing Notepad++ window
3.3.1. Method #1. On left mouse button.
3.3.2. Method #2. On left mouse button.

3.4. Open Administator console window in current directory
3.4.1. Method #1. On left mouse button. Total Commander bitness independent.
3.4.2. Method #2. On left mouse button. Total Commander bitness dependent.
3.4.3. Method #3. On right mouse button -> As Administrator.
3.4.4. Method #4. On left mouse button.
3.4.5. Method #5. Call command cmda.bat and Administrator password after.

3.5. Edit SVN externals (SVN properties)
3.5.1. Method #1. By path list from ANSI text file over SVN GUI.
3.5.2. Method #2. By path list from UNICODE text file over SVN GUI.
3.5.3. Method #3. By path list from command line over SVN GUI.
3.5.4. Method #4. By path list from command line one by one over external editor.

3.6. Open SVN Log for selected files and directories together

3.7. Open TortoiseSVN status dialog for a set of WC directories (always opens to show unversioned changes).
3.7.1. Method #1. (By default if no -window-per-*/-all-in-one flags) One window for all WC directories with or without versioned changes.
3.7.2. Method #2. Window per unique repository root with or without versioned changes in respective WC directory.
3.7.3. Method #3. Window per command line WC directory with or without versioned changes.
3.7.4. Method #4. Window per WC root directory with or without versioned changes.

3.8. Open TortoiseSVN commit dialogs for a set of WC directories
3.8.1. Method #1. (By default if no -window-per-*/-all-in-one flags) Window per unique repository root with changes in respective WC directory.
3.8.2. Method #2. One window for all WC directories with changes.
3.8.3. Method #3. Window per command line WC directory with changes.
3.8.4. Method #4. Window per WC root directory with changes.

3.9. One pane comparison for 2 selected files
3.9.1. Method #1. By path list from ANSI text file.
3.9.2. Method #2. By path list from command line.

3.10. One pane comparison for 2 selected files with sorted content
3.10.1. Method #1. By path list from ANSI text file.
3.10.2. Method #2. By path list from command line.

3.11. Shell/SVN/GIT files batch move
3.11.1. Method #1. Move files by selection list from ANSI text file.
3.11.2. Method #2. Move files by selection list from UNICODE text file.

3.12. Shell/SVN/GIT files batch rename
3.12.1. Method #1. Rename files by selection list from ANSI text file.
3.12.2. Method #2. Rename files by selection list from UNICODE text file.

3.13. Shell/SVN/GIT files batch copy
3.13.1. Method #1. Copy files by selection list from ANSI text file.
3.13.2. Method #2. Copy files by selection list from UNICODE text file.

3.14. Shell file to files copy by list
3.14.1. Method #1. Shell file to files copy by ANSI list
3.14.2. Method #2. Shell file to files copy by UNICODE list

3.15. Create batch directories
3.15.1. Method #1. Create directories in current directory by list from ANSI text file.
3.15.2. Method #2. Create directories in selected directories by list from ANSI text file.
3.15.3. Method #3. Create directories in current directory by list from UNICODE text file.
3.15.4. Method #4. Create directories in selected directories by list from UNICODE text file.

3.16. Create batch empty files
3.16.1. Method #1. Create directories in current directory by list from ANSI text file.
3.16.2. Method #2. Create directories in selected directories by list from ANSI text file.
3.16.3. Method #3. Create directories in current directory by list from UNICODE text file.
3.16.4. Method #4. Create directories in selected directories by list from UNICODE text file.

3.17. Concatenate video files

3.18. Save/Load file selection list to/from a saveload slot
3.18.1. Save file selection list to a saveslot
3.18.2. Load file selection list from a saveslot

4. AUTHOR

------------------------------------------------------------------------------
1. CONFIGURE
------------------------------------------------------------------------------

To configure into an outter directory do run the `configure.bat` with at least
first parameter - path to the outter directory.

To configure into an inner directory do run the `configure.bat` without
parameters.

CAUTION:
  To use saveload feature to load file selection list from file path lists you
  must execute the steps introduced in the
  `Load file selection list from a saveslot` section of this file!

------------------------------------------------------------------------------
1.1 Configure into outter directory
------------------------------------------------------------------------------

The `configure.bat` script will copy all scripts and dependencies into outter
directory.

------------------------------------------------------------------------------
1.2 Configure into inner directory
------------------------------------------------------------------------------

The `configure.bat` script will copy dependencies into inner directories.
The `contools` project `Scripts/Tools` subdirectory must already exist or been
copied as is because the script would copy files and subdirectories from it.

------------------------------------------------------------------------------
2. CONFIGURATION STORAGE FILES
------------------------------------------------------------------------------

All scripts below would work only if all configuration files would store
correct configuration variables. These configurations files are:

* `profile.vars`

The distribution contains only an example of configuration variables, all the
rest you should figure out on your own.

------------------------------------------------------------------------------
3. DESCRIPTION ON SCRIPTS USAGE
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.1. Open a notepad window independently to selected files.
------------------------------------------------------------------------------

For Notepad++:

call_nowindow.vbs
notepad_edit_files.bat -wait -npp -multiInst -nosession "%P"

For Windows Notepad:

call_nowindow.vbs
notepad_edit_files.bat "%P"

------------------------------------------------------------------------------
3.2. Open standalone notepad window for selected files.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.2.1. Method #1 On left mouse button.
------------------------------------------------------------------------------
(Console window is hidden (no flickering))

For Notepad++:

call_nowindow.vbs
notepad_edit_files.bat -wait -npp -nosession -multiInst "%P" %S

For Windows Notepad:

call_nowindow.vbs
notepad_edit_files.bat "%P" %S

------------------------------------------------------------------------------
3.2.2. Method #2. On left mouse button.
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
3.3. Open selected files in existing Notepad++ window.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.3.1. Method #1. On left mouse button.
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
3.3.2. Method #2. On left mouse button.
------------------------------------------------------------------------------
(Console window appears on a moment (flickering))

call_nowindow.vbs
notepad_edit_files.bat -npp -nosession "%P" %S

------------------------------------------------------------------------------
3.4. Open Administator console window in current directory.
------------------------------------------------------------------------------
CAUTION:
1. Windows can create virtualized `sysnative` directory itself after install or after update rollup with reduced privilege rights, where, for example,
   we can not start `sysnative/cmd.exe` under administrator user.
2. Virtualized `sysnative` directory visible ONLY from 32-bit applications.

For above reasons we should create another directory may be additionally to the `sysnative` one which is:

1. Visible from any application bitness mode.
2. No specific privilege rights restriction by the system and cmd.exe executable from there can be run under administrator user w/o any additional manipulations.

------------------------------------------------------------------------------
3.4.1. Method #1. On left mouse button. Total Commander bitness independent.
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
3.4.2. Method #2. On left mouse button. Total Commander bitness dependent.
------------------------------------------------------------------------------
(In Window x64 will open cmd.exe which bitness will be dependent on
Total Commander bitness)
(may be in some cases it won't work, for example, command "pip install pip --upgrade" in Python 3.5 in Windows 7 x86 responds as "access denided")
(correction: may be the error is an error of Python, the internet advises to run command as: "python -m pip install --upgrade")

cmd_admin.lnk
/K set "PWD=%P"&call cd /d "%%PWD%%"

------------------------------------------------------------------------------
3.4.3. Method #2. On right mouse button -> As Administrator.
------------------------------------------------------------------------------

cmd.exe
/K set "PWD=%P"&call cd /d "%%PWD%%"

------------------------------------------------------------------------------
3.4.4. Method #3. On left mouse button.
------------------------------------------------------------------------------
(may be in some cases it won't work, for example, command "netsh winhttp reset proxy" in Windows 7 x86 responds as "access denided")
(in not english version of Windows instead of the "Administrator" you have to use a localized name)

runas
/user:Administrator "cmd.exe /K set \"PWD=%P\\"&call cd /d \"%%PWD%%\"&title User: ^<Administrator^>"

or

cmd_as_user.bat
Administrator "%P"

------------------------------------------------------------------------------
3.4.5. Method #4. Call command cmda.bat and Administrator password after.
------------------------------------------------------------------------------
(cmda.user.bat by default cantains a localized group name of Administrators which uses to take first Administrator name for the console
if cmda.bat didn't have that name at first argument)

cmda.bat
"<Administrator name>"

------------------------------------------------------------------------------
3.5. Edit SVN externals (SVN properties).
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.5.1. Method #1. By path list from ANSI text file over SVN GUI.
------------------------------------------------------------------------------
(all windows together)

call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByList.bat /command:properties "%P" %L

------------------------------------------------------------------------------
3.5.2. Method #2. By path list from UNICODE text file over SVN GUI.
------------------------------------------------------------------------------
(all windows together)

call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByList.bat -from_utf16 /command:properties "%P" %WL

------------------------------------------------------------------------------
3.5.3. Method #3. By path list from command line over SVN GUI.
------------------------------------------------------------------------------
(all windows together)

call_nowindow.vbs
scm\tortoisesvn\TortoiseProc.bat /command:properties "%P" %S

------------------------------------------------------------------------------
3.5.4. Method #4. By path list from command line one by one over external editor.
------------------------------------------------------------------------------
(one notepad window at a time)

cmd.exe
/C set SVN_EDITOR="c:\Program Files\Notepad++\notepad++.exe" -multiInst -nosession&svn pe svn:externals %S&echo.Waiting 10 sec or press any key...&timeout /t 10 > nul

or

externals_edit.bat
%S

------------------------------------------------------------------------------
3.6. Open SVN Log for selected files and directories together.
------------------------------------------------------------------------------
(all windows together)

call_nowindow.vbs
scm\tortoisesvn\TortoiseProc.bat /command:log "%P" %S

------------------------------------------------------------------------------
3.7. Open TortoiseSVN status dialog for a set of WC directories (always opens to show unversioned changes).
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.7.1. Method #1. (By default if no -window-per-*/-all-in-one flags) One window for all WC directories with or without versioned changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -all-in-one /command:repostatus "%P" %S

or

call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat /command:repostatus "%P" %S

------------------------------------------------------------------------------
3.7.2. Method #2. Window per unique repository root with or without versioned changes in respective WC directory.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-reporoot /command:repostatus "%P" %S

------------------------------------------------------------------------------
3.7.3. Method #3. Window per command line WC directory with or without versioned changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcdir /command:repostatus "%P" %S

------------------------------------------------------------------------------
3.7.4. Method #4. Window per WC root directory with or without versioned changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcroot /command:repostatus "%P" %S

------------------------------------------------------------------------------
3.8. Open TortoiseSVN commit dialogs for a set of WC directories (opens only if has not empty versioned changes).
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.8.1. Method #1. (By default if no -window-per-*/-all-in-one flags) Window per unique repository root with changes in respective WC directory.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-reporoot /command:commit "%P" %S

or

call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat /command:commit "%P" %S

------------------------------------------------------------------------------
3.8.2. Method #2. One window for all WC directories with changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -all-in-one /command:commit "%P" %S

------------------------------------------------------------------------------
3.8.3. Method #3. Window per command line WC directory with changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcdir /command:commit "%P" %S

------------------------------------------------------------------------------
3.8.4. Method #4. Window per WC root directory with changes.
------------------------------------------------------------------------------
call_nowindow.vbs
scm\tortoisesvn\TortoiseProcByNestedWC.bat -window-per-wcroot /command:commit "%P" %S

------------------------------------------------------------------------------
3.9. One pane comparison for 2 selected files.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.9.1. Method #1. By path list from ANSI text file.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_files_by_list.bat -wait "%P" %L

------------------------------------------------------------------------------
3.9.2. Method #2. By path list from command line.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_files.bat -wait "%P" %S

------------------------------------------------------------------------------
3.10. One pane comparison for 2 selected files with sorted content.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.10.1. Method #1. By path list from ANSI text file.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_sorted_files_by_list.bat -wait "%P" %L

------------------------------------------------------------------------------
3.10.2. Method #2. By path list from command line.
------------------------------------------------------------------------------

call_nowindow.vbs
compare_sorted_files.bat -wait "%P" %S

------------------------------------------------------------------------------
3.11. Shell/SVN/GIT files batch move
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.11.1. Method #1. Move files by selection list from ANSI text file.
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
3.11.2. Method #2. Move files by selection list from UNICODE text file.
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
3.12. Shell/SVN/GIT files batch rename
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.12.1. Method #1. Rename files by selection list from ANSI text file.
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
3.12.2. Method #2. Rename files by selection list from UNICODE text file.
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
3.13. Shell/SVN/GIT files batch copy
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.13.1. Method #1. Copy files by selection list from ANSI text file.
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
3.13.2. Method #2. Copy files by selection list from UNICODE text file.
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
3.14. Shell file to files copy by list
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.14.1. Method #1. Shell file to files copy by ANSI list
------------------------------------------------------------------------------

call.vbs
copy_file_to_files_by_list.bat -from_file %P%N "<file_paths_list_file>"

------------------------------------------------------------------------------
3.14.2. Method #2. Shell file to files copy by UNICODE list
------------------------------------------------------------------------------

call.vbs
copy_file_to_files_by_list.bat -from_utf16 -from_file %P%N "<file_paths_list_file>"

------------------------------------------------------------------------------
3.15. Create batch directories
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.15.1. Method #1. Create directories in current directory by list from ANSI text file.
------------------------------------------------------------------------------

call.vbs
create_dirs_by_list.bat "%P"

------------------------------------------------------------------------------
3.15.2. Method #2. Create directories in selected directories by list from ANSI text file.
------------------------------------------------------------------------------

call.vbs
create_dirs_by_list.bat "%P" %L

------------------------------------------------------------------------------
3.15.3. Method #3. Create directories in current directory by list from UNICODE text file.
------------------------------------------------------------------------------

call.vbs
create_dirs_by_list.bat -from_utf16 "%P"

------------------------------------------------------------------------------
3.15.4. Method #4. Create directories in selected directories by list from UNICODE text file.
------------------------------------------------------------------------------

call.vbs
create_dirs_by_list.bat -from_utf16 "%P" %WL

------------------------------------------------------------------------------
3.16. Create batch empty files
------------------------------------------------------------------------------

------------------------------------------------------------------------------
3.16.1. Method #1. Create empty files in current directory by list from ANSI text file.
------------------------------------------------------------------------------

call.vbs
create_empty_files_by_list.bat "%P"

------------------------------------------------------------------------------
3.16.2. Method #2. Create empty files in selected directories by list from ANSI text file.
------------------------------------------------------------------------------

call.vbs
create_empty_files_by_list.bat "%P" %L

------------------------------------------------------------------------------
3.16.3. Method #3. Create empty files in current directory by list from UNICODE text file.
------------------------------------------------------------------------------

call.vbs
create_empty_files_by_list.bat -from_utf16 "%P"

------------------------------------------------------------------------------
3.16.4. Method #4. Create empty files in selected directories by list from UNICODE text file.
------------------------------------------------------------------------------

call.vbs
create_empty_files_by_list.bat -from_utf16 "%P" %WL

------------------------------------------------------------------------------
3.17. Concatenate video files
------------------------------------------------------------------------------

call.vbs
converters\ffmpeg\ffmpeg_convert_by_list.bat -wait -pause_on_exit %L "%T"

------------------------------------------------------------------------------
3.18. Save/Load file selection list to/from a saveload slot
------------------------------------------------------------------------------

To be able to save and load file paths selection list in the Total Commander
for minimal steps or mouse clicks you have to make some preparations before the
usage.

------------------------------------------------------------------------------
3.18.1. Save file selection list to a saveslot
------------------------------------------------------------------------------

At first, you have to set all required variables in the `profile.vars`:

* SAVELOAD_ROOT
* SAVELOAD_FILE_LISTS_DIR

After that you can create the buttons:

For ANSI file paths:

call.vbs
save_file_list.bat -timeout_to_close_sec <timeout_to_close_sec> -to_file_name "<file_name>" "%P" %L

For UNICODE file paths:

call.vbs
save_file_list.bat -timeout_to_close_sec <timeout_to_close_sec> -to_file_name "<file_name>" "%P" %WL

Where:
  * `<file_name>` - file name with extension relative to the current
    directory `%P` there the file paths list would be saved.
  * `<timeout_to_close_sec>` - timeout in seconds before close a console
    window.

The files name must be by the same path as in the
`saveload_search_in_slot_<INDEX_STR>_SearchIn` variables in below section.

------------------------------------------------------------------------------
3.18.2. Load file selection list from a saveslot
------------------------------------------------------------------------------

At first, you have to create search template in your main configuration file of
the Total Commander in the section `[searches]`:

```
saveload_search_in_slot_<INDEX_STR>_SearchFor=*.*
saveload_search_in_slot_<INDEX_STR>_SearchIn=@c:\Total Commander Scripts\.saveload\file_lists\<INDEX_STR>.lst
saveload_search_in_slot_<INDEX_STR>_SearchText=
saveload_search_in_slot_<INDEX_STR>_SearchFlags=0|103002010021|||||||||0000|||
```

Where the `<INDEX_STR>` can be any index string (for example, from `00` up to
`99`) and the path `c:\Total Commander Scripts\.saveload\file_lists` is an
arbitraty directory there all lists would be saved to and loaded from. You can
create multiple arbitrary empty files in that directory using another command
described here in the section `Create batch empty files`.

NOTE:
  The prefix string `saveload_search_in_slot_<INDEX_STR>` is a search template
  name in the `Find Files` dialog in the Total Commander. So instead of adding
  the string in the `[searches]` section, you may create all respective
  templates through the same dialog from the `Load/Save` tab using the same
  values from the example above.

After that you can create any arbitrary number of buttons, but I recommend to
you to create 5 or 10 buttons, not more:

LOADSEARCH saveload_search_in_slot_<INDEX_STR>

Then you can click on the button to open the respective `Find Files` dialog.
Next click to the find button would show the last saved file paths list which
you can feed to the Total Commander last active panel.

------------------------------------------------------------------------------
4. AUTHOR
------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
