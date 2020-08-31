* README_EN.txt
* 2020.02.10
* contools/python

1. DESCRIPTION
2. SCRIPTS
3. USAGE
4. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Set of scripts for the python application maintains.

-------------------------------------------------------------------------------
2. SCRIPTS
-------------------------------------------------------------------------------
`rebuild_portable_pycache.bat` -
  to recompile .pyc files in a particular directory

`copy_pycache.bat` -
  to copy .pyc files into places of .py files.

-------------------------------------------------------------------------------
3. USAGE
-------------------------------------------------------------------------------
1. Make a copy of the directory you want to recompile. For example, if this is
   the `c:\python35-32\Lib\site-packages` directory then copy it into,
   for example, `c:\python35-32\Lib\site-packages.rebuilt`.
2. Run the `rebuild_portable_pycache.bat` as:
   `call rebuild_portable_pycache.bat "c:\python35-32" "c:\python35-32\Lib\site-packages.rebuilt"`
3. Create new directory:
  `c:\python35-32\Lib\site-packages.portable`
4. Run the `copy_pycache.bat` as:
   `call copy_pycache.bat "c:\python35-32\Lib\site-packages.rebuilt" "c:\python35-32\Lib\site-packages.portable"`

Now the `c:\python35-32\Lib\site-packages.portable` contains the portable
version of the .pyc files from the `c:\python35-32\Lib\site-packages` directory.
You can copy it into the site-packages archive of the python portable
distribution - `python35.zip`.

-------------------------------------------------------------------------------
4. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
