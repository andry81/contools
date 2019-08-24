# xonsh python module for commands with extension modules usage: cmdoplib, xonsh

import os, sys, xonsh, imp#importlib

### local import ###

def import_module(dir_path, module_name, ref_module_name = None):
  ### CAUTION: direct implementation, can not load modules directly from any arbitrary directory
  ##evalx('import "{0}"'.format(os.path.join(dir_path, module_name).replace('\\', '/')))

  ## CAUTION: implementation through the importlib, better than previous, but still can not load modules with periods in a file name
  module_file_path = os.path.join(dir_path, module_name).replace('\\', '/')
  #if sys.version_info[0] > 3 or sys.version_info[0] == 3 and sys.version_info[1] >= 4:
  #  #import_spec = importlib.machinery.PathFinder.find_spec(os.path.splitext(module_name)[0] if ref_module_name is None else ref_module_name, [os.path.dirname(module_file_path)])
  #  import_spec = importlib.util.spec_from_file_location(os.path.splitext(module_name)[0] if ref_module_name is None else ref_module_name, os.path.join(dir_path, module_name).replace('\\', '/'))
  #  import_module = importlib.util.module_from_spec(import_spec)
  #  import_spec.loader.exec_module(import_module)
  #else:
  #  # back compatability
  module_file, module_file_name, module_desc = imp.find_module(os.path.splitext(module_name)[0], [os.path.dirname(module_file_path)])
  globals()[module_name if ref_module_name is None else ref_module_name] = imp.load_module(module_file_path, module_file, module_file_name, module_desc)

import_module($CONTOOLS_ROOT, 'cmdoplib.py')

### functions ###

def source_module(dir_path, module_name):
  #source dir_path/module_name
  evalx('source r"{0}"'.format(os.path.join(dir_path, module_name).replace('\\', '/')))

# call from pipe
def pcall(args):
  args.pop(0)(*args)

# call from pipe w/o capture: https://xon.sh/tutorial.html#uncapturable-aliases
@xonsh.tools.uncapturable
def pcall_nocap(args):
  args.pop(0)(*args)

# /dev/null (Linux) or nul (Windows) replacement
def pnull(args, stdin=None):
  for line in stdin:
    pass
