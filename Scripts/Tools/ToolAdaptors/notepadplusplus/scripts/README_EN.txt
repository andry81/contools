* README_EN.txt
* 2023.10.10
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
    Use the 32 bit Notepad++ version because of the 64 bit still is not
    ready on a moment.

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

`-z -append`

  Append mode.
  Runs Notepad++ as a launcher instance to delegate files opening to child
  Notepad++ process(es). If a Notepad++ instance already has been running, then
  appends files to existing Notepad++ instance, otherwise opens a new window
  instance. If files has appended to existing Notepad++ instance, then after
  that the launcher does by default auto close.

`-z -restore_single_instance`

  Has meaning in the append mode, when the Notepad++ instance does auto close
  at the end. If there were no other instances, then the Notepad++ does restore
  the window show state (for example, unminimizes).
  Useful in case when user want to hide the window blinking.

`-z --child_cmdline_len_limit -z 4096`

  Has meaning in the append mode.
  Reduces maximum command line length limit which is 32767 as by default.
  The launcher Notepad++ instance builds each command line until this limit and
  only after runs it.
  To append each file by a separate child Notepad++ process you can set it to
  1.

`-z -no_exit_after_append`

  Do not auto close the launcher Notepad++ instance in case of append mode.
  Useful to debug the launcher on Python errors from the console.

For the rest options see the `npplib.py` script file.

-------------------------------------------------------------------------------
4. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
