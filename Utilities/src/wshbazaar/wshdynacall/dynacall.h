//------------------------------------------------------------------
//  Dynacall.h - 32-bit Dynamic function calls. Ton Plooy 1998
//------------------------------------------------------------------
#ifndef __DYNACALL_H
#define __DYNACALL_H

#include <windef.h>
#include <winnt.h>
#include <guiddef.h>

#define  DC_MICROSOFT           0x0000      // Default
#define  DC_BORLAND             0x0001      // Borland compat
#define  DC_CALL_CDECL          0x0010      // __cdecl
#define  DC_CALL_STD            0x0020      // __stdcall
#define  DC_RETVAL_MATH4        0x0100      // Return value in ST
#define  DC_RETVAL_MATH8        0x0200      // Return value in ST

#define  DC_CALL_STD_BO         (DC_CALL_STD | DC_BORLAND)
#define  DC_CALL_STD_MS         (DC_CALL_STD | DC_MICROSOFT)
#define  DC_CALL_STD_M8         (DC_CALL_STD | DC_RETVAL_MATH8)

#define  DC_FLAG_ARGPTR         0x00000002

#pragma pack(1)                 // Set struct packing to one byte

typedef union RESULT {          // Various result types
    int     Int;                // Generic four-byte type
    long    Long;               // Four-byte long
    void   *Pointer;            // 32-bit pointer
    float   Float;              // Four byte real
    double  Double;             // 8-byte real
    __int64 int64;              // big int (64-bit)
} RESULT;

typedef struct DYNAPARM {
    DWORD       dwFlags;        // Parameter flags
    int         nWidth;         // Byte width
    union {                     // 
        DWORD   dwArg;          // 4-byte argument
        void   *pArg;           // Pointer to argument
    };
} DYNAPARM;

WINBASEAPI DWORD WINAPI SearchProcAddress(HINSTANCE hInst, LPSTR szFunction);
WINBASEAPI RESULT WINAPI DynaCall(int Flags, DWORD lpFunction, int nArgs, DYNAPARM Parm[], LPVOID pRet, int nSize);

#endif
