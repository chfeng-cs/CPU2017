/*
 * specinvoke - run and accurately time lists of commands
 * Copyright 1998-2016 Standard Performance Evaluation Corporation
 *
 * specinvoke.c: The platform-independent bits
 *
 * $Id: specinvoke.c 4356 2016-05-26 21:09:32Z CloyceS $
 */

#include "specinvoke.h"

/* These are defined in the platform-specific modules */
extern char **invoke_args;
extern char **command_ptr;
extern char  *shell;

static char *vcrev = "$Revision: 4356 $";

int debug = 0;

typedef enum { NORMAL, FULL_LINE } cmdfile_option_type;

/* Arguments for "NORMAL" options are separated in the command file from the
 * option by a mandatory space, and consist of only whitespace.
 * Arguments for "FULL_LINE" options don't have to be separated from the
 * option by whitespace, but leading whitespace is trimmed anyway.  The
 * argument extends to the end of the string in *ptr.
 *
 * The *ptr input string is expected to have all trailing whitespace
 * (including CR and NL) stripped.
 */
static inline char *get_cmdfile_arg(cmdfile_option_type optiontype, char option, char **ptr, int line, bool dup_arg, specinvoke_state_t *state) {
    if (**ptr != ' ' && optiontype == NORMAL) {
        printf ("Illegally formatted option '%c' on line %d (expected space, got '%c')\n",
                option, line, **ptr);
        specinvoke_exit(1, state);
    }
    while (**ptr == ' ' || **ptr == '\t') {
        (*ptr)++;
    }
    char *arg = (*ptr)++;
    while (**ptr != '\0'
            && (optiontype == FULL_LINE || (**ptr != ' ' && **ptr != '\t'))) {
        (*ptr)++;
    }
    if (**ptr != '\0') {
        **ptr = '\0';
        (*ptr)++;
    }

    return dup_arg ? strdup(arg) : arg;
}

int main (int argc, char *argv[], char *env[]) {
    FILE *fp;
    char *cname = "speccmds.cmd",
         *resultname = NULL,
         *dir = NULL,
         *outputname = NULL,
         *errname = NULL,
         **currenv = NULL,
         **curr = NULL,
         **currval = NULL,
         *prefix,
          command[16384];
    int iterations = 1,
        i,
        c,
        run,
        version = 0,
        line = 0,
        active_copies = 0,
        child_error = 0,
        total_child_error = 0,
        child_return = 0,
        num_commands,
        num_copies,
        cur_cmd,
        cur_copy,
        num_env,
        cur_env;
    spec_time_t whole_start_time,
                whole_stop_time,
                run_start_time,
                run_stop_time,
                whole_elapsed_time,
                run_elapsed_time;
    command_info_t *command_info = NULL;
    copy_info_t *copy_info = NULL;
    specinvoke_state_t state; /* General state and settings info */

    char *versionid, *impl_id;
    check_malloc(versionid, char *, strlen(vcrev) * sizeof(char),
            stdout, specinvoke_exit(1, NULL),
            "Failed allocating memory for version string.\n")
    if (strlen(vcrev) <= 10) {
        /* True when '$Revision: 4356 $' keyword is not expanded */
        strcpy(versionid, "<dev>\0");
    } else {
        strcpy(versionid, vcrev + 11);
        char *tmpptr = strrchr(versionid, ' ');
        if (tmpptr) *tmpptr = 0;
    }
    check_malloc(impl_id, char *, strlen(impl_vcrev) * sizeof(char),
            stdout, specinvoke_exit(1, NULL),
            "Failed allocating memory for implementation version string.\n")
    if (strlen(impl_vcrev) <= 10) {
        /* True when '$Revision: 4356 $' keyword is not expanded */
        strcpy(impl_id, "<dev>\0");
    } else {
        strcpy(impl_id, impl_vcrev + 11);
        char *tmpptr = strrchr(impl_id, ' ');
        if (tmpptr) *tmpptr = 0;
    }

    /* Unbuffer regular output */
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);

    /* Make sure that the state struct is empty */
    memset(&state, 0, sizeof(state));

    /* Initialize the non-platform-specific values */
    state.redir           = true;
    state.dry_run         = 0;
    state.delay           = (time_t)0;
    state.no_stdin        = UNSET;
    state.outfp           = stdout;
    state.exit_on_failure = PER_COPY;

    /* Initialize the platform-specific stuff */
    init_state(&state);

    /* Parse arguments */
    while ((c = my_getopt(argc, argv, "vnd:i:o:e:f:c:s:A?hErS:NZCD:qkt:p:")) != EOF) {
        switch (c) {
            case 'v': version++;                     break;
            case 'n': state.dry_run++;               break;
            case 'd': dir         = optarg;          break;
            case 'i': iterations  = atoi(optarg);    break;
            case 'o': outputname  = optarg;          break;
            case 'e': errname     = optarg;          break;
            case 'f': cname       = optarg;          break;
            case 's': state.shell = optarg;          break;
            case 'A': specinvoke_exit(0, &state);    break;
            case '?':
            case 'h': usage(argv[0], &state);        break;
            case 'E': child_return = 1;              break;
            case 'r': state.redir = false;           break;
            case 'S': state.delay = atoi(optarg);    break;
            case 'N': state.no_stdin = NUL;          break;
            case 'Z': state.no_stdin = ZEROFILE;     break;
            case 'C': state.no_stdin = CLOSE;        break;
            case 'D': debug  = atoi(optarg);
                      printf("Enabled debugging at level %d\n", debug);
                      break;
            case 'q': state.exit_on_failure = FIRST_ERROR; break;
            case 'k': state.exit_on_failure = NEVER;       break;
            case 't': switch(tolower(optarg[0])) {
                          case 'g': state.timer_type = GETTIMEOFDAY; break;
                          case 'f': state.timer_type = FTIME;        break;
                          case 'n': state.timer_type = NONE;         break;
                          case 'q':
                          case 'p': state.timer_type = QPC;          break;
                          default:
                                    printf("Unknown timer type '%s' selected\n", optarg);
                                    specinvoke_exit(1, &state);
                      }
                      break;
            case 'p': i = 0;
                      while (optarg[i] == '-' && optarg[i] != 0)
                          i++;
                      switch(optarg[i]) {
                          case 0: printf("No option to test found for -p\n");
                                  specinvoke_exit(1, &state);
                                  break;
                          case 'k':
                          case 'e':
                          case 'o':
                          case 'i':
                          case 'c': printf("specinvoke command processor: '-%c' accepted per command\n", optarg[i]);
                                    specinvoke_exit(0, &state);
                          case 'N':
                          case 'r':
                          case 'u':
                          case 'C':
                          case 'b':
                          case 'S':
                          case 'E': printf("specinvoke command processor: '-%c' accepted globally\n", optarg[i]);
                                    specinvoke_exit(0, &state);
                          default:
                                    printf("specinvoke command processor: illegal option '-%c'\n", optarg[i]);
                                    specinvoke_exit(1, &state);
                      }
                      break;
        }
    }

    if (argv[optind] != NULL)
        cname = argv[optind++];

    if (version) {
        printf ("specinvoke r%s (OS implementation r%s)\n", versionid, impl_id);
        specinvoke_exit(0, &state);
    }

    if (iterations < 1) {
        printf ("Iterations must be >= 1!\n");
        usage(argv[0], &state);
    }

    /* Find out how precise the clock is */
    state.res = (time_t)time_cal(&state);

    if (!state.dry_run) {
        if (dir != NULL && chdir(dir)) {
            printf("Can't chdir to '%s': %s(%d)\n",
                    dir, STRERROR(errno), errno);
            specinvoke_exit(1, &state);
        }

        if (errname != NULL) {
            if (freopen(errname, "w", stderr) == NULL) {
                printf("Can't open new stderr '%s': %s(%d)\n",
                        errname, STRERROR(errno), errno);
                specinvoke_exit (1, &state);
            }
            setvbuf(stderr, NULL, _IONBF, 0);
        }
        if (outputname) {
            if (freopen(outputname, "w", stdout) == NULL) {
                printf("Can't open new stdout '%s': %s(%d)\n",
                        outputname, STRERROR(errno), errno);
                specinvoke_exit (1, &state);
            }
            setvbuf(stdout, NULL, _IONBF, 0);
        }

        /* Make a copy of cname and change ".cmd" (if any) to ".out". */
        i = strlen(cname);
        check_malloc(resultname, char *,(i + 5) * sizeof(char),
                stdout, specinvoke_exit(1, &state),
                "Failed allocating memory for a copy of the command file name.\n")
        specstrncpy(resultname, cname, i);
        *(resultname + i) = '\0';
        if (i > 3 && !specstrncmp(resultname + i - 4, ".cmd", 4)) {
            /* Yay! Just replace the .cmd with .out */
            specstrncpy(resultname + i - 4, ".out", 4);
        } else {
            /* Append it */
            strcat(resultname, ".out");
        }
        state.outfp = fopen(resultname, "w");
        if (state.outfp == NULL) {
            printf ("Can't open result output file '%s': %s(%d)\n", resultname,
                    STRERROR(errno), errno);
            specinvoke_exit (1, &state);
        }
        setvbuf(state.outfp, NULL, _IONBF, 0);
        free(resultname);
    }


    fp = fopen (cname, "r");
    if (fp == NULL) {
        printf ("Can't open command file '%s': %s(%d)\n", cname, STRERROR(errno), errno);
        specinvoke_exit (1, &state);
    }

    /* Find out how many commands we are going to run and how many environment
     * variables will be set.
     */
    num_commands = 0;
    num_copies   = 0;
    num_env      = 0;
    while (fgets(command, sizeof(command), fp) != NULL) {
        char *ptr = command;
        if (strcmp(command, "__END__") == 0)
            break;
        while (*ptr == ' ' || *ptr == '\t')
            ptr++;
        if (*ptr == '#' || *ptr == '\0') {
            continue;

        } else if (*ptr == '-') {
            ptr++;
            switch (*ptr) {
                /* -C (or the old -u) set the run directory for a copy */
                case 'C':
                case 'u': num_copies++; break;

                /* -E are used for recording an environment variable */
                case 'E': num_env++; break;

                /* -b sets a bind variable for the copy that follows it */
                case 'b': break; /* Not a command; not needed for counting */

                /* -S sets the inter-copy delay for staggered homogenous rate */
                case 'S': state.delay = atoi(ptr + 1); break;

                /* -r indicates that command redirection is already included */
                case 'r': state.redir = false; break;

                /* -N sets the way that commands with no input specified are
                 * treated.
                 */
                case 'N': break; /* Not a command; handled later */

                /* Everything else is assumed to belong to a command */
                default: num_commands++; break;
            }

        } else {
            /* It _is_ possible to have a command with no options, but the
             * CPU tools will never generate a line like that.
             */
            num_commands++;
        }
    }

    /* No -C lines?  No problem... still run at least one instance */
    if (num_copies <= 0) {
        num_copies = 1;
    }

    /* Make sure that we really are at the end of file */
    if (!feof(fp)) {
        printf ("Error counting entries in command file '%s': %s(%d)\n",
                cname, STRERROR(errno), errno);
        specinvoke_exit (1, &state);
    }

    if (num_copies <= 0) {
        printf ("No '-C' lines in command file!\n");
        specinvoke_exit (1, &state);
    }

    if (num_commands <= 0) {
        printf ("No commands to issue!\n");
        specinvoke_exit (1, &state);
    }

    check_malloc(command_info, command_info_t *,
                 num_commands * sizeof(struct command_info_s), stdout,
                 specinvoke_exit(1, &state),
                 "Failed allocating memory for command structures.\n")
    memset(command_info, 0, num_commands * sizeof(struct command_info_s));
    for (cur_cmd = 0; cur_cmd < num_commands; cur_cmd++) {
        command_info[cur_cmd].num = cur_cmd;
    }

    check_malloc(copy_info, copy_info_t *,
                 num_copies * sizeof(struct copy_info_s), stdout,
                 specinvoke_exit(1, &state),
                 "Failed allocating memory for copy_info structures\n")
    memset(copy_info, 0, num_copies * sizeof(struct copy_info_s));
    for (cur_copy = 0; cur_copy < num_copies; cur_copy++) {
        copy_info[cur_copy].num = cur_copy;
    }

    if (num_env) {
        check_malloc(state.env_vars, char **, (num_env + 1) * sizeof(char *),
                stdout, specinvoke_exit(1, &state),
                "Failed allocating memory for environment variable names\n")
        check_malloc(state.env_vals, char **, (num_env + 1) * sizeof(char *),
                stdout, specinvoke_exit(1, &state),
                "Failed allocating memory for environment variable values\n")
        memset(state.env_vars, 0, (num_env + 1) * sizeof(char *));
        memset(state.env_vals, 0, (num_env + 1) * sizeof(char *));
    }
    rewind(fp);

    cur_cmd  = 0;
    cur_copy = 0;
    cur_env  = 0;
    while (fgets(command, sizeof(command), fp) != NULL) {
        int len;
        bool is_command_line = true;
        char *ptr = command;
        line++;
        if (strcmp(command, "__END__") == 0)
            break;

        /* Skip leading whitespace */
        while (*ptr == ' ' || *ptr == '\t')
            ptr++;

        /* Skip comment or empty lines */
        if (*ptr == '#' || *ptr == '\0')
            continue;

        len = strlen(command);
        if (len == (sizeof(command) - 1) && command[len-1] != '\n' && command[len-1] != '\r') {
            printf ("Line %d too long\n", line);
            specinvoke_exit (1, &state);
        }

        /* Trim trailing whitespace */
        while ((len > 0) &&
                (((command[len-1] == '\n') || (command[len-1] == '\r')) ||
                 ((command[len-1] == ' ')  || (command[len-1] == '\t'))))
            command[--len] = 0;

        command_info[cur_cmd].dir    = NULL;
        command_info[cur_cmd].input  = NULL;
        command_info[cur_cmd].output = NULL;
        command_info[cur_cmd].err    = NULL;

        while (*ptr == '-') {
            char option = *(ptr + 1);
            ptr += 2;   /* Advance to the character after the option */

            /* When adding options here, do not forget to update the switch
             * used by the -p command line option in the main option parsing
             * loop.
             */
            switch (option) {
                case 'c': command_info[cur_cmd].dir    = get_cmdfile_arg(NORMAL, option, &ptr, line, true, &state); break;
                case 'i': command_info[cur_cmd].input  = get_cmdfile_arg(NORMAL, option, &ptr, line, true, &state); break;
                case 'o': command_info[cur_cmd].output = get_cmdfile_arg(NORMAL, option, &ptr, line, true, &state); break;
                case 'e': command_info[cur_cmd].err    = get_cmdfile_arg(NORMAL, option, &ptr, line, true, &state); break;
                case 'k': command_info[cur_cmd].ignore_failure = true; break;
                case 'u':
                case 'C': is_command_line = false;
                          if (cur_copy >= num_copies) {
                              printf ("-C is only allowed once at the beginning of a line!\n");
                              specinvoke_exit (1, &state);
                          }
                          copy_info[cur_copy++].dir = get_cmdfile_arg(NORMAL, option, &ptr, line, true, &state);
                          break;
                case 'b': is_command_line = false;
                          if (cur_copy >= num_copies) {
                              printf ("-b is only allowed once at the beginning of a line!\n");
                              specinvoke_exit (1, &state);
                          }
                          copy_info[cur_copy].bind = get_cmdfile_arg(FULL_LINE, option, &ptr, line, true, &state);
                          break;
                case 'S': is_command_line = false;
                          break;
                case 'E': is_command_line = false;
                          if (cur_env >= num_env) {
                              printf("Too many environment settings!  Expected only %d\n", num_env + 1);
                              specinvoke_exit (1, &state);
                          }
                          state.env_vars[cur_env] = get_cmdfile_arg(NORMAL, option, &ptr, line, true, &state);
                          state.env_vals[cur_env] = strdup(ptr);
                          cur_env++;
                          *ptr = '\0'; /* End the searching-for-options loop, if *ptr == '-' */
                          break;
                case 'r': is_command_line = false;
                          break;
                case 'N': is_command_line = false;
                          char *method = get_cmdfile_arg(NORMAL, option, &ptr, line, false, &state);
                          if (state.no_stdin == UNSET) { /* Allow command line override */
                              switch(tolower(*method)) {
                                  case 'n': state.no_stdin = NUL;      break;
                                  case 'f':
                                  case 'z': state.no_stdin = ZEROFILE; break;
                                  case 'c': state.no_stdin = CLOSE;    break;
                                  default:
                                            printf ("Unrecognized method '%s' for dealing with no stdin\n", method);
                                            specinvoke_exit (1, &state);
                              }
                          } else {
                              printf ("Ignoring redundant no_stdin setting of '%s' from command file\n", method);
                          }
                          break;
                default:
                          printf ("Illegal option '%c' on line %d\n",
                                  option, line);
                          specinvoke_exit (1, &state);
            }

            /* Skip over whitespace that singleton options might have left
             * (since they don't try to consume an argument).
             */
            while(*ptr == ' ' || *ptr == '\t') {
                ptr++;
            }
        }
        if (is_command_line) {
            if (ptr == NULL || *ptr == '\0') {
                /* No command in command file */
                printf("Command missing on line %d\n", line);
                specinvoke_exit (1, &state);
            } else {
                command_info[cur_cmd].cmd = strdup(ptr);
                cur_cmd++;
            }
        }
    }
    if (cur_cmd != num_commands) {
        printf("Error: Too few commands read from the command file; %d read, should be %d\n", cur_cmd, num_commands);
        specinvoke_exit (1, &state);
    }

    if (!feof(fp)) {
        printf ("Error reading entries in command file '%s': %s(%d)\n",
                cname, STRERROR(errno), errno);
        specinvoke_exit (1, &state);
    }

    fclose(fp);

    init_os(num_commands * num_copies + 1); /* Total commands + slop */

    if (state.dry_run) {
        /* Add a shell comment char to the beginning of each line */
        prefix = "# ";
    } else {
        prefix = "\0";
    }
    fprintf (state.outfp, "%sspecinvoke r%s\n", prefix, versionid);
    fprintf (state.outfp, "%s Invoked as:", prefix);
    curr = argv;
    while (curr && *curr) {
        fprintf(state.outfp, " %s", *curr);
        curr++;
    }
    fprintf (state.outfp, "\n");
    fprintf (state.outfp,
            "%stimer ticks over every %lu ns\n", prefix, (unsigned long)state.res);

    if (!state.dry_run || state.dry_run >= 2) {
        if (!state.dry_run && env == 0) {
            fprintf(state.outfp, " No environment variables in effect for these runs\n");
        } else if (state.dry_run >= 2 && state.env_vars == 0) {
            fprintf(state.outfp, "%s No environment variables defined for these runs\n", prefix);
        } else if(!state.dry_run) {
            /* A real run, so output the current env */
            fprintf (state.outfp, " Environment in effect for these runs:\n");
            i = 1;
            curr = env;
            while (curr && *curr) {
                fprintf(state.outfp, " #%2d: %s\n", i++, *curr);
                curr++;
            }
        } else {
            /* A fake run (probably from command line), so output the stored
             * environment
             */
            printf ("# Environment in effect for these runs:\n");
            curr = state.env_vars;
            currval = state.env_vals;
            while (curr && *curr) {
                printf ("%s=%s\n", *curr, *currval);
                curr++;
                currval++;
            }
            curr = state.env_vars;
            i = 5;
            if (curr)
                printf ("export");
            while (curr && *curr) {
                /* Try to keep the lines looking niceish, but handle
                 * an extra-long variable name nicely too.
                 */
                if ((i + strlen(*curr) + 1) > 80 && i > 5) {
                    printf ("\nexport");
                    i = 5;
                }
                i += strlen(*curr) + 1;
                printf (" %s", *curr);
                curr++;
            }
            if (curr)
                printf ("\n");

            /* Check that the stored environment matches the current
             * environment.  This will allow us to emit unset commands for
             * variables in the current environment that were not in the run
             * environment.
             * This is O(n2), but the number of environment variables should be
             * small, so there's no incentive to make this less stupid.
             */
            /* Make a list of just the names of current environment */
            for(i = 0, currenv = env; *currenv; currenv++, i++);
            char **tmpenv;
            check_malloc(tmpenv, char **, (i + 1) * sizeof(char *),
                         stdout, specinvoke_exit(1, &state),
                         "Failed allocating memory for temporary environment list.\n")
            for(i = 0, currenv = env; *currenv; currenv++, i++) {
                char *tmpend = strchr(*currenv, '=');
                int len;
                if (tmpend == NULL) {
                    /* Shouldn't happen */
                    len = strlen(*currenv);
                } else {
                    len = (int)(tmpend - *currenv);
                }
                check_malloc(tmpenv[i], char *, (len + 1) * sizeof(char),
                             stdout, specinvoke_exit(1, &state),
                             "Failed allocating memory for temporary environment name.\n")
                specstrncpy(tmpenv[i], *currenv, len);
                *(tmpenv[i] + len) = '\0';
                tmpenv[i+1] = NULL;
            }
            for(currenv = tmpenv; *currenv; currenv++) {
                i = 0;
                for(curr = state.env_vars; *curr; curr++) {
                    if (strcmp(*currenv, *curr) == 0) {
                        i = 1;
                        break;
                    }
                }
                if (i == 0) {
                    printf("unset %s\n", *currenv);
                }
            }
            for(currenv = tmpenv; *currenv; currenv++) {
                free(*currenv);
            }
            free(tmpenv);
        }
    }

    if (!state.dry_run) {
        fprintf (state.outfp, "running commands in %s %d times\n",
                cname, iterations);

        gettime(&state, &whole_start_time);
        fprintf (state.outfp, "runs started at\t\t%10" PRId64", %09" PRId64 ", %s",
                (long long) whole_start_time.sec,
                (long long) whole_start_time.nsec,
                ctime(&whole_start_time.sec));
        fflush (state.outfp);
    }

    /* Perform actual run */
    for (run = 1; run <= iterations; run++) {
        long status;
        int cindex = 0;
        pid_t pid;

        reinit_os();

        if (!state.dry_run) {
            gettime(&state, &run_start_time);
            fprintf (state.outfp,
                    "run %d started at\t%10" PRId64 ", %09" PRId64 ", %s", run,
                    (long long) run_start_time.sec,
                    (long long) run_start_time.nsec,
                    ctime(&run_start_time.sec));
            fflush (state.outfp);
        } else {
            if (num_copies > 1) {
                printf("# Fake output for rate runs will not necessarily clearly represent the order\n");
                printf("# that workloads would be run in a real run.\n");
            }
            if (state.dry_run < 2) {
                printf("# Use another -n on the command line to see chdir commands and env dump\n");
            }
        }

        bool start_ok = true;
        /* Start the first command for all copies */
        for (i = 0; i < num_copies; i++) {
            pid_t pid;
            if (cindex >= num_commands)
                break;
            pid = invoke( &copy_info[i], &command_info[cindex], env, &state );
            if (pid < 0) {
                /* Stop spawning new jobs; wait for existing ones to exit */
                start_ok = false;
                num_copies = i + 1;
                break;
            }
            copy_info[i].index = 1;
            copy_info[i].pid = pid;
            if (state.delay > 0) {
                if (state.dry_run) {
                    printf ("# sleep for %ld milliseconds\n", (long)state.delay);
                } else {
                    if (specmillisleep(state.delay) < 0) {
                        /* Something bad happened; give up */
                        start_ok = false;
                        num_copies = i + 1;
                        break;
                    }
                }
            }
        }

        active_copies = num_copies;
        int dry_index = 0; /* Used to interleave commands for all copies in fake output */
        while (active_copies) {
            bool found;
            int cindex;
            spec_time_t stop_time;
            if (state.dry_run) {
                status = 0;
                if (dry_index >= num_copies)
                    dry_index = 0;
                pid = copy_info[dry_index].pid;
                dry_index++;
            } else {
                pid = wait_for_next(&status, false);
            }
            if (pid == -1) {
                int saved_errno = errno;
                if (saved_errno == EINTR) {
                    /* wait was interrupted by signal; go around again */
                    continue;
                } else if (saved_errno == ECHILD) {
                    /* no children available; this should never happen
                     * since it indicates that no child processes exist, we
                     * can just exit the loop
                     */
                    break;
                }

                /* It should not be possible to reach this code except on
                 * Windows.
                 * If we're here, SOMETHING bad has happened.  Keep
                 * waiting for children to exit, but don't start new ones.
                 */
                fprintf (stderr, "wait_for_next returned -1: %s (%d)\n",
                        STRERROR(saved_errno), saved_errno);
                fprintf (state.outfp, "wait_for_next returned -1: %s (%d)\n",
                        STRERROR(saved_errno), saved_errno);
                start_ok = false;
            }
            if (status != 0)
                child_error++;
            gettime(&state, &stop_time);
            found = false;
            for (i = 0; i < num_copies; i++) {
                if (pid == copy_info[i].pid) {
                    cindex = i;
                    found = true;
                    if (!state.dry_run) {
                        spec_time_t elapsed;
                        if (! subtime(&stop_time, &copy_info[i].start_time,
                                    &elapsed)) {
                            fprintf (state.outfp,
                                    "ERROR: negative elapsed time detected: s=%" PRId64 " nsec=%" PRId64 "\n",
                                    (long long) elapsed.sec, (long long) elapsed.nsec);
                            start_ok = false;
                        }
                        fprintf (state.outfp,
                                "child finished: %u,\t%10" PRId64 ", %09" PRId64 ", sec=%" PRId64 ", nsec=%" PRId64 ", pid=%" PRId64 ", rc=%u\n",
                                copy_info[i].num,
                                (long long) stop_time.sec,
                                (long long) stop_time.nsec,
                                (long long) elapsed.sec,
                                (long long) elapsed.nsec,
                                (long long) pid, (unsigned int) status);
                        fflush (state.outfp);
                    }
                    /* Start the next command only if there are more commands
                     * to start (obviously)
                     * AND there have been no previous child errors and
                     *     exit_on_failure == FIRST_ERROR (-q)
                     * OR the just-exited command was successful and
                     *     exit_on_failure == PER_COPY
                     * OR the just-exited command failed and ignore_failure
                     *     was set and exit_on_failure == PER_COPY
                     * OR exit_on_failure == NEVER (-k).
                     */
                    if (start_ok
                            && copy_info[cindex].index < num_commands
                            && (state.exit_on_failure == NEVER
                                || (state.exit_on_failure == PER_COPY && (status == 0 || command_info[copy_info[cindex].index - 1].ignore_failure))
                                || (state.exit_on_failure == FIRST_ERROR && child_error == 0)
                                )) {
                        pid = invoke (&copy_info[i],
                                &command_info[copy_info[cindex].index],
                                env, &state );
                        if (pid < 0) {
                            /* Stop spawning new jobs; wait for existing ones to exit */
                            start_ok = false;
                            active_copies--;
                            break;
                        }
                        copy_info[i].pid = pid;
                        copy_info[cindex].index++;
                    } else {
                        copy_info[i].pid = -1;
                        active_copies--;
                    }
                    break;
                }
            }
            if (!found) {
                fprintf (stderr, "child with unknown pid %" PRId64 " exited!\n", (long long)pid);
                start_ok = false;
            }
        }

        if (state.dry_run)
            continue;

        if (child_error) {
            total_child_error += child_error;
            printf ("error: %d children finished with errors\n", child_error);
        }

        gettime(&state, &run_stop_time);
        fprintf (state.outfp,
                "run %d finished at:\t%10" PRId64 ", %09" PRId64 ", %s", run,
                (long long) run_stop_time.sec, (long long) run_stop_time.nsec,
                ctime(&run_stop_time.sec));
        if (! subtime(&run_stop_time, &run_start_time, &run_elapsed_time)) {
            fprintf (state.outfp,
                    "ERROR: negative elapsed time for run %d detected: s=%" PRId64 " nsec=%" PRId64 "\n",
                    run,
                    (long long) run_elapsed_time.sec,
                    (long long) run_elapsed_time.nsec);
        }
        fprintf (state.outfp,
                "run %d elapsed time:\t%10" PRId64 ", %09" PRId64 ", %" PRId64 ".%09" PRId64 "\n", run,
                (long long) run_elapsed_time.sec,
                (long long) run_elapsed_time.nsec,
                (long long) run_elapsed_time.sec,
                (long long) run_elapsed_time.nsec);
        fflush (state.outfp);
    }
    if (state.dry_run) {
        specinvoke_exit (0, &state);
    }
    gettime(&state, &whole_stop_time);
    fprintf (state.outfp, "runs finished at\t%10" PRId64 ", %09" PRId64 ", %s",
            (long long) whole_stop_time.sec, (long long) whole_stop_time.nsec,
            ctime(&whole_stop_time.sec));
    if (! subtime(&whole_stop_time, &whole_start_time, &whole_elapsed_time)) {
        fprintf (state.outfp,
                "ERROR: negative elapsed overall time detected: s=%" PRId64 " nsec=%" PRId64 "\n",
                (long long) whole_elapsed_time.sec,
                (long long) whole_elapsed_time.nsec);
    }
    fprintf (state.outfp,
            "runs elapsed time:\t%10" PRId64 ", %09" PRId64 ", %" PRId64 ".%09" PRId64 "\n",
            (long long) whole_elapsed_time.sec,
            (long long) whole_elapsed_time.nsec,
            (long long) whole_elapsed_time.sec,
            (long long) whole_elapsed_time.nsec);
    if (total_child_error) {
        fprintf (state.outfp,
                "error: a total of %d children finished with errors\n",
                total_child_error);
    }
    fflush(state.outfp);

    cleanup_os(&state);

    /* All this stuff is just to make valgrind happy.  No actual
     * memory leaks are prevented here.
     */
    if (command_info != NULL) {
        for(cur_cmd = 0; cur_cmd < num_commands; cur_cmd++) {
            if (command_info[cur_cmd].cmd != NULL)
                free(command_info[cur_cmd].cmd);
            if (command_info[cur_cmd].dir != NULL)
                free(command_info[cur_cmd].dir);
            if (command_info[cur_cmd].input != NULL)
                free(command_info[cur_cmd].input);
            if (command_info[cur_cmd].output != NULL)
                free(command_info[cur_cmd].output);
            if (command_info[cur_cmd].err != NULL)
                free(command_info[cur_cmd].err);
        }
        free(command_info);
    }
    if (copy_info != NULL) {
        for(cur_copy = 0; cur_copy < num_copies; cur_copy++) {
            if (copy_info[cur_copy].dir != NULL)
                free(copy_info[cur_copy].dir);
            if (copy_info[cur_copy].bind != NULL)
                free(copy_info[cur_copy].bind);
        }
        free(copy_info);
    }
    if (num_env) {
        for(i = 0; i <= num_env; i++) {
            if (state.env_vars[i] != NULL)
                free(state.env_vars[i]);
            if (state.env_vals[i] != NULL)
                free(state.env_vals[i]);
        }
        free(state.env_vars);
        free(state.env_vals);
    }

    /* Bye bye */
    specinvoke_exit(child_return ? !!total_child_error : 0, &state);
}


/*
 * Subtract one time from another, used to calculate elapsed times.
 * Returns an error if the calculated time is negative.
 */
bool subtime(spec_time_t *a, spec_time_t *b, spec_time_t *c) {
    c->sec  = a->sec  - b->sec;
    c->nsec = a->nsec - b->nsec;
    if (c->nsec < 0) {
        c->sec--;
        c->nsec += 1000000000L;
    }
    if (c->sec < 0 || c->nsec < 0)
        return false;

    return true;
}

/*
 * Print out a usage message
 */
void usage(char *name, specinvoke_state_t *state) {
    printf ("Usage: %s [options] [instructionfile]\n", name);
    printf ("Options:\n"
            "   -i <n>          iterations\n"
            "   -E              return non-zero exit code if child does\n"
            "   -s shell        shell to invoke\n"
            "   -f file         instruction file\n"
            "   -o file         output file\n"
            "   -e file         error file\n"
            "   -d dir          change to dir first\n"
           );
    printf ("   -n[n]           print a 'dry_run' of commands\n"
            "   -A              return 0 error code\n"
            "   -S msecs        sleep between spawning copies (in milliseconds)\n"
            "   -r              don't do I/O redirection; commands assumed to include it\n"
            "   -N              open null device when no input file is specified\n"
            "   -Z              use zero-length file when no input file is specified\n"
            "   -C              (default) close stdin when no input file is specified\n"
           );
    printf ("   -D <n>          Turn on debugging at level <n>\n"
            "   -q              Stop issuing commands as soon as one fails\n"
            "   -k              Issue all commands, even if some fail\n"
#if defined(_WIN32) || defined(_WIN64)
            "   -t <t>          Select method for timing execution. <t> must be one of\n"
            "                     ftime, qpc, or perfcounter\n"
#endif
            "                   Default is platform-dependent.\n"
            "   -p <o>          Check whether -<o> is valid for use in the command file\n"
            "   -h, -?          Print this message\n"
           );
    specinvoke_exit (0, state);
}

pid_t dry_invoke(copy_info_t *ui, command_info_t *ci, specinvoke_state_t *si) {
    static pid_t pid = 1000;
    char *dir    = (ui->dir == NULL) ? ci->dir : ui->dir,
         *tmpcmd = NULL,
         *cmd    = ci->cmd,
         *numbuf = NULL;

    printf("# Starting run for copy #%u\n", ui->num);

    gettime(si, &(ui->start_time));
    if (dir && si->dry_run >= 2) {
        printf ("cd %s\n", dir);
    }

    /* Do bind variable substitution */
    if (ui->bind != 0) {
        tmpcmd = sub_strings(cmd, BINDSTRVAR, ui->bind);
        if (tmpcmd == NULL)
            return -1;
        cmd = tmpcmd;
    }

    /* Do copy number substitution */
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

    if (si->redir == true && ci->input == NULL) {
        print_no_stdin_setup(ui, ci, si);
    }
    printf ("%s", cmd);
    free(cmd); /* No sense in wasting memory... */
    if (si->redir == true) {
        if (ci->input) {
            printf (" < %s", ci->input);
        } else {
            print_no_stdin_use(ui, ci, si);
        }
        if (ci->output) {
            printf (" > %s", ci->output);
        }
        if (ci->err) {
#ifdef _WIN32
            printf (" 2> %s", ci->err);
#else
            printf (" 2>> %s", ci->err);
#endif
        }
    }
    printf ("\n");
    if (si->redir == true && ci->input == NULL) {
        print_no_stdin_teardown(ui, ci, si);
    }
    return pid++;
}

/* Here are a couple of standard string functions, reimplemented here so
   that they are portable and can be debugged once.
   */
char *specstrstr(char *haystack, char *needle) {
    int   needlelen = 0,
          haylen = 0;
    char *look = haystack;

    if (haystack == NULL)
        return NULL;
    if (needle == NULL)
        return haystack;

    needlelen = strlen(needle);
    haylen = strlen(haystack);
    /* Look for the first character in needle in haystack.  For specinvoke,
       it's going to be far more common for the needle *not* to be found.
       */
    while(*look && ((look - haystack) <= (haylen - needlelen))) {
        if (*look == *needle)
            break;
        look++;
    }
    /* Now go into dumb mode, where we do a full compare on every location */
    while(*look && ((look - haystack) <= (haylen - needlelen))) {
        if (!specstrncmp(look, needle, needlelen))
            return look;
        look++;
    }
    return NULL;
}

/* This isn't a full implementation of strncmp.  In particular, it only
   outputs whether or not the strings are similar, and makes no qualitative
   comparisons.
   */
int specstrncmp(char *a, char *b, int len) {
    char *tmpa = a,
         *tmpb = b;
    int   i = 0;

    if ((a == NULL) && (b == NULL))
        return 0;
    if ((a == NULL) || (b == NULL))
        return 1;

    while(*tmpa && *tmpb && (i <= len)) {
        if (*tmpa != *tmpb)
            return 1;
        i++;
        tmpa++;
        tmpb++;
    }
    return 0;
}

int specstrncpy(char *dst, char *src, int len) {
    /* Copy at most len bytes of src to dst, but don't copy the null byte
       at the end. */
    int i = 0;

    while (*src && (i < len)) {
        *dst++ = *src++;
        i++;
    }
    return i;
}

void specinvoke_exit(int code, specinvoke_state_t *state)
{
    if (state != (specinvoke_state_t *)0 && state->outfp != stdout) {
        fprintf(state->outfp, "specinvoke exit: rc=%d\n", code);
    }
    printf("specinvoke exit: rc=%d\n", code);
    exit(code);
}

char *make_number_buf(unsigned num) {
    /* Make a buffer and copy the string representation of 'num' into it. */
    int   buf_size = 1;
    char *numbuf;

    /* Now this part could be replaced with log(num)/log(10), but for the
       tiny range of numbers that we'll be looking at, some conditionals
       and a little insurance will be plenty.
       */
    if (num < 10) {
        buf_size++;
    } else if (num < 100) {
        buf_size += 2;
    } else if (num < 1000) {
        buf_size += 3;
    } else if (num < 10000) {
        /* Approaching the realm of fantasy... */
        buf_size += 4;
    } else if (num < 100000) {
        /* Almost there... */
        buf_size += 5;
    } else if (num < 1000000) {
        /* Here we are! */
        buf_size += 6;
    } else {
        /* This is the insurance.  It should last until an unsigned int is
         * longer than 64 bits.
         */
        buf_size += 20;
    }

    check_malloc(numbuf, char *, buf_size * sizeof(char), stdout,
                 return NULL,
                 "Failed allocating memory for number buffer.\n")
    memset(numbuf, 0, buf_size * sizeof(char));
    /* sprintf() is used for ease of porting */
    sprintf(numbuf, "%u", num);

    return(numbuf);
}

char *sub_strings(char *src, char *find, char *replace) {
    /* Make a copy of src, replacing occurances of find with replace */
    int replen,
        findlen,
        srclen,
        newlen = 0;
    bool found = false;
    char *tmp   = src,
         *last  = src,
         *rc    = NULL,
         *tmprc = NULL;

    if (src == NULL) return NULL;
    if (find == NULL) return src;

    replen  = strlen(replace);
    findlen = strlen(find);
    srclen  = strlen(src);

    /* Insure++ complains that realloc() frees a NULL pointer.  So make rc
     * non-NULL.  This handles the allocation that would be necessary in
     * the tmp==last section below.
     */
    check_malloc(rc, char *, replen * sizeof(char) + 1, stdout,
                 return NULL,
                 "Failed in initial allocation for string subtitution.\n")

    /* Find find */
    tmp = specstrstr(src, find);
    found = (tmp != NULL) ? true : false;
    while (tmp != NULL) {
        /* Copy the bit into rc that hasn't yet been copied. */
        if (tmp == last) {
            /* It's at the beginning of the string; just copy */
            memset(rc, 0, replen * sizeof(char) + 1);
            newlen = specstrncpy(rc, replace, replen);
        } else {
            tmprc = (char *)realloc(rc,
                    sizeof(char) * (newlen + (tmp - last) + replen + 1));
            if (tmprc == NULL) {
                fprintf(stderr, "Can't realloc %d bytes for %p: %s(%d)\n",
                        (int)(sizeof(char) * (newlen + (tmp - last) + replen + 1)),
                        rc, STRERROR(errno), errno);
                return NULL;
            }
            rc = tmprc;
            newlen += specstrncpy(rc + newlen, last, tmp - last);
            newlen += specstrncpy(rc + newlen, replace, replen);
        }
        last = tmp + findlen;
        tmp = specstrstr(last, find);
    }
    /* Finish the end of the string, if applicable */
    if (last != src && last < (src + srclen)) {
        tmprc = (char *)realloc(rc, sizeof(char) * (newlen + (srclen - (last - src)) + 1));
        if (tmprc == NULL) {
            fprintf(stderr, "Can't realloc %d bytes for %p: %s(%d)\n",
                    (int)(sizeof(char) * (newlen + (srclen - (last - src)) + 1)),
                    rc, STRERROR(errno), errno);
            return NULL;
        }
        rc = tmprc;
        newlen += specstrncpy(rc + newlen, last, (srclen - (last - src)));
    }

    /* Maybe find wasn't found */
    if (!found) {
        free(rc);
        return(strdup(src));
    } else {
        *(rc + newlen) = '\0';
        return(rc);
    }
}

long time_cal(specinvoke_state_t *si) {
    /* Attempt to figure out what resolution whatever timer we're using
     * supports.
     * Returns the minimum time found, since the system can never go
     * faster than the minimum, but might often take longer.
     * This value is used to determine how timestamps will be rounded.
     */
    spec_time_t time,
                prev;
    int i = 0,
        counts[TIMER_CAL_TRIES];
    long min_time = 0,
         deltas[TIMER_CAL_TRIES],
         delta;

    gettime(si, &time);
    prev.sec = time.sec;
    prev.nsec = time.nsec;

    for(i = 0; i < TIMER_CAL_TRIES; i++) {
        int count = 0;
        while (prev.nsec == time.nsec
                && prev.sec == time.sec) {
            gettime(si, &time);
            count++;
        }
        delta = deltas[i] = ((time.sec - prev.sec) * 1000000000) + (time.nsec - prev.nsec);
        counts[i] = count;
        if (delta < min_time || min_time == 0)
            min_time = delta;
        prev.sec  = time.sec;
        prev.nsec = time.nsec;
    }
    if (debug) {
        for(i = 0; i < TIMER_CAL_TRIES; i++)
            printf("time delta for iteration %d: %ldns (%d rounds)\n", i, deltas[i], counts[i]);
        printf("specinvoke: calculated timer resolution (%d iterations): %ld ns using ", i, min_time);
        switch(si->timer_type) {
            case GETTIMEOFDAY: puts("gettimeofday");
                               break;
            case FTIME:        puts("_ftime");
                               break;
            case QPC:          puts("QueryPerformanceCounter");
                               break;
            default:           puts("unknown timer mechanism");
                               break;
        }
    }

    return (min_time);
}

/* Editor settings: (please leave this at the end of the file)
 * vim: set filetype=c syntax=c shiftwidth=4 tabstop=8 expandtab nosmarttab ai:
 */
