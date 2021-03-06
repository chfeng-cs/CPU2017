/* getopt.c:
 * a public domain implementation of getopt()
 *
 * The following source code is an adaptation of the public domain getopt()
 * implementation presented at the 1985 UNIFORUM conference in Dallas,
 * Texas. Slight edits have been made to improve readability and the result
 * is released into the public domain like that from which it was derived.
 */

#if defined(HAVE_CONFIG_H)
# include "config.h"
#endif

#include <stdio.h>
#include <string.h>

int optind = 1;
int optopt;
char *optarg;

int
my_getopt(int argc, char **argv, char *opts)
{
	static int sp = 1;
	register int c;
	register char *cp;

	if (sp == 1) {
		
		/* If all args are processed, finish */
		if (optind >= argc) {
			return EOF;
		}
		if (argv[optind][0] != '-' || argv[optind][1] == '\0') {
			return EOF;
		}
		
	} else if (!strcmp(argv[optind], "--")) {
		
		/* No more options to be processed after this one */
		optind++;
		return EOF;
		
	}
	
	optopt = c = argv[optind][sp];

	/* Check for invalid option */
	if (c == ':' || (cp = strchr(opts, c)) == NULL) {
		
		fprintf(stderr,
			"%s: illegal option -- %c\n",
			argv[0],
			c);
		if (argv[optind][++sp] == '\0') {
			optind++;
			sp = 1;
		}
		
		return '?';
	}

	/* Does this option require an argument? */
	if (*++cp == ':') {

		/* If so, get argument; if none provided output error */
		if (argv[optind][sp+1] != '\0') {
			optarg = &argv[optind++][sp+1];
		} else if (++optind >= argc) {
			fprintf(stderr,
				"%s: option requires an argument -- %c\n",
				argv[0],
				c);
			sp = 1;
			return '?';
		} else {
			optarg = argv[optind++];
		}
		sp = 1;

	} else {
		if (argv[optind][++sp] == '\0') {
			sp = 1;
			optind++;
		}
		optarg = NULL;
	}
	
	return c;
}
