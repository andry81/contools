* README_EN.txt
* 2024.01.12
* contools/notepadplusplus

1. DESCRIPTION
2. INSTALLATION
3. SCRIPTS
4. USAGE
5. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Set of scripts for the Notepad++ Python Scripts plugin.

-------------------------------------------------------------------------------
2. INSTALLATION
-------------------------------------------------------------------------------

1. Install `PythonScript` plugin within the Notepad++ `Plugins` menu item.
   Note:
    Use the 32 bit Notepad++ version because the 64 bit still is not ready on
    the moment.

2. Copy scripts into `scripts` subdirectory inside the Notepad++ directory:
   `../plugins/Config/PythonScript`.

3. Change the initialization item from the PythonScript configuration menu
   item: `Plugins->Python Scripts->Configuration...`:
   From `LAZY` to `ATSTARTUP`

Now each time when the Notepad++ starts it will call to `startup.py` script.

-------------------------------------------------------------------------------
3. SCRIPTS
-------------------------------------------------------------------------------
* `/tacklebar/libs/npplib.py` -

  main library script.

* `/tacklebar/reopen_all_files.py` -

  script to workaround the Notepad++ bug:
    `[Feature Request] Language auto detection from simplified session file`:
    https://github.com/notepad-plus-plus/notepad-plus-plus/issues/5844

* `/tacklebar/toggle_readonly_flag_for_all_tabs.py` -

  script to toggle the Read-Only flag for all TABS (not files)

* `/tacklebar/clear_readonly_flag_from_all_files.py` -

  script to clear the Read-Only flag from all TAB FILES

* `startup.py` -

  script to call upon the Notepad++ instance launch.

-------------------------------------------------------------------------------
3. USAGE
-------------------------------------------------------------------------------
Basically, `startup.py` will automatically call upon start of each Notepad++
instance.
All other scripts can be directly used from the Notepad++ Plugins menu.

Examples of the Notepad++ extra command line:

>
notepad++.exe -nosession -multiInst -z -from_utf16 -z --open_from_file_list -z "<utf-16le-with-bom-paths-list-file>"

>
notepad++.exe -nosession -multiInst -z -from_utf16le -z --open_from_file_list -z "<utf-16le-without-bom-paths-list-file>"

Additionsl command line arguments:

`-z --open_short_path_if_gt_limit -z 258`

  Translates each path into a short DOS path if greater than the limit.
  Can workaround long path files open, which Notepad++ does not support.

  See the related long path issue:
    `Can not open long path files` :
    https://github.com/notepad-plus-plus/notepad-plus-plus/issues/9181

`-z -append`

  Append mode.
  Runs Notepad++ instance to either open the files from a list inplace or
  delegate files to open them in an already running Notepad++ process.
  If a Notepad++ instance already has been running and has no `-multiInst`
  parameter on the command line (shared instance), then the files delegates to
  open into that instance. After that the launched instance does auto close.
  If there is no Notepad++ instance without `-multiInst` parameter on the
  command line (not shared instance), then the files does open inplace.

`-z -restore_if_open_inplace`

  Has meaning in the append mode.
  If there were no shared instance without `-multiInst` on the command line,
  then the Notepad++ does restore the window show state (for example,
  unminimizes) before open inplace.
  Useful in case when the user want to hide the window blinking.

`-z --child_cmdline_len_limit -z 4096`

  Has meaning in the append mode and if `-z -append_by_child_instance` is used.
  Reduces maximum command line length limit which is 32767 as by default.
  In case of a delegated open the launched Notepad++ instance builds each
  command line until this limit and only after runs it.
  To append each file by a separate child Notepad++ process you can set it to
  1.

`-z -append_by_child_instance`

  Has meaning in the append mode.
  By default file open delegation made through the `WM_COPYDATA` +
  `COPYDATA_FILENAMESW` message as a most reliable. To replace it by a child
  process method use this option.

`-z -no_activate_after_append`

  Do not activate the Notepad++ instance main window in case of delegated open
  in the append mode.
  Useful to avoid window focus change after append.

`-z -no_exit_after_append`

  Do not auto close the launched Notepad++ instance in case of delegated open
  in the append mode.
  Useful to debug the launched instance on the Python errors from the console.

For the rest options see the `npplib.py` script file.

-------------------------------------------------------------------------------
4. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
