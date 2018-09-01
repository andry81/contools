#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

// Usage: ClearCache C: D:
#include <tchar.h>
#include <stdio.h>
#include <windows.h>
#include <string.h>
#include <string>
#include <vector>

#include "common.hpp"

// based on: https://stackoverflow.com/questions/2220336/change-file-owner-in-windows/2220355#2220355
//

static BOOL SetPrivilege(
    HANDLE hToken,          // access token handle
    LPCTSTR lpszPrivilege,  // name of privilege to enable/disable
    BOOL bEnablePrivilege   // to enable or disable privilege
)
{
    TOKEN_PRIVILEGES tp;
    LUID luid;

    if (!LookupPrivilegeValue(
        NULL,            // lookup privilege on local system
        lpszPrivilege,   // privilege to lookup 
        &luid))        // receives LUID of privilege
    {
        printf("LookupPrivilegeValue error: %u\n", GetLastError());
        return FALSE;
    }

    tp.PrivilegeCount = 1;
    tp.Privileges[0].Luid = luid;
    if (bEnablePrivilege)
        tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
    else
        tp.Privileges[0].Attributes = 0;

    // Enable the privilege or disable all privileges.

    if (!AdjustTokenPrivileges(
        hToken,
        FALSE,
        &tp,
        sizeof(TOKEN_PRIVILEGES),
        (PTOKEN_PRIVILEGES)NULL,
        (PDWORD)NULL))
    {
        printf("AdjustTokenPrivileges error: %u\n", GetLastError());
        return FALSE;
    }

    if (GetLastError() == ERROR_NOT_ALL_ASSIGNED)

    {
        printf("The token does not have the specified privilege. \n");
        return FALSE;
    }

    return TRUE;
}

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

    if (argc < 3) {
        return -3;
    }

    DWORD last_error = 0;

    HANDLE token;
    TCHAR * filename = argv[1];
    TCHAR * newuser = argv[2];
    DWORD len;
    PSECURITY_DESCRIPTOR security = NULL;
    PSID sidPtr = NULL;

    switch(1) case 1: default:
    __try {
        // Get the privileges you need
        SetLastError(0); last_error = 0;
        if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, &token)) {
            SetPrivilege(token, _T("SeTakeOwnershipPrivilege"), 1);
            SetPrivilege(token, _T("SeSecurityPrivilege"), 1);
            SetPrivilege(token, _T("SeBackupPrivilege"), 1);
            SetPrivilege(token, _T("SeRestorePrivilege"), 1);
        } else {
            last_error = GetLastError();
            break;
        }

        // Create the security descriptor, 5 retries
        SetLastError(0); last_error = 0;
        if(!GetFileSecurity(filename, OWNER_SECURITY_INFORMATION, security, 0, &len)) {
            last_error = GetLastError();
            if (last_error != 0 && last_error != 0x7A) {
                break;
            }
        }

        security = (PSECURITY_DESCRIPTOR)malloc(len);

        SetLastError(0); last_error = 0;
        if (!InitializeSecurityDescriptor(security, SECURITY_DESCRIPTOR_REVISION)) {
            last_error = GetLastError();
            break;
        }

        // Get the sid for the username
        TCHAR domainbuf[4096];
        DWORD sidSize = 0;
        DWORD bufSize = 4096;
        SID_NAME_USE sidUse;
        LookupAccountName(NULL, newuser, sidPtr, &sidSize, domainbuf, &bufSize, &sidUse);
        sidPtr = (PSID)malloc(sidSize);
        SetLastError(0); last_error = 0;
        if (!LookupAccountName(NULL, newuser, (PSID)sidPtr, &sidSize, domainbuf, &bufSize, &sidUse)) {
            last_error = GetLastError();
            break;
        }

        // Set the sid to be the new owner
        SetLastError(0); last_error = 0;
        if (!SetSecurityDescriptorOwner(security, sidPtr, 0)) {
            last_error = GetLastError();
            break;
        }

        // Save the security descriptor
        SetLastError(0); last_error = 0;
        if (!SetFileSecurity(filename, OWNER_SECURITY_INFORMATION, security)) {
            last_error = GetLastError();
            break;
        }
    }
    __finally
    {
        free(security);
        free(sidPtr);
    }

    return last_error;
}
