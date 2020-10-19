/*
 * specinvoke - run and accurately time lists of commands
 * Copyright 1998-2017 Standard Performance Evaluation Corporation
 *
 * win32.c: Windows-specific functions
 *
 * $Id: win32.c 5904 2018-04-19 17:53:15Z CloyceS $
 */

#include "specinvoke.h"

char *impl_vcrev = "$Revision: 5904 $";

extern int debug;  /* From specinvoke.c */

HANDLE *win32_handles;
long   *win32_pids;
long   win32_count;
__int64 qpc_freq = -1;
time_t base_time = 0;
long   win32_enqueue_index = MAXIMUM_WAIT_OBJECTS;
long   win32_dequeue_index = MAXIMUM_WAIT_OBJECTS;

static __int64 get_qpc_freq(int do_exit);

void init_state(specinvoke_state_t *si) {
    si->timer_type  = NONE;
    /* These values are not actually used... */
    si->invoke_args = NULL;
    si->command_ptr = NULL;
    si->shell       = NULL;
}

void init_os(int num) {
    check_malloc(win32_handles, HANDLE *, (num + 1) * sizeof(HANDLE), NULL,
                 stderr, "Failed allocating space for handle array.\n")
    check_malloc(win32_pids,    long *,   (num + 1) * sizeof(DWORD),  NULL,
                 stderr, "Failed allocating space for PID array.\n")
    win32_count   = 0;
}
void reinit_os() {
    win32_count   = 0;
}

void cleanup_os(UNUSED_PARAM(specinvoke_state_t *si)) {
    UNUSED_VAR(si);
}

pid_t invoke(copy_info_t *ui, command_info_t *ci,
        UNUSED_PARAM(char **env),
        specinvoke_state_t *si) {
    PROCESS_INFORMATION stProcInfo;
    STARTUPINFO         stStartInfo;
    SECURITY_ATTRIBUTES stSecAttr;
    char *dir    = (ui->dir == NULL) ? ci->dir : ui->dir,
         *numbuf = NULL,
         *cmd    = ci->cmd,
         *tmpcmd = NULL;
    UNUSED_VAR(env);

    int ret_iter;
    if (si->dry_run)
        return dry_invoke(ui, ci, si);

    gettime(si, &(ui->start_time));

    if (dir && _chdir(dir)) {
        fprintf (stderr, "Can't change directory to '%s' for copy #%d: %s(%d)\n",
                ci->dir, ui->num, strerror(errno), errno);
        fprintf (si->outfp, "Can't change directory to '%s' for copy #%d: %s(%d)\n",
                ci->dir, ui->num, strerror(errno), errno);
        return -1;
    }

    stSecAttr.nLength = sizeof (stSecAttr);
    stSecAttr.lpSecurityDescriptor = NULL;
    stSecAttr.bInheritHandle = TRUE;

    memset (&stStartInfo, 0, sizeof (stStartInfo)); /* Clear the block */
    stStartInfo.cb = sizeof (stStartInfo);          /* Set the structure size */
    stStartInfo.dwFlags = STARTF_USESTDHANDLES;     /* Use handles I pass it */

    /* Do bind variable subtitution */
    if (ui->bind != 0) {
        tmpcmd = sub_strings(cmd, BINDSTRVAR, ui->bind);
        if (tmpcmd == NULL)
            return -1;
        if (cmd != ci->cmd)
            free(cmd);
        cmd = tmpcmd;
    }

    /* Do copy number subtitution */
    numbuf = make_number_buf(ui->num);
    if (numbuf == NULL) {
        /* Something bad happened.  Give up instead of executing a bad
         * (unsubstituted) command.
         */
        return -1;
    }
    tmpcmd = sub_strings(cmd, COPYNUMVAR, numbuf);
    if (tmpcmd == NULL)
        return -1;
    if (cmd != ci->cmd)
        free(cmd);
    cmd = tmpcmd;
    free(numbuf);

    if (cmd == ci->cmd) {
        /* Make a free()able copy */
        cmd = strdup(ci->cmd);
    }

    if (si->redir) {
        if (ci->err) {
            stStartInfo.hStdError = CreateFile (
                    ci->err,                      /* pointer to name of the file */
                    GENERIC_WRITE,                /* access (read-write) mode */
                    FILE_SHARE_READ | FILE_SHARE_DELETE, /* share mode */
                    &stSecAttr,                   /* pointer to security attrib. */
                    CREATE_ALWAYS,                /* how to create */
                    FILE_ATTRIBUTE_NORMAL,        /* file attributes */
                    NULL);
            if (stStartInfo.hStdError == INVALID_HANDLE_VALUE) {
                fprintf(stderr, "Can't open '%s' to attach to error handle for copy #%d\n",
                        ci->err, ui->num);
                fprintf(si->outfp, "Can't open '%s' to attach to error handle for copy #%d\n",
                        ci->err, ui->num);
                return -1;
            }
        }
        if (ci->input) {
            stStartInfo.hStdInput = CreateFile (
                    ci->input,              /* pointer to name of the file */
                    GENERIC_READ,           /* access (read-write) mode */
                    FILE_SHARE_READ | FILE_SHARE_DELETE, /* share mode */
                    &stSecAttr,             /* pointer to security attributes */
                    OPEN_EXISTING,          /* how to create */
                    FILE_ATTRIBUTE_NORMAL,  /* file attributes */
                    NULL);
            if (stStartInfo.hStdInput == INVALID_HANDLE_VALUE) {
                fprintf(stderr, "Can't open '%s' to attach to input handle for copy #%d\n",
                        ci->input, ui->num);
                fprintf(si->outfp, "Can't open '%s' to attach to input handle for copy #%d\n",
                        ci->input, ui->num);
                return -1;
            }
        } else {
            if (si->no_stdin == NUL) {
                /* Open NUL: for stdin */
                stStartInfo.hStdInput = CreateFile (
                        "NUL:",                 /* pointer to name of the file */
                        GENERIC_READ,           /* access (read-write) mode */
                        FILE_SHARE_READ | FILE_SHARE_DELETE, /* share mode */
                        &stSecAttr,             /* pointer to security attributes */
                        OPEN_EXISTING,          /* how to create */
                        FILE_ATTRIBUTE_NORMAL,  /* file attributes */
                        NULL);
                if (stStartInfo.hStdInput == INVALID_HANDLE_VALUE) {
                    fprintf(stderr, "Can't open NUL: to attach to input handle for copy #%d\n",
                            ui->num);
                    fprintf(si->outfp, "Can't open NUL: to attach to input handle for copy #%d\n",
                            ui->num);
                    return -1;
                }
            } else if (si->no_stdin == ZEROFILE) {
                /* Create a zero-length file for stdin */
                char *tmpfile;
                check_malloc(tmpfile, char *, 255 * sizeof(char),
                        stderr, return -1,
                        "Failed allocating space for temporary zero-length input file name.\n")
                int rc = sprintf(tmpfile, "spec_empty_file.%u.%ld", ui->num, (long) ui->pid);
                if (rc < 0) {
                    fprintf(stderr, "Can't create temporary filename for zero-length file to attach to stdin for copy #%d\n",
                            ui->num);
                    fprintf(si->outfp, "Can't create temporary filename for zero-length file to attach to stdin for copy #%d\n",
                            ui->num);
                    return -1;
                }
                stStartInfo.hStdInput = CreateFile (
                        tmpfile,                /* pointer to name of the file */
                        GENERIC_READ,           /* access (read-write) mode */
                        FILE_SHARE_READ | FILE_SHARE_DELETE, /* share mode */
                        &stSecAttr,             /* pointer to security attributes */
                        CREATE_ALWAYS,          /* how to create */
                        FILE_ATTRIBUTE_TEMPORARY,     /* file attributes */
                        NULL);
                if (stStartInfo.hStdInput == INVALID_HANDLE_VALUE) {
                    fprintf(stderr, "Can't create zero-length file '%s' to attach to input handle for copy #%d\n",
                            tmpfile, ui->num);
                    fprintf(si->outfp, "Can't create zero-length file '%s' to attach to input handle for copy #%d\n",
                            tmpfile, ui->num);
                    return -1;
                }
                free(tmpfile);
            } else {
                /* Just use regular stdin */
                stStartInfo.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
            }
        }
        if (ci->output) {
               stStartInfo.hStdOutput = CreateFile (
                    ci->output,                   /* pointer to name of the file */
                    GENERIC_WRITE,                /* access (read-write) mode */
                    FILE_SHARE_READ | FILE_SHARE_DELETE, /* share mode */
                    &stSecAttr,                   /* ptr to security attributes */
                    CREATE_ALWAYS,                /* how to create */
                    FILE_ATTRIBUTE_NORMAL,        /* file attributes */
                    NULL);
            if (stStartInfo.hStdOutput == INVALID_HANDLE_VALUE) {
                fprintf(stderr, "Can't open file '%s' to attach to output handle for copy #%d\n",
                        ci->output, ui->num);
                fprintf(si->outfp, "Can't open file '%s' to attach to output handle for copy #%d\n",
                        ci->output, ui->num);
                return -1;
            }
        }
    } else {
        /* Just use regular handles */
        stStartInfo.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
        stStartInfo.hStdOutput = GetStdHandle(STD_OUTPUT_HANDLE);
        stStartInfo.hStdError = GetStdHandle(STD_ERROR_HANDLE);
    }

    if (CreateProcess (
                NULL,                     /* Command to execute */
                cmd,                      /* Command line args */
                NULL,                     /* Default process security */
                NULL,                     /* Default thread security */
                TRUE,                     /* Must be TRUE to use std handles */
                NORMAL_PRIORITY_CLASS,    /* No special scheduling */
                NULL,                     /* Inherit our environment block */
                NULL,                     /* Inherit our currrent directory */
                &stStartInfo,             /* Start info*/
                &stProcInfo)) {           /* <- Process info */
        /* We increment the overall count variable at the end */
        if(win32_count >= MAXIMUM_WAIT_OBJECTS)
        {
            win32_handles[win32_enqueue_index] = stProcInfo.hProcess;
            win32_pids[win32_enqueue_index] = stProcInfo.dwProcessId;
        } else {
            win32_handles[win32_count] = stProcInfo.hProcess;
            win32_pids[win32_count]    = stProcInfo.dwProcessId;
        }
    } else {
        fprintf(stderr, "Can't create process for copy #%d (cmd='%s')\n",
                ui->num, cmd);
        fprintf(si->outfp, "Can't create process for copy #%d (cmd='%s')\n",
                ui->num, cmd);
        return -1;
    }
    if (si->redir) {
        if (ci->output)  CloseHandle (stStartInfo.hStdOutput);
        if (si->no_stdin != ZEROFILE && si->no_stdin != NUL)
            if (ci->input) CloseHandle (stStartInfo.hStdInput);
        if (ci->err)     CloseHandle (stStartInfo.hStdError);
    }

    ui->pid = (win32_count >= MAXIMUM_WAIT_OBJECTS) ? win32_pids[win32_enqueue_index] : win32_pids[win32_count];
    fprintf (si->outfp, "child started: %u,\t%" PRId64 ", %" PRId64 ", pid=%ld, '%s'\n", ui->num,
            (long long) ui->start_time.sec, (long long) ui->start_time.nsec,
            (long) ui->pid, cmd);

    free(cmd); /* No sense wasting memory */
    ret_iter = (win32_count >= MAXIMUM_WAIT_OBJECTS) ? win32_enqueue_index : win32_count;

    /* get next enqueue buffer index */
    if(win32_count>=MAXIMUM_WAIT_OBJECTS)
    {
        win32_enqueue_index++;
    } else {
        win32_enqueue_index = MAXIMUM_WAIT_OBJECTS;
    }

    /* increment */
    win32_count++;

    return win32_pids[ret_iter];
}

long wait_for_next (long *status, bool nowait) {
    DWORD rc;
    long pid = -1;
    int index;
    DWORD count = (win32_count > MAXIMUM_WAIT_OBJECTS) ? MAXIMUM_WAIT_OBJECTS : win32_count;

    /* The caller uses errno to figure out what (if anything) went wrong
     * when the return is -1.
     */
    errno = 0;

    if (win32_count == 0) {
        return 0;
    }
    /* Note nowait is hardcoded to true in the call in specinvoke.c, so this
     * call always blocks
     */
    rc = WaitForMultipleObjects (count, win32_handles, FALSE, nowait ? 0 : INFINITE);
    if (rc >= WAIT_OBJECT_0 && rc < (unsigned)(WAIT_OBJECT_0 + count)) {
        index = rc - WAIT_OBJECT_0;
        if (!GetExitCodeProcess(win32_handles[index], (LPDWORD)status)) {
            /* Something went wrong, so mark this process as bad but keep
             * going.
             */
            fprintf (stderr, "Can't get exit code for process handle in slot %d", index);
            *status = 1;
        }
        if (*status == STILL_ACTIVE) {
            /* tell specinvoke to go around again */
            *status = 0;
            errno = EINTR;
            return -1;
        }
        pid = win32_pids[index];
        CloseHandle (win32_handles[index]);

#define FILL_FINISHED_PROCESS_SLOT \
        if(win32_count >= MAXIMUM_WAIT_OBJECTS                            \
                && win32_dequeue_index < win32_enqueue_index)             \
        {                                                                 \
            /* the handle at 'index' is now not in use so we overwrite it \
             * and decrement the process count                            \
             */                                                           \
            win32_handles[index] = win32_handles[win32_dequeue_index];    \
            win32_pids[index] = win32_pids[win32_dequeue_index];          \
            win32_dequeue_index++;                                        \
            win32_count--;                                                \
        } else {                                                          \
            /* Move one in from the end so we check fewer handles for     \
             * completion                                                 \
             * */                                                         \
            win32_count--;                                                \
            win32_handles[index] = win32_handles[win32_count];            \
            win32_pids   [index] = win32_pids   [win32_count];            \
        }
        FILL_FINISHED_PROCESS_SLOT
    } else if (rc >= WAIT_ABANDONED_0 && rc < (unsigned)(WAIT_ABANDONED_0 + count)) {
        /* This should only happen if the handle is a mutex, and that should
         * NEVER be the case here, so just replace it in the index and return
         * a status that will ensure that the run tanks.
         */
        index = rc - WAIT_ABANDONED_0;
        fprintf (stderr, "Mutex handle abandoned! (pid=%ld)\n", win32_pids[index]);
        CloseHandle (win32_handles[index]);

        FILL_FINISHED_PROCESS_SLOT

        *status = 1;
        errno = EINVAL;
        return -1;
    } else if (rc == WAIT_TIMEOUT) {
        if (nowait) {
            fprintf (stderr, "MsgWaitForMultipleObjects timed out when no timeout was requested!  How did THAT happen?\n");
        }
        /* tell specinvoke to just try again */
        errno = EINTR;
        return -1;
    } else {
        // rc == WAIT_FAILED, or something not documented
        int errnum = GetLastError ();
        fprintf (stderr, "WaitForMultipleObjects failed (rc=%lu; errnum=%d)\n",
                rc, errnum);
        *status = 1;
        errno = EINVAL;
        return -1;
    }
    return pid;
}

void print_no_stdin_setup(
        copy_info_t *ui,
        UNUSED_PARAM(command_info_t *ci),
        specinvoke_state_t *si) {
    if (si->no_stdin == ZEROFILE) {
        printf ("type NUL > spec_empty_file.%u.%ld\n", ui->num, (long) ui->pid);
    }
}
void print_no_stdin_use(
        copy_info_t *ui,
        UNUSED_PARAM(command_info_t *ci),
        specinvoke_state_t *si)
{
    if (si->no_stdin == NUL) {
        printf (" < NUL");
    } else if (si->no_stdin == ZEROFILE) {
        printf (" < spec_empty_file.%u.%ld", ui->num, (long) ui->pid);
    } else {
        /* specinvoke on Windows doesn't actually _do_ CLOSE */
    }
}
void  print_no_stdin_teardown(
        copy_info_t *ui,
        UNUSED_PARAM(command_info_t *ci),
        specinvoke_state_t *si)
{
    if (si->no_stdin == ZEROFILE) {
        printf ("del spec_empty_file.%u.%ld\n", ui->num, (long) ui->pid);
    }
}

void gettime(specinvoke_state_t *si, spec_time_t *t) {
    LARGE_INTEGER count, tmp_ns;
    struct _timeb tb;

    /* This just makes the compiler not whine */
    t->sec = t->nsec = 0;

    switch (si->timer_type) {
        case QPC:
            if (qpc_freq < 0) {
                /* QPC was selected, but we don't know the frequency yet.
                 * Go get it, and fail if that's not possible.
                 */
                qpc_freq = get_qpc_freq(1);
            }
            QueryPerformanceCounter(&count);
            /* Seconds is easy */
            t->sec = base_time + (count.QuadPart / qpc_freq);
            /* Get fractional seconds in terms of QPC ticks */
            tmp_ns.QuadPart = count.QuadPart % qpc_freq;
            /* Scale up... */
            tmp_ns.QuadPart *= 1000000000LL;
            /* ...then back down to just nanoseconds */
            tmp_ns.QuadPart /= qpc_freq;
            t->nsec = (time_t)tmp_ns.QuadPart;
            break;
        case FTIME:
            _ftime(&tb);
            t->sec  = tb.time + (tb.timezone * 60);
            t->nsec = tb.millitm * 1000000;
            break;
        case NONE:
            qpc_freq = get_qpc_freq(0);
            if (qpc_freq > 0) {
                if (debug)
                    printf("# gettime(): QueryPerformanceFrequency returned %I64d for counts/sec; base timestamp is %lu\n",
                            qpc_freq, (unsigned long)base_time);
                si->timer_type = QPC;
            } else {
                fprintf(stderr, "QueryPerformanceFrequency failed; falling back to _ftime\n");
                si->timer_type = FTIME;
            }
            gettime(si, t);
            break;
        default:
            fprintf(stderr, "Unsupported timer type (%d) in gettime()\n", (int)si->timer_type);
            /* This exit is okay, since gettime() is called before spawning
             * any children, so specinvoke won't leave any orphans.
             */
            specinvoke_exit(1, si);
            break;
    }
}

int specmillisleep(time_t milliseconds) {
    Sleep(milliseconds);
    return(0);
}

static __int64 get_qpc_freq(int do_exit) {
    LARGE_INTEGER count;

    if (QueryPerformanceFrequency(&count)) {
        /* Get the base timestamp to add to the counts returned by
         * QueryPerformanceCounter() to make a plausible timestamp.
         */
        time_t curtime     = time(NULL);
        __int64 tmp_qpc_freq = count.QuadPart;
        QueryPerformanceCounter(&count);
        base_time = curtime - (count.QuadPart / tmp_qpc_freq);

        return tmp_qpc_freq;
    } else if (do_exit != 0) {
        fprintf(stderr, "QueryPerformanceFrequency failed\n");
        specinvoke_exit(do_exit, (specinvoke_state_t *)NULL);
    }

    return -1;
}

/* Editor settings: (please leave this at the end of the file)
 * vim: set filetype=c syntax=c shiftwidth=4 tabstop=8 expandtab nosmarttab ai:
 */
