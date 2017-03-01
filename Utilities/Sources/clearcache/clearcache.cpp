#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include "common.hpp"

// Usage: ClearCache C: D:
#include <tchar.h>
#include <stdio.h>
#include <windows.h>
#include <string.h>
#include <string>
#include <vector>

#include "common.hpp"

int _tmain(int argc, LPTSTR argv[])
{
  if(!argc || !argv[0])
    return -1;

  bool do_show_help = false;

  if(argc >= 2 && argv[1] && !_tcscmp(argv[1], _T("/?"))) {
    if (argc >= 3) return 2;
    do_show_help = true; // /?
  }

  if(do_show_help) {
#ifdef _UNICODE
    ::_putws(
#else
    ::puts(
#endif
#include "help_inl.hpp"
      );

    return -2;
  }

  LPCTSTR DOS_PREFIX = _T("\\\\.\\");
  for (int i = 1; i < argc; i++)
  {
    LPCTSTR arg = argv[i];
    LPTSTR path = (LPTSTR)calloc(_tcslen(arg) + _tcslen(DOS_PREFIX) + 1, sizeof(*arg));
    __try
    {
      if (_istalpha(arg[0]) && arg[1] == _T(':') &&
        (arg[2] == _T('\0') ||
        arg[2] == _T('\\') && arg[3] == _T('\0')))
      {
        _tcscat(path, DOS_PREFIX);
      }
      _tcscat(path, arg);
      HANDLE hFile = CreateFile(path,
        FILE_READ_DATA, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
      if (hFile != INVALID_HANDLE_VALUE) {
        CloseHandle(hFile);
      }
      else {
        const DWORD le = GetLastError();
        if (le != ERROR_SHARING_VIOLATION && le != ERROR_ACCESS_DENIED) {
          _ftprintf(stderr, _T("Error %d clearing %s\n"), le, argv[i]);
          return le;
        }
      }
    }
    __finally
    {
      free(path);
    }
  }
  return 0;
}
