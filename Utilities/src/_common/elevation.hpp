#pragma once

#ifndef __ELEVATION_HPP__
#define __ELEVATION_HPP__

#include "common.hpp"

#include <nt/ntseapi.h>
#include <nt/ntifs.h>

#include <shldisp.h>
#include <shlobj.h>
#include <exdisp.h>
#include <atlbase.h>
#include <stdlib.h>

// /shell-exec*
enum ShellExecMethod
{
    ShellExecMethod_None                            = 0,

    ShellExecMethod_ElevateFromExplorer             = 1,    // ShellExecute
    ShellExecMethod_UnelevateFromExplorer           = 2,    // same as UnelevationMethod_ShellExecuteFromExplorer

    ShellExecMethod_Default                         = ShellExecMethod_ElevateFromExplorer
};

// /unelevate*
enum UnelevationMethod
{
    UnelevationMethod_None                          = 0,

    UnelevationMethod_SearchProcToAdjustToken       = 1,    // based on: https://stackoverflow.com/questions/45915599/how-can-i-unelevate-a-process/45921237#45921237
    UnelevationMethod_ShellExecuteFromExplorer      = 2,    // based on: https://stackoverflow.com/questions/37948064/how-to-launch-non-elevated-administrator-process-from-elevated-administrator-con/37949303#37949303

    UnelevationMethod_Default                       = UnelevationMethod_SearchProcToAdjustToken
};

inline BOOL CreateProcessNonElevated(
    HANDLE hParentProcessToken, HANDLE hCurrentProcessToken, PCWSTR lpApplicationName, PWSTR lpCommandLine,
    LPSECURITY_ATTRIBUTES lpProcessAttributes, LPSECURITY_ATTRIBUTES lpThreadAttributes, BOOL bInheritHandles,
    DWORD dwCreationFlags, LPVOID lpEnvironment, LPCWSTR lpCurrentDirectory,
    LPSTARTUPINFOW lpStartupInfo, LPPROCESS_INFORMATION lpProcessInformation)
{
    DWORD win_error = NOERROR;

    HANDLE hParentProcessTokenDup;
    union {
        PVOID buf;
        PTOKEN_PRIVILEGES ptp;
    };
    ULONG PrivilegeCount;
    int priviliges_count = 3;
    BOOL fAdjust;
    PLUID_AND_ATTRIBUTES Privileges;
    TOKEN_LINKED_TOKEN tlt;
    ULONG cb = 0;
    ULONG rcb;

    PVOID stack = alloca(sizeof(UCHAR));
    // NOTE: no stack allocations after that point

    rcb = FIELD_OFFSET(TOKEN_PRIVILEGES, Privileges[SE_MAX_WELL_KNOWN_PRIVILEGE]);

    do {
        if (cb < rcb) {
            cb = RtlPointerToOffset(buf = alloca(rcb - cb), stack);
        }

        SetLastError(0); // just in case
        if (GetTokenInformation(hParentProcessToken, TokenPrivileges, buf, cb, &rcb)) {
            if (PrivilegeCount = ptp->PrivilegeCount) {
                priviliges_count = 3;
                fAdjust = FALSE;

                Privileges = ptp->Privileges;

                do {
                    switch (Privileges->Luid.LowPart) {
                    case SE_ASSIGNPRIMARYTOKEN_PRIVILEGE:
                    case SE_INCREASE_QUOTA_PRIVILEGE:
                    case SE_TCB_PRIVILEGE:
                        if (!(Privileges->Attributes & SE_PRIVILEGE_ENABLED)) {
                            Privileges->Attributes |= SE_PRIVILEGE_ENABLED;
                            fAdjust = TRUE;
                        }

                        if (!--priviliges_count) {
                            win_error = NOERROR;

                            SetLastError(0); // just in case
                            if (DuplicateTokenEx(hParentProcessToken,
                                TOKEN_ADJUST_PRIVILEGES | TOKEN_IMPERSONATE,
                                0, SecurityImpersonation, TokenImpersonation,
                                &hParentProcessTokenDup)) {
                                if (fAdjust) {
                                    SetLastError(0); // just in case
                                    AdjustTokenPrivileges(hParentProcessTokenDup, FALSE, ptp, rcb, NULL, NULL);
                                    win_error = GetLastError();
                                }

                                if (win_error == NOERROR) {
                                    SetLastError(0); // just in case
                                    if (SetThreadToken(0, hParentProcessTokenDup)) {
                                        tlt = TOKEN_LINKED_TOKEN{};
                                        SetLastError(0); // just in case
                                        if (GetTokenInformation(hCurrentProcessToken, TokenLinkedToken, &tlt, sizeof(tlt), &rcb)) {
                                            SetLastError(0); // just in case
                                            CreateProcessAsUser(
                                                tlt.LinkedToken,
                                                lpApplicationName, lpCommandLine,
                                                lpProcessAttributes, lpThreadAttributes, bInheritHandles,
                                                dwCreationFlags, lpEnvironment, lpCurrentDirectory,
                                                lpStartupInfo, lpProcessInformation);
                                            win_error = GetLastError();

                                            _close_handle(tlt.LinkedToken);

                                            // WARNING:
                                            //  Must be closed externally.
                                            //
                                            //if (err == NOERROR) {
                                            //    _close_handle(lpProcessInformation.hThread);
                                            //    _close_handle(lpProcessInformation.hProcess);
                                            //}
                                        }
                                        else {
                                            win_error = GetLastError();
                                        }

                                        SetThreadToken(0, 0);
                                    }
                                    else {
                                        win_error = GetLastError();
                                    }
                                }

                                _close_handle(hParentProcessTokenDup);
                            }
                            else {
                                win_error = GetLastError();
                            }

                            SetLastError(win_error);

                            return !win_error;
                        }
                    }
                } while (Privileges++, --PrivilegeCount);
            }

            SetLastError(ERROR_NOT_FOUND);

            return 0;
        }

    } while ((win_error = GetLastError()) == ERROR_INSUFFICIENT_BUFFER);

    SetLastError(win_error);

    return !win_error;
}

inline BOOL CreateProcessNonElevated(
    HANDLE hCurrentProcessToken, PCWSTR lpApplicationName, PWSTR lpCommandLine,
    LPSECURITY_ATTRIBUTES lpProcessAttributes, LPSECURITY_ATTRIBUTES lpThreadAttributes, BOOL bInheritHandles,
    DWORD dwCreationFlags, LPVOID lpEnvironment, LPCWSTR lpCurrentDirectory,
    LPSTARTUPINFOW lpStartupInfo, LPPROCESS_INFORMATION lpProcessInformation)
{
    DWORD win_error = NOERROR;

    HANDLE hSnapshot;
    HANDLE hParentProcess;
    HANDLE hParentProcessToken;

    TOKEN_PRIVILEGES tp = {
        1,{ { { SE_DEBUG_PRIVILEGE } , SE_PRIVILEGE_ENABLED } }
    };

    AdjustTokenPrivileges(hCurrentProcessToken, FALSE, &tp, sizeof(tp), NULL, NULL);

    // much more effective of course use NtQuerySystemInformation(SystemProcessesAndThreadsInformation) here
    hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

    if (hSnapshot != INVALID_HANDLE_VALUE) {
        PROCESSENTRY32W pe{ sizeof(pe) };

        SetLastError(0); // just in case
        if (Process32FirstW(hSnapshot, &pe)) {
            win_error = ERROR_NOT_FOUND;

            do {
                if (pe.th32ProcessID && pe.th32ParentProcessID) {
                    SetLastError(0); // just in case
                    if (hParentProcess = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pe.th32ProcessID)) {
                        SetLastError(0); // just in case
                        if (OpenProcessToken(hParentProcess, TOKEN_QUERY | TOKEN_DUPLICATE, &hParentProcessToken)) {
                            CreateProcessNonElevated(
                                hParentProcessToken, hCurrentProcessToken, lpApplicationName, lpCommandLine,
                                lpProcessAttributes, lpThreadAttributes, bInheritHandles,
                                dwCreationFlags, lpEnvironment, lpCurrentDirectory,
                                lpStartupInfo, lpProcessInformation);
                            win_error = GetLastError();

                            _close_handle(hParentProcessToken);
                        }
                        else {
                            win_error = GetLastError();
                        }

                        _close_handle(hParentProcess);
                    }
                    else {
                        win_error = GetLastError();
                    }
                }
            } while (win_error && Process32NextW(hSnapshot, &pe));
        }
        else {
            win_error = GetLastError();
        }

        _close_handle(hSnapshot);
    }

    SetLastError(win_error);

    return !win_error;
}

inline BOOL CreateProcessNonElevated(
    PCWSTR lpApplicationName, PWSTR lpCommandLine,
    LPSECURITY_ATTRIBUTES lpProcessAttributes, LPSECURITY_ATTRIBUTES lpThreadAttributes, BOOL bInheritHandles,
    DWORD dwCreationFlags, LPVOID lpEnvironment, LPCWSTR lpCurrentDirectory,
    LPSTARTUPINFOW lpStartupInfo, LPPROCESS_INFORMATION lpProcessInformation)
{
    DWORD win_error = NOERROR;

    HANDLE hCurrentProcessToken;
    TOKEN_ELEVATION_TYPE tet{};
    ULONG rcb;

    SetLastError(0); // just in case
    if (OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY | TOKEN_ADJUST_PRIVILEGES, &hCurrentProcessToken)) { // replaced: NtCurrentProcess()
        SetLastError(0); // just in case
        if (GetTokenInformation(hCurrentProcessToken, ::TokenElevationType, &tet, sizeof(tet), &rcb)) {
            if (tet == TokenElevationTypeFull) {
                CreateProcessNonElevated(
                    hCurrentProcessToken, lpApplicationName, lpCommandLine,
                    lpProcessAttributes, lpThreadAttributes, bInheritHandles,
                    dwCreationFlags, lpEnvironment, lpCurrentDirectory,
                    lpStartupInfo, lpProcessInformation);
                win_error = GetLastError();
            }
            else {
                win_error = ERROR_ALREADY_ASSIGNED;
            }
        }
        else {
            win_error = GetLastError();
        }

        _close_handle(hCurrentProcessToken);
    }
    else {
        win_error = GetLastError();
    }

    SetLastError(win_error);

    return !win_error;
}

inline HRESULT FindDesktopFolderView(REFIID riid, void **ppv)
{
    HRESULT hr = S_OK;

    CComPtr<IShellWindows> spShellWindows;
    if (FAILED(hr = spShellWindows.CoCreateInstance(CLSID_ShellWindows))) {
        return hr;
    }

    CComVariant vtLoc(CSIDL_DESKTOP);
    CComVariant vtEmpty;
    long lhwnd;
    CComPtr<IDispatch> spdisp;

    if (FAILED(hr = spShellWindows->FindWindowSW(&vtLoc, &vtEmpty, SWC_DESKTOP, &lhwnd, SWFO_NEEDDISPATCH, &spdisp))) {
        return hr;
    }

    CComPtr<IShellBrowser> spBrowser;

    if (FAILED(hr = CComQIPtr<IServiceProvider>(spdisp)->QueryService(SID_STopLevelBrowser, IID_PPV_ARGS(&spBrowser)))) {
        return hr;
    }

    CComPtr<IShellView> spView;

    if (FAILED(hr = spBrowser->QueryActiveShellView(&spView))) {
        return hr;
    }

    if (FAILED(hr = spView->QueryInterface(riid, ppv))) {
        return hr;
    }

    return hr;
}

// FindDesktopFolderView incorporated by reference
inline HRESULT GetDesktopAutomationObject(REFIID riid, void **ppv)
{
    HRESULT hr = S_OK;

    CComPtr<IShellView> spsv;

    if (FAILED(hr = FindDesktopFolderView(IID_PPV_ARGS(&spsv)))) {
        return hr;
    }

    CComPtr<IDispatch> spdispView;

    if (FAILED(hr = spsv->GetItemObject(SVGIO_BACKGROUND, IID_PPV_ARGS(&spdispView)))) {
        return hr;
    }

    if (FAILED(hr = spdispView->QueryInterface(riid, ppv))) {
        return hr;
    }

    return hr;
}

inline HRESULT ShellExecuteNonElevated(PCWSTR pszFile, PCWSTR pszParameters, PCWSTR pszDirectory, PCWSTR pszOperation, int nShowCmd)
{
    HRESULT hr = S_OK;

    CComPtr<IShellFolderViewDual> spFolderView;

    if (FAILED(hr = GetDesktopAutomationObject(IID_PPV_ARGS(&spFolderView)))) {
        return hr;
    }

    CComPtr<IDispatch> spdispShell;

    if (FAILED(hr = spFolderView->get_Application(&spdispShell))) {
        return hr;
    }

    if (FAILED(hr = CComQIPtr<IShellDispatch2>(spdispShell)->ShellExecute(CComBSTR(pszFile),
        CComVariant(pszParameters ? pszParameters : L""),
        CComVariant(pszDirectory ? pszDirectory : L""),
        CComVariant(pszOperation ? pszOperation : L""),
        CComVariant(nShowCmd)))) {
        return hr;
    }

    return hr;
}

#endif
