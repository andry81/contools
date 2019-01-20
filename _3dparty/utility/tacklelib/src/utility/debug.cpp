#include <tacklelib/utility/debug.hpp>
#include <tacklelib/utility/platform.hpp>

#if defined(UTILITY_PLATFORM_WINDOWS)
#include <windows.h>
#include <intrin.h>
#elif defined(UTILITY_PLATFORM_POSIX)
#include <sys/ptrace.h>
#include <signal.h>
static void signal_handler(int) { }
#else
#error is_under_debugger is not supported for this platform
#endif


namespace utility {

void debug_break(bool condition)
{
    DEBUG_BREAK_IN_DEBUGGER(condition); // avoid signal if not under debugger
}

bool is_under_debugger()
{
#if defined(UTILITY_PLATFORM_WINDOWS)
    return ::IsDebuggerPresent() ? true : false;
#elif defined(UTILITY_PLATFORM_POSIX)
    return ptrace(PTRACE_TRACEME, 0, NULL, 0) == -1;
// another implementation from the StackOverflow site: http://stackoverflow.com/questions/3596781/detect-if-gdb-is-running
// USE IN EMERGENCY SITUATION
//#include <sys/stat.h>
//#include <string.h>
//#include <fcntl.h>
//
//int IsDebuggerPresent(void)
//{
//    char buf[1024];
//    int debugger_present = 0;
//
//    int status_fd = open("/proc/self/status", O_RDONLY);
//    if (status_fd == -1)
//        return 0;
//
//    ssize_t num_read = read(status_fd, buf, sizeof(buf));
//
//    if (num_read > 0)
//    {
//        static const char TracerPid[] = "TracerPid:";
//        char *tracer_pid = strstr(buf, TracerPid);
//
//        if (tracer_pid)
//            debugger_present = atoi(tracer_pid + sizeof(TracerPid) - 1) ? true : false;
//    }
//
//    return debugger_present;
//}
#endif
}

}
