#
# util.pl
#
# Copyright 1999-2019 Standard Performance Evaluation Corporation
#
# $Id: util.pl 6266 2019-06-25 03:46:16Z CloyceS $

use strict;
use Safe;
use Scalar::Util qw(blessed);
use File::stat;
use IO::Dir;
use File::Copy;
use File::Basename;
use File::Path;
use MIME::Base64;
use Carp;
use IO::Handle;
use IO::File;
use Fcntl qw(:flock);
use POSIX qw(:sys_wait_h);
use IO::Socket; # For PTD support
use Time::HiRes;
use Date::Parse;
use Data::Dumper;
use File::Spec qw(rel2abs);
eval 'use String::ShellQuote';
my $shellquote = $@ eq '';

require 'util_common.pl';

our ($ua);

my %logged_vars = ();
my %old_logged = ();
my $diff_debug = 0;

my $version = '$LastChangedRevision: 6266 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'util.pl'} = $version;

sub check_tolerances {
    my ($abstol, $reltol, $bench) = @_;
    my $ret = '';

    # Check reltol for large values
    if (::ref_type($reltol) eq 'HASH') {
        foreach my $val (get_hash_leaves($reltol)) {
            if ($val->[1] >= 1) {
                $ret .= "Unreasonably large relative tolerance ($val->[1]) set for $val->[0] in $bench\n";
            }
        }
    } else {
        if ($reltol >= 1) {
            $ret .= "Unreasonably large relative tolerance ($reltol) set for all in $bench\n";
        }
    }

    # Check abstol for small values
    # No, actually don't.  Absolute tolerances may really need to be very small.
    #if (::ref_type($abstol) eq 'ARRAY') {
    #} else {
    #  if ($abstol < epsilon) {
    #    $ret .= "Unreasonably small absolute tolerance ($abstol) set for all in $bench\n";
    #  }
    #}

    return $ret;
}

sub get_hash_leaves {
    my ($val, $curr) = @_;
    my @rc = ();

    if (::ref_type($val) eq 'HASH') {
        foreach my $key (sort keys %{$val}) {
            if ($curr ne '') {
                push @rc, get_hash_leaves($val->{$key}, $curr."->{$key}");
            } else {
                push @rc, get_hash_leaves($val->{$key}, $key);
            }
        }
    } elsif (::ref_type($val) eq 'ARRAY') {
        $curr = 'array' if $curr ne '';
        for(my $i = 0; $i < @{$val}; $i++) {
            push @rc, get_hash_leaves($val->[$i], $curr."->[$i]");
        }
    } else {
        return [ $curr, $val ];
    }

    return @rc;
}

sub link_file {
    my ($srcdir, $targetfile, $dirs) = @_;

    return 0 unless defined($targetfile);
    if (ref($dirs) ne 'ARRAY') {
        return 0 if ($dirs eq '');
        $dirs = [ $dirs ];
    }
    my @dirs = grep { defined } @{$dirs};

    my $source = jp($srcdir, $targetfile);
    return undef unless -e $source;

# Link the file from $srcdir into all the directories
    foreach my $dir (@dirs) {
        my $target = jp($dir, $targetfile);
        if (!link($source, $target)) {
            Log(0, "\nWARNING: Linking $source to $target failed: $!\n");
            Log(0, '  '.Carp::longmess()."\n\n");
            return 0;
        }
    }

    return 1;
}

sub copy_file {
    my ($source, $targetfile, $dirs, $verify, $sumhash, $genhash) = @_;
    # CVT2DEV: $verify = 0;
    $sumhash = \%::file_sums unless ref($sumhash) eq 'HASH';

    if (!defined($targetfile)) {
        $targetfile = basename($source);
    }
    if (ref($dirs) ne 'ARRAY') {
        if ($dirs eq '') {
            $dirs = [ dirname($targetfile) ];
            $targetfile = basename($targetfile);
        } else {
            $dirs = [ $dirs ];
        }
    }

    # Do some pre-copy checks
    foreach my $dir (@{$dirs}) {
        next unless defined($dir);
        my $target = jp($dir, $targetfile);
        if (-e $target) {
            # Sheesh!  Make sure that the *target* isn't read-only
            # Thanks very much, Microsoft!
            copy_perms($target, $target, 0644);
        }
    }

    # Copy the file into all the directories
    foreach my $dir (@{$dirs}) {
        next unless defined($dir);
        my $target = jp($dir, $targetfile);
        if (!copy($source, $target)) {
            Log(0, "\nERROR: Copying $source to $target failed: $!\n");
            Log(0, '  '.Carp::longmess()."\n\n");
            return 0;
        }
    }

    # Do the post-copy cleanup and file verification
    # Get the hash from the MANIFEST if the source is compressed (because
    # there's no real file to generate it _from_) or if check_integrity is
    # is on.
    my $refhash = $sumhash->{$source};
    if ($verify) {
        if (!defined($refhash)) {
            # It's not in the existing set, but that MAY be okay
            if ($genhash) {
                # Expected to be missing, so generating a sum for it is okay.
                # Get the bit length from a file in MANIFEST
                $refhash = filedigest($source, length((values %{$sumhash})[0]) * 4);
            } else {
                # Not okay
                Log(0, "\nERROR: Missing reference checksum for $source".Carp::longmess()."\n\n");
                return 0;
            }
        }
    }
    foreach my $dir (@{$dirs}) {
        next unless defined($dir);
        my $target = jp($dir, $targetfile);
        # Ensure that the copied file is not read-only
        copy_perms($source, $target, 0644);
        # Set the modification time on the target to match the source
        utime (@{stat($source)}[8,9], $target);

        if ($verify) {
            my ($targhash, $bits, $algo) = filedigest($target, length($refhash) * 4);
            Log(89, "Comparing $algo hashes:\n  $refhash $source\n  $targhash $target\n");
            my $errcount = 0;
            while (($refhash ne $targhash) && ($errcount < 5)) {
                $errcount++;
                Log(0, "Target file ($target) $algo doesn't match\nafter copy from $source in copy_file ($errcount tr".(($errcount > 1)?'ies':'y')." total)!\nSleeping 2 seconds to see if it gets better...\n");
                sleep(2);
                ($targhash, $bits, $algo) = filedigest($target, $bits);
            }
            if ($errcount >= 5) {
                # The files continued to mismatch; it's an error
                Log(0, "\nERROR: File checksum mismatch while copying $source to $target".Carp::longmess()."\n\n");
                offer_verify_advice();
                # Let's leave some evidence for later diagnosis if keeptmp is
                # on, or if this is not a release build
                unlink $target unless (::is_devel($::suite_version) or istrue($::global_config->keeptmp));
                return 0;
            }
        }
    }
    return 1;
}

sub copy_tree {
    my ($source, $target, $sumhash, $ignore, $fast) = @_;
    # CVT2DEV: $fast = 1;
    $sumhash = \%::file_sums unless ref($sumhash) eq 'HASH';
    if (ref($ignore) eq 'ARRAY') {
        $ignore = { map { $_ => 1 } @{$ignore} };
    } elsif (ref($ignore) ne 'HASH') {
        $ignore = { };
    }
    my $dir = new IO::Dir $source;
    while (defined(my $file = $dir->read)) {
        next if $file eq '.' || $file eq '..';
        next if exists $ignore->{$file};
        my $sf = jp($source, $file);
        my $tf = jp($target, $file);
        if (-e $tf) {
            # Make sure that the target isn't read-only.  See bile above
            copy_perms($tf, $tf, 0644);
        }
        if (-f $sf) {
            if ($::check_integrity && !$fast) {
                if (!exists $sumhash->{$sf}) {
                    Log(0, "\n$sf has no stored checksum!\n");
                    offer_verify_advice();
                    return 0;
                }
                if ($sumhash->{$sf} ne filedigest($sf, length($sumhash->{$sf}) * 4)) {
                    Log(0, "\n$sf is corrupt!\n");
                    offer_verify_advice();
                    return 0;
                }
            }
            if (!copy($sf, $tf)) {
                Log(0, "ERROR: Copying $sf to $tf failed: $!\n");
                Log(0, '  '.Carp::longmess());
                return 0;
            }
            # Ensure that the copied file is not read-only
            copy_perms($sf, $tf, 0644);
            utime (@{stat($sf)}[8,9], $tf);
        } elsif (-d $sf and $file ne '.svn' and $file ne '.git') {
            eval { mkpath($tf) };
            if ($@) {
                Log(0, "ERROR: Couldn't create destination directory: $@\n");
                return 0;
            }
            if (!copy_tree($sf, $tf, $sumhash, $ignore, $fast)) {
                # Propagate the error back up
                return 0;
            }
        }
    }
    return 1;
}

sub find_biggest_ext {  ## find the file with the highest suffix
    my $dir = shift;
    my $ext = shift;
    $ext = '' unless defined($ext);
    my $dh = new IO::Dir $dir;
    my $num = 0;
    if (!defined $dh) {
        Log(0, "find_biggest_num: Can't open directory '$dir': $!\n");
    } else {
        while (defined($_ = $dh->read)) {
            $num = $1 if m/\.(\d+)${ext}$/ && $1 > $num;
        }
    }
    return $num;
}

sub build_tree_hash {
    my ($bmobj, $sumhash, @absdirs) = @_;
    my ($files, $dirs) = ({}, {});

    my $os = $bmobj->OS if (ref($bmobj) ne '');
    my @work;
    for my $dir (@absdirs) {
        push (@work, [$dir, '', ''])
    }

    while (@work) {
        my ($absdir, $absroot, @paths) = @{shift @work};
        while (@paths) {
            my $path    = shift(@paths);
            my $root    = jp($absroot, $path);
            my $dir     = jp($absdir, $path);
            my $dh = new IO::Dir $dir;
            my $file;

            if (! defined $dh ) {
                Log(0, "Can't open path '$dir: $!\n");
                return(undef, undef);
            }
            while (defined($file = $dh->read)) {
                # Ignore hidden files (CPUv6 Trac #642); they should be
                # harmless, and they are often created without knowledge of or
                # direction from the user.  (VIM's swap files, MacOS X Finder's
                # .DS_Store files)
                next if $file =~ /^\./;
                my $absfile = jp($dir, $file);
                my $relfile = jp($root, $file);
                if (-d $absfile) {
                    if ($file eq '.' or $file eq '..' or
                        $file eq '.svn' or $file eq '.git') {
                    } elsif ($file =~ m/^OS_(.*)(-|$)/i) {
                        if ($1 eq $os) {
                            push (@work, [ $absfile, $root, '' ]);
                        }
                    } else {
                        $dirs->{$relfile} = '';
                        push (@paths, $relfile);
                    }
                } elsif (-f $absfile) {
                    if ($::check_integrity &&
                        istrue($bmobj->strict_rundir_verify) &&
                        defined($sumhash) && ref($sumhash) eq 'HASH') {
                        if (!exists($sumhash->{$absfile})) {
                            Log(0, "build_tree_hash: $absfile not found in checksum list\n");
                            return (undef, undef);
                        }
                    }
                    $files->{$relfile} = $absfile;
                } else {
                    Log(0, "build_tree_hash: Can't tell what $absfile is!\n");
                }
            }
        }
    }
    return ($files, $dirs);
}

sub offer_verify_advice {
    if (!istrue($::global_config->reportable)) {
        Log(0, "\n Since this run is not reportable, you may avoid this error in the future\n");
        Log(0, " by setting\n");
        Log(0, "   strict_rundir_verify = 0\n");
        Log(0, " in your config file.\n\n");
    }
}

    # $cmd   -- the (possibly unexpanded) command string
    # $outn  -- basename for output and errors files
    # $repl  -- array of hash(es) of replacement variables and values
    # $quiet -- Whether or not to complain about error exits
    # $no_output -- Whether to suppress all output

# Run command(s), possibly doing variable expansion and possibly logging the
# output.
# Parameters:
# $cmd:    the command to execute.  caller is responsible for pasting commands
#          together in a way that's appropriate for the shell on the target
#          platform.
# $opts:   a hash ref of various options:
#    - repl:     array ref of objects to use for command variable expansion.
#                Any array (even an empty one) will cause expansion to be done
#    - basename: base name for output files if names are not specified
#                explicitly
#    - combined: whether or not stdout and stderr from the command should be
#                commingled
#    - outname:  filename for output (stdout only if combined output not
#                specified; all output otherwise)
#    - errname:  filename for stderr (ignored if combined output specified)
#    - fake:     whether to execute the command or just print it.  This is
#                separate from $config->fake because sometimes it's necessary
#                to actually run a command in fake mode (as with "specmake -n"
#                or something like that)
#    - ignoreerr: whether or not to log a complaint about a non-zero exit from
#                 $cmd
#    - nooutput: suppress all output to the screen/log
sub log_system {
    my ($cmd, $opts) = @_;
    $opts = {} unless ref($opts) eq 'HASH';
    my $config  = $::global_config;
    my $tmpdir_output = 0;

    my $teeout;
    if ($opts->{'nooutput'}) {
        $opts->{'ignoreerr'} = 1;
        $teeout = 0;
    } else {
        $teeout = istrue($config->teeout);
    }
    my $orig_basename = $opts->{'basename'};

    # If $config->fake is true, but $opts->{'fake'} is not, then this is an
    # example command (such as 'make -n') which should be sent to the screen as
    # well as the log.
    $teeout = 1 if (istrue($config->fake) and !$opts->{'fake'} and !$opts->{'nooutput'});

    # Get a temporary file if no output options were specified
    if ((!defined($opts->{'basename'}) or $opts->{'basename'} eq '')
            and ((!defined($opts->{'outname'}) or $opts->{'outname'} eq '')
                or (!$opts->{'combined'} and (!defined($opts->{'errname'}) or $opts->{'errname'} eq '')))) {
        my $tmpdir  = ::get_tmp_directory($config, 1);
        $opts->{'basename'} = ::jp($tmpdir, 'tmp');
        $tmpdir_output = 1;
    }

    # Make or use names for output files
    my ($outname, $errname);
    if (exists($opts->{'outname'}) and $opts->{'outname'} ne '') {
        $outname = $opts->{'outname'};
    } else {
        $outname = $opts->{'basename'}.'.out';
    }
    if (exists($opts->{'errname'}) and $opts->{'errname'} ne '') {
        $errname = $opts->{'errname'};
    } else {
        $errname = $opts->{'basename'}.'.err';
    }

    # Figure out what (if any) output redirection will happen. $redir/$append
    # are only used when printing commands, so DON'T set them to anything
    # if teeout is on.
    my ($redir,  $err_redir)  = ('', '');
    my ($append, $err_append) = ('', '');
    if ($opts->{'combined'}) {
        $errname   = undef;
        if ($teeout == 0) {
            $redir     =  '>'.$outname.' 2>&1';
            $append    = '>>'.$outname.' 2>&1';
        }
        $err_redir = $err_append = '';
    } elsif ($teeout == 0) {
        $redir      =   '>'.$outname;
        $append     =  '>>'.$outname;
        $err_redir  =  '2>'.$errname;
        $err_append = '2>>'.$errname;
    }
    foreach my $tmpfile ($errname, $outname) {
        unlink $tmpfile if defined($tmpfile) and $tmpfile ne '';
    }

    my @repl = (::ref_type($opts->{'repl'}) eq 'ARRAY') ? @{$opts->{'repl'}} : ();
    my $rc = 0;
    my $desc = ' '.$orig_basename if $orig_basename ne '';

    if (exists($opts->{'repl'}) and ::ref_type($opts->{'repl'}) eq 'ARRAY') {
        $cmd = ::path_protect($cmd);
        $cmd = command_expand($cmd, $opts->{'repl'}, 'no_log' => $opts->{'nooutput'});
        $cmd = ::path_unprotect($cmd);
    }
    my @cmdlist = split(/[\r\n]+/, $cmd);

    my $fake_cmd = substr($cmd, 0, 40);
    $fake_cmd .= '...' if (length($cmd) > 40);
    $fake_cmd = $orig_basename." ($fake_cmd)" if $orig_basename ne '';

    Log (120, "Issuing$desc command '$cmd'\n") unless ($opts->{'nooutput'} or istrue($config->fake));

    # give user some indication of what is happening if she is
    # is about to get some tee output
    Log(0, join('; ', @cmdlist)."\n") if (!$opts->{'fake'} and $teeout);

    # Fix up the environment, if that's happening
    my %oldENV = %ENV;
    main::munge_environment(@repl) if $opts->{'env_vars'} or (!exists($opts->{'env_vars'}) and istrue($config->env_vars));

    # These numbers should ideally match the ones in runcpu_system
    my $loglvl = 180;
    $loglvl = 0 if ($teeout or istrue($config->fake));

    # Go
    my $start = time;
    Log (125, "Start$desc command: ", timeformat('date-time', $start), " ($start)\n") unless ($opts->{'nooutput'} or istrue($config->fake));

    my $errno = undef;
    if ($opts->{'fake'}) {
        if (!$opts->{'nooutput'}) {
            my @cmds = @cmdlist;
            my $printcmd = [ shift(@cmds)." $redir $err_redir" ];
            push @{$printcmd}, map { "$_ $append $err_append" } @cmds;
            Log(0, join("\n", @$printcmd)."\n");
        }
        $rc = 0;

    } else {
        Log($loglvl, "\n%% Fake commands from $fake_cmd:\n") if (!$opts->{'nooutput'} and istrue($config->fake));
        $rc = runcpu_system($config, [ @cmdlist ], undef,
            {
                'tee'      => $teeout,
                'basename' => $opts->{'basename'},
                'outfile'  => $outname,
                'errfile'  => $errname,
                'cleanup'  => 0,
            });
        $errno = $! if $rc == -1;
        Log($loglvl, "%% End of fake output from $fake_cmd\n\n") if istrue($config->fake);
    }
    my $stop = time;
    my $elapsed = $stop-$start;
    if (!$opts->{'nooutput'} and !istrue($config->fake)) {
        Log (125, "Stop$desc command: ", timeformat('date-time', $stop), " ($stop)\n");
        Log (125, "Elapsed time for$desc command: ", to_hms($elapsed), " ($elapsed)\n");
    }
    %ENV = %oldENV;

    if ($rc) {
        if ($rc == $config->sigint and !istrue($config->ignore_sigint)) {
            ## the command was interrupted
            Log(0, "Exit on SIGINT\n");
            do_exit(1);
        }

        my @files = ();
        if ($errname ne '' and -f $errname and -s $errname) {
            push @files, '"'.rel2abs($errname).'"';
        }
        if (@files == 0 or $^O =~ /MSWin/) {
            # Windows compilers often dump the important error messages to
            # stdout.  Also include it if there was nothing in the error file
            if ($outname ne '' and -f $outname and -s $outname) {
                push @files, '"'.rel2abs($outname).'"';
            }
        }
        my $msg;
        if (@files > 0) {
            # Attempt to keep the file around if it was made in a temporary
            # directory (Trac #778)
            $config->{'keeptmp'} = 1 if $tmpdir_output;
            $msg = ":\n".
                   "\n".
                   "  ----------------------------------------------------------------------------\n".
                   "  Please review ".(@files > 1 ? 'these files' : 'this file').":\n".
                   "    ".join("\n    ", @files)."\n".
                   "  ----------------------------------------------------------------------------\n";
        } else {
            $msg = '; no non-empty output files exist';
        }
        $msg .= "\n";

        my $exitcode = WEXITSTATUS($rc);
        $msg .= "  Command returned exit code $exitcode\n" if $exitcode;
        if ($rc & 0xff) {
            $msg .= sprintf "  Command exited with signal %d%s\n", $rc & 0x7f, ($rc & 0x80) ? '(core dumped)' : '';
        }
        $msg .= "  Error may have been \"$errno\"\n" if defined($errno);

        Log(0, "Error with$desc '$cmd'$msg") unless $opts->{'ignoreerr'};
    }
    return $rc;
}

sub munge_environment {
    my (@refs) = @_;
    no strict 'refs';
    my %vars_set = ();

    while (@refs && ref($refs[0]) ne '') {
        my $ref = shift @refs;
        if (blessed($ref) && $ref->isa('Spec::Config')) {
            foreach my $key ($ref->list_keys) {
                if ($key =~ m/^ENV_(\S+)/) {
                    my $name = $1;
                    my $val = $ref->accessor($key);
                    Log(35, "Setting(config) environment variable \"$name\" to \"$val\"\n");
                    if ($val =~ /\s+$/) {
                        Log(0, "WARNING: Value for environment variable \"$name\" has trailing whitespace!\n");
                    }
                    use warnings 'FATAL' => qw(utf8);
                    $ENV{$name} = $val;
                    $vars_set{$name}++;
                }
            }
        } elsif (::ref_type($ref) eq 'HASH') {
            foreach my $key (keys %$ref) {
                if ($key =~ m/^ENV_(\S+)/) {
                    my $name = $1;
                    my $val = $ref->{$key};
                    Log(35, "Setting(hash) environment variable \"$name\" to \"$val\"\n");
                    if ($val =~ /\s+$/) {
                        Log(0, "WARNING: Value for environment variable \"$name\" has trailing whitespace!\n");
                    }
                    use warnings 'FATAL' => qw(utf8);
                    $ENV{$name} = $val;
                    $vars_set{$name}++;
                }
            }
        }
    }
    while (@refs > 1) {
        my $name = shift @refs;
        my $val = shift @refs;
        if ($name =~ m/^ENV_(\S+)/) {
            Log(35, "Setting(param) environment variable \"$name\" to \"$val\"\n");
            if ($val =~ /\s+$/) {
                Log(0, "WARNING: Value for environment variable \"$name\" has trailing whitespace!\n");
            }
            use warnings 'FATAL' => qw(utf8);
            $ENV{$name} = $val;
            $vars_set{$name}++;
        }
    }

    return sort keys %vars_set;
}

sub command_expand {
    my ($pattern, $repl, %opts) = @_;

    # If the string does not contain any $, then there will not be anything
    # to expand.  But if the verbosity is sufficiently high, do it anyway.
    return $pattern unless ($pattern =~ m/\$/ or Log(35));

    my $last_string;
    my $do_log = 1 - !!$opts{'no_log'};  # Intentional; undef => 0
    my $do_setup = 1;
    my @refs = ();
    if ((::ref_type($repl) eq 'ARRAY')) {
        @refs = @{$repl};
    } else {
        @refs = ($repl);
    }
    my $s = $opts{'safe'};
    if (defined($s)) {
        if (ref($s) eq 'Safe') {
            # The caller has provided a presumably pre-setup Safe compartment
            # with variables, etc, populated.
            $do_setup = 0;
        }
    }
    $s = new_safe_compartment('tmp', undef) unless defined($s);

    my $string = $pattern;
    my %paths = ();             # Path variables that may need
    # post-interpolation fixup if they contain \

    no strict 'refs';

    if ($do_setup) {
        my (undef, $file, $line) = caller;

        if ($do_log) {
            %old_logged = %logged_vars;
            %logged_vars = ('__called_from_sub__' => "$file line $line");
        }
        while (@refs && ref($refs[0]) ne '') {
            my $ref = shift @refs;
            if (blessed($ref) && $ref->isa('Spec::Config')) {
                my $from;
                # Show the _result_ of preENV_* settings if it looks like they
                # have been applied; i.e. if preenv is false and note-preenv is
                # true.  Otherwise just show the preENV_* lines themselves.
                # This is more defensive than usual since there's no guarantee
                # that $ref is the top-level config object, though it usually
                # is.
                my $preenv      = $ref->accessor_nowarn('preenv');
                my $notepreenv  = $ref->accessor_nowarn('note_preenv');
                my $show_as_env = (defined($preenv) && defined($notepreenv) && !::istrue($preenv) && ::istrue($notepreenv));
                for my $key ($ref->list_keys) {
                    my $val;
                    if($show_as_env and $key =~ /^preENV_(.*)/ and exists($ENV{$1})) {
                        $from = 'environment';
                        $key = $1;
                        $val = $ENV{$key};
                    } else {
                        $from = 'config';
                        $val = $ref->accessor($key);
                    }
                    safe_store($key, $val, $s, $from, \%paths, $do_log);
                }
            } elsif (ref($ref) eq 'HASH') {
                for my $key (keys %$ref) {
                    my $val = $ref->{$key};
                    safe_store($key, $val, $s, 'hash', \%paths, $do_log);
                }
            }
        }
# These are expanded by specinvoke
        my $safevarref = $s->varglob('SPECCOPYNUM');
        $$safevarref = '$SPECCOPYNUM';
        $safevarref = $s->varglob('BIND');
        $$safevarref = '$BIND';
        report_sub_vars() if $do_log;
    }

    $string = $pattern;
    for (my $i = 0; ; $i++) {
        $last_string = $string;
        $string =~ s/([\\])(.)/($2 eq '#')?"\\$1$2":"\\$1\\$2"/eg;
        $string =~ s/\#/\\\#/g;
        $string = $s->reval("qq#$string#;");
        if ($@) {
            Log(0, "expansion of '$pattern' in stage '$last_string' caused an eval error: $@\n");
            do_exit(1);
        }
        last if $string eq $last_string;
        if ($i >= 100) {
            Log(0, "expansion of '$pattern' resulted in $i recursions!\n");
            do_exit(1);
        }
    }
    $string =~ s/([\\])(\#)/($2 eq '#')?"\\$1$2":"\\$1\\$2"/eg;
    $string =~ s/\#/\\\#/g;
    $string = $s->reval("qq#$string#;");
# Now that all of the interpolations have happened, go back and make the
# paths right.
# We reverse sort by length of path to avoid screwing up more specific
# paths by replacing their prefixes first.
    foreach my $pathkey (sort { length($paths{$b}->[1]) <=> length($paths{$a}->[1]) } keys %paths) {
        $string =~ s/\Q$paths{$pathkey}->[0]\E/$paths{$pathkey}->[1]/g;
    }

    return wantarray ? ($string, $s) : $string;
}

sub safe_store {
    my ($key, $val, $compartment, $label, $pathref, $do_log) = @_;

    my $valtype = ref($val);
    # Only put scalars and arrays into the Safe compartment.
    return if ($valtype ne '' && $valtype ne 'ARRAY');

    # Some variables should not be put into the Safe compartment.
    return if ($key =~ /^(?:(?:raw|pp)txtconfig(?:all)?|oldhashes|compile_options|flags)$/);

    my $safevarref = $compartment->varglob($key);
    if ($valtype eq 'ARRAY') {
        # There are a few arrays that should not be propagated
        return if ($key =~ /^(?:refs|formatlist|benchconf|benchsets|result_list|entries|runlist|setobjs|orig_argv)/);
        @{$safevarref} = @{$val};
        $logged_vars{$key} = [ '( '.join(', ', @{$val}).' )', $key, $label, '@' ] if $do_log;
    } else {
        $$safevarref = $val;
        $logged_vars{$key} = [ "\"$val\"", $key, $label, '$' ] if $do_log;
        if ($key =~ /(\S*(?:path|top))/o) {
            # Transform any backslashes in the path to forward
            # slashes, and stow the original result so that it
            # can be put back after the eval (which would destroy
            # the backslashes in the path)
            my $fixpath = $val;
            $fixpath =~ s/\\/\//go;
            $pathref->{$key} = [ $fixpath, $val ];
            $$safevarref = $fixpath;
        }
    }
}

sub report_sub_vars {
    my $header_done = 0;
    my $min_log_level = 35;

    Log($min_log_level, "Variable list for substitution");
    if (exists($logged_vars{'__called_from_sub__'})) {
        Log($min_log_level, " (called from $logged_vars{'__called_from_sub__'})");
    }
    Log($min_log_level, ":\n");

    # Now report on what's changed
    my %seen = ();
    foreach my $key (sort grep { exists($old_logged{$_}) } keys %logged_vars) {
        next if $key eq '__called_from_sub__';
        my ($oldtxt) = @{$old_logged{$key}};
        delete $old_logged{$key};
        $seen{$key}++;
        my ($txt, $item, $from, $type) = @{$logged_vars{$key}};
        next if $oldtxt eq $txt;
        if (!$header_done) {
            Log($min_log_level, " - Variables available for interpolation that have changed since the last list:\n");
            $header_done = 1;
        }
        # Mark things with the high bit set so they don't mess up log file
        # viewers expecting UTF or something.
        $txt =~ s/([\x{80}-\x{ff}])/sprintf "\\x{%02X}", ord($1)/ego;
        Log($min_log_level, "    (From $from) $type$item = $txt\n");
    }
    if (!$header_done) {
        Log($min_log_level, " - No variables changed\n");
    }

    # Now for the new stuff.
    $header_done = 0;
    foreach my $key (sort grep { !exists($seen{$_}) } keys %logged_vars) {
        next if $key eq '__called_from_sub__';
        my ($txt, $item, $from, $type) = @{$logged_vars{$key}};
        if (!$header_done) {
            Log($min_log_level, " - Variables available for interpolation that were not in the last list:\n");
            $header_done = 1;
        }
        # Mark things with the high bit set so they don't mess up log file
        # viewers expecting UTF or something.
        $txt =~ s/([\x{80}-\x{ff}])/sprintf "\\x{%02X}", ord($1)/ego;
        Log($min_log_level, "    (From $from) $type$item = $txt\n");
    }
    if (!$header_done) {
        Log($min_log_level, " - No new variables\n");
    }

    # Now for the deleted stuff.
    $header_done = 0;
    foreach my $key (sort keys %old_logged) {
        next if $key eq '__called_from_sub__';
        my ($txt, $item, $from, $type) = @{$old_logged{$key}};
        if (!$header_done) {
            Log($min_log_level, " - Variables from the previous list that are NO LONGER AVAILABLE:\n");
            $header_done = 1;
        }
        Log($min_log_level, "    $type$item\n");
    }
    if (!$header_done) {
        Log($min_log_level, " - No deleted variables\n");
    }
}

## ############
## SUB                   FROM_HMS
## ############

## takes strings of hh:mm:ss (or mm:ss) and returns number of seconds

sub from_hms {
    my ($time) = @_;
    my (@vals) = split (":", $time);
    $time = 0;
    for (@vals) {
        $time *= 60;
        $time += $_;
    }
    $time;
}

## ############
## SUB                   TO_HMS
## ############

## takes seconds and returns a string of hh:mm:ss
## optionally can take a second argument of decimal seconds

sub to_hms {
    my ($t, $t2) = @_;
    my ($h,$m,$s);
    $s = $t % 60;
    $t = int($t/60);
    $m = $t % 60;
    $h = int($t/60);
    if ($t2) {
        sprintf ("%02d:%02d:%02d.%06d", $h, $m, $s, $t2);
    } else {
        sprintf ("%02d:%02d:%02d", $h, $m, $s);
    }
}

sub uniq {
    my (@data) = @_;
    my %u = map { $_ => 1 } @data;
    return keys %u;
}

sub apply_diff {
    my ($path, $hunks) = @_;
    my ($all_ok, $offset_used) = (1, 0);

    my $fh = new IO::File '<'.$path;
    die "Couldn't open $path for reading: $!\nStopped" unless defined($fh);

    # This will take more memory (two copies of each file instead of just one),
    # but is pretty necessary to ensure that we have arrays of lines no matter
    # which OS happens to be running the script.
    local $/ = undef;           # Slurp mode
    my $contents = <$fh>;
    undef $fh;

    # Clean the line endings.
    # Don't use [\r\n]+ for the split because that removes sequences of
    # blank lines.
    my @oldfile = map { tr{\012\015}{\012\012}s; $_ } split(/(?:\n|\r\n)/, $contents);

    # The basic workings are from apply_diff in Algorithm::Apply::Diff

    my $delta = 0;
    my $hunk_count = 0;
    foreach my $changeref (@{$hunks}) {
        $hunk_count++;
        if ($diff_debug) {
            Log(0, "\n\n---------------------------------------------------------------\n");
            Log(0, "New hunk (#$hunk_count): base = ".$changeref->{'base'}."; context = ".$changeref->{'clines'}."\n");
            Log(0, "Current delta is $delta\n");
            Log(0, "\nCalling match_context($changeref->{'base'} + $delta, $changeref->{'context'}, \@oldfile)\n");
        }
        my $base = match_context($changeref->{'base'} + $delta,
            $changeref->{'context'}, \@oldfile);
        my $offset = $base - ($changeref->{'base'} + $delta);
        Log(0, "base == $base\noffset == $offset\n") if $diff_debug;
        if (!defined($base)) {
            Log(0, "ERROR: hunk $hunk_count FAILED at $changeref->{'base'} for $path\n");
            $all_ok = 0;
            next;
        }
        $offset_used++ if $offset;

        # The context finder effectively gets rid of any "delta" that we
        # might need to keep track of.  It would always be 0 if you could
        # ensure that the original file was the same as the file against
        # which the diff was generated.  But if you could guarantee that,
        # all of this context crap wouldn't be necessary.
        $delta -= ($base - $changeref->{'base'});       # Probably 0
        Log(0, "(context adj) delta == $delta\n") if $diff_debug;

        # Because finding the context effectively changes the offset into
        # the "new" file, it's necessary to adjust the index for new insertions
        # to take into account the "help" that we got from the context finder.
        my $newdelta = $changeref->{'base'} - $base + $offset;
        Log(0, "newdelta == $newdelta\n") if $diff_debug;
        foreach my $change (@{$changeref->{'diffs'}}) {
            if (ref($change) eq 'ARRAY') {
                my ($pos, $line, $repl) = @{$change};
                my $del_line = $repl + $base + $delta + $offset;
                if (defined($repl)) {
                    # Do the removal
                    my @oldlines = splice(@oldfile, $del_line, 1);
                    Log(0, "Removed line at ($repl + $base + $delta + $offset = $del_line):\n  ".join("\n  ", @oldlines)."\n") if $diff_debug;
                    --$delta;   # Because it will be incremented again shortly
                }
                # Do the add
                splice(@oldfile, $pos + $base + $newdelta, 0, $line);
                Log(0, "Added line at ($pos + $base + $newdelta = ".($pos + $base + $newdelta).") (delta == $delta):\n  $line\n") if $diff_debug;
                ++$delta;
            } elsif (ref($change) eq '' && ($change <= 0)) {
                # It's a delete
                my $del_line = (-1 * $change) + $base + $delta + $offset;
                if ($del_line <= $#oldfile) {
                    my @oldlines = splice(@oldfile, $del_line, 1);
                    Log(0, "Deleted lines at ((-1 * $change) + $base + $delta + $offset = $del_line):\n  ".join("\n  ", @oldlines)."\n") if $diff_debug;
                    --$delta;
                } elsif ($diff_debug) {
                    Log(0, "Can't delete line $del_line of ".$#oldfile.": out of range\n");
                }
            } else {
                die "Huh?  Bad diff ($change)\n";
            }
        }
        $delta += ($base - $changeref->{'base'});       # Probably 0
        if ($diff_debug) {
            Log(0, "(context REadj) delta == $delta\n");
            print_range(0, \@oldfile, "Finished hunk:\n  ", "\n  ", ($changeref->{'base'} - 5), ($changeref->{'base'} + 10)); Log(0, "\n");
            Log(0, "(post apply) delta == $delta\n");
        }
        if ($offset) {
            Log(125, "    hunk $hunk_count offset ".pluralize($offset, 'line')." for $path\n");
        } else {
            Log(125, "    hunk $hunk_count applied cleanly to $path\n");
        }
    }

# Rewrite the file now that it has been transformed into its new form...
    $fh = new IO::File '>'.$path;
    $fh->print(join("\012", map { defined($_) ? $_ : "HEY! UNDEF LINE!" } @oldfile)."\012");
    $fh->close();

    return (diffdigest($path, 512), $offset_used, $all_ok);
}

sub match_context {
    my ($base, $context, $lines) = @_;
    my $rc = undef;

    # Find and return the index into @$lines where all of @$context can be
    # found.  Return undef if not found.

    return undef if (ref($context) ne 'ARRAY' || ref($lines) ne 'ARRAY');

    $rc = search_context($base, 1, $context, $lines);
    $rc = search_context($base, -1, $context, $lines) if (!defined($rc));

    return $rc;
}

sub search_context {
    my ($base, $inc, $context, $lines) = @_;
    # This actually does the work that you thought match_context would do

    if ($diff_debug) {
        Log(0, "search_context($base, $inc, $context, $lines) called\n");
        print_range(0, $context, "Context:\n  ", "\n  "); Log(0, "\n");
        print_range(0, $lines, "Lines[$base..]:\n  ", "\n  ", $base, $base + $#{$context}); Log(0, "\n");
    }

    for(; $base < @{$lines}+0 && $base >= 0; $base += $inc) {
        my $idx = 0;
        while(defined($lines->[$base + $idx]) && defined($context->[$idx]) &&
            ($lines->[$base + $idx] eq $context->[$idx])) {
            $idx++;
        }
        if ($idx >= @{$context}+0) {
            # Finished!
            Log(0, "Found at $base\n") if $diff_debug;
            return $base;
        }
    }
    Log(0, "Not found\n") if $diff_debug;
    return undef;
}

sub print_range {
    my ($loglevel, $aref, $head, $eol, $start, $end) = @_;
    return unless Log($loglevel);
    $start = 0 unless defined $start;
    $end = $#{$aref} unless defined $end;
    Log($loglevel, $head) if defined($head);
    $eol = "\n" unless defined($eol) && $eol ne '';
    while($start < 0) {
        Log($loglevel, sprintf("%05d: undef$eol", $start));
        $start++;
    }
    while($start < $end) {
        if ($start <= $#{$aref}) {
            Log($loglevel, sprintf("%05d: %s$eol", $start, defined($aref->[$start]) ? $aref->[$start] : 'undef'));
            $start++;
        } else {
            Log($loglevel, sprintf("%05d: *** out of range ***$eol", $start, ));
            $start++;
        }
    }
}

sub check_version {
    # Phone home (to SPEC) to see if a newer version of the suite has been
    # released.
    my ($url, $timeout, $proxy, $will_continue) = @_;
    my ($ver, $pause) = ($::current_version, undef, 0);
    $url = $::default_config->{'update_url'} unless defined($url);
    if ($url eq $::default_config->{'update_url'}) {
        # The user hasn't modified the base URL, so append 'devel' or 'release' as appropriate.
        $url =~ s#/+$##;
        $url .= is_devel($::current_version) ? '/devel' : '/release';
    }
    $timeout ||= 30;

    Log(1,  "Downloading update information");
    Log(30, " from $url");
    Log(1,  " for version check...\n");
    my ($res, %updates) = get_update_list($url, $timeout, $proxy, { 'include_same' => 1 });
    ::Log(50, Data::Dumper->Dump([\%updates],['avail_updates'])."\n");

    if ($res->{'success'}) {
        Log(1, "OK\n");
        if (%updates) {
            my $selected = select_update(\%updates, { });
            if (defined($selected)
                    and ::normalize_version($selected->{'to'}) != normalize_version($::current_version)) {
                # An update to a newer version is available
                Log(0, "\n".
                    "NOTICE: Your version, $::current_version, is not the newest.\n".
                    "        ".ucfirst(::human_version($selected->{'to'})));
                $ver = $selected->{'to'};
                if (defined($selected->{'release_date'}) and $selected->{'release_date'} ne '') {
                    Log(0, " was released on $selected->{'release_date'}.");
                }
                else {
                    Log(0, " is available.");
                }
                Log(0, "\n".
                    "        Use 'runcpu --update' to get the new version.  For more info, see:\n".
                    "        https://www.spec.org/$::lcsuite/Docs/runcpu.html#update\n".
                    "\n");
                $pause = 1;
            }
            else {
                # No update available
                Log(0, "\tVersion $::current_version of $::suite is the latest available.\n".
                    "\n");
            }
        }
        else {
            # No updates found
            Log(0, "\n".
                "WARNING: You are running a version of the suite ($::current_version) that is newer\n".
                "         than the newest official release from SPEC.  Generated results\n".
                "         may not be acceptable for publication.\n".
                "\n");
            $pause = 1;
        }
    } else {
        Log(1, "...Version check failed.\n");
        Log(0, "\n".
            "          A connection to the internet is useful, but is NOT required\n".
            "          in order to run $::suite.  If one is available, several\n".
            "          components will be checked to see if they are current.  If\n".
            "          you need to use an HTTP proxy to access the Internet, please\n".
            "          see the 'http_proxy' entry in config.html.\n".
            "\n");
        $pause = 1;
    }

    if ($pause && $will_continue) {
        my $spaces = " " x 23;
        Log(0,
            "${spaces}----------------------------------\n".
            "${spaces}The run will continue in 5 seconds\n".
            "${spaces}----------------------------------\n".
            "\n");
        sleep 5;
    }

    return $ver;
}

sub generate_runcpu_commandline {
    my ($cl_opts, $config, $macros, $unmacros, @options) = @_;

    my @command = (jp($config->top, 'bin', 'specperl'), jp($config->top, 'bin', 'harness', 'runcpu'), '--config', $config->configfile);

    # Do macro definitions
    foreach my $macro (sort keys %{$macros}) {
        next if $macro =~ /^ENV_/; # ENV_ macros always come from the user env
        my ($name, $val) = ($macro, $macros->{$macro});
        if ($shellquote and $^O !~ /MSWin/i) {
            $name = shell_quote_best_effort($name);
            $val  = shell_quote_best_effort($val);
        }
        push @command, '--define', $name.'='.$val;
    }
    foreach my $macro (sort keys %{$unmacros}) {
        next if $macro =~ /^ENV_/; # ENV_ macros always come from the user env
        $macro = shell_quote_best_effort($macro) if ($shellquote and $^O !~ /MSWin/i);
        push @command, '--undef', $macro;
    }

    foreach my $thing (qw(keeptmp log_timestamp)) {
        if (istrue($config->accessor_nowarn($thing))) {
            push @command, "--$thing";
        } else {
            push @command, "--no$thing";
        }
    }

    push @command, @options;

    return wantarray ? @command : join(' ', @command);
}

sub list_dir {
    my ($dir, %opts) = @_;
    my @rc = ();

    if (!-d $dir) {
        if (!-e $dir) {
            return "*** Directory \"$dir\" does not exist! ***\n";
        } else {
            return "*** \"$dir\" is not a directory! ***\n";
        }
    }

    my $dh = new IO::Dir $dir;
    if (!defined($dh)) {
        return "*** \"$dir\" could not be opened for reading: $!\n";
    }
    while(defined(my $file = $dh->read)) {
        if ($opts{'stat'}) {
            push @rc, "$file (stat: ".join(',', @{stat(::jp($dir, $file))}).')';
        } else {
            push @rc, $file;
        }
    }

    return @rc;
}

# Munge up a path so that backslashes can be preserved and path separators
# normalized.
sub path_protect {
    my ($text, $as_win) = @_;
    $as_win = ($^O =~ /MSWin/) unless defined($as_win);

    # Here's the special character breakdown:
    # 0377 - path separator (to be converted to native separator)
    # 0376 - literal forward slash

    if ($as_win) {
        # On Windows, assume that whitespace-slash-nonslash_text is a switch
        # and leave it alone.  "/.../" is a path, and those should be munged.
        # All non-doubled backslashes are path components, so munge those too

        # First, doubled backslashes in a network path
        $text =~ s#(?<=\s)\\\\(\S+[\\/])#\377\377$1#g;
        $text =~ s#^\\\\(\S+[\\/])#\377\377$1#g;

        # Then all the other backslashes (path separators)
        $text =~ s/\\/\377/g;

        # Leading forward slashes (path separators)
        $text =~ s#(?<=\s)/(\S+/)#\377$1#g;

        # Embedded forward slashes (path separators)
        $text =~ s#(?<!\s)/#\377#g;

        # Other forward slashes (switch character)
        $text =~ s#/#\376#g;
    } else {
        # Easy... / is a path separator (ONLY), and \ is an escape (ONLY)

        # Forward slashes (path separators)
        $text =~ s#/#\377#g;
    }

    return $text;
}

sub path_unprotect {
    my ($text, $as_win) = @_;
    $as_win = ($^O =~ /MSWin/) unless defined($as_win);

    $text =~ s#\376#/#g;
    if ($as_win) {
        # Then all the other backslashes (path separators)
        $text =~ s/\377/\\/g;
    } else {
        $text =~ s#\377#/#g;
    }
    return $text;
}

sub dump_removetree_errors {
    my ($eol, $errors) = @_;

    return unless ref($errors) eq 'ARRAY' and @{$errors};
    my @msgs = ();
    foreach my $err (@{$errors}) {
        next unless ref($err) eq 'HASH';
        my ($file, $message) = %{$err};
        $file .= ': could not unlink: ' unless $file eq '';
        push @msgs, $file.$message;
    }
    return join($eol, @msgs);
}

sub collapse_dirnames {
    my (@dirnames) = @_;

    @dirnames = sort bydirnum grep { defined } @dirnames;
    return '' unless @dirnames;
    return $dirnames[0] if @dirnames == 1;

    my @rc = ();
    my $curname = '';
    my $firstnum = '';
    my $lastnum = '';
    foreach my $dirname (@dirnames) {
        my ($name, $num) = $dirname =~ m/^(\S+?)\.(\d*)$/;
        if (!defined($num)) {
            # No sequence, so just push it
            push @rc, $dirname;
            next;
        }
        if ($curname ne $name) {
            if ($curname ne '') {
                # New name; push out the old stuff
                finish_sequence(\@rc, $curname, $firstnum, $lastnum);
            }
            push @rc, $dirname;
            $curname = $name;
            $firstnum = $lastnum = $num;
        } else {
            if ($num > $lastnum + 1) {
                # Break in the sequence
                finish_sequence(\@rc, $curname, $firstnum, $lastnum);
                push @rc, $dirname;
                $firstnum = $lastnum = $num;
            } else {
                $lastnum = $num;
            }
        }
    }
    finish_sequence(\@rc, $curname, $firstnum, $lastnum);

    return @rc;
}

sub finish_sequence {
    my ($listref, $name, $firstnum, $lastnum) = @_;

    if ($lastnum > $firstnum + 1) {
        # 3 or more numbers in the sequence
        push @$listref, pop(@$listref)."-${lastnum}";
    } elsif ($lastnum == $firstnum + 1) {
        # Only two
        push @$listref, $name.'-'.$lastnum;
    }
}

sub check_list {
    # Check to see if $item appears in the text of $list.  For some reason,
    # $list =~ /$item/ does not always work...
    my ($list, $item) = @_;

    foreach my $listitem (split(/[,[:space:]]+/, $list)) {
        return 1 if ($listitem eq $item);
    }
    return 0;
}

sub send_to_meters {
    my ($cmd, @meterlist) = @_;

    # For multiple meters, this would best be done in parallel, but in Perl
    # that's tough to do in a portable fashion.
    foreach my $meter (@meterlist) {
        $meter->{'sock'}->print($cmd) if $meter->{'sock'};
    }

    # XXX Error return should be possible
    return 1;
}

sub get_meter_responses {
    my ($cmd, $meters, $expected) = @_;
    $meters = ref($meters) eq 'ARRAY' ? $meters : [ $meters ];

    foreach my $meter (@{$meters}) {
        my $tmp = '';
        do {
            $tmp = $meter->{'sock'}->getline() if $meter->{'sock'};
            $tmp =~ tr/\015\012//d;
            ::Log(134, "Meter '".$meter->{'name'}."' returns '$tmp' for '$cmd' command\n");
            push @{$meter->{'responses'}}, $tmp;
        } while (defined($expected) and $tmp !~ /$expected/ and $meter->{'sock'});
    }

    # XXX Error return should be possible
    return 1;
}

# Return a meter-specific range value if one is present, the default if one
# is set, or undef otherwise.
sub per_meter_range {
    my ($meter, $ranges) = @_;

    return undef if (ref($meter) ne 'HASH' || !defined($ranges));

    # A valid range is either "A" (case-insensitive, optionally followed by non-whitespace), an integer, or a decimal
    # number.  Whitespace and a unit, if any, will be ignored.  The match will be left in $1.
    my $rangere = qr/^(?|(a)\S*|(\d+(?:\.\d+)?))\s*(?:v\S*|a\S*)?$/i;

    if (ref($ranges) eq 'HASH') {
        for my $name ($meter->{'name'}, 'default') {
            if (exists($ranges->{$name}) and $ranges->{$name} =~ /$rangere/) {
                return 'Auto' if uc($1) eq 'A';
                return $1;
            }
        }
    } elsif ($ranges =~ /$rangere/) {
        # No per-meter settings
        return 'Auto' if uc($1) eq 'A';
        return $1;
    }

    return undef;
}

# Given a hash with ranges and a meter reference, set those ranges if possible,
# returning 1 on success and 0 otherwise.
sub meter_read_range {
    my ($meter, $channel) = @_;

    # Nothing to do if the meterref isn't a meter
    return undef if (ref($meter) ne 'HASH');

    my $sock = $meter->{'sock'};
    my $name = $meter->{'name'};
    my $chanselect = ($channel eq '') ? '' : ",$channel";
    my $cmd = "RR$chanselect";
    ::Log(34, "PTD($name): Sending range reading command '$cmd'".($channel eq '' ? '' : " for channel $channel")."\n");
    my $tmp = 'Ranges,0,-1,0,-1';
    if ($sock) {
        $sock->print("$cmd\r\n");
        $tmp = $sock->getline();
    }
    $tmp =~ tr/\015\012//d;
    ::Log(34, "PTD($name): Got response '$tmp'\n");
    if ($tmp =~ /^Invalid number of parameter/) {
        ::Log(0, "ERROR: PTD at $name rejects command '$cmd'\n");
        return undef;
    } elsif ($tmp !~ /^Ranges,/) {
        ::Log(0, "ERROR: Unkown response '$tmp' received when trying to read ranges on PTD at $name\n");
        return undef;
    } else {
        my @resp = split(/,/, $tmp);
        return {
            'a_auto' => $resp[1], 'a' => $resp[2],
            'v_auto' => $resp[3], 'v' => $resp[4],
        };
    }
}

# Given a hash with ranges and a meter reference, set those ranges if possible,
# returning 1 on success and 0 otherwise.
sub meter_set_range {
    my ($meter, $ranges) = @_;

    # Nothing to do if the meterref isn't a meter or if the ranges
    # don't contain ranges...
    return 1 if (ref($meter) ne 'HASH' || ref($ranges) ne 'HASH');

    if ($meter->{'can_rangeset'}) {
        my ($name, $sock) = @{$meter}{'name', 'sock'};
        foreach my $rangetype (qw(a v)) {
            my $tmprange = per_meter_range($meter, $ranges->{$rangetype});
            # Disallow auto-ranging for voltage
            if ($tmprange eq 'Auto' and $rangetype eq 'v') {
                ::Log(0, "ERROR: The voltage range is set to 'auto' for PTD at $name\n");
                return 0;
            }
            if (defined($tmprange) && ($tmprange eq 'Auto' or $tmprange > 0)) {
                for(my $chan = 0; $chan < $meter->{'channels'}; $chan++) {
                    my $chanselect = ($chan == 0) ? '' : ",$chan";

                    # Read the current range to see if we even need to try
                    # to set the range for this channel
                    if ($chan > 0 || $meter->{'channels'} == 1) {
                        my $currange = meter_read_range($meter, ($chan == 0 ? '' : $chan));
                        if (!defined($currange) || ref($currange) ne 'HASH') {
                            # meter_read_range will have already logged the error message
                            return 0;
                        } elsif (($tmprange eq 'Auto' and $currange->{$rangetype.'_auto'} > 0)
                                or ($currange->{$rangetype.'_auto'} <= 0 and $currange->{$rangetype} == $tmprange)) {
                            ::Log(34, "PTD($name): '$rangetype' range".($chanselect ne '' ? " for channel $chan" : '')." already set\n");
                            next;
                        }
                    }

                    my $cmd = "SR,$rangetype,$tmprange$chanselect";
                    ::Log(34, "PTD($name): Sending range setting command '$cmd' for channel $chan\n");
                    my $tmp = "Range $rangetype changed";
                    if ($sock) {
                        $sock->print("$cmd\r\n");
                        $tmp = $sock->getline();
                    }
                    $tmp =~ tr/\015\012//d;
                    ::Log(34, "PTD($name): Got response '$tmp'\n");
                    if ($tmp =~ /^(?:Null channel|Invalid channel|Channel number out)/) {
                        ::Log(0, "ERROR: Bad channel while setting '$rangetype' range on PTD at $name with command '$cmd': $tmp\n");
                        return 0;
                    } elsif ($tmp =~ /^(?:Error in|Invalid number of) parameter/) {
                        ::Log(0, "ERROR: PTD at $name rejects command '$cmd'\n");
                        return 0;
                    } elsif ($tmp =~ /^(?:Error|Meter busy)/) {
                        ::Log(0, "ERROR: Failed trying to set '$rangetype' range on PTD at $name\n");
                        return 0;
                    } elsif ($tmp !~ /^Range $rangetype changed/i) {
                        ::Log(0, "WARNING: Unknown response '$tmp' received when trying to set '$rangetype' range on PTD at $name\n");
                    }

                    # Read the range back and make sure it's set properly
                    # (except for the sum channel on multi-channel analyzers)
                    if ($chan > 0 || $meter->{'channels'} == 1) {
                        my $currange = meter_read_range($meter, ($chan == 0 ? '' : $chan));
                        if (!defined($currange) || ref($currange) ne 'HASH') {
                            # meter_read_range will have already logged the error message
                            return 0;
                        } elsif ($sock and ($currange->{$rangetype.'_auto'} <= 0 and $currange->{$rangetype} < $tmprange)) {
                            ::Log(0, "ERROR: '$rangetype' range received from PTD at $name does not match range set ($tmprange)\n");
                            return 0;
                        }
                    }
                }
            }
        }
    }

    return 1;
}

sub meter_reset {
    my ($meter) = @_;
    my $sock = $meter->{'sock'};
    if ($sock) {
        $sock->print("Reset\r\n");
        my $tmp = $sock->getline();
    }
}

# Given a list of meters (host:port or host), connect to them and
# return a list of sockets as well as initial responses.
sub meter_connect {
    my ($meterlist, $timeout, $ranges, $fake, $type) = @_;
    my @rc = ();
    my $sock;

    return undef unless ref($meterlist) eq 'ARRAY';

    my $have_alarm = eval { alarm(0); 1 };
    # As of 6 Jan 2012, alarm() does not work in the way we want it to
    # on Windows 7 with Perl 5.12.3.  So just pretend Windows doesn't
    # support it:
    $have_alarm = 0 if ($^O =~ /Win32/);

    # For multiple meters, this would best be done in parallel, but in Perl
    # that's tough to do in a portable fashion.
    foreach my $meter (@{$meterlist}) {
        next unless (defined($meter) && $meter ne '');
        my ($host, $port) = ($meter, 8888);
        if ($meter =~ m#^([^:]+)(?::(\d+))?$#) {
            # Not a full URI, just a host:port pair
            $host = $1;
            $port = $2 if ($2 ne '')
        } else {
            ::Log(0, "ERROR: '$meter' is not a valid meter\n  specification. Use either a hostname or host:port notation.\n");
            $sock = -1;
            next;
        }

        # If an error's been seen, don't try to connect to more meters
        next if $sock == -1;

        my $timeout_msg = $have_alarm ? "with $timeout second timeout" : "(no timeout)";
        # The newline is necessary to get it to output immediately
        ::Log(103, "Attempting to connect to PTD at $host:$port $timeout_msg...\n");
        if ($fake) {
            ::Log(134, "  Faking successful connection to $host:$port\n");
            $sock = 0;
        } else {
            eval {
                # All this "alarm" business is because IO::Socket::INET's Timeout
                # doesn't actually do anything.
                local $SIG{'ALRM'} = sub { die 'connect timeout' };
                alarm $timeout if $have_alarm;
                $sock = new IO::Socket::INET(Proto => 'tcp',
                    PeerAddr => $host,
                    PeerPort => $port,
                    Timeout => $timeout);
                alarm 0 if $have_alarm;
            };
            if (defined($sock)) {
                ::Log(134, "  Successfully connected to $host:$port\n");
            } else {
                if ($@ && $@ =~ /connect timeout/) {
                    ::Log(103, "  Connection to $host:$port timed out!\n");
                } elsif ($@) {
                    ::Log(103, "  Connection to $host:$port failed (eval returned '$@')\n");
                } else {
                    ::Log(103, "  Connection to $host:$port failed!\n");
                }
                $sock = -1;
                last;
            }
        }

        my $meterref = {
            'name' => $host.':'.$port,
            'tag'  => lc($host.$port),     # will be fixed up more
            'sock' => $sock
        };
        $meterref->{'tag'} =~ tr{A-Za-z0-9}{}cd;

        my $tmp;
        if ($fake) {
            if ($type eq 'temp') {
                $tmp = "DummyTemp,5000,1,1,0,0,0,0,0,version=9.9.9-1fee1ded-20161226,OS=your uname/whatever output here,mode=temperature,0,0,1,0,0,no_cal_date,na"
            } else {
                $tmp = "Dummy,1000,1,1,1,1,1,1,0,version=9.9.9-1fee1ded-20161226,OS=your uname/whatever output here,mode=power,1,1,1,0,0,no_cal_date,SPECpower's Dummy Analyzer v1.0"
            }
        } else {
            # Ask PTD about the meter that's attached
            $sock->print("Identify\r\n");
            # From a now-vanished section of the PTD design document, the output is
            # expected to be the following, delimited by commas:
            # meter driver module + driver IDN response
            # averaging interval in ms
            # can measure watts / temperature?
            # can measure volts / humidity?
            # can measure amps?
            # can measure power factor?
            # can measure energy?
            # can measure frequency?
            # is accepted for publication by SPEC?
            # PTD version (see below)
            # Host OS info
            # PTD mode
            # is accuracy estimation enabled?
            # is range setting enabled?
            # number of channels
            $tmp = $sock->getline();
            $tmp =~ tr/\015\012//d;
        }
        $meterref->{'responses'} = [ $tmp ];
        @{$meterref}{qw(driver interval can_watts can_volts can_amps can_pf
        can_energy can_freq is_accepted ptd_version host_os
        ptd_mode can_accuracy can_rangeset channels rest)
        } = split(/,/, $tmp, 16);
        delete $meterref->{'rest'} unless defined($meterref->{'rest'});
        ::Log(134, "  PTD\@$host:$port returns '$tmp' for Identify\n");
        if ($meterref->{'ptd_version'} =~ /^version=([^-]+)-([[:xdigit:]]{8})(?:-(\d{4})(\d{2})(\d{2}))?(?:;module=([^-]+)-([[:xdigit:]]{8})\((\d+)\))?$/i) {
            @{$meterref}{qw(ptd_version ptd_crc)} = ($1, $2);
            if (!defined($3)) {
                ::Log(0, "ERROR: Could not get build date for PTD at $host:$port\n");
                $sock->close();
                $sock = -1;
                next;
            }
            $meterref->{ptd_build_date} = "$3-$4-$5";
            if (defined($6)) {
                @{$meterref}{qw(meter_mod_version meter_mod_crc meter_mod_size)} = ($6, $7, $8);
            }
            $meterref->{'ptd_full_version'} = $meterref->{'ptd_version'};
            $meterref->{'ptd_version'} =~ s/\D+$//; # Trim off tags so that
            # comparisons will work properly
            if (defined($meterref->{ptd_version}) && $meterref->{ptd_version} lt '1.9.1') {
                ::Log(0, "ERROR: The version of PTD running on $host:$port is too old! v1.9.1 or later is required.\n");
                $sock->close();
                $sock = -1;
                next;
            }
        } else {
            ::Log(0, "ERROR: Could not parse complete version string from PTD ($host:$port) Identify response\n");
            $sock->close() unless $fake;
            $sock = -1;
            next;
        }
        $meterref->{'driver'} =~ s/-na$//;   # Get rid of the "None" IDN string
        $meterref->{'host_os'} =~ s/^OS=//;
        $meterref->{'ptd_mode'} =~ s/^mode=//;
        if ($meterref->{'ptd_mode'} eq 'temperature') {
            # Convert field names for temp. meters
            @{$meterref}{qw(can_temperature can_humidity)} = @{$meterref}{qw(can_watts can_volts)};
            # Remove unused ones
            delete @{$meterref}{qw(can_watts can_volts can_amps can_pf can_energy
            can_freq)};
        }
        # Turn all the numbers into numbers
        foreach my $tmpkey (keys %{$meterref}) {
            $meterref->{$tmpkey} += 0 if ($meterref->{$tmpkey} =~ /^\d+$/);
        }

        if (!$fake) {
            # Reset any measurements that may be on-going
            meter_reset($meterref);

            # Try to figure out the clock skew (if any) between the PTD host and here
            $tmp = meter_time_offset($meterref);
            if (!defined($tmp)) {
                ::Log(0, "ERROR: Failed trying to calculate time offset for PTD host at $host:$port\n");
                $sock->close();
                $sock = -1;
                next;
            }

            ::Log(134, "  Clock skew from PTD host at $host:$port is $tmp ms\n");
            $meterref->{'offset'} = ($tmp / 1000) if defined($tmp);

            # Set up ranges (if necessary)
            if (!meter_set_range($meterref, $ranges)) {
                # meter_set_range will log an error if there is one
                $sock->close();
                $sock = -1;
                next;
            }
        }

        push @rc, $meterref;
    }

    if ($sock == -1) {
        # Close open connections (if any)
        foreach my $meterref (@rc) {
            if (defined($meterref->{'sock'}) && $meterref->{'sock'}->connected != undef) {
                # This should always be true
                $meterref->{'sock'}->close();
            }
        }
        ::Log(0, "ERROR: Communications could not be established with one or more power analyzers.\n");
        return undef;
    } else {
        return (1, @rc);
    }
}

# Attempt to figure out the time difference between the clocks on the PTD
# host and this system by starting a measurement and polling for timestamped
# samples.  Do this for 5 samples (2-25 seconds).  Ignore results that are
# < 1 sampling interval, as RL can wait that long to return a sample if one
# isn't immediately available.
sub meter_time_offset {
    my ($meter) = @_;
    my @offsets = ();

    return undef unless defined($meter->{'sock'}) && defined($meter->{'sock'}->connected);
    my $sock = $meter->{'sock'};

    # Start a measurement
    $sock->print("Go,0,0\n");
    my $tmp = get_expected_line($meter, 'Starting untimed measurement', 'attempting to start time calibration run');
    return undef unless defined($tmp);

    # Give it a few sampling intervals to start up, then start reading
    my $waittime = int(3 * ($meter->{'interval'} / 1000));
    $waittime = 3 if ($waittime < 3);
    sleep($waittime);

    # Check for meter connectivity
    $sock->print("R*\n");
    $tmp = get_expected_line($meter, qr/(?:Watts|Temperature),[0-9-]/, 'checking basic functionality');
    return undef unless defined($tmp);

    while (@offsets < 5) {
        # There's a little race in PTD's RL command.  If there are no available
        # samples, it will wait one sampling interval for one to show up.
        # Unfortunately, if the wait begins at the same time the previous sample
        # was taken, it'll finish before the next sample shows up.  So, a little
        # delay here will help keep that from happening...
        sleep(0.1);
        $sock->print("RL,1\n");
        $tmp = get_expected_line($meter, 'Last 1 sample', 'attempting to read sample during time calibration run');
        return undef unless defined($tmp);
        my $now = Time::HiRes::time;
        $tmp = get_expected_line($meter, 'Time,', 'attempting to read sample during time calibration run');
        return undef unless defined($tmp);
        if ($tmp =~ /^Time,([^,]+),/) {
            push @offsets, ($now - ptdtime2time($1)) * 1000;
        }
    }

    # Stop the measurement
    $sock->print("Stop\n");
    $tmp = $sock->getline();

    # Average the offsets
    my $avg = 0;
    foreach my $offset (@offsets) {
        $avg += $offset;
    }
    $avg /= @offsets;

    if (abs($avg) < $meter->{'interval'}) {
        # This is within measurement error, so ignore it
        return 0;
    }

    ::Log(33, "Calculated time offset for meter at ".$meter->{'name'}." is ${avg}s\n");
    return $avg;
}

sub get_expected_line {
    my ($meter, $expected, $what) = @_;

    my $tmp = $meter->{'sock'}->getline();
    if ($tmp !~ /^$expected/) {
        ::Log(0, "ERROR: Got '$tmp' (expected '$expected...') when $what on PTD at ".$meter->{'name'}."\n");
        $meter->{'sock'}->print("Stop\n");
        $tmp = $meter->{'sock'}->getline() if $meter->{'sock'};
        return undef;
    }
    return $tmp;
}

# Add the given time interval into the supplied sequence, extending or merging
# intervals as necessary.  The new time interval is given as the END time and
# the duration.  This assumes that the interval list is ordered by start time
# and does not contain any overlapping intervals.
sub add_interval {
    my ($list, $end, $duration) = @_;

    return unless ref($list) eq 'ARRAY';

    my $start = $end - $duration;
    for(my $i = 0; $i < @{$list}; $i++) {
        my $interval = $list->[$i];
        if ($interval->[0] <= $start && $start <= $interval->[1]) {
            # This is an overlapping interval
            if ($end > $interval->[1]) {
                # It extends the current interval (move the end)
                my ($tmpstart, $tmpend) = ($interval->[0], $end);
                splice @{$list}, $i, 1;
                add_interval($list, $tmpend, $tmpend-$tmpstart);
            }
            return;

        } elsif ($interval->[0] <= $end && $end <= $interval->[1]) {
            # This is also an overlapping interval
            if ($start < $interval->[0]) {
                # It extends the current interval (move the start)
                my ($tmpstart, $tmpend) = ($start, $interval->[1]);
                splice @{$list}, $i, 1;
                add_interval($list, $tmpend, $tmpend-$tmpstart);
            }
            return;

        } elsif ($start < $interval->[0] && $interval->[0] > $end) {
            # Precedes the current interval
            splice @{$list}, $i, 0, [ $start, $end ];
            return;
        } elsif ($start < $interval->[0] && $end > $interval->[1]) {
            # Encloses the current interval
            splice @{$list}, $i, 1, [ $start, $end ];
            return;
        }
    }
    # If we get here, then it's a new interval
    push @{$list}, [ $start, $end ];

    return;
}

# Given a list of meter references ($name, $socket, @responses),
# tell them to start measuring and collect their responses into
# the list.
sub meter_start {
    my ($mark, $ranges, @meterlist) = @_;

    return 1 if @meterlist == 0;

    foreach my $meter (@meterlist) {
        # Reset to get rid of previous error counts, etc.
        meter_reset($meter);

        # Set the ranges as specified
        if (!meter_set_range($meter, $ranges)) {
            return 0;
        }
    }

    if (defined($mark) && $mark !~ m#^\s*$#) {
        $mark = ','.$mark;
    }

    send_to_meters("Go,0,0$mark\r\n", @meterlist);

    # Now that they're all started, find out what they all said
    get_meter_responses('Go', \@meterlist, qr/^(Error|Starting untimed)/);

    # XXX What does it look like when this fails?
    return 1;
}

# Given a list of meter references ($name, $socket, @responses),
# tell them to change the logging mark.
sub meter_mark {
    my ($mark, @meterlist) = @_;
    my @rc = ();

    return 1 if (!defined($mark) || $mark =~ m#^\s*$#);
    return 1 if @meterlist == 0;

    send_to_meters("Mark,$mark\r\n", @meterlist);

    # Now that they're all started, find out what they all said
    get_meter_responses('Mark', \@meterlist);

    # XXX What does it look like when this fails?
    return 1;
}

# Given a list of meter references ($name, $socket, @responses),
# tell them to stop measuring power.
sub meter_stop {
    my (@meterlist) = @_;

    send_to_meters("Stop\r\n", @meterlist);

    # Now that they're all stopped, find out what they all said
    get_meter_responses('Stop', \@meterlist, qr/^(Error|Stopping)/);

    return 1;
}

# Use "RL" to get samples with timestamps
sub do_RL {
    my ($samplehash, $fieldlist, @meterlist) = @_;
    my ($min, $max);
    my $isok = 1;
    my %rc = ();

    if (defined($samplehash)) {
        if (::ref_type($samplehash) ne 'HASH') {
            ::Log(0, "ERROR: bad value in samplehash parameter for do_RL()\n");
            return (0);
        }
    } else {
        $samplehash = {};
    }
    if (::ref_type($fieldlist) ne 'HASH' || (keys %{$fieldlist}) == 0) {
        ::Log(0, "ERROR: bad value in fieldlist parameter for do_RL()\n");
        return (0);
    }

    my $fieldre = '^('.join('|', keys %{$fieldlist}).')$';
    $fieldre = qr/$fieldre/;

    foreach my $meter (@meterlist) {
        my $channel = ($meter->{'channels'} > 1) ? ",*" : '';
        # Ask for the uncertainties
        my $cmd = 'Uncertainty';
        send_to_meters("$cmd$channel\r\n", $meter);
        my $tmp = 'Uncertainty,0,0,0,1,0,1,0';
        $tmp = $meter->{'sock'}->getline() if $meter->{'sock'};
        $tmp =~ tr/\012\015//d;
        push @{$meter->{'responses'}}, $tmp;
        my @uncertainties = ();
        if ($tmp =~ s/\Q$cmd\E,//) {
            # Normal response; convert them all to numbers
            my @vals = map { $_ + 0 } split(/,/, $tmp);
            while(@vals) {
                my ($acc_avg, $acc_min, $acc_max, $acc_total, $acc_invalid, $acc_valid, $acc_unknown) = splice @vals, 0, 7;
                next unless ($acc_avg >= 0);
                push @{$rc{$meter->{'name'}}->{'uncertainty'}}, [ $acc_avg, $acc_min, $acc_max, $acc_total, $acc_invalid, $acc_valid, $acc_unknown ];
            }
        }

        send_to_meters("RL,*$channel\r\n", $meter);

        # The first line should say how many samples we're getting
        $tmp = 'Last 1 samples';
        $tmp = $meter->{'sock'}->getline() if $meter->{'sock'};
        $tmp =~ tr/\012\015//d;
        push @{$meter->{'responses'}}, $tmp;
        my $samples = 0;
        $rc{$meter->{'name'}}->{'samples'} = [] unless exists($rc{$meter->{'name'}}->{'samples'});
        if ($tmp =~ /Last (\d+) sample/) {
            # This is normal
            $samples = $1;
            if (exists($samplehash->{$meter}) && defined($samplehash->{$meter}) && $samples != $samplehash->{$meter}) {
                $isok = 0;
                ::Log(0, "Meter '".$meter->{'name'}."' reported ".$samplehash->{$meter}." samples, but returned $samples sample values\n");
            }
        } elsif ($tmp =~ /^Invalid/) {
            # Something's wrong
            ::Log(0, "Meter '".$meter->{'name'}."' returned '$tmp' in response to 'RL,*$channel' command.\n");
            $isok = 0;
            next;
        }
        elsif ($tmp =~ /(?:Insufficient|No) unread/) {
            ::Log(0, "Meter '".$meter->{'name'}."' reports no unread samples available in response to 'RL,*$channel' command.\n");
            $isok = 0;
            next;
        }
        if ($samples == 0) {
            ::Log(0, "Meter '".$meter->{'name'}."' produced an unrecognized response ('$tmp') to RL,*$channel and no samples were read.\n");
            $isok = 0;
            next;
        }

        # Read all the samples
        while($samples > 0) {
            $samples--;
            $tmp = 'Time,'.time2ptdtime().',Watts,1,Volts,1,Amps,1,PF,1';
            $tmp = $meter->{'sock'}->getline() if $meter->{'sock'};
            $tmp =~ tr/\012\015//d;
            push @{$meter->{'responses'}}, $tmp;
            my @fields = split(/,/, $tmp);
            if ($fields[0] ne 'Time') {
                ::Log(0, "Meter '".$meter->{'name'}."' returned unexpected line '$tmp' when reading samples from RL command.\n");
                $isok = 0;
                next;
            }
            shift (@fields);      # Eat the 'Time'
            my $field = shift(@fields);
            my $ts = ptdtime2time($field, $meter->{'offset'});
            if (!defined($ts)) {
                ::Log(0, "Error: Could not read timestamp from '$field'\n");
                $isok = 0;
                next;
            }
            my %counts = ();
            my %vals = ();
            while (@fields) {
                my ($field, $val) = (shift(@fields), shift(@fields));
                if ($field !~ /^[A-Z]/) {
                    ::Log(0, "Error parsing field data from RL command; got field '$field' with value '$val'\n");
                    $isok = 0;
                    last;
                }

                # Don't store fields that the meter says it can't provide
                next unless $meter->{'can_'.lc($field)};

                $counts{$field} = 0 unless defined($counts{$field});
                $min = $val if ($field =~ /$fieldre/ && ($min > $val || $counts{$field} == 0 || !defined($min)));
                $max = $val if ($field =~ /$fieldre/ && ($max < $val || $counts{$field} == 0 || !defined($max)));
                $vals{$field}->[$counts{$field}] = $val + 0;
                $counts{$field}++;
            }

            # Save off the fields of interest, as well as the timestamp
            my %tmprec = ( 'ts' => $ts );
            my $gotsome = 0;
            foreach my $field (grep { ::ref_type($vals{$_}) eq 'ARRAY' } keys %{$fieldlist}) {
                if ($meter->{'channels'} > 1 && @{$vals{$field}} == ($meter->{'channels'} + 1)) {
                    # Get rid of the first element; it's the "sum" channel.  We'll
                    # do our own summing.
                    shift @{$vals{$field}};
                }
                $tmprec{$fieldlist->{$field}} = [ @{$vals{$field}} ];
                $gotsome++;
            }
            push @{$rc{$meter->{'name'}}->{'samples'}}, { %tmprec } if $gotsome;
        }
    }

    return ($isok, %rc);
}

sub trim_and_average {
    my ($sampleref, $discard) = @_;
    my ($label, $old_avg, $old_min, $old_max, $old_samples) = ($sampleref->[0], @{$sampleref->[1]->{'pwrstat'}}[0..3]);
    $label = "meter '".$label."'";

    if ($discard == 0) {
        # Easy
        return ($old_avg, $old_min, $old_max, $old_samples, @{$sampleref}[2..$#{$sampleref}]);
    }

    # Filter out "error" values
    my @samples = ();
    foreach my $sample (@{$sampleref}[2..$#{$sampleref}]) {
        # sum_channels() returns -1 if there's a bad reading in the sample
        push @samples, $sample if sum_channels($sample) >= 0;
    }

    my ($avg, $min, $max);

    if (@samples < ($discard * 2) * 2) {
        # Let's not discard more than half the samples
        Log(1, ucfirst($label)." does not have enough samples to support clipping " .
            "and re-averaging! (needs ".($discard * 2 * 2).", has ".(@samples+0).")\n");
        return undef;
    } else {
        my $old_samples = @samples+0;
        Log(27, "Clipping ".($discard * 2)." samples from $label\n");
        # Trim from the beginning
        splice(@samples, 0, $discard);
        # Trim from the end
        splice(@samples, -$discard, $discard);
        # Get the local min and max and average
        my @sample_sums = sort { $a <=> $b } map { sum_channels($_) } @samples;
        ($min, $max) = @sample_sums[0, -1];
        my $numsamples = @samples+0;
        my $total = 0;
        foreach my $sample (@sample_sums) {
            $total += $sample;
        }
        $avg = $total / $numsamples;
        Log(127, sprintf("%s differences: avg: %+g (%+g%%); min: %+g (%+g%%); max: %+g (%+g%%); samples: %d (%+g%%)\n",
                ucfirst($label),
                ($avg - $old_avg),
                $old_avg ? (($avg - $old_avg) / $old_avg) * 100 : 'INF',
                ($min - $old_min),
                $old_min ? (($min - $old_min) / $old_min) * 100 : 'INF',
                ($max - $old_max),
                $old_max ? (($max - $old_max) / $old_max) * 100 : 'INF',
                ($numsamples - $old_samples),
                $old_samples ? (($numsamples - $old_samples) / $old_samples) * 100 : 'INF'));
    }

    return($avg, $min, $max, (@samples+0), @samples);
}

# Given a list of power analyzer references, ask them for the average power
# measured and return the total average power, average average power, maximum
# uncertainty, and average uncertainty, as well as the full list of returned
# per-meter values.
sub power_analyzer_watts {
    my ($error_percentage, @meterlist) = @_;
    my @rc = ();
    my ($isok, $total, $meters, $min, $max) = (1, 0, 0, 2_999_999_999, 0);
    my %tmprc = ();
    my $error_reltol = $error_percentage / 100;

    return ($isok) if @meterlist == 0;

    # "RR" to get ranging settings
    foreach my $meter (@meterlist) {
        my $channel = ($meter->{'channels'} > 1) ? ',*' : '';
        my ($ampauto, $amprange, $voltauto, $voltrange);
        my $tmp = 'Ranges,0,-1,0,-1';
        send_to_meters("RR$channel\r\n", $meter);
        $tmp = $meter->{'sock'}->getline() if $meter->{'sock'};
        $tmp =~ tr/\015\012//d;
        ::Log(134, "Meter '".$meter->{'name'}."' returned '$tmp' to 'RR$channel' command\n");
        push @{$meter->{'responses'}}, $tmp;
        my @vals = split(/,/, $tmp);
        shift(@vals);     # Get rid of the command tag
        # Convert them all to numbers
        @vals = map { $_ + 0 } @vals;
        my @chanvals = ();
        while(@vals) {
            push @chanvals, [ splice @vals, 0, 4 ];
        }
        if (@chanvals == $meter->{'channels'}+1) {
            # PTD 1.4.3+ includes the "virtual sum" channel as the first set of
            # values, so get rid of it
            shift @chanvals;
        } elsif (@chanvals < $meter->{'channels'}) {
            ::Log(0, "ERROR: Response to read range command from PTD at ".$meter->{'name'}." did not return data for all channels!\n");
            return 0;
        }
        while (@chanvals) {
            my $chandata = shift(@chanvals);
            my ($ampauto, $amprange, $voltauto, $voltrange) = @{$chandata};
            if (($amprange < 0 && $ampauto <= 0) || ($voltrange < 0 && $voltauto <= 0)) {
                # Nonsense ranges; the meter probably doesn't support reporting them
                push @{$tmprc{$meter->{'name'}}->{'range'}}, [ undef, undef ];
            } else {
                # Record amp and volt ranges; -1 means auto-ranging is on
                $amprange = -1 if $ampauto;
                $voltrange = -1 if $voltauto;
                push @{$tmprc{$meter->{'name'}}->{'range'}}, [ $amprange, $voltrange ];
            }
        }
    }

    # "Watts" to get aggregated data
    send_to_meters("Watts\r\n", @meterlist);
    foreach my $meter (@meterlist) {
        my ($avg, $tmp_min, $tmp_max, $samples, $errors, $valid_samples);
        my $tmp = 'Watts,1,1,1,1,0,1';
        $tmp = $meter->{'sock'}->getline() if $meter->{'sock'};
        $tmp =~ tr/\015\012//d;
        my ($cmd, @vals) = split(/,/, $tmp);
        ::Log(134, "Meter '".$meter->{'name'}."' returned '$tmp' to 'Watts' command\n");
        push @{$meter->{'responses'}}, $tmp;
        ($avg, $tmp_min, $tmp_max, $samples, $errors, $valid_samples) = @vals;
        # Convert everything to numbers
        $avg += 0;
        $tmp_min += 0;
        $tmp_max += 0;
        $samples += 0;
        $errors += 0;
        $valid_samples += 0;
        $total += $avg;
        if ($errors != 0) {
            ::Log(0, "Meter '".$meter->{'name'}."' reports $errors errors\n");
            $isok = 0 if ($errors > ($samples * $error_reltol));
        }
        if ($samples != $valid_samples) {
            ::Log(0, "Meter '".$meter->{'name'}."' reports $samples samples, of which only $valid_samples are good\n");
            $isok = 0 if (($samples - $valid_samples) > ($samples * $error_reltol));
        }
        $tmprc{$meter->{'name'}}->{'pwrstat'} = [ $avg, $tmp_min, $tmp_max, $samples, $errors, $valid_samples ];
        $meters++;
    }

    my ($tmpok, %watts_list) = do_RL({ map { $_->{'name'} => $tmprc{$_->{'name'}}->{'pwrstat'}->[3] } (grep { ::check_elem('ARRAY', $tmprc{$_->{'name'}}, 'pwrstat') } @meterlist) },
        { 'Watts' => 'pwr' },
        @meterlist);
    $isok &= $tmpok;

    # Assemble the saved values to return
    my ($uncertainty_total, $max_uncertainty) = (0, undef);
    foreach my $meter (@meterlist) {
        my $uncertainty = $watts_list{$meter->{'name'}}->{'uncertainty'};
        if (::ref_type($uncertainty) ne 'ARRAY') {
            if (map { grep { $_ < 0 } @{$_} } @{$tmprc{$meter->{'name'}}->{'range'}}) {
                ::Log(0, "NOTICE: Power analyzer '".$meter->{'name'}."' returned no measurement uncertainty information due to auto-ranging\n");
            } else {
                ::Log(0, "ERROR: Power analyzer '".$meter->{'name'}."' returned no measurement uncertainty information\n");
                $isok = 0;
            }

            # Fake it up so its power data is still returned
            $uncertainty = $watts_list{$meter->{'name'}}->{'uncertainty'} = [];
        }
        foreach my $channelref (@{$uncertainty}) {
            my ($acc_avg, $acc_min, $acc_max, $acc_total, $acc_invalid, $acc_valid, $acc_unknown) = (0, 0, 0, 0, 0, 0, 0);
            ($acc_avg, $acc_min, $acc_max, $acc_total, $acc_invalid, $acc_valid, $acc_unknown) = @{$channelref} if ::ref_type($channelref) eq 'ARRAY';
            $max_uncertainty = $acc_max if !defined($max_uncertainty) || ($acc_max > $max_uncertainty);
            $uncertainty_total += ($acc_avg * $tmprc{$meter->{'name'}}->{'pwrstat'}->[0]);
            if ($acc_total > 0) {
                # Check to see that uncertainty requirements are met
                # No more than 1% samples may have unknown uncertainty
                if ($acc_total * ($::global_config->{'max_unknown_uncertainty'} / 100) < $acc_unknown) {
                    ::Log(0, "ERROR: Number of samples with unknown uncertainty from $meter->{'name'} exceeds ".$::global_config->{'max_unknown_uncertainty'}."%\n");
                    $isok = 0;
                }
                if ($acc_avg > ($::global_config->{'max_average_uncertainty'} / 100)) {
                    ::Log(0, "ERROR: Average uncertainty of all samples from $meter->{'name'} exceeds ".$::global_config->{'max_average_uncertainty'}."%\n");
                    $isok = 0;
                }
                if ($acc_invalid / $acc_total > $::global_config->{'uncertainty_exception'}) {
                    ::Log(0, sprintf("ERROR: Too many samples (%.2f%%) from %s have an uncertainty of more than %d%%\n", ($acc_invalid / $acc_total), $meter->{'name'}, $::global_config->{'max_average_uncertainty'}));
                    $isok = 0;
                }
            }
        }
        push @rc, [ $meter->{'name'},
            {
                %{$tmprc{$meter->{'name'}}},
                'accstat' => $watts_list{$meter->{'name'}}->{'uncertainty'}
            },
            @{$watts_list{$meter->{'name'}}->{'samples'}}
        ];
    }

    my $avg = undef;
    if ($meters > 0) {
        $avg = $total/$meters;
        ::Log(33, "Watts reading returns preliminary watts(total=$total, avg=$avg) uncertainty(max=$max_uncertainty, avg=".($uncertainty_total/$total).")\n");
    } else {
        ::Log(33, "Watts reading returns preliminary watts(total=$total, avg=UNDEF(no meters)) uncertainty(max=$max_uncertainty, avg=".($uncertainty_total/$total).")\n");
    }
    return ($isok, $total, $avg, $max_uncertainty, $uncertainty_total/$total, @rc);
}

# Trim a list of samples based on time.  Return total, average, min, max, and
# the list of new samples.
sub extract_samples {
    my ($meterlist, $intervals, $discard) = @_;
    my ($total, $avg, $min, $max) = (0);
    my @sample_totals = ();
    my @return_samples = ();

    foreach my $meter (@{$meterlist}) {
        # Save the info + aggregate data
        my $name = $meter->[0];
        my ($mavg, $mmin, $mmax, $num_samples, $errors, $valid) = @{$meter->[1]->{'pwrstat'}};
        my @keep = ();
        for(my $i = 2; $i < @{$meter}; $i++) {
            foreach my $interval_ref (@{$intervals}) {
                my ($start, $end) = @{$interval_ref};
                if ($meter->[$i]->{'ts'} < $start) {
                    # Won't be in this list of intervals
                    last;

                } elsif ($meter->[$i]->{'ts'} <= $end) {
                    # It's a keeper
                    push @keep, $meter->[$i];
                    last;

                } elsif (@keep == 0 && int($meter->[$i]->{'ts'}) <= $end) {
                    # Relax the restrictions a little bit so that at least ONE
                    # sample will be taken.  This should only happen when the
                    # benchmark run takes less time than the meter sampling
                    # interval.
                    push @keep, $meter->[$i];
                    last;
                }
            }
        }

        return undef unless @keep;

        # Recalculate the meter-local metrics
        ($mmin, $mavg, $mmax, $num_samples, $valid) = (undef, 0, undef, 0, 0);

        for(my $i = 0; $i < @keep; $i++) {
            my $sum = sum_channels($keep[$i]);
            if ($sum < 0 or $sample_totals[$i] < 0) {
                # If one channel returns an error for a measurement, that whole sample is bad
                $sample_totals[$i] = -1;
                next;
            }
            $mavg += $sum;
            $mmin = $sum if (!defined($mmin) || $sum < $mmin);
            $mmax = $sum if (!defined($mmax) || $sum > $mmax);
            $num_samples++;
            # Just assume that selected samples are okay...
            $valid++;

            # Add each sample to the totals; this assumes that all meters
            # run at the same sample rate and start and end at the same
            # time.  This array is used to figure global min and max.
            $sample_totals[$i] += $sum;
        }
        $mavg /= $num_samples;
        $total += $mavg;

        # Throw it back on the pile...
        push @return_samples, [
            $name,
            { 'pwrstat' => [ $mavg, $mmin, $mmax,
                    $num_samples, $errors, $valid ],
                'accstat' => [ @{$meter->[1]->{'accstat'}}   ],
                'range'   => [ @{$meter->[1]->{'range'}}     ]
            },
            @keep
        ];
    }

    # Trim the sample list and re-average
    if ($discard > 0) {
        $total = 0;
        @sample_totals = ();
        foreach my $meter (@return_samples) {
            my ($new_avg, $new_min, $new_max, $numsamples, @samples) =
            trim_and_average($meter, $discard);
            if (defined($new_avg)) {
                # Uncomment this to trim the list of stored samples to match
                # the list used to generate the new min/average/max.
                #splice @{$meter}, 2, @{$meter}-2, @samples;

                # Add each sample to the totals; this assumes that all meters
                # run at the same sample rate and start and end at the same
                # time.  This array is used to figure global min and max.
                for(my $i = 0; $i < @samples; $i++) {
                    my $sample_val = sum_channels($samples[$i]);
                    if ($sample_val < 0 or $sample_totals[$i] < 0) {
                        # If a single measurement for a sample is bad, the whole sample is bad
                        $sample_totals[$i] = -1;
                    } else {
                        $sample_totals[$i] += $sample_val;
                    }
                }
                $total += $new_avg;

                # Get previous values for sample counts, etc.
                my ($samples, $errors, $valid_samples) = @{$meter->[1]->{'pwrstat'}}[4..6];

                # Because it's unlikely that the trimming will get rid of
                # any of the bad samples, keep the error counts and the
                # valid sample count relatively the same as it was before.
                # This COULD push the number of bad samples over the
                # meter_errors_percentage threshold, but ignore it.
                # So...
                $valid_samples = @{$meter} - ($samples - $valid_samples) - 2;
                $samples = @{$meter}-2;

                $meter->[1]->{'pwrstat'} = [ $new_avg, $new_min, $new_max, $samples, $errors, $valid_samples ];
            }
        }
    }
    # Figure out global min/max
    @sample_totals = grep { $_ > 0 } sort { $a <=> $b } @sample_totals;
    ($min, $max) = @sample_totals[0, @sample_totals-1];

    return ($total, $total/@{$meterlist}, $min, $max, @return_samples);
}

sub sum_channels {
    my ($sample) = @_;
    my $sum = 0;

    return undef unless (ref($sample) eq 'HASH');

    foreach my $reading (@{$sample->{'pwr'}}) {
        # Errors (-1), missed samples (-2), unreasonably low values (negative values other than -1 or -2), and
        # unreasonably large values (let's say a billion is a reasonable definition for "unreasonably large") indicate
        # errors and will be ignored when recalculating averages and stuff like that.
        return -1 if $reading < 0 or $reading > 1_000_000_000;
        $sum += $reading;
    }

    return $sum;
}

# Convert a PTD RL timestamp to localtime, possibly with compensation
sub ptdtime2time {
    my ($ts, $offset) = @_;

    my $ptdtime = undef;
    if ($ts =~ /^(\d+)-(\d+)-(\d+) (\d+:\d+:\d+\.\d+)$/) {
        $ptdtime = str2time("$3-$1-$2T$4");
        $ptdtime += $offset if defined($offset);
    }

    return $ptdtime;
}

# Convert a time value to a PTD RL timestamp
sub time2ptdtime {
    my ($ts) = @_;
    $ts = time unless defined($ts);

    return POSIX::strftime("%m-%d-%Y %H:%M:%S.0000", localtime($ts));
}

# Given a PTD command that will return the standard (avg, min, max), return
# the average average, lowest, and highest, along with the full list of
# returned per-meter values.
sub temp_meter_temp_and_humidity {
    my ($error_percentage, @meterlist) = @_;
    my $isok = 1;
    my $error_reltol = $error_percentage / 100;
    my @rc = ();
    my $rc = {
        'temperature' => [
            undef, # average
            undef, # min
            undef, # max
            []     # meter+samples list
        ],
        'humidity' => [
            undef, # average
            undef, # min
            undef, # max
            []     # meter+samples list
        ]
    };

    return $isok if @meterlist == 0;

    # Collect the avg/min/max data
    foreach my $cmd (qw(Temperature Humidity)) {
        my ($total, $meters, $min, $max, @samples) = (0, 0, undef, undef, undef);
        my %tmprc = ();
        send_to_meters("$cmd\r\n", @meterlist);

        # Collect the responses
        foreach my $meter (@meterlist) {
            my $tmp = "${cmd},25,25,25,1,0,1";
            $tmp = $meter->{'sock'}->getline() if $meter->{'sock'};
            $tmp =~ tr/\015\012//d;
            ::Log(134, "Meter '".$meter->{'name'}."' returned '$tmp' to '$cmd' command\n");
            push @{$meter->{'responses'}}, $tmp;
            my ($cmd, $avg, $tmp_min, $tmp_max, $samples, $errors, $valid_samples) = split(/,/, $tmp);
            if ($avg < 0 && $samples == 0) {
                # PTD has indicated that the measurement is unsupported, or that
                # there's an error
                if ($cmd eq 'Temperature') {
                    # Problem; all temp sensors should measure temperature
                    ::Log(0, "Temperature meter '".$meter->{'name'}."' indicates an error or lack of samples\n");
                    $isok = 0;
                }
                # No problem for humidity; some temp sensors don't measure that
                next;
            }
            # Convert everything to numbers
            $avg += 0;
            $tmp_min += 0;
            $tmp_max += 0;
            $samples += 0;
            $errors += 0;
            $valid_samples += 0;
            if ($errors != 0) {
                ::Log(0, "Meter '".$meter->{'name'}."' reports $errors errors\n");
                $isok = 0 if ($errors > ($samples * $error_reltol));
            }
            if ($samples != $valid_samples) {
                ::Log(0, "Meter '".$meter->{'name'}."' reports $samples ".lc($cmd)." samples, of which only $valid_samples are good\n");
                $isok = 0 if (($samples - $valid_samples) > ($samples * $error_reltol));
            }
            $tmprc{$meter->{'name'}} = [ $meter->{'name'}, $avg, $tmp_min, $tmp_max, $samples, $errors, $valid_samples ];
            $min = $tmp_min if ($tmp_min < $min || !defined($min));
            $max = $tmp_max if ($tmp_max < $max || !defined($max));
            $total += $avg;
            $meters++;
        }
        if ($meters > 0) {
            ::Log(33, lc($cmd)." readings return avg=".($total/$meters).", min=$min, max=$max\n");
            $rc->{lc($cmd)} = [ $total/$meters, $min, $max, (values %tmprc) ];
        }
    }

    # Use "RL" to get samples with timestamps
    my ($tmpok, %tempout) = do_RL({ map { $_->[0] => $_->[4] } @{$rc->{'temperature'}}[3..$#{$rc->{'temperature'}}] },
        {
            'Temperature' => 'temp',
            'Humidity'    => 'hum',
        },
        @meterlist);
    $isok &= $tmpok;

    # Assemble the saved values to return
    @rc = ( $rc );
    foreach my $meter (sort { $a->{'name'} cmp $b->{'name'} } @meterlist) {
        push @rc, [ $meter->{'name'}, @{$tempout{$meter->{'name'}}->{'samples'}} ] if ::ref_type($tempout{$meter->{'name'}}->{'samples'}) eq 'ARRAY';
    }

    return ($isok, @rc);
}

# Find out if specinvoke understands the given option.
sub specinvoke_can {
    my ($opt) = @_;

    my $specrun = jp($::global_config->top, 'bin', $::global_config->specrun);
    my $tmp = qx/$specrun -n $opt -f ${$}nocmdfile${$} 2>&1/;
    $? = 0;       # So as to not taint other things
    if ($tmp =~ /illegal option --/) {
        return 0;
    } else {
        return 1;
    }
}

# Find out if specinvoke understands the given option in a command file.
sub specinvoke_cmd_can {
    my ($opt) = @_;

    my $specrun = jp($::global_config->top, 'bin', $::global_config->specrun);
    my $tmp = qx/$specrun -p $opt 2>&1/;
    if ($? == 0 && $tmp !~ /illegal option --/) {
        if ($tmp =~ /per command/) {
            return 1;
        } elsif ($tmp =~ /globally/) {
            return 2;
        }
    }

    $? = 0;       # So as to not taint other things
    return 0;
}

# Find out if specmake understands the given option.
sub specmake_can {
    my ($make, $opt) = @_;
    my $rc = 0;

    my $tmp = qx/$make $opt -h 2>&1/;
    $rc = $?;
    $? = 0;       # So as to not taint other things
    if ($rc != 0 || $tmp =~ /unrecognized option/) {
        return 0;
    } else {
        return 1;
    }
}

# Return a list of accurate-ish metric names for the supplied benchsets
sub get_metrics {
    my ($config, $power, @bsets) = @_;

    return (
        map {
            my $metric = first { $power ? /_energy/ : !/_energy/ } keys %{$config->{'benchsets'}->{$_}->{'metric_names'}};
            $metric =~ s/_(?:base|peak).*//;
            $metric;
        } @bsets
    );
}

# Given a hash of environment variables and values as specified in the config file, pull them out from the actual
# environment (if present) or use the value specified in the config file
sub get_actual_env_values {
    my (%tmpenv) = @_;

    foreach my $varname (sort keys %tmpenv) {
        $tmpenv{$varname} = exists($ENV{$varname}) ? $ENV{$varname} : $tmpenv{$varname};
    }

    return %tmpenv;
}


# Unitish tests here
if (grep { $_ eq 'test:add_interval' } @ARGV) {
    my @tests = (
        # Start                       New             Expected        Label
        [ [],                         [2,1],          [[1,2]],        'First' ],
        [ [[1,5]],                    [7,1],          [[1,5],[6,7]],  'Append' ],
        [ [[3,4]],                    [2,1],          [[1,2],[3,4]],  'Prepend' ],
        [ [[1,2],[6,7]],              [5,2],          [[1,2],[3,5],[6,7]],'Insert' ],
        [ [[1,2],[3,4]],              [3,1],          [[1,4]],        'Overlap + merge' ],
        [ [[1,4]],                    [6,3],          [[1,6]],        'Extend end' ],
        [ [[4,7]],                    [6,3],          [[3,7]],        'Extend start' ],
        [ [[2,6]],                    [4,2],          [[2,6]],        'Subset start' ],
        [ [[2,6]],                    [6,2],          [[2,6]],        'Subset end' ],
        [ [[2,6]],                    [6,4],          [[2,6]],        'Complete subset' ],
        [ [[3,5]],                    [6,5],          [[1,6]],        'Complete superset' ],
    );
    require Test::More; Test::More->import(tests => @tests+0);
    foreach my $testref (@tests) {
        my ($start, $new, $expected, $label) = @{$testref};
        my @working = @{$start};
        add_interval(\@working, @{$new});
        $Data::Dumper::Indent=0;
        if (!is_deeply(\@working, $expected, $label)) {
            diag(Data::Dumper->Dump([$start, $new, $expected, \@working],[qw(start new expected got)]));
        }
    }
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab mouse= colorcolumn=120:
