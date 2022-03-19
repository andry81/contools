#pragma once

#ifndef __ELEVATION_HPP__
#define __ELEVATION_HPP__

#include "common.hpp"

#include <nt/ntseapi.h>
#include <nt/ntifs.h>

// Based on:
//  https://stackoverflow.com/questions/45915599/how-can-i-unelevate-a-process/45921237#45921237
//

inline BOOL CreateProcessNonElevated(
    HANDLE hParentProcessToken, HANDLE hCurrentProcessToken, PCWSTR lpApplicationName, PWSTR lpCommandLine,
    LPSECURITY_ATTRIBUTES lpProcessAttributes, LPSECURITY_ATTRIBUTES lpThreadAttributes, BOOL bInheritHandles,
    DWORD dwCreationFlags, LPVOID lpEnvironment, LPCWSTR lpCurrentDirectory,
    LPSTARTUPINFOW lpStartupInfo, LPPROCESS_INFORMATION lpProcessInformation)
{
    static volatile UCHAR guz;

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
    DWORD win_error = NOERROR;

    PVOID stack = alloca(guz);
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
    static TOKEN_PRIVILEGES tp = {
        1, { { { SE_DEBUG_PRIVILEGE } , SE_PRIVILEGE_ENABLED } }
    };

    HANDLE hSnapshot;
    HANDLE hParentProcess;
    HANDLE hParentProcessToken;
    DWORD win_error = NOERROR;

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
    HANDLE hCurrentProcessToken;
    TOKEN_ELEVATION_TYPE tet{};
    ULONG rcb;

    DWORD win_error = NOERROR;

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

#endif
