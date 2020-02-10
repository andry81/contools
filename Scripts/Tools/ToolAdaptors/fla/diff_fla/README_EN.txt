* README_EN.txt
* 2013.08.11
* diff_fla

1. DESCRIPTION
2. LICENSE
3. FILE SET
4. REQUIREMENTS
5. INSTALLATION AND INTEGRATION
6. USAGE
6.1. Perforce
7. KNOWN ISSUES
7.1. Click on the Perforce "Diff ..." item from the context menu doesn't invoke
     the Adove Flash CS3
8. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
The script set to compare 2 fla files in Abobe Flash CS3 environment. Includes
batch script for Perforce integration.

-------------------------------------------------------------------------------
2. LICENSE
-------------------------------------------------------------------------------
The Boost license (see included text file "license.txt" or
http://www.boost.org/users/license.html)

-------------------------------------------------------------------------------
3. FILE SET
-------------------------------------------------------------------------------
* FlaToXML.jsfl:
  xml generator, uses Adobe Flash GUI to produce xml-s.
* diff_perforce.py:
  python comparator, uses xml generator and compares 2 xml using p4merge tool.
* diff_perforce.bat:
  python comparator wrapper, invokes from the Perforce GUI application.

-------------------------------------------------------------------------------
4. REQUIREMENTS
-------------------------------------------------------------------------------
* Python interpretator:
  The scripts tested with Active State python interpretator version 2.7.x
  (http://www.activestate.com/activepython).
* Adobe Flash CS3
  You have to install it into the registry to make the application accessable
  from the scripts. See the Python script for the details.

-------------------------------------------------------------------------------
5. INSTALLATION AND INTEGRATION
-------------------------------------------------------------------------------
You do have to install all dependencies from the REQUIREMENTS section before
use the scripts.

For manual integration you do not need all 3 scripts, only 2 of them: jsfl+py.
But for the Perforce integration you have to manually add a custom compare tool
into the Perforce GUI (for example,
see http://stackoverflow.com/questions/2989089/how-to-use-a-custom-compare-tool-with-perforce).

Put as extension the ".fla" and set path to the bat file.
Because bat file uses it's own logic to find the Python interpretator, you have
several choices to help it to find the Python:
1. Add path to the python interpretator directory with executable to the PATH
   variable before call to the bat script
2. set PYTHON_INSTALL_PATH variable to the python interpretator directory with
   executable before call to the bat script
3. set PYTHON_EXEC_PATH variable to the python interpretator executable before
   call to the bat script

-------------------------------------------------------------------------------
6. USAGE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
6.1. Perforce
-------------------------------------------------------------------------------
Use "Diff ..." menu item from the context menu on any versioned fla file to
initiate fla files comparison.

-------------------------------------------------------------------------------
7. KNOWN ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
7.1. Click on the Perforce "Diff ..." item from the context menu doesn't invoke
     the Adove Flash CS3
-------------------------------------------------------------------------------
You have several choices:
1. Close all dialog windows in the Adove Flash GUI instance before the call
2. Terminate all instances of the Adove Flash GUI before the call
3. Restart the Perforce GUI

-------------------------------------------------------------------------------
8. AUTHOR
-------------------------------------------------------------------------------
timrobinson007 at gmail dot com
andry at inbox dot ru
