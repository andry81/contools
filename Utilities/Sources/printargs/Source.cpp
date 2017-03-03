#include <stdio.h>
#include <string.h>

int main(int argc, char * argv[])
{
    if (argc < 1) return 0;
    for (int i = 0; i < argc; i++)
    {
        printf("%02u|%s|\n", strlen(argv[i]), argv[i]);
    }
    return argc;
}
