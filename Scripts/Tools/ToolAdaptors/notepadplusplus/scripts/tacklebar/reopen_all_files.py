import sys, os, inspect
if sys.version_info[0] > 3 or sys.version_info[0] == 3 and sys.version_info[1] >= 4: # >= 3.4
  import importlib.util, importlib.machinery
else:
  import imp

# execute from the script directory
SOURCE_FILE = os.path.normcase(os.path.abspath(inspect.getsourcefile(lambda:0))).replace('\\','/')
SOURCE_DIR = os.path.dirname(SOURCE_FILE)

if 'importlib' in globals():
  npplib_spec = importlib.util.spec_from_loader('npplib', importlib.machinery.SourceFileLoader('npplib', SOURCE_DIR + '/libs/npplib.py'))
  npplib = importlib.util.module_from_spec(npplib_spec)
  npplib_spec.loader.exec_module(npplib)
else:
  npplib = imp.load_source('npplib', SOURCE_DIR + '/libs/npplib.py')

# inject globals
setattr(npplib, 'notepad', notepad)

# execute
npplib.reopen_all_files()
