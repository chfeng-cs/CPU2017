/*
 * specinvoke - run and accurately time lists of commands
 * Copyright 1998-2016 Standard Performance Evaluation Corporation
 *
 * specinvoke.h: Program-wide definitions and headers
 *
 * $Id: specinvoke.h 4356 2016-05-26 21:09:32Z CloyceS $
 */

#include "config.h"

/* The text which will be substituted with the copy number in the executed
 * command
 */
#define COPYNUMVAR "$SPECCOPYNUM"

/* The text which will be substituted with the bind value in the executed
 * command
 */
#define BINDSTRVAR "$BIND"

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#ifdef HAVE_ERRNO_H
#include <errno.h>
#endif

#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif

#ifdef TIME_WITH_SYS_TIME
# include <sys/time.h>
# include <time.h>
#else
# ifdef HAVE_SYS_TIME_H
#  include <sys/time.h>
# else
#  include <time.h>
# endif
#endif

#ifdef HAVE_SYS_TIMEB_H
#include <sys/timeb.h>
#endif

#ifdef HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif

#ifdef HAVE_STDBOOL_H
# include <stdbool.h>
#else
# error specinvoke requires C99 booleans
#endif

#include "getopt.h"

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#include <direct.h>
#define HAVE_NON_BLOCKING_WAIT
#define chdir _chdir
# if !defined(NO_NEED_PID_T) && (defined(_MSC_VER) || defined(NEED_PID_T))
typedef int pid_t;
# endif
#endif

#ifdef HAVE_STRING_H
#include <string.h>
# if defined(_WIN32) && !defined(strdup)
#  define strdup _strdup
# endif
#endif

#ifdef HAVE_WAITPID
#define HAVE_NON_BLOCKING_WAIT
#endif

#if !defined(HAVE_STRERROR)
#define STRERROR(x) ""
#else
#define STRERROR(x) strerror(x)
#endif

#if defined(HAVE_INTTYPES_H)
# include <inttypes.h>
#endif
#if !defined(PRId64)
/* "lld" should be C99-compliant */
# define PRId64 "lld"
#endif

/* The OS implementation module will provide this */
extern char *impl_vcrev;

/* If the timer method on Windows is _ftime, each try will take at least
 * 10ms, which adds up to real time real quick.
 */
#define TIMER_CAL_TRIES 100

/* longs should handle 32 bits */
typedef struct spec_time_s {
    time_t sec;
    time_t nsec; /* NOTE: These are nanoseconds */
} spec_time_t;

typedef struct command_info_s {
    int  num;
    char *dir;
    char *input;
    char *output;
    char *err;
    char *cmd;
    bool  ignore_failure;
} command_info_t;

typedef struct copy_info_s {
    unsigned int num;
    spec_time_t  start_time;
    spec_time_t  stop_time;
    pid_t        pid;
    int          index;
    char        *bind;
    char        *dir;
} copy_info_t;

typedef enum { UNSET, CLOSE, NUL, ZEROFILE } no_stdin_method;

typedef struct specinvoke_state_s {
    char **invoke_args;
    char **command_ptr;
    char  *shell;
    bool   redir;    /* Whether or not to do I/O redirection ourselves */
    int    dry_run;  /* Fake the commands? (>=2 be very verbose) */
    time_t delay;    /* Delay (in milliseconds) between starting new jobs */
    no_stdin_method no_stdin;
    FILE  *outfp;
    time_t res;      /* Timer resolution in nanoseconds */
    /* When to exit:
     * NEVER: Always keep going
     * FIRST_ERROR: Stop the whole run after one error
     * PER_COPY: Run commands for a copy as long as there's success
     */
    enum { NEVER, FIRST_ERROR, PER_COPY } exit_on_failure;
    char **env_vars;
    char **env_vals;
    enum { NONE, GETTIMEOFDAY, FTIME, QPC } timer_type;
} specinvoke_state_t;

/* Prototypes */
void  usage(char *name, specinvoke_state_t *state);
pid_t invoke(copy_info_t *ui, command_info_t *ci, char **env,
        specinvoke_state_t *si);
pid_t dry_invoke(copy_info_t *ui, command_info_t *ci, specinvoke_state_t *si);
void  gettime(specinvoke_state_t *si, spec_time_t *t);
long  time_cal(specinvoke_state_t *si);
bool  subtime(spec_time_t *a, spec_time_t *b, spec_time_t *c);
long  wait_for_next (long *status, bool nowait);
void  print_no_stdin_setup(copy_info_t *ui, command_info_t *ci, specinvoke_state_t *si);
void  print_no_stdin_use(copy_info_t *ui, command_info_t *ci, specinvoke_state_t *si);
void  print_no_stdin_teardown(copy_info_t *ui, command_info_t *ci, specinvoke_state_t *si);
void  init_state(specinvoke_state_t *si);
void  init_os(int num);
void  reinit_os();
void  cleanup_os();
char *specstrstr(char *haystack, char *needle);
int   specstrncmp(char *a, char *b, int len);
int   specstrncpy(char *dst, char *src, int len);
int   specmillisleep(time_t milliseconds);
void  specinvoke_exit(int code, specinvoke_state_t *state);
char *make_number_buf(unsigned num);
char *sub_strings(char *src, char *find, char *replace);

#if defined(WIN32) && defined(_MSC_VER)
/* The Microsoft compilers provide this as a macro already */
# define UNUSED_VAR(x) UNREFERENCED_PARAMETER(x)
# define UNUSED_PARAM(x) x
#elif defined(__GNUC__)
# define UNUSED_VAR(x)
# define UNUSED_PARAM(x) x __attribute__ ((unused))
#else
# define UNUSED_VAR(x)
# define UNUSED_PARAM(x) x
#endif

#define check_malloc(var, type, len, outfp, exit_action, ...)  \
    var = (type)malloc(len);                                   \
    if (var == NULL) {                                         \
        fprintf(outfp, "Could not malloc %d bytes: %s(%u)\n",  \
                (int)(len), STRERROR(errno), (unsigned)errno); \
        fprintf(outfp, __VA_ARGS__);                           \
        exit_action;                                           \
    }                                                          \
    memset(var, 0, len);

/* Editor settings: (please leave this at the end of the file)
 * vim: set filetype=c syntax=c shiftwidth=4 tabstop=8 expandtab nosmarttab ai:
 */
