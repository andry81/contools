from __future__ import print_function

def toggle_readonly_flag_for_all_tabs():
  print('toggle_readonly_flag_for_all_tabs:')

  all_files = notepad.getFiles()
  active_file = notepad.getCurrentFilename()

  num_toggled = 0

  for f in reversed(all_files):
    print("  - " + f)
    notepad.activateFile(f[0])
    notepad.menuCommand(MENUCOMMAND.EDIT_SETREADONLY)
    num_toggled += 1

  notepad.activateFile(active_file)

  print()
  print('* Number of toggled paths: '+ str(num_toggled))
  print()

def clear_readonly_flag_from_all_files():
  print('clear_readonly_flag_from_all_files:')

  all_files = notepad.getFiles()
  active_file = notepad.getCurrentFilename()

  num_cleared = 0

  for f in reversed(all_files):
    print("  - " + f)
    notepad.activateFile(f[0])
    notepad.menuCommand(MENUCOMMAND.EDIT_CLEARREADONLY)
    num_cleared += 1

  notepad.activateFile(active_file)

  print()
  print('* Number of cleared paths: ' + str(num_cleared))
  print()

def reopen_all_files():
  print('reopen_all_files:')

  all_files = list(notepad.getFiles())
  active_file = notepad.getCurrentFilename()

  notepad.saveAllFiles()
  notepad.closeAll()

  num_reopened = 0

  for f in all_files:
    print("  - " + f[0])
    notepad.open(f[0])
    num_reopened += 1

  # reactive in reverse order
  for f in reversed(all_files):
    notepad.activateFile(f[0])

  notepad.activateFile(active_file)

  print()
  print('* Number of reopened paths: ' + str(num_reopened))
  print()

def process_extra_command_line():
  import os, io, shlex

  print('process_extra_command_line:')

  cmdline_list = shlex.split(notepad.getCommandLine())

  from_utf8 = False
  from_utf16 = False
  from_utf16le = False
  from_utf16be = False

  open_from_file_list_path = ''
  next_arg_is_file_list_path = False

  open_path_len_limit = 0 # open as is
  next_arg_is_open_path_limit = False

  chdir_path = ''
  next_arg_is_chdir_path = False

  do_reopen_all_files = False

  for arg in cmdline_list:
    if arg == '-z':
      continue

    if next_arg_is_file_list_path:
      open_from_file_list_path = str(arg)
      next_arg_is_file_list_path = False
    elif next_arg_is_chdir_path:
      chdir_path = str(arg)
      next_arg_is_chdir_path = False
    elif next_arg_is_open_path_limit:
      open_path_len_limit = max(int(arg), 255) # 255 is builtin minimum
      next_arg_is_open_path_limit = False
      print('--open_short_path_if_gt_limit ' + str(open_path_len_limit))
    else:
      if arg == '-from_utf8':
        from_utf8 = True
      elif arg == '-from_utf16':
        from_utf16 = True
      elif arg == '-from_utf16le':
        from_utf16le = True
      elif arg == '-from_utf16be':
        from_utf16be = True
      elif arg == '--open_from_file_list':
        next_arg_is_file_list_path = True
      elif arg == '--open_short_path_if_gt_limit':
        next_arg_is_open_path_limit = True
      elif arg == '--chdir':
        next_arg_is_chdir_path = True
      elif arg == '-reopen_all_files':
        do_reopen_all_files = True

  num_opened = 0

  if chdir_path:
    os.chdir(chdir_path)
    print('--chdir: ' + chdir_path)

  if open_from_file_list_path:
    if open_path_len_limit > 0:
      import ctypes

    print('--open_from_file_list:')

    with open(open_from_file_list_path, 'rb') as file_list: # CAUTION: binary mode is required to correctly decode string into `utf-8` below
      file_content = file_list.read()

    # CAUTION:
    #   Do decode with explicitly stated encoding to avoid the error:
    #   `UnicodeDecodeError: 'charmap' codec can't decode byte ... in position ...: character maps to <undefined>`
    #   (see details: https://stackoverflow.com/questions/27453879/unicode-decode-error-how-to-skip-invalid-characters/27454001#27454001 )
    #
    recode_to_utf8 = False
    if from_utf8:
      file_content_decoded = file_content.decode('utf-8', errors = 'ignore')
      recode_to_utf8 = True
    elif from_utf16:
      file_content_decoded = file_content.decode('utf-16', errors = 'ignore')
      recode_to_utf8 = True
    elif from_utf16le:
      file_content_decoded = file_content.decode('utf-16-le', errors = 'ignore')
      recode_to_utf8 = True
    elif from_utf16be:
      file_content_decoded = file_content.decode('utf-16-be', errors = 'ignore')
      recode_to_utf8 = True
    else:
      file_content_decoded = file_content

    # To iterate over lines instead chars.
    # (see details: https://stackoverflow.com/questions/3054604/iterate-over-the-lines-of-a-string/3054898#3054898 )
    file_strings = io.StringIO(file_content_decoded)

    # CAUTION:
    #   The `win32api.GetShortPathName` awaits ascii format and unicode variant is not implemented in Python 2.7.
    #   So we must use `ctype` module to directly call `GetShowrtPathNameW` instead.
    #   For details:
    #     https://mail.python.org/pipermail/python-win32/2006-May/004697.html
    #
    #        John Machin irta:
    #     >     According to my reading of the source, the function you have called
    #     >     expects an 8-bit string.
    #     >     ====
    #     >     static PyObject *
    #     >     PyGetShortPathName(PyObject * self, PyObject * args)
    #     >     {
    #     >         char *path;
    #     >         if (!PyArg_ParseTuple(args, "s:GetShortPathName", &path))
    #     >     ====
    #     >     If it is given Unicode, PyArg_ParseTuple will attempt to encode it
    #     >     using the default encoding (ascii). Splat.
    #     >
    #     >     Looks like you need a GetShortPathNameW() but it's not implemented.
    #     >     Raise it as an issue on the pywin32 sourceforge bug register. Tell
    #     >     Mark
    #     >     I sent you :-)
    #     >
    #     >     It may be possible to fake up your default encoding to say cp1252 BUT
    #     >     take the advice of anyone who screams "Don't do that!" and in any
    #     >     case
    #     >     this wouldn't help you with a Russian, Chinese, etc etc filename.
    #     >
    #     >     Another thought: try using ctypes.
    #     >

    file_path_unc_prefix_utf16le = u'\\\\?\\'.encode('utf-16-le', errors = 'ignore') # a constant

    for line in file_strings:
      file_path = line.strip()
      if file_path:
        file_path_decoded = file_path
        if recode_to_utf8:
          file_path = file_path_decoded.encode('utf-8', errors = 'ignore')
        print("  - " + file_path)

        # 255 is builtin minimum
        if open_path_len_limit <= 255 or open_path_len_limit >= len(file_path):
          notepad.open(file_path)
        else:
          file_path_unc_utf16le = file_path_unc_prefix_utf16le + file_path_decoded.encode('utf-16-le', errors = 'ignore')
          file_path_buf = ctypes.create_unicode_buffer(len(file_path_unc_utf16le) + 1)

          # ISSUE:
          #   Tests showed `ctypes.windll.kernel32.GetShortPathNameW` can return 0 time to time on a long path file for no reason.
          #
          if ctypes.windll.kernel32.GetShortPathNameW(file_path_unc_utf16le, file_path_buf, ctypes.sizeof(file_path_buf)):
            print("    - " + str(file_path_buf.value))
            notepad.open(str(file_path_buf.value))
          else:
            print("    - path may not opened: `ctypes.windll.kernel32.GetShortPathNameW` call is failed.")
            # fall back to long path
            notepad.open(file_path)

          #file_path_buf = None

        num_opened += 1

  print()
  print('* Number of opened paths: ' + str(num_opened))
  print()

  if do_reopen_all_files:
    reopen_all_files()

def open_from_file_list(file_list):
  print('open_from_file_list:')

  num_opened = 0

  for file in file_list:
    print("  - " + file)
    notepad.open(file)
    num_opened += 1

  print()
  print('* Number of opened paths: ' + str(num_opened))
  print()
