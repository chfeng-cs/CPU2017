/*
 * specinvoke - run and accurately time lists of commands
 * Copyright 1998-2016 Standard Performance Evaluation Corporation
 *
 * unix.c: Functions for UNIX and UNIX-like systems
 *
 * $Id: unix.c 4356 2016-05-26 21:09:32Z CloyceS $
 */

#include "specinvoke.h"

char *impl_vcrev = "$Revision: 4356 $";

extern int debug;  /* From specinvoke.c */

void init_state(specinvoke_state_t *si) {
    check_malloc(si->invoke_args, char **, 4 * sizeof(char *), stderr,
                 specinvoke_exit(1, si),
                 "Failed allocating storage for state structure.\n")
    si->invoke_args[0] = "/bin/sh";
    si->invoke_args[1] = "-c";
    si->invoke_args[2] = "replace_me";
    si->invoke_args[3] = 0;
    si->command_ptr    = &(si->invoke_args[2]);
    si->shell          = "/bin/sh";
    si->timer_type     = GETTIMEOFDAY;
}

void init_os(UNUSED_PARAM(int num)) {
}
void reinit_os() {
}
void cleanup_os(specinvoke_state_t *si) {
    if (si->invoke_args != 0) {
        free(si->invoke_args);
    }
}
pid_t invoke(copy_info_t *ui, command_info_t *ci, char **env,
        specinvoke_state_t *si) {
    pid_t pid;
    char *dir    = (ui->dir == NULL) ? ci->dir : ui->dir,
         *cmd    = ci->cmd,
         *tmpcmd = NULL,
         *numbuf = NULL;
    int infd = -1;

    if (si->dry_run)
        return dry_invoke(ui, ci, si);

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
         * (uunsubstituted) command.
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

    gettime(si, &(ui->start_time));
    if ((pid = fork()) < 0) { /* Error */
        fprintf (stderr, "Can't fork for copy #%d: %s (%d)\n",
                ui->num, STRERROR(errno), errno);
        fprintf (si->outfp, "Can't fork for copy #%d: %s (%d)\n",
                ui->num, STRERROR(errno), errno);
        return -1;
    } else if (pid == 0) {  /* Child */
        if (dir && chdir (dir)) {
            fprintf (stderr, "specinvoke: Can't change directory to '%s': %s(%d)\n",
                    dir, STRERROR(errno), errno);
            specinvoke_exit (1, si);
        }

        if (si->redir) {
            if (ci->err != NULL) {
                int errfd = open(ci->err, O_WRONLY|O_CREAT|O_APPEND, 0644);
                if (errfd < 0) {
                    fprintf (stderr, "specinvoke: Can't open error file '%s': %s(%d)\n",
                            ci->err, STRERROR(errno), errno);
                    specinvoke_exit (1, si);
                }
                fflush(stderr);
                close(2);
                dup2(errfd, 2);
                close(errfd);
            }

            close(0);
            if (ci->input != NULL) {
                infd = open(ci->input, O_RDONLY);
                if (infd < 0) {
                    fprintf (stderr, "Can't open input file '%s': %s(%d)\n",
                            ci->input, STRERROR(errno), errno);
                    specinvoke_exit (1, si);
                }
            } else {
                if (si->no_stdin == NUL) {
                    /* Attach stdin to /dev/null */
                    infd = open("/dev/null", O_RDONLY);
                    if (infd < 0) {
                        fprintf (stderr, "Can't open /dev/null for stdin: %s(%d)\n",
                                STRERROR(errno), errno);
                        specinvoke_exit (1, si);
                    }
                } else if (si->no_stdin == ZEROFILE) {
                    /* Attach stdin to a zero-length file */
                    char *tmpfile;
                    check_malloc(tmpfile, char *, 255 * sizeof(char),
                                 stderr, specinvoke_exit(1, si),
                                 "Failed allocating space for temporary zero-length input file name.\n")
                    int rc = sprintf(tmpfile, "spec_empty_file.%u.%ld", ui->num, (long) ui->pid);
                    if (rc < 0) {
                        fprintf (stderr, "Can't create zero-length temporary filename\n ");
                        specinvoke_exit (1, si);
                    }
                    infd = open(tmpfile, O_RDWR|O_CREAT|O_TRUNC, 0666);
                    if (infd < 0) {
                        fprintf (stderr, "Can't create %s for stdin: %s(%d)\n",
                                tmpfile, STRERROR(errno), errno);
                        specinvoke_exit (1, si);
                    }
                    unlink(tmpfile); /* Don't leave it lying around */
                    free(tmpfile);
                } else {
                    /* Punt (or CLOSE specifically specified) */
                    dup2(2, 0);
                }
            }

            close(1);
            if (ci->output != NULL) {
                /* This should end up being 1 (stdout) */
                int outfd = open(ci->output, O_WRONLY|O_CREAT|O_TRUNC, 0644);
                if (outfd < 0) {
                    fprintf (stderr, "Can't open output file '%s': %s(%d)\n",
                            ci->output, STRERROR(errno), errno);
                    specinvoke_exit (1, si);
                }
            } else {
                dup2(2, 1);
            }
        }

        /* We could redirect them here.  This might be useful for VMS? */
        *(si->command_ptr) = cmd;
        si->invoke_args[0] = si->shell;
        execve(si->shell, si->invoke_args, env);
    } else { /* Parent */
        ui->pid = pid;
        fprintf (si->outfp,
                "child started: %u,\t%10" PRId64 ", %09" PRId64 ", pid=%ld, '%s'\n", ui->num,
                (long long) ui->start_time.sec,
                (long long) ui->start_time.nsec,
                (long) ui->pid, cmd);
        free(cmd); /* No sense wasting memory */
        *(si->command_ptr) = NULL;
    }
    if (infd >= 0) {
        close(infd);
    }
    return pid;
}

long wait_for_next (long *status, bool nowait) {
    int real_status;
    long pid;
    if (nowait) {
        pid = waitpid(-1, &real_status, WNOHANG);
    } else {
        pid = wait(&real_status);
    }
    *status = real_status;
    return pid;
}

void print_no_stdin_setup(
        copy_info_t *ui,
        UNUSED_PARAM(command_info_t *ci),
        specinvoke_state_t *si) {
    if (si->no_stdin == ZEROFILE) {
        printf ("cp /dev/null spec_empty_file.%u.%ld\n", ui->num, (long) ui->pid);
    }
}
void print_no_stdin_use(
        copy_info_t *ui,
        UNUSED_PARAM(command_info_t *ci),
        specinvoke_state_t *si)
{
    if (si->no_stdin == NUL) {
        printf (" < /dev/null");
    } else if (si->no_stdin == ZEROFILE) {
        printf (" < spec_empty_file.%u.%ld", ui->num, (long) ui->pid);
    } else {
        /* Punt (or CLOSE specifically specified) */
        printf (" 0<&-");
    }
}
void  print_no_stdin_teardown(
        copy_info_t *ui,
        UNUSED_PARAM(command_info_t *ci),
        specinvoke_state_t *si)
{
    if (si->no_stdin == ZEROFILE) {
        printf ("rm spec_empty_file.%u.%ld\n", ui->num, (long) ui->pid);
    }
}

void gettime(specinvoke_state_t *si, spec_time_t *t) {
    struct timeval tv;
    struct timezone tz;
    if (si->timer_type != GETTIMEOFDAY) {
        fprintf(stderr, "Unsupported timer type (%d) in gettime()\n", (int)si->timer_type);
        /* This exit is okay, since gettime() is called before spawning any
         * children, so specinvoke won't leave any orphans.
         */
        specinvoke_exit(1, si);
    }
    gettimeofday(&tv, &tz);
    t->sec  = tv.tv_sec;
    t->nsec = tv.tv_usec * 1000;
}

int specmillisleep(time_t milliseconds) {

#if defined(HAVE_NANOSLEEP)
    /* The POSIX.1 nanosleep function is preferred */
    struct timespec sleeptime;
    int rc = 0;

    sleeptime.tv_sec  = milliseconds / 1000;
    sleeptime.tv_nsec = (milliseconds % 1000) * 1000000;
    rc = nanosleep(&sleeptime, NULL);
    if (rc < 0 && errno == ENOSYS) {
        fprintf(stderr, "specinvoke configuration error: nanosleep(2) is not available!\n");
        return -1;
    }
    return rc;
#elif defined(HAVE_USLEEP)
    /* But fall back to the usleep function if necessary */
    return usleep((unsigned int)(milliseconds * 1000));
#elif defined(HAVE_SELECT)
    struct timeval sleeptime;
    int rc = 0;
    sleeptime.tv_sec  = milliseconds / 1000;
    sleeptime.tv_usec = (milliseconds % 1000) * 1000;
    return select(0, 0, 0, 0, &sleeptime);
#else
    /* Fail if none of nanosleep, usleep, or select are available */
# error There is no defined sleep function
#endif

}

/* Editor settings: (please leave this at the end of the file)
 * vim: set filetype=c syntax=c shiftwidth=4 tabstop=8 expandtab nosmarttab ai:
 */
