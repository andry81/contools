# pure python module for commands w/o extension modules usage (xonsh, cmdix and others)

import os, sys, re, imp#importlib

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

# error print
def print_err(*args, **kwargs):
  print(*args, file=sys.stderr, **kwargs)

def extract_urls(str):
  urls = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', str.lower())
  urls_arr = []
  for url in urls:
    lastChar = url[-1] # get the last character
    # if the last character is not (^ - not) an alphabet, or a number,
    # or a '/' (some websites may have that. you can add your own ones), then enter IF condition
    if (bool(re.match(r'[^a-zA-Z0-9/]', lastChar))): 
      urls_arr.append(url[:-1]) # stripping last character, no matter what
    else:
      urls_arr.append(url) # else, simply append to new list
  return urls_arr
