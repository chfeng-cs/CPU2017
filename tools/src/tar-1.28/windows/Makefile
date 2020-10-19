#
# Makefile for GNU tar on Windows using MinGW GCC
#
# $Id: Makefile 1086 2011-02-17 00:26:01Z cloyce $

CC=gcc

BITS ?= 64

# These settings are for debugging
CFLAGS = -std=gnu99 -ggdb -O0 -fno-inline-functions -Wall -Wextra

# And these aren't
CFLAGS = -std=gnu99 -O3 -Wall

# __USE_MINGW_ANSI_STDIO fixes problems with %Lf and causes them with PRIuMAX.
CPPFLAGS = -I. -Ignu -I../gnu -I../lib -DHAVE_CONFIG_H -DNO_RMT -DBUILDBITS=$(BITS)

LIBSRC = $(addprefix ../gnu/, \
		copy-acl.c		\
		set-acl.c		\
		allocator.c		\
		areadlink.c		\
		areadlinkat.c		\
		argmatch.c		\
		argp-ba.c		\
		argp-eexst.c		\
		argp-fmtstream.c	\
		argp-fs-xinl.c		\
		argp-help.c		\
		argp-parse.c		\
		argp-pin.c		\
		argp-pv.c		\
		argp-pvh.c		\
		argp-xinl.c		\
		argp-version-etc.c	\
		backupfile.c		\
		bitrotate.c		\
		c-ctype.c		\
		c-strcasecmp.c		\
		c-strncasecmp.c		\
		careadlinkat.c		\
		cloexec.c		\
		close-stream.c		\
		closeout.c		\
		opendir-safer.c		\
		dirname.c		\
		basename.c		\
		dirname-lgpl.c		\
		basename-lgpl.c		\
		stripslash.c		\
		exclude.c		\
		exitfail.c		\
		chmodat.c		\
		chownat.c		\
		fd-hook.c		\
		fdutimensat.c		\
		filenamecat-lgpl.c	\
		fprintftime.c		\
		full-write.c		\
		gettime.c		\
		getpagesize.c		\
		hash.c			\
		human.c			\
		imaxtostr.c		\
		inttostr.c		\
		offtostr.c		\
		uinttostr.c		\
		umaxtostr.c		\
		localcharset.c		\
		malloca.c		\
		mbchar.c		\
		mbscasecmp.c		\
		mbuiter.c		\
		modechange.c		\
		openat-die.c		\
		parse-datetime.c	\
		priv-set.c		\
		progname.c		\
		acl-errno-valid.c	\
		file-has-acl.c		\
		qcopy-acl.c		\
		qset-acl.c		\
		quotearg.c		\
		safe-read.c		\
		safe-write.c		\
		save-cwd.c		\
		savedir.c		\
		se-context.c		\
		se-selinux.c		\
		stat-time.c		\
		statat.c		\
		strftime.c		\
		strnlen1.c		\
		tempname.c		\
		timespec.c		\
		unistd.c		\
		dup-safer.c		\
		fd-safer.c		\
		pipe-safer.c		\
		unlinkdir.c		\
		utimens.c		\
		version-etc.c		\
		version-etc-fsf.c	\
		wctype-h.c		\
		xmalloc.c		\
		xalloc-die.c		\
		xgetcwd.c		\
		xsize.c			\
		xstrndup.c		\
		xstrtol.c		\
		xstrtoul.c		\
		xstrtol-error.c		\
		xstrtoumax.c		\
		xvasprintf.c		\
		xasprintf.c		\
		asnprintf.c		\
		at-func2.c		\
		canonicalize-lgpl.c	\
		chdir-long.c		\
		chown.c			\
		close.c			\
		closedir.c		\
		dirfd.c			\
		dup.c			\
		dup2.c			\
		error.c			\
		euidaccess.c		\
		faccessat.c		\
		fchdir.c		\
		fchmodat.c		\
		fchownat.c		\
		fcntl.c			\
		fdopendir.c		\
		fileblocks.c		\
		fnmatch.c		\
		fpending.c		\
		fstat.c			\
		fstatat.c		\
		futimens.c		\
		getcwd.c		\
		getcwd-lgpl.c		\
		getdelim.c		\
		getdtablesize.c		\
		getgroups.c		\
		getline.c		\
		getopt.c		\
		getopt1.c		\
		gettimeofday.c		\
		group-member.c		\
		lchown.c		\
		link.c			\
		linkat.c		\
		localeconv.c		\
		malloc.c		\
		memrchr.c		\
		mkdir.c			\
		mkdirat.c		\
		mkdtemp.c		\
		mkfifo.c		\
		mkfifoat.c		\
		mknod.c			\
		mknodat.c		\
		msvc-inval.c		\
		msvc-nothrow.c		\
		nl_langinfo.c		\
		obstack.c		\
		open.c			\
		openat.c		\
		openat-proc.c		\
		opendir.c		\
		posix_openpt.c		\
		printf-args.c		\
		printf-parse.c		\
		ptsname.c		\
		ptsname_r.c		\
		raise.c			\
		rawmemchr.c		\
		read.c			\
		readlink.c		\
		readlinkat.c		\
		realloc.c		\
		regex.c			\
		rename.c		\
		renameat.c		\
		rmdir.c			\
		rpmatch.c		\
		secure_getenv.c		\
		selinux-at.c		\
		setenv.c		\
		sleep.c			\
		snprintf.c		\
		stat.c			\
		stpcpy.c		\
		strchrnul.c		\
		strdup.c		\
		strerror.c		\
		strerror-override.c	\
		strndup.c		\
		symlink.c		\
		symlinkat.c		\
		time_r.c		\
		ttyname_r.c		\
		unlink.c		\
		unlinkat.c		\
		unlockpt.c		\
		unsetenv.c		\
		utimensat.c		\
		vasnprintf.c		\
		vsnprintf.c		\
		wcwidth.c		\
		write.c			\
	 ) \
	$(addprefix ../lib/, \
		paxerror.c		\
		paxexit-status.c	\
		paxnames.c		\
		rtapelib.c		\
		stdopen.c		\
		wordsplit.c		\
		xattr-at.c		\
	 )

TARSRC = $(addprefix ../src/, \
		buffer.c		\
		checkpoint.c		\
		compare.c		\
		create.c		\
		delete.c		\
		exit.c			\
		exclist.c		\
		extract.c		\
		xheader.c		\
		incremen.c		\
		list.c			\
		misc.c			\
		names.c			\
		sparse.c		\
		suffix.c		\
		system.c		\
		tar.c			\
		transform.c		\
		unlink.c		\
		update.c		\
		utf8.c			\
		warning.c		\
		xattrs.c		\
	 )

LIBOBJS = $(LIBSRC:.c=.o)
TAROBJS = $(TARSRC:.c=.o)
LIBS = # -lmingwex

all: tar.exe

libtar.a: $(LIBOBJS)
	$(AR) r $@ $(LIBOBJS)

tar.exe: libtar.a $(TAROBJS)
	$(CC) $(CFLAGS) -o $@ $(TAROBJS) libtar.a $(LIBS)

%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

%.i: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -C -E $< > $@

clean:
	del /q /s /f ..\*.i
	del /q /s /f ..\*~
	del /q /s /f $(subst /,\\,$(LIBOBJS))
	del /q /s /f $(subst /,\\,$(TAROBJS))
	del /q /s /f libtar.a tar.exe
