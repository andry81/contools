//------------------------------------------------------------------
//  Dynacall.c - 32-bit Dynamic function calls. Ton Plooy 1998
//------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#define  WIN32_LEAN_AND_MEAN
#include <windows.h>

#undef   WINBASEAPI         // Is __declspec(dllimport) in winbase.h
#define  WINBASEAPI         __declspec(dllexport)

#include "dynacall.h"

//------------------------------------------------------------------

WINBASEAPI DWORD WINAPI SearchProcAddress(HINSTANCE hInst, LPSTR szFunction)
{
    // Add some simple searching to the GetProcAddress function.
    // Various Win32 functions have two versions, a ASCII and
    // a Unicode version.
    DWORD dwAddr;
    char  szName[128];

    if ((dwAddr = (DWORD)GetProcAddress(hInst, szFunction)) == 0) {
        // Function name not found, try some variants
        strcpy(szName, szFunction);
        strcat(szName, "A");            // ASCII
        dwAddr = (DWORD)GetProcAddress(hInst, szName);
    }
    return dwAddr;
}

//------------------------------------------------------------------

WINBASEAPI RESULT WINAPI DynaCall(int Flags, DWORD lpFunction, int nArgs, DYNAPARM Parm[], LPVOID pRet, int nRetSiz)
{
    // Call the specified function with the given parameters. Build a
    // proper stack and take care of correct return value processing.
    RESULT  Res = { 0 };
    int     i, nInd, nSize;
    DWORD   dwEAX, dwEDX, dwVal, *pStack, dwStSize = 0;
    BYTE   *pArg;

    // Reserve 256 bytes of stack space for our arguments
    _asm mov pStack, esp
    _asm sub esp, 0x100

    // Push args onto the stack. Every argument is aligned on a
    // 4-byte boundary. We start at the rightmost argument.
    for (i = 0; i < nArgs; i++) {
        nInd  = (nArgs - 1) - i;
        // Start at the back of the arg ptr, aligned on a DWORD 
        nSize = (Parm[nInd].nWidth + 3) / 4 * 4;
        pArg  = (BYTE *)Parm[nInd].pArg + nSize - 4;
        dwStSize += (DWORD)nSize; // Count no of bytes on stack
        while (nSize > 0) {
            // Copy argument to the stack
            if (Parm[nInd].dwFlags & DC_FLAG_ARGPTR) {
                // Arg has a ptr to a variable that has the arg
                dwVal = *(DWORD *)pArg; // Get first four bytes
                pArg -= 4;              // Next part of argument
            }
            else {
                // Arg has the real arg
                dwVal = Parm[nInd].dwArg;
            }
            // Do push dwVal
            pStack--;           // ESP = ESP - 4
            *pStack = dwVal;    // SS:[ESP] = dwVal
            nSize -= 4;
        }
    }
    if ((pRet != NULL) && ((Flags & DC_BORLAND) || (nRetSiz > 8))) {
        // Return value isn't passed through registers, memory copy
        // is performed instead. Pass the pointer as hidden arg.
        dwStSize += 4;          // Add stack size
        pStack--;               // ESP = ESP - 4
        *pStack = (DWORD)pRet;  // SS:[ESP] = pMem
    }

    _asm add esp, 0x100         // Restore to original position
    _asm sub esp, dwStSize      // Adjust for our new parameters

    // Stack is now properly built, we can call the function
    _asm call [lpFunction]

    _asm mov dwEAX, eax         // Save eax/edx registers
    _asm mov dwEDX, edx         //

    // Possibly adjust stack and read return values.
    if (Flags & DC_CALL_CDECL) {
        _asm add esp, dwStSize
    }
    if (Flags & DC_RETVAL_MATH4) {
        _asm fstp dword ptr [Res]
    }
    else if (Flags & DC_RETVAL_MATH8) {
        _asm fstp qword ptr [Res]
    }
    else if (pRet == NULL) {
        _asm mov  eax, [dwEAX]
        _asm mov  DWORD PTR [Res], eax
        _asm mov  edx, [dwEDX]
        _asm mov  DWORD PTR [Res + 4], edx
    }
    else if (((Flags & DC_BORLAND) == 0) && (nRetSiz <= 8)) {
        // Microsoft optimized less than 8-bytes structure passing
        _asm mov ecx, DWORD PTR [pRet]
        _asm mov eax, [dwEAX]
        _asm mov DWORD PTR [ecx], eax
        _asm mov edx, [dwEDX]
        _asm mov DWORD PTR [ecx + 4], edx
    }
    return Res;
}
