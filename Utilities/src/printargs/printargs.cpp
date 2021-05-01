#include <stdio.h>
#include <string.h>

#include "std/tstring.hpp"
#include "std/tstdio.hpp"

int _tmain(int argc, const TCHAR * argv[])
{
    if (argc < 1) return 0;

    for (int i = 0; i < argc; i++)
    {
        _tprintf(_T("%02zu|%s|\n"), tstrlen(argv[i]), argv[i]);
    }

    return argc;
}
