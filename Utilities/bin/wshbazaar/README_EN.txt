* README_EN.txt
* 2024.02.13
* contools--utilities--wshbazaar

1. DESCRIPTION
2. PREREQUISITES
3. EXAMPLES
3.1. AdjustTokenPrivileges
3.2. SetFileShortName
3.3. GetFileShortName

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Windows Script Host Bazaar. The OCX components by Günter Born.

Original site:

  http://www.borncity.com/web/WSHBazaar1/WSHDynaCall.htm

Related links:

  http://script-coding.com/dynwrap.html

-------------------------------------------------------------------------------
2. PREREQUISITES
-------------------------------------------------------------------------------

Currently used these set of OS platforms, compilers, interpreters, modules,
IDE's, applications and patches to run with or from:

1. OS platforms:

* Windows XP
* Windows 7+

2. C++11 compilers:

* (primary) Microsoft Visual C++ 2019

3. IDE's.

* Microsoft Visual Studio 2019

-------------------------------------------------------------------------------
3. EXAMPLES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
3.1. AdjustTokenPrivileges
-------------------------------------------------------------------------------
Various `AdjustTokenPrivileges` examples.

Source:
  https://learn.microsoft.com/en-us/windows/win32/seccrypto/setting-the-backup-and-restore-privileges

```c
HRESULT ModifyPrivilege(
    IN LPCTSTR szPrivilege,
    IN BOOL fEnable)
{
    HRESULT hr = S_OK;
    TOKEN_PRIVILEGES NewState;
    LUID             luid;
    HANDLE hToken    = NULL;

    // Open the process token for this process.
    if (!OpenProcessToken(GetCurrentProcess(),
                          TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY,
                          &hToken ))
    {
        printf("Failed OpenProcessToken\n");
        return ERROR_FUNCTION_FAILED;
    }

    // Get the local unique ID for the privilege.
    if ( !LookupPrivilegeValue( NULL,
                                szPrivilege,
                                &luid ))
    {
        CloseHandle( hToken );
        printf("Failed LookupPrivilegeValue\n");
        return ERROR_FUNCTION_FAILED;
    }

    // Assign values to the TOKEN_PRIVILEGE structure.
    NewState.PrivilegeCount = 1;
    NewState.Privileges[0].Luid = luid;
    NewState.Privileges[0].Attributes =
              (fEnable ? SE_PRIVILEGE_ENABLED : 0);

    // Adjust the token privilege.
    if (!AdjustTokenPrivileges(hToken,
                               FALSE,
                               &NewState,
                               0,
                               NULL,
                               NULL))
    {
        printf("Failed AdjustTokenPrivileges\n");
        hr = ERROR_FUNCTION_FAILED;
    }

    // Close the handle.
    CloseHandle(hToken);

    return hr;
}
```

Source:
  https://learn.microsoft.com/en-us/windows/win32/secauthz/privilege-constants#example
  https://github.com/microsoft/Windows-classic-samples/blob/1d363ff4bd17d8e20415b92e2ee989d615cc0d91/Samples/ManagementInfrastructure/cpp/Process/Provider/WindowsProcess.c#L49

```c
BOOL EnablePrivilege()
{
    LUID PrivilegeRequired ;
    DWORD dwLen = 0, iCount = 0;
    BOOL bRes = FALSE;
    HANDLE hToken = NULL;
    BYTE *pBuffer = NULL;
    TOKEN_PRIVILEGES* pPrivs = NULL;

    bRes = LookupPrivilegeValue(NULL, SE_DEBUG_NAME, &PrivilegeRequired);
    if( !bRes) return FALSE;

    bRes = OpenThreadToken(GetCurrentThread(), TOKEN_QUERY | TOKEN_ADJUST_PRIVILEGES, TRUE, &hToken);
    if(!bRes) return FALSE;

    bRes = GetTokenInformation(hToken, TokenPrivileges, NULL, 0, &dwLen);
    if (TRUE == bRes)
    {
        CloseHandle(hToken);
        return FALSE;
    }
    pBuffer = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, dwLen);
    if(NULL == pBuffer) return FALSE;

    if (!GetTokenInformation(hToken, TokenPrivileges, pBuffer, dwLen, &dwLen))
    {
        CloseHandle(hToken);
        HeapFree(GetProcessHeap(), 0, pBuffer);
        return FALSE;
    }

    // Iterate through all the privileges and enable the one required
    bRes = FALSE;
    pPrivs = (TOKEN_PRIVILEGES*)pBuffer;
    for(iCount = 0; iCount < pPrivs->PrivilegeCount; iCount++)
    {
        if (pPrivs->Privileges[iCount].Luid.LowPart == PrivilegeRequired.LowPart &&
          pPrivs->Privileges[iCount].Luid.HighPart == PrivilegeRequired.HighPart )
        {
            pPrivs->Privileges[iCount].Attributes |= SE_PRIVILEGE_ENABLED;
            // here it's found
            bRes = AdjustTokenPrivileges(hToken, FALSE, pPrivs, dwLen, NULL, NULL);
            break;
        }
    }

    CloseHandle(hToken);
    HeapFree(GetProcessHeap(), 0, pBuffer);
    return bRes;
}
```

-------------------------------------------------------------------------------
3.2. SetFileShortName
-------------------------------------------------------------------------------
VBS example of a call to Win32 API `SetFileShortNameW` function using
`wshdynacall32.dll` or the original `dynwrap.dll` component.

CAUTION:
  At least one component (`wshdynacall32.dll` or `dynwrap.dll`) must be already
  registered.

NOTE:
  To be able to call the `SetFileShortNameW` the process must have has these
  set of privileges enabled:

    * `SeBackupPrivilege`
    * `SeRestorePrivilege`

  You must explicitly request these using something else.
  The example below does use the `bellamyjc--jcb-ocx` project component to
  request these. Otherwise use the examples from section
  `AdjustTokenPrivileges` here to write and use your own component or function.

CAUTION:
  The script requires the Adminitrator privileges to request above priviliges.

CAUTION:
  The script process must be a 32-bit process to create `jcb.tools` object to
  request above privileges.

See `Scripts/Tools/ToolAdaptors/vbs/set_fileshortpath.vbs` for the example.

-------------------------------------------------------------------------------
3.3. GetFileShortName
-------------------------------------------------------------------------------
VBS example of request the Short Filename Path (SFN) of a file.

CAUTION:
  At least one component (`wshdynacall32.dll` or `dynwrap.dll`) must be already
  registered.

NOTE:
  The script does not require the Adminitrator privileges.

See `Scripts/Tools/ToolAdaptors/vbs/get_fileshortname.vbs` for the example.
