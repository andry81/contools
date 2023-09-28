// CAUTION:
//  This implementation still can not be precise for several reasons.
//  For example, this has 2-phase redirection:
//  1. {
//     {
//         foo
//     } 2>&1 >&6 | pipetimes.exe -a "$ErrIndexFilePath" | tee -a "$ErrFilePath" >&2
//     } 6>&1 | pipetimes.exe -a "$OutIndexFilePath" | tee -a "$OutFilePath"
//
//  To handle different phases of redirection corretly:
//  1. The utility must get all the streams at the same time which not gonna
//     happen because of lags inside the shell output.
//  2. Two processes of pipetimes.exe must process both streams together w/o
//     schedule lags which not gonna happen too, because of not real time OS.
//
//  As a result the $ErrIndexFilePath and $OutIndexFilePath will contain the
//  time lag values.

#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <wchar.h>
#include <wincon.h>
#include <assert.h>
#include <stdio.h>
#include <time.h>
#include <inttypes.h>

#include <vector>
#include <iostream>
#include <fstream>
#include <io.h>
#include <fcntl.h>
#include <sys/stat.h>

#include <mmsystem.h>

#include "common.hpp"

#define USE_NATIVE_IMPLEMENTATION       1
#define REOPEN_HANDLE_INSTEAD_UPDATE    0

#ifdef _UNICODE
#error Unicode is not supported.
#endif


namespace
{
    enum _error
    {
        err_help_output     = -1,
        err_none            = 0,
        err_invalid_format  = 1,
        err_invalid_params  = 2,
        err_io_error        = 16,
        err_unspecified     = 255
    };
}

template <int v>
struct int_identity
{
    static constexpr const int value = v;
};

enum SafeStaticCastType
{
    SafeStaticCastType_CheckSizeof              = 1,
    SafeStaticCastType_CheckAlignof             = 2,
    SafeStaticCastType_CheckSizeofAndAlignof    = 3
};

struct tag_check_sizeof : int_identity<SafeStaticCastType_CheckSizeof> {};
struct tag_check_alignof : int_identity<SafeStaticCastType_CheckAlignof> {};
struct tag_check_sizeof_and_alignof : int_identity<SafeStaticCastType_CheckSizeofAndAlignof> {};

// static_cast(s) with sizeof and alignment test on at least the same size

template <typename T, typename U>
inline T static_cast_extra(const U & v, int_identity<SafeStaticCastType_CheckSizeofAndAlignof> = int_identity<SafeStaticCastType_CheckSizeofAndAlignof>{})
{
    static_assert(sizeof(T) >= sizeof(v), "size of T must fit the size of U");
    static_assert(alignof(T) >= alignof(U), "alignment of T must fit the alignment of U");
    return static_cast<T>(v);
}

template <typename T, typename U>
inline T static_cast_extra(const U & v, int_identity<SafeStaticCastType_CheckSizeof>)
{
    static_assert(sizeof(T) >= sizeof(v), "size of T must fit the size of U");
    return static_cast<T>(v);
}

template <typename T, typename U>
inline T static_cast_extra(const U & v, int_identity<SafeStaticCastType_CheckAlignof>)
{
    static_assert(alignof(T) >= alignof(U), "alignment of T must fit the alignment of U");
    return static_cast<T>(v);
}

HANDLE g_stdin_handle = 0;
HANDLE g_stdout_handle = 0;
const std::streamsize g_stream_reserve_size = 65536;
const std::streamsize g_stream_read_at_once_size = 65536;
const std::streamsize g_stream_min_block_read_size = 4096;

struct AutoHandleBase
{
    HANDLE handle;

    AutoHandleBase(HANDLE handle_ = 0) : handle(handle_) {}
    ~AutoHandleBase()
    {
        if(handle)
        {
            ::CloseHandle(handle);
            handle = 0; // just in case
        }
    }
};

struct FileAutoHandle
{
    FILE* handle;

    FileAutoHandle(FILE* handle_ = NULL) : handle(handle_) {}

    ~FileAutoHandle()
    {
        if(handle)
        {
            fclose(handle);
            handle = 0;
        }
    }
};

struct EventAutoHandle : AutoHandleBase
{
    EventAutoHandle(bool manual_reset, bool initial_state)
    {
        if(!(handle = ::CreateEvent(NULL, manual_reset ? TRUE : FALSE, initial_state ? TRUE : FALSE, NULL)))
            assert(0);
    }
};

bool query_timer_res(LARGE_INTEGER& timer_res)
{
    if(::QueryPerformanceFrequency(&timer_res))
        return true;

    // something is wrong
    const DWORD last_error = ::GetLastError();
    fprintf(stderr, "%s: LastError: %i (0x%08X)\n", __argv[0], last_error, last_error);
    assert(0);

    return false;
}

bool query_time(LARGE_INTEGER& time)
{
    if(::QueryPerformanceCounter(&time))
        return true;

    // something is wrong
    const DWORD last_error = ::GetLastError();
    fprintf(stderr, "%s: LastError: %i (0x%08X)\n", __argv[0], last_error, last_error);
    assert(0);

    return false;
}

bool is_console_handle(HANDLE h)
{
    return ((((ptrdiff_t)h) & 0x10000003) == 0x3) ? true : false;
}

int main(int argc,const char* argv[])
{
    // CAUTION:
    //  In Windows if you call `CreateProcess` like this: `CreateProcess("a.exe", "/b", ...)`, then the `argv[0]` would be `/b`, not `a.exe`!
    //

    if(!argc || !argv[0])
        return err_unspecified;

    if(argc < 2 || !argv[1] || !strlen(argv[1])) {
        return err_invalid_format;
    }

    bool do_show_help = false;
    bool do_append = false;

    if(argc >= 2 && argv[1] && !::strcmp(argv[1], "/?")) {
        if (argc >= 3) return err_invalid_format;
        do_show_help = true; // /?
    }
    else if(!strcmp(argv[1], "/a") || !strcmp(argv[1], "-a"))
    {
        do_append = true;
    }

    if(do_show_help)
    {

#define INCLUDE_HELP_INL_EPILOG(N) ::puts(
#define INCLUDE_HELP_INL_PROLOG(N) );    
#include "gen/help_inl.hpp"

        return err_help_output;
    }

    DWORD last_error;

    g_stdin_handle = ::GetStdHandle(STD_INPUT_HANDLE);
    if(g_stdin_handle == INVALID_HANDLE_VALUE || !g_stdin_handle)
    {
        last_error = ::GetLastError();
        fprintf(stderr,
            "%s: LastError: %i (0x%08X)\n",
            argv[0], last_error, last_error);
        assert(0);
        return 1;
    }

    const bool is_console_handle_res = is_console_handle(g_stdin_handle);
    if(is_console_handle_res)
    {
        // this utility works ONLY in piping mode
        return 2;
    }

    const char* index_file_name;
    const char* pipe_file_name = 0;
    size_t index_file_name_len = 0;
    size_t pipe_file_name_len = 0;
    if(!do_append)
    {
        index_file_name = argv[1];
        if(argc >= 3)
        {
            pipe_file_name = argv[2];
        }
    }
    else
    {
        if(argc < 3 || !argv[2])
        {
            return err_invalid_format;
        }
        index_file_name = argv[2];
        if(argc >= 4)
        {
            pipe_file_name = argv[3];
        }
    }

    index_file_name_len = strlen(index_file_name);
    if(!index_file_name_len)
    {
        return err_invalid_format;
    }

    pipe_file_name_len = pipe_file_name ? strlen(pipe_file_name) : 0;

    FileAutoHandle index_file_handle;
    if(!do_append)
        index_file_handle.handle = fopen(index_file_name, "wb");
    else
        index_file_handle.handle = fopen(index_file_name, "ab");
    if(!index_file_handle.handle)
        return 7;

    FileAutoHandle pipe_file_handle;
    if(pipe_file_name)
        pipe_file_handle.handle = _fsopen(pipe_file_name, "rb", _SH_DENYNO);

    g_stdout_handle = ::GetStdHandle(STD_OUTPUT_HANDLE);

    // reset standard streams as binary streams to disable special line characters formatting
#if !REOPEN_HANDLE_INSTEAD_UPDATE
    // Microsoft Visual C++ 2005 CRT doesn't implement reopening of standard i/o handles
    // by freopen function.
    _setmode(0, _O_BINARY);
    _setmode(1, _O_BINARY);
#else
    // need to duplicate system handle before reopen it!
    HANDLE current_proc_handle = GetCurrentProcess();
    {
        HANDLE stdin_handle_copy = 0;
        if(!DuplicateHandle(current_proc_handle, g_stdin_handle, current_proc_handle, &stdin_handle_copy, 0, FALSE, DUPLICATE_SAME_ACCESS))
            assert(0);
        freopen("conin$", "rb", stdin);
        if(SetStdHandle(STD_INPUT_HANDLE, stdin_handle_copy))
            g_stdin_handle = stdin_handle_copy;
    }
    {
        HANDLE stdout_handle_copy = 0;
        if(!DuplicateHandle(current_proc_handle, g_stdout_handle, current_proc_handle, &stdout_handle_copy, 0, FALSE, DUPLICATE_SAME_ACCESS))
            assert(0);
        freopen("conout$", "ab", stdout);
        if(SetStdHandle(STD_OUTPUT_HANDLE, stdout_handle_copy))
            g_stdout_handle = stdout_handle_copy;
    }
#endif

    /*
    // open console buffer's handle
    AutoHandleBase stdin_buffer_handle =
        ::CreateFile("CONIN$", GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ, 0, OPEN_EXISTING, 0, 0);
    //AutoHandleBase stdout_buffer_handle =
    //    ::CreateFile("CONOUT$", GENERIC_READ|GENERIC_WRITE, FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0);

    // update console mode to read asynchroniously
    DWORD console_mode = 0;
    if(GetConsoleMode(stdin_buffer_handle.handle, &console_mode))
    {
        console_mode &= ~(ENABLE_LINE_INPUT | ENABLE_ECHO_INPUT);
        if(!SetConsoleMode(stdin_buffer_handle.handle, console_mode))
        {
            last_error = GetLastError();
            fprintf(stderr,
                "%s: LastError: %i (0x%08X)\n",
                __argv[0], last_error, last_error);
            assert(0);
        }
    }
    else
    {
        last_error = GetLastError();
        fprintf(stderr,
            "%s: LastError: %i (0x%08X)\n",
            __argv[0], last_error, last_error);
        assert(0);
    }
    */

    // same for the CRT layer
    setvbuf(stdin, NULL, _IONBF, 0);

    // just in case: http://stackoverflow.com/questions/9371238/why-is-reading-lines-from-stdin-much-slower-in-c-than-python
    std::ios_base::sync_with_stdio(false);

#if USE_NATIVE_IMPLEMENTATION
    // implementation via Win32 API (preferred because more precise in time quality)

    /*
    // Because thread could switch context from one core/processor to another on multicore/multiprocessor
    // systems and the function QueryPerformanceCounter could use counter-per-core/processor, then it may involve
    // not linear (and so asynchronicity) counting in case when threads switching between cores/processors
    // This is because the linearity of counting is not requirement of the function QueryPerformanceCounter
    // in case of usage on multiple cores/processors, this is requirement only for a single core at a time.
    // To avoid not linear counting, we should freeze thread only under one core/processor to avoid
    // problems with time line linearity of counting.
    DWORD process_affinity_mask;
    DWORD system_affinity_mask;
    const BOOL process_res = ::GetProcessAffinityMask(GetCurrentProcess(), &process_affinity_mask, &system_affinity_mask);
    if(process_res)
    {
        for(int i = 0; i < sizeof(process_affinity_mask)*8; i++)
        {
            if(process_affinity_mask & (0x1<<i))
            {
                // stick to the first available core/processor.
                DWORD process_new_affinity_mask = (0x1<<i);
                if(!::SetProcessAffinityMask(GetCurrentProcess(), process_new_affinity_mask))
                    assert(0); // just in case.
                DWORD thread_new_affinity_mask = process_new_affinity_mask;
                if(!::SetThreadAffinityMask(GetCurrentThread(), thread_new_affinity_mask))
                    assert(0); // just in case.
                break;
            }
        }
    }
    else
        assert(0); // ignore affinity set.
    */

    /*
    LARGE_INTEGER li_start_time;
    LARGE_INTEGER li_time1;
    LARGE_INTEGER li_time2;
    LARGE_INTEGER li_time_res;

    const unsigned __int64 time_scale = 100000;

    if(!query_timer_res(li_time_res))
        return 8;

    // remember first counter value to store only relative values
    if(!query_time(li_start_time))
        return 9;
        */

    std::vector<unsigned char> input_stream_buf;
    std::streamsize input_stream_offset_index = 0;
    OVERLAPPED read_overlapped;
    EventAutoHandle read_async_accomplish_event(FALSE, TRUE); // will close automatically
    struct _stat64 pipe_file_stat;

    input_stream_buf.resize(g_stream_reserve_size);
    memset(&read_overlapped, 0, sizeof(read_overlapped));
    read_overlapped.hEvent = read_async_accomplish_event.handle;

    bool do_read = true;

    do
    {
        // read begin time
        DWORD begin_time_msec = timeGetTime();
        //if(!query_time(li_time1))
        //    li_time1 = 0; // continue piping at any cost

        // read console input
        DWORD num_read_chars = 0;
        const DWORD read_res = ::ReadFile(g_stdin_handle, &input_stream_buf[0],
            g_stream_read_at_once_size, &num_read_chars, &read_overlapped);
        last_error = GetLastError();

        if(!read_res)
        {
            switch(last_error)
            {
                case ERROR_IO_PENDING:
                    begin_time_msec = timeGetTime();
                    break;

                case ERROR_BROKEN_PIPE:
                    do_read = false;
                    continue;
                    break;

                default:
                    fprintf(stderr,
                        "%s: ReadLastError: %i (0x%08X)\n",
                        __argv[0], last_error, last_error);
                    assert(0);
                    do_read = false;
                    continue;
                    break;
            }

            // update begin time
            begin_time_msec = timeGetTime();

            if(!::GetOverlappedResult(g_stdin_handle, &read_overlapped, &num_read_chars, TRUE))
            {
                last_error = GetLastError();
                switch(last_error)
                {
                    case ERROR_BROKEN_PIPE:
                        do_read = false;
                        break;

                    default:
                        fprintf(stderr,
                            "%s: LastError: %i (0x%08X)\n",
                            __argv[0], last_error, last_error);
                        assert(0);
                }
            }
        }

        if(num_read_chars)
        {
            // read end time
            const DWORD end_time_msec = timeGetTime();
            //if(!query_time(li_time2))
            //    li_time2 = 0; // continue piping at any cost

            //const long double timeValue = long double(li_time1.QuadPart);
            //const long double timeRes = long double(li_time_res.QuadPart)/time_scale;

            //fprintf(index_file_handle.handle, "%I64X %I64X %X %X\n",
            //    unsigned __int64(timeValue/timeRes), input_stream_offset_index, input_stream_len);

            //FILE_BASIC_INFO fbi;
            //memset(&fbi, 0, sizeof(fbi));
            //GetFileInformationByHandleEx(g_stdin_handle, FileBasicInfo, &fbi, sizeof(fbi));

            if(pipe_file_handle.handle && !_fstat64(_fileno(pipe_file_handle.handle), &pipe_file_stat))
            {
                fprintf(index_file_handle.handle, "%X %X %" PRIxPTR " %X %I64X\n",
                    begin_time_msec, end_time_msec, size_t(static_cast_extra<uint64_t>(input_stream_offset_index)), num_read_chars, pipe_file_stat.st_mtime); // CAUTION: input_stream_offset_index truncation to 32-bit
            }
            else
            {
                fprintf(index_file_handle.handle, "%X %X %" PRIxPTR " %X\n",
                    begin_time_msec, end_time_msec, size_t(static_cast_extra<uint64_t>(input_stream_offset_index)), num_read_chars); // CAUTION: input_stream_offset_index truncation to 32-bit
            }
            //fflush(index_file_handle.handle);

            input_stream_offset_index += num_read_chars;

            // push input to output as is
            DWORD num_written_chars = 0;
            ::WriteFile(g_stdout_handle, &input_stream_buf[0], num_read_chars, &num_written_chars, NULL);
        }

        if(do_read)
            Sleep(0); // provoke thread context switch
    }
    while(do_read);

#else
    // implementation via C++ streams

    std::vector<char> input_stream_buf;
    std::vector<char> input_stream_at_once_buf;

    std::streamsize overall_input_stream_len = 0;
    std::streamsize input_stream_len;
    std::streamsize inputStreamAtOnceLen;

    input_stream_buf.reserve(g_stream_read_at_once_size*16);
    input_stream_at_once_buf.resize(g_stream_read_at_once_size);

    bool isInputFail = std::cin.fail();
    bool isInputEof = std::cin.eof();
    bool isInputBad = false;
    bool isInputGood = false;

    bool readTime = true;
    bool printTime = false;

    std::ios_base::sync_with_stdio(false); // speedup: http://stackoverflow.com/questions/9371238/why-is-reading-lines-from-stdin-much-slower-in-c-than-python

    while(!isInputEof)
    {
        input_stream_buf.resize(0);
        input_stream_len = 0; // including null-terminating character.

        //printf("!=%I64X:%I64X\n", li_time.QuadPart, li_time_res.QuadPart);
        if(isInputFail)
        {
            // enable next read.
            std::cin.clear();
        }

        // actually, input stream awaiting inside function std::cin::getline.
        std::cin.getline(&input_stream_at_once_buf[0], g_stream_read_at_once_size);
        inputStreamAtOnceLen = std::cin.gcount();

        // if not empty input.
        if(readTime && inputStreamAtOnceLen > 0)
        {
            if(!query_time(li_time))
                return 10;

            readTime = false;
            printTime = true;
        }

        isInputFail = std::cin.fail();
        isInputEof = std::cin.eof();
        isInputBad = std::cin.bad();
        isInputGood = std::cin.good();
        //input_stream_at_once_buf[inputStreamAtOnceLen] = '\0';

        // if is out of buffer.
        bool may_out_of_buf = isInputFail && !isInputEof && !isInputBad;
        // if is delimiter character reached.
        bool isDelimiterHit = !isInputFail && !isInputEof && !isInputBad && isInputGood;

        const bool wasOutOfBuffer = may_out_of_buf;
        while(may_out_of_buf)
        {
            // out of buffer.
            if(inputStreamAtOnceLen > 0)
            {
                // excluding null-terminating character.
                input_stream_buf.resize(input_stream_len+inputStreamAtOnceLen+1);
                memcpy(&input_stream_buf[input_stream_len], &input_stream_at_once_buf[0],
                    sizeof(input_stream_at_once_buf[0])*(inputStreamAtOnceLen+1));

                input_stream_len += inputStreamAtOnceLen;
            }

            if(isInputFail)
            {
                // enable next read.
                std::cin.clear();
            }

            std::cin.getline(&input_stream_at_once_buf[0],g_stream_read_at_once_size);
            inputStreamAtOnceLen = std::cin.gcount();
            isInputFail = std::cin.fail();
            isInputEof = std::cin.eof();
            isInputBad = std::cin.bad();
            isInputGood = std::cin.good();
            //input_stream_at_once_buf[inputStreamAtOnceLen] = '\0';

            // if is out of buffer.
            may_out_of_buf = isInputFail && !isInputEof && !isInputBad;
            // if is delimiter character reached.
            isDelimiterHit = !isInputFail && !isInputEof && !isInputBad && isInputGood;
        }
        if(inputStreamAtOnceLen > 0)
        {
            if(!wasOutOfBuffer)
                input_stream_len += inputStreamAtOnceLen-1;
            else
            {
                // make last copy.
                input_stream_buf.resize(input_stream_len+inputStreamAtOnceLen);
                memcpy(&input_stream_buf[input_stream_len], &input_stream_at_once_buf[0],
                    sizeof(input_stream_at_once_buf[0])*(inputStreamAtOnceLen-1));

                input_stream_len += inputStreamAtOnceLen-1;
            }
        }

        if(!inputStreamAtOnceLen)
        {
            continue;
        }

        if(input_stream_len)
        {
            if(is_unix_output)
            {
                // discard last CR character at the end of line.
                if(!wasOutOfBuffer)
                {
                    if(input_stream_at_once_buf[input_stream_len-1] == '\x0D')
                        input_stream_len--;
                }
                else
                {
                    if(input_stream_buf[input_stream_len-1] == '\x0D')
                        input_stream_len--;
                }
            }
        }
        if(input_stream_len)
        {
            fwrite(!wasOutOfBuffer ? &input_stream_at_once_buf[0] : &input_stream_buf[0],
                input_stream_len, 1, stdout);
        }
        if(isDelimiterHit)
        {
            if(g_text_output_type)
            {
                fwrite("\x0A", 1, 1, stdout);
            }
            else
            {
                // add CR character to output if not wrote yet.
                if(!wasOutOfBuffer)
                {
                    if(input_stream_at_once_buf[input_stream_len-1] != '\x0D')
                    {
                        input_stream_len++;
                        fwrite("\x0D\x0A", 2, 2, stdout);
                    }
                    else
                    {
                        fwrite("\x0A", 1, 1, stdout);
                    }
                }
                else
                {
                    if(input_stream_buf[input_stream_len-1] != '\x0D')
                    {
                        input_stream_len++;
                        fwrite("\x0D\x0A", 2, 2, stdout);
                    }
                    else
                    {
                        fwrite("\x0A", 1, 1, stdout);
                    }
                }
            }
        }
        std::cout.flush(); // write at once if buffered output.

        if(printTime)
        {
            const long double timeValue = long double(li_time.QuadPart);
            const long double timeRes = long double(li_time_res.QuadPart)/time_scale;

            fprintf(index_file_handle,g_text_output_type ? "%I64X %X %X\n" : "%I64X %X %X\r\n",
                unsigned __int64(timeValue/timeRes), overall_input_stream_len, input_stream_len+1);
            //fflush(index_file_handle); // write at once if buffered output.

            printTime = false;
        }

        if(!readTime)
        {
            if(isDelimiterHit)
                readTime = true;
        }

        if(isDelimiterHit)
            overall_input_stream_len += input_stream_len+1;
    }
#endif

    return 0;
}
