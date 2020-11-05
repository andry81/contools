* README_EN.txt
* 2020.08.31
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

* `reopen_all_files.py` -

  script to workaround the Notepad++ bug:
    `[Feature Request] Language auto detection from simplified session file`:
    https://github.com/notepad-plus-plus/notepad-plus-plus/issues/5844

* `toggle_readonly_flag_for_all_tabs.py` -

  script to toggle the Read-Only flag for all TABS (not files)

* `clear_readonly_flag_from_all_files.py` -

  script to clear the Read-Only flag from all TAB FILES

* `startup.py` -

  script to call upon the Notepad++ instance launch.

-------------------------------------------------------------------------------
3. USAGE
-------------------------------------------------------------------------------
Basically, `startup.py` will automatically call upon start of each Notepad++
instance.
All other scripts can be directly used from the Notepad++ Plugins menu.

-------------------------------------------------------------------------------
4. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
