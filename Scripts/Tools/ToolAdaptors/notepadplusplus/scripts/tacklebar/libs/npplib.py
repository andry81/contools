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
  file_index = len(all_files)

  for f in reversed(all_files):
    file_index -= 1
    print('  [{}] {}'.format(file_index, f))
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
    print('  [{}] {}'.format(num_reopened, f[0]))
    notepad.open(f[0])
    num_reopened += 1

  # reactive in reverse order
  for f in reversed(all_files):
    notepad.activateFile(f[0])

  notepad.activateFile(active_file)

  print()
  print('* Number of reopened paths: ' + str(num_reopened))
  print()

def process_notepadpp_windows(restore_single_instance, out_params):
  import ctypes
  from ctypes import wintypes

  class InParams:
    current_pid = 0

  user32 = ctypes.windll.user32
  kernel32 = ctypes.windll.kernel32

  WNDENUMPROC = ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
  SW_RESTORE = wintypes.DWORD(9)

  in_params = InParams()

  in_params.current_pid = kernel32.GetCurrentProcessId()
  process_id = wintypes.DWORD()

  wnd_class_name_buf_size = 256
  wnd_class_name_buf = ctypes.create_unicode_buffer(256)

  def enum_notepadpp_windows(hwnd, lparam):
    user32.GetClassNameW(hwnd, wnd_class_name_buf, wnd_class_name_buf_size)
    #wnd_class_name_buf[255] = 0 # string terminator character in case of truncation
    if u'Notepad++' in wnd_class_name_buf.value:
      out_params.num_instances += 1
      user32.GetWindowThreadProcessId(hwnd, ctypes.byref(process_id))
      if process_id.value == in_params.current_pid:
        out_params.notepadpp_hwnd = hwnd
    return True # continue enumerating

  user32.EnumWindows(WNDENUMPROC(enum_notepadpp_windows), 0)

  if restore_single_instance:
    print('process_notepadpp_windows:')
    print('  - pid: ' + str(in_params.current_pid))
    print('  - num instances: ' + str(out_params.num_instances))
    if out_params.notepadpp_hwnd and not out_params.num_instances > 1: # single instance
      print('  - instance restored')
      user32.ShowWindow(out_params.notepadpp_hwnd, SW_RESTORE)
    else:
      print('  - instance NOT restored')

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

  child_cmdline_len_limit = 32767 # use default limit - 32767
  next_arg_is_child_cmdline_len_limit = False

  chdir_path = ''
  next_arg_is_chdir_path = False

  do_append = False
  do_reopen_all_files = False
  do_restore_single_instance = False

  is_multi_instance = False

  no_exit_after_append = False

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
    elif next_arg_is_child_cmdline_len_limit:
      # 1 is builtin minimum, means: use one file to open per each child Notepad++ command line
      # 32767 is builtin maximum for Win32 CreateProcess
      child_cmdline_len_limit = min(max(int(arg), 1), 32767)
      next_arg_is_child_cmdline_len_limit = False
      print('--child_cmdline_len_limit ' + str(child_cmdline_len_limit))
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
      elif arg == '--child_cmdline_len_limit':
        next_arg_is_child_cmdline_len_limit = True
      elif arg == '--chdir':
        next_arg_is_chdir_path = True
      elif arg == '-reopen_all_files':
        do_reopen_all_files = True
      elif arg == '-restore_single_instance':
        do_restore_single_instance = True
      elif arg == '-append':
        do_append = True
      elif arg == '-multiInst':
        is_multi_instance = True
      elif arg == '-no_exit_after_append':
        no_exit_after_append = True

  # append and restore has meaning ONLY in multi-instance mode
  if not is_multi_instance:
    do_append = False
    do_restore_single_instance = False
  # restore has meaning ONLY in the minimized show state used in the append mode
  elif not do_append:
    do_restore_single_instance = False

  num_processed_paths = 0
  num_success_paths = 0

  # True - open files in current Notepad++ instance
  # False - open file in a child Notepad++ instance
  do_open_inplace = True

  if chdir_path:
    os.chdir(chdir_path)
    print('--chdir: ' + chdir_path)

  if open_from_file_list_path:
    if do_append or open_path_len_limit > 0:
      import ctypes

    # construct child command line
    if do_append:
      class OutParams:
        notepadpp_hwnd = None
        num_instances = 0

      out_params = OutParams()

      # process Notepad++ instances as standalone windows
      process_notepadpp_windows(do_restore_single_instance, out_params)

      if out_params.notepadpp_hwnd and not out_params.num_instances > 1: # single instance
        is_single_instance = True
      else:
        is_single_instance = False
        do_open_inplace = False

        # prepare child Notepad++ command line to pass all being opened files into it to append to existing Notepad++ instance (except this instance)
        child_cmdline_prefix_list = list()
        child_cmdline_file_list = list()

        next_arg_ignore = False

        # filter out all `-z` parameters to leave only Notepad++ builtin parameters except several specific
        for arg in cmdline_list:
          if next_arg_ignore:
            next_arg_ignore = False
            continue

          if arg == '-z':
            next_arg_ignore = True
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
            if arg == '-nosession':
              continue
            if arg == '-multiInst':
              continue

            child_cmdline_prefix_list.append(arg)

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
    #
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
    #     >     ...
    #     >
    #     >     Another thought: try using ctypes.
    #     >

    file_path_unc_prefix_utf16le = u'\\\\?\\'.encode('utf-16-le', errors = 'ignore') # a constant

    kernel32 = ctypes.windll.kernel32

    for line in file_strings:
      file_path = line.strip()
      if file_path:
        file_path_decoded = file_path
        if recode_to_utf8:
          file_path = file_path_decoded.encode('utf-8', errors = 'ignore')
        print('  [{}] ({}) {}'.format(num_processed_paths, len(file_path), file_path))

        # 255 is builtin minimum
        if open_path_len_limit <= 255 or open_path_len_limit >= len(file_path):
          if do_open_inplace:
            notepad.open(file_path)
          else:
            child_cmdline_file_list.append(file_path)

          num_success_paths += 1
        else:
          file_path_unc_utf16le = file_path_unc_prefix_utf16le + file_path_decoded.encode('utf-16-le', errors = 'ignore')
          file_path_buf_size = len(file_path_unc_utf16le) + 1 # in characters
          file_path_buf = ctypes.create_unicode_buffer(file_path_buf_size) # plus terminator character

          # ISSUE:
          #   Tests showed `ctypes.windll.kernel32.GetShortPathNameW` can return 0 time to time on a long path file for no reason.
          #
          if kernel32.GetShortPathNameW(file_path_unc_utf16le, file_path_buf, file_path_buf_size):
            file_path = str(file_path_buf.value)

            print('    - ({}) {}'.format(len(file_path), file_path))

            if do_open_inplace:
              notepad.open(str(file_path_buf.value))
            else:
              child_cmdline_file_list.append(str(file_path_buf.value))

            num_success_paths += 1
          else:
            print("    - path may be is not opened: `ctypes.windll.kernel32.GetShortPathNameW` call is failed.")

            # fall back to long path
            if do_open_inplace:
              notepad.open(file_path)
            # ISSUE:
            #   We have to skip append into a child command line, because in that case Notepad++ does not open the entire command line
            #   including not long file path arguments if at least one argument is a long file path!
            #
            #else:
            #  child_cmdline_file_list.append(file_path)

          #file_path_buf = None

        num_processed_paths += 1

  print()
  print('* Number of success paths: {} of {}'.format(str(num_success_paths), str(num_processed_paths)))
  print()

  if not do_open_inplace:
    import sys

    print('executing child subprocess:')

    if len(child_cmdline_file_list):
      import subprocess

      # each command line must be not longer than a command line length limit
      cmdline_len_max = child_cmdline_len_limit

      # count accumulated command line length respective to white space characters
      white_space_chars = ' \t'

      child_subprocess_prefix_cmdline_list = [sys.argv[0]] + child_cmdline_prefix_list[1:]
      child_subprocess_prefix_cmdline_len = 0

      def cmdline_len(arg_list):
        cmdline_len = 0
        arg_index = 0

        for arg in arg_list:
          if len(arg):
            arg_has_white_space_char = any(elem in arg for elem in white_space_chars)
            cmdline_len += len(arg) + (2 if arg_has_white_space_char else 0)
          else: # empty argument
            cmdline_len += 2

          if arg_index:
            cmdline_len += 1 # space between arguments

          arg_index += 1

        return cmdline_len

      child_subprocess_prefix_cmdline_len = cmdline_len(child_subprocess_prefix_cmdline_list)

      while len(child_cmdline_file_list):
        file_path = child_cmdline_file_list.pop(0)
        file_path_list = [file_path]

        child_subprocess_prev_cmdline_list = child_subprocess_prefix_cmdline_list + file_path_list
        child_subprocess_prev_cmdline_len = child_subprocess_prefix_cmdline_len + 1 + cmdline_len(file_path_list)

        if len(child_cmdline_file_list):
          file_path = child_cmdline_file_list[0]

          child_subprocess_next_cmdline_list = child_subprocess_prev_cmdline_list + [file_path]
          child_subprocess_next_cmdline_len = child_subprocess_prev_cmdline_len + 1 + cmdline_len([file_path])

          while cmdline_len_max >= child_subprocess_next_cmdline_len:
            child_cmdline_file_list.pop(0)

            file_path_list.append(file_path)

            child_subprocess_prev_cmdline_list = child_subprocess_next_cmdline_list
            child_subprocess_prev_cmdline_len = child_subprocess_next_cmdline_len

            if len(child_cmdline_file_list):
              file_path = child_cmdline_file_list[0]

              child_subprocess_next_cmdline_list = child_subprocess_prev_cmdline_list + [file_path]
              child_subprocess_next_cmdline_len = child_subprocess_prev_cmdline_len + 1 + cmdline_len([file_path])
            else:
              break

        print('  - ' + str(child_subprocess_prefix_cmdline_list))
        print('    command line length: ' + str(child_subprocess_prev_cmdline_len))

        file_index = 0

        for file_path in file_path_list:
          print('    [{}] ({}) {}'.format(file_index, len(file_path), file_path))
          file_index += 1

        subprocess.call(child_subprocess_prev_cmdline_list, stdin = None, stdout = None, stderr = None, shell = False)
    else:
      print('  - None')

    if not no_exit_after_append:
      sys.exit(0)

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
