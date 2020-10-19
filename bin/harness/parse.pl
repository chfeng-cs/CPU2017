#
# parse.pl
#
# Copyright 1999-2018 Standard Performance Evaluation Corporation
#
# $Id: parse.pl 6058 2018-10-01 17:28:36Z CloyceS $

use strict;
use Getopt::Long;
use Text::ParseWords;
use Carp qw(cluck);
use List::Util qw(first max);
use List::MoreUtils qw(nsort_by);
use Scalar::Util qw(reftype);
use EmptyButTrue;
require 'flagutils.pl';
require 'util.pl';

my $version = '$LastChangedRevision: 6058 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'parse.pl'} = $version;

# List of options (canonical and all aliases) that runcpu may use when calling
# itself, but which users should or may not use directly.
# Note that presence in this list is not sufficient to prohibit user use of the
# flag.
# The value indicates whether or not there's a value that should also be
# removed from ARGV when the option is seen.
%::runcpu_only_options = (
    'from_runcpu'   => 1,
    'logfile'       => 1,
    'lognum'        => 1,
    'test'          => 0,
    'check_version' => 0,
    'check-version' => 0,
    'note_preenv'   => 0,
    'note-preenv'   => 0,
    'nopreenv'      => 0,
    'rawformat'     => 0,
    'R'             => 0,
    'update'        => 0,
    'version'       => 0,
    'V'             => 0,
);

# This won't work for hash options because the args passed in differ.  Luckily
# we don't have any of those.
# $type determines where and how the option is stored:
# ''  => switch; option stored for re-use
# '!' => toggle; option stored for re-use
# 's' => string; option and value stored for re-use
# 'i' => integer; option and value stored for re-use
# 'f' => number; option and value stored for re-use
# 'X' => ignore; store neither option nor value for re-use
my %option_position = ();
my $current_position = 0;
sub record {
    my ($dest, $type, $optname, $optval) = @_;
    my $option = $optname;
    $option_position{$option} = $current_position++;

    # Unfortunately I couldn't figure out how to get $type
    # from the $optname object.  At least, not in a way
    # that I was sure would be future-proof.

    # Make sure that the sense of switched options are recorded properly
    if ($type eq '!') {
        $option = 'no'.$option if !defined($optval) or $optval == 0;
        $type = '';
    }

    # Do not record options that only runcpu may use itself
    $type = 'X' if exists($::runcpu_only_options{$optname});

    push @::original_opts, ((length($option) == 1) ? '-' : '--').$option if $type ne 'X';
    if (defined($optval)) {
        push @::original_opts, $optval if $type ne '' and $type ne 'X';
        if (reftype($dest) eq 'HASH') {
            $dest->{$optname} = $optval;
        } elsif (reftype($dest) eq 'ARRAY') {
            push @$dest, $optval;
        } elsif (reftype($dest) eq 'SCALAR') {
            ${$dest} = $optval;
        }
    }
}

sub parse_commandline {
    my ($config, $cl_opts) = @_;
    my @macros = ();
    my @undefkeys = ();
    my @flagsurls = ();
    my $bp_bench = undef;

    # No defaults
    $cl_opts->{'bundlename'} = $cl_opts->{'bundleaction'} = '';

    # Array to store command line arguments that aren't benchmark selections.
    @::original_opts = ();

    if (exists $ENV{'SPEC_RUNSPEC'}) {
        unshift @ARGV, shellwords($ENV{'SPEC_RUNSPEC'});
    }

    Getopt::Long::Configure(qw(permute ignore_case bundling_override));
    my @actions = ();
    my $rc = GetOptions ($cl_opts,
        # Options that take arguments, sorted lexically by name
        'action|a=s'                                                    => sub { record(\@actions, 's', @_) },
        'basepeak:s@'                                                   => sub { record(undef, 's', @_); if (defined($_[1]) and $_[1] ne '') { push @$bp_bench, $_[1]; } else { $bp_bench = 'full'; } },
        'comment=s'                                                     => sub { record($cl_opts, 's', @_) },
        'configfile|config|c=s'                                         => sub { record($cl_opts, 's', @_) },
        'copies|C=s'                                                    => sub { record($cl_opts, 's', @_) },
        'copynum=i'                                                     => sub { record($cl_opts, 's', @_) },
        'define|S=s'                                                    => sub { record(\@macros, 's', @_) },
        'delay=i'                                                       => sub { record($cl_opts, 's', @_) },
        'device=s'                                                      => sub { record($cl_opts, 's', @_) },
        'expid=s'                                                       => sub { record($cl_opts, 's', @_) },
        'flagsurl|flags|F=s'                                            => sub { record(\@flagsurls, 's', @_) },
        'from_runcpu=i'                                                 => sub { record($cl_opts, 'i', @_) },
        'graph_max|graph-max|graphmax=f'                                => sub { record($cl_opts, 'f', @_) },
        'graph_min|graph-min|graphmin=f'                                => sub { record($cl_opts, 'f', @_) },
        'http_proxy|http-proxy=s'                                       => sub { record($cl_opts, 's', @_) },
        'http_timeout|http-timeout=i'                                   => sub { record($cl_opts, 'i', @_) },
        'info_wrap_columns|info-wrap|info-wrap-columns|infowrap=i'      => sub { record($cl_opts, 'i', @_) },
        'iterations|n=i'                                                => sub { record($cl_opts, 'i', @_) },
        'label|L=s'                                                     => sub { record($cl_opts, 's', @_) },
        'logfile=s'                                                     => sub { record($cl_opts, 's', @_) },
        'lognum=s'                                                      => sub { record($cl_opts, 's', @_) },
        'make-bundle|make_bundle=s'                                     => sub { if ($_[1]) { $cl_opts->{'bundlename'} = $_[1]; $cl_opts->{'bundleaction'} = 'make'; } else { delete $cl_opts->{'bundlename'}; delete $cl_opts->{'bundleaction'}; } },
        'notes_wrap_columns|notes-wrap|notes-wrap-columns|noteswrap=i'  => sub { record($cl_opts, 'i', @_) },
        'output_format|output-format|output|o=s'                        => sub { record($cl_opts, 's', @_) },
        'output_root|output-root=s'                                     => sub { record($cl_opts, 's', @_) },
        'parallel_test_workloads|parallel-test-workloads=s'             => sub { record($cl_opts, 's', @_) },
        'parallel_test|parallel-test=i'                                 => sub { record($cl_opts, 'i', @_) },
        'platform=s'                                                    => sub { record($cl_opts, 's', @_) },
        'ranks=i'                                                       => sub { record($cl_opts, 'i', @_) },
        'runmode=s'                                                     => sub { record($cl_opts, 's', @_) },
        'size|input|i=s'                                                => sub { record($cl_opts, 's', @_) },
        'stagger=i'                                                     => sub { record($cl_opts, 'i', @_) },
        'test:s'                                                        => sub { record($cl_opts, 's', @_) },
        'threads=i'                                                     => sub { record($cl_opts, 'i', @_) },
        'train_with=s'                                                  => sub { record($cl_opts, 's', @_) },
        'tune|tuning|T=s'                                               => sub { record($cl_opts, 's', @_) },
        'undef=s'                                                       => sub { record(\@undefkeys, 's', @_) },
        'unpack-bundle|unpack_bundle=s'                                 => sub { if ($_[1]) { $cl_opts->{'bundlename'} = $_[1]; $cl_opts->{'bundleaction'} = 'unpack'; } else { delete $cl_opts->{'bundlename'}; delete $cl_opts->{'bundleaction'}; } },
        'use-bundle|use_bundle=s'                                       => sub { if ($_[1] && ($::from_runcpu & 1) == 0) { $cl_opts->{'bundlename'} = $_[1]; $cl_opts->{'bundleaction'} = 'use'; } else { delete $cl_opts->{'bundlename'}; delete $cl_opts->{'bundleaction'}; } },
        'username|U=s'                                                  => sub { record($cl_opts, 's', @_) },
        'verbose|verbosity|debug|v=i'                                   => sub { record($cl_opts, 'i', @_) },
        # No sub for this one since runcpu will only set this when calling
        # itself, and so we don't need to remember it.
        'userundir=s@',

        # Options that are toggles or plain switches, sorted lexically by name
        'check_version|check-version'                           => sub { record($cl_opts, '', @_) },
        # runspec will never call itself with --configpp, so no need to
        # remember the option was used.
        'configpp'                                              => sub { if ($_[1]) { push @actions, 'configpp' } else { @actions = grep { !/configpp/ } @actions } },
        'deletework|d'                                          => sub { record($cl_opts, '' , @_) },
        'fake|dryrun|dry-run|dry_run!'                          => sub { record($cl_opts, '!', @_) },
        'feedback!'                                             => sub { record($cl_opts, '!', @_) },
        'graph_auto|graph-auto!'                                => sub { record($cl_opts, '!', @_) },
        'help|h|?'                                              => sub { record($cl_opts, '' , @_) },
        'ignore_errors|ignoreerror|ignore-errors|I!'            => sub { record($cl_opts, '!', @_) },
        'keeptmp!'                                              => sub { record($cl_opts, '!', @_) },
        'log_timestamp|log-timestamp!'                          => sub { record($cl_opts, '!', @_) },
        'loose|l'                                               => sub { record($cl_opts, '' , @_) },
        'make_no_clobber|make-no-clobber|M'                     => sub { record($cl_opts, '' , @_) },
        'mockup|fakereportable'                                 => sub { record($cl_opts, '' , @_) },
        'nobuild|N'                                             => sub { record($cl_opts, '' , @_) },
        'noratios!'                                             => sub { record($cl_opts, '!', @_) },
        'note_preenv|note-preenv'                               => sub { record($cl_opts, '' , @_) },
        'power!'                                                => sub { record($cl_opts, '!', @_) },
        'preenv|pre_env|pre-env!'                               => sub { record($cl_opts, '!', @_) },
        'rawformat|R'                                           => sub { record($cl_opts, '' , @_) },
        'rebuild|D'                                             => sub { record($cl_opts, '' , @_) },
        'reportable!'                                           => sub { record($cl_opts, '!', @_) },
        'reportonly|fakereport'                                 => sub { record($cl_opts, '' , @_) },
        'review!'                                               => sub { record($cl_opts, '!', @_) },
        's'                                                     => sub { record($cl_opts, '' , @_) },
        'setprocgroup!'                                         => sub { record($cl_opts, '!', @_) },
        'strict!'                                               => sub { record($cl_opts, '!', @_) },
        'table!'                                                => sub { record($cl_opts, '!', @_) },
        'unbuffer|f'                                            => sub { record($cl_opts, '' , @_) },
        'update:s'                                              => sub { record($cl_opts, '' , @_) },
        'use_submit_for_compare|use-submit-for-compare!'        => sub { record($cl_opts, '!', @_) },
        'use_submit_for_speed|use-submit-for-speed!'            => sub { record($cl_opts, '!', @_) },
        'version|V'                                             => sub { record($cl_opts, '' , @_) },
    );

    # Just in case there has been an oversight and a nonvolatile option has
    # been inserted into the list of command line options, throw it out and
    # issue a warning.
    foreach my $nvconfig (keys %$main::nonvolatile_config) {
        if (exists($cl_opts->{$nvconfig})) {
            delete $cl_opts->{$nvconfig};
            Log(0, "$nvconfig is immutable.  Do not attempt to set it via the command line.\n");
        }
    }

    if (($::from_runcpu & 1) == 1 and $cl_opts->{'userundir'} ne '') {
        $cl_opts->{'rundir'} = $cl_opts->{'userundir'};
    }

    # Check setting for label
    if (exists($cl_opts->{'label'})
            and $cl_opts->{'label'} =~ /[,:=\s]/) {
        Log(100, "ERROR: Illegal characters in 'label'; please use only alphanumerics,\n");
        Log(100, "       underscores (_), hyphens (-), and periods (.).\n");
        $rc = 0;
    }

    # Check bundle name
    if (   exists($cl_opts->{'bundlename'})
        && $cl_opts->{'bundlename'} ne '') {
        my $tmpname = basename($cl_opts->{'bundlename'});
        if ($tmpname !~ /^[A-Za-z0-9_.-]+$/) {
            Log(100, "ERROR: Illegal characters in bundle name; please use only alphanumerics,\n");
            Log(100, "       underscores (_), hyphens (-), and periods (.).\n");
            $rc = 0;
        }
    }

    # Expand the list of benchmarks for basepeak
    if (ref($bp_bench) eq 'ARRAY') {
        $bp_bench = [ split(/[,:]+/, join(',', @$bp_bench)) ];
        # Now throw back everything that is an existing filename
        $config->{'bp_bench'} = [ ];
        foreach my $bench (@$bp_bench) {
            if (-e $bench) {
                # It's a file, so put it back in @ARGV to be processed
                unshift @ARGV, $bench;
            } else {
                push @{$config->{'bp_bench'}}, $bench;
            }
        }
        $config->{'bp_bench'} = 'full' unless @{$config->{'bp_bench'}};
    } elsif (defined($bp_bench) && $bp_bench eq 'full') {
        $config->{'bp_bench'} = 'full';
    }

    # Set the run mode
    if (exists($cl_opts->{'runmode'})) {
        if ($cl_opts->{'runmode'} !~ /^(?:rate|shrate|speed)$/i) {
            Log(100, "ERROR: Argument to --runmode must be one of 'speed', 'rate', or 'shrate'.\n");
            $rc = 0;
        } else {
            $cl_opts->{'runmode'} = lc($cl_opts->{'runmode'});
        }
    }

    # Fix up macros for use when parsing the config file
    foreach my $macro (@macros) {
        if ($macro =~ /^([^=:]+)[=:](.*)$/o) {
            # It's a name/value pair
            $cl_opts->{'pp_macros'}->{$1} = Spec::Config::pp_macro_expand($2, $cl_opts->{'pp_macros'}, 1, 0, 'command line', 1, 0, 0);
        } else {
            # It's just a name; give it the empty-but-true value
            $cl_opts->{'pp_macros'}->{$macro} = $EmptyButTrue::val;
        }
    }
    foreach my $key (@undefkeys) {
        $cl_opts->{'pp_unmacros'}->{$key} = 1;
        delete $cl_opts->{'pp_macros'}->{$key} if exists $cl_opts->{'pp_macros'}->{$key};
    }

    # --fakereportable and --mockup just mean '--fakereport --reportable',
    # so fix things up.
    if (exists $cl_opts->{'mockup'}) {
        $cl_opts->{'reportonly'} = 1;
        $cl_opts->{'reportable'} = 1;
        delete $cl_opts->{'fakereportable'};
        delete $cl_opts->{'mockup'};
    }

    # --reportonly and --fakereport are just handy synonyms for
    # '--action=report', so act accordingly
    if (exists $cl_opts->{'reportonly'}) {
        @actions = ('report');
        delete $cl_opts->{'reportonly'};
    }

    # Check the action(s) specified.  This will help catch typos like
    # '-a <cfgfile>'.  In any case, only the last one specified gets stuffed
    # into the action slot.
    foreach my $action (map { lc($_) } @actions) {
        if (! grep { $action eq $_ } @{$::nonvolatile_config->{'valid_actions'}}) {
            die "\n\"$action\" is not a valid action!\n\n";
        }
    }
    my $action = pop @actions;
    $cl_opts->{'action'} = $action if (defined($action) && $action);

    # 'loose', 'strict', and 'reportable' are all really ways of talking
    # about 'reportable', so munge things up properly.  Having 4 ways to
    # choose this is one of the things I'd undo if I could.
    # But I can't, so choose the last one that actually appeared on the command
    # line to use.
    my @reportable_opts = reverse
                          nsort_by { $option_position{$_}+0 }
                          grep { exists($option_position{$_}) }
                          qw(loose s strict reportable);
   if (@reportable_opts) {
       my $reportable_opt = lc($reportable_opts[0]);
       if (exists($cl_opts->{$reportable_opt})) {
           if ($reportable_opt eq 'loose') {
               $cl_opts->{'reportable'} = 1 - $cl_opts->{$reportable_opt};
           } else {
               $cl_opts->{'reportable'} = $cl_opts->{$reportable_opt};
           }
       } else {
           die "\nOption '--$reportable_opt' was parsed but does not appear in the list of command\n"
           ."line arguments.  This should never happen.  Please report this problem to\n"
           ."${main::lcsuite}support\@spec.org, including the command line used and the config file.\n";
       }
    }
    delete $cl_opts->{'loose'};
    delete $cl_opts->{'s'};
    delete $cl_opts->{'strict'};

    # Run the Perl test suite, if asked
    if (exists $cl_opts->{'test'} && defined($cl_opts->{'test'})) {
        print "Running the Perl test suite...\n";
        chdir main::jp($ENV{'SPEC'}, 'bin');
        my @args = ( main::jp($ENV{'SPEC'}, 'bin', 'specperl'), main::jp('test', 'TEST') );
        push @args, '-dots' if $cl_opts->{'test'} eq 'dots';
        if ($^O =~ /MSWin/) {
            # If we use exec for Windows, the user gets dumped to the command
            # line long before the tests are finished.
            system @args;
            exit $?;
        } else {
            exec @args;
            # This should never happen
            die "exec of $args[0] failed: $!\n";
        }
    }

    # Take care of the flags file(s)
    @flagsurls = split(/,+/, join(',', @flagsurls));
    $cl_opts->{'flagsurl'} = [];
    if (@flagsurls && !grep { /^noflags$/ } @flagsurls) {
        foreach my $url (@flagsurls) {
            $url =~ s|\\|/|g; # Change \ to / for Windows users
            if ($url !~ m!^([^:]+://|file:)!) {
                if (! -e $url) {
                    Log(0, "ERROR: Specified flags file path ($url) could not be found.\n");
                    Log(0, "       To get a flags report, you must re-format generated results with a\n");
                    Log(0, "       valid flags file.\n");
                    next;
                }
            } elsif ($url !~ /^(http|file):/) {
                die "ERROR: Unsupported flags file URL scheme in \"$url\";\n       please use file: or http:.\nStopped";
            }
            push @{$cl_opts->{'flagsurl'}}, $url;
        }
    }
    if (@{$cl_opts->{'flagsurl'}} == 0) {
        # No flags files found
        delete $cl_opts->{'flagsurl'};
    }

    # Unset the http proxy?
    if ($cl_opts->{'http_proxy'} eq 'none') {
        delete $ENV{'http_proxy'};
        $config->{'cl_opts'}->{'http_proxy'} = '';
    }

    # Options to pass to rawformat
    $config->{'rawformat_opts'} = [];
    foreach my $opt (qw( table review graph_auto )) {
        push @{$config->{'rawformat_opts'}}, ($cl_opts->{$opt} ? "--$opt" : "--no$opt") if exists($cl_opts->{$opt});
    }
    foreach my $opt (qw( graph_min graph_max verbose )) {
        push @{$config->{'rawformat_opts'}}, ("--$opt", $cl_opts->{$opt}) if exists($cl_opts->{$opt});
    }

    # If doing explicit rate and parallel_test is not specified, then default
    # it to the number of copies specified on the command line.
    if ($cl_opts->{'runmode'} =~ /rate$/ and !exists($cl_opts->{'parallel_test'})
            and $cl_opts->{'copies'} > 0) {
        $cl_opts->{'parallel_test'} = $cl_opts->{'copies'};
    }
    if (exists($cl_opts->{'parallel_test'}) && $cl_opts->{'parallel_test'} < 1) {
        Log(100, "ERROR: Setting for parallel_test must be a positive integer\n");
        delete $cl_opts->{'parallel_test'};
    }

    # OMP2012 shouldn't be using --rate, but it probably won't hurt to be safe
    if ($::lcsuite =~ /^omp/) {
        delete $cl_opts->{'parallel_test'};
    }

    # runcpu is the only one allowed to set its own logfile and lognum
    if ($cl_opts->{'from_runcpu'} == 0
            and (exists($cl_opts->{'logfile'})
                or exists($cl_opts->{'lognum'}))) {
        Log(0, "ERROR: Only runcpu itself may use --logfile or --lognum\n");
        delete $cl_opts->{'logfile'};
        delete $cl_opts->{'lognum'};
    }
    $::from_runcpu = $cl_opts->{'from_runcpu'} if $cl_opts->{'from_runcpu'};

    # For configpp, the output filename needs to be stored in the cl_opts area
    if ($cl_opts->{'action'} eq 'configpp'
            and $cl_opts->{'output_format'}) {
        $config->{'cl_opts'}->{'output_format'} = $cl_opts->{'output_format'};
    }

    # If --update gets no argument, it will exist but not be empty, so make it
    # true.
    if (exists($cl_opts->{'update'}) and $cl_opts->{'update'} eq '') {
        $cl_opts->{'update'} = $EmptyButTrue::val;
    }

    if (!$rc || istrue($cl_opts->{'help'})) {
        print "For help, type \"runcpu --help\"\n";
        #usage();
        exit (!$rc ? 1 : 0);
    }

    # Store persistent command line options (ones that will be referenced
    # later) into the config object itself.  Not all possible options fall
    # into this category.  This also isn't the complete list; some options
    # (such as --fakereport) which are aggregates or aliases for other options
    # are handled separately.
    foreach my $clopt (qw(
        check_version
        comment
        configfile
        copies
        copynum
        delay
        deletework
        device
        expid
        ext
        fake
        feedback
        graph_auto
        graph_max
        graph_min
        http_proxy
        http_timeout
        ignore_errors
        info_wrap_columns
        iterations
        keeptmp
        log_timestamp
        logfile
        lognum
        make_no_clobber
        nobuild
        noratios
        note_preenv
        notes_wrap_columns
        output_root
        parallel_test
        parallel_test_workloads
        platform
        power
        preenv
        ranks
        rawformat
        rebuild
        reportable
        review
        runmode
        setprocgroup
        stagger
        table
        threads
        train_with
        unbuffer
        update
        use_submit_for_compare
        use_submit_for_speed
        username
        verbose
        )) {
        $config->{'cl_opts'}->{$clopt} = $cl_opts->{$clopt} if exists($cl_opts->{$clopt});
    }

    return 1;
}

# Does some post-final-config checks.  For sanity, should not modify $config.
sub validate_options {
    my ($config) = @_;

    if (istrue($config->unbuffer)) {
        $|=1;
    }
    if ($config->label eq '') {
        Log(0, "\nERROR: Please specify a label!  (-L or --label or label= in config file)\n");
        do_exit(1);
    }

    # Check the types for numerics
    my ($rc, $badval);
    if ($config->runmode =~ /rate$/) {
        ($rc, $badval) = check_numbers($config->copies);
        if (!$rc) {
            Log(100, "\nERROR: '$badval' is not a valid value for copies!\n");
            do_exit(1);
        }
    }
    ($rc, $badval) = check_numbers($config->iterations);
    if (!$rc) {
        Log(100, "\nERROR: '$badval' is not a valid value for iterations!\n");
        do_exit(1);
    }
    ($rc, $badval) = check_numbers($config->verbose);
    if (!$rc) {
        Log(100, "\nERROR: '$badval' is not a valid value for verbose!\n");
        do_exit(1);
    }

    if ($::lcsuite eq 'accel') {
        # Check platform and device
        my $ok = 1;
        foreach my $thing (qw(platform device)) {
            my $val = $config->accessor_nowarn($thing);
            if (defined($val) && $val =~ /^\s*$/) {
                Log(100, "\nERROR: Please specify a value for $thing (--$thing or $thing= in config file)\n");
                $ok = 0;
            }
        }
        do_exit(1) unless $ok;
    }

    if (istrue($config->fake) && !istrue($config->teeout)) {
        $config->{'teeout'} = 1;
    }
}

sub check_numbers {
    my ($aref) = @_;
    my ($rc, $badval);

    if (ref($aref) eq 'ARRAY') {
        foreach my $thing (@{$aref}) {
            $rc = check_number($thing);
            return ($rc, $thing) unless $rc;
        }
    } elsif (ref($aref) eq '') {
        $rc = check_number($aref);
        return ($rc, $aref) unless $rc;
    } else {
        Log(100, "Can't check object of type ".ref($aref)."!\n");
        return (1, $aref);
    }
    return(1, undef);
}

sub check_number {
    my ($thing) = @_;

    return scalar($thing =~ /^\d+$/o);
}

sub resolve_choices {
    my ($config, $cl_opts) = @_;
    # List of formats to do; rawformat will sort it all out
    $config->{'formatlist'} = [ split(/[:,]+/, $config->output_format) ];

    my $action = $config->action;
    my $tmp = choose_string($action, @{$config->valid_actions});
    if (!defined $tmp) {
        if (istrue($config->check_version)) {
            return 0;
        } else {
            Log(0, "I don't know what type of action '$action' is!\n");
            do_exit(1);
        }
    }
    # Fix up the small number of synonyms that we have
    if (lc($action) eq 'onlyrun') {
        $action = 'only_run';
    } elsif (lc($action) eq 'run') {
        $action = 'validate';
    } elsif (lc($action) eq 'runsetup') {
        $action = 'setup';
    }
    $config->action($action);

    $config->{'tunelist'} = [ sort { $a cmp $b }
                                choose_strings('Tune', $config->{'tune'},
                                               [ @{$config->valid_tunes} ],
                                               [])
                            ];

    # Take care of size 'all':
    if ($config->{'size'} =~ /\ball\b/) {
        if ($::lcsuite eq 'cpu2017') {
            $config->{'size'} =~ s/\ball\b/test,train,ref/;
        } elsif ($::lcsuite =~ /^(mpi2007|omp)/) {
            ::Log(0, "\nERROR: 'all' is not a valid workload size for $::suite\n\n");
            ::do_exit(1);
        } else {
            # It doesn't mean anything special... what did you expect?
        }
    }

    if (ref($config->{'tunelist'}) ne 'ARRAY' ||
        @{$config->{'tunelist'}} == 0) {
        if (istrue($config->check_version)) {
            return 0;
        } else {
            Log(0, "A valid tuning level must be selected using -T or --tune on the command line\n");
            Log(0, "or by setting 'tunelist' in the configuration file.\n");
            do_exit(1);
        }
    }

    # Validate the sizes
    $config->{'sizelist'} = [ ];
    if ($::lcsuite eq 'cpu2017') {
        foreach my $maybe_size (split(/[,:]+|\s+/, $config->{'size'})) {
            if ($maybe_size =~ /^(?:all|test|train|ref)/i) {
                push @{$config->{'sizelist'}}, $maybe_size unless grep { /$maybe_size/ } @{$config->{'sizelist'}};
            } else {
                Log(0, "Notice: '$maybe_size' is not a valid workload size.  It will be added to the list\n");
                Log(0, "         of benchmarks to run.\n");
                push @ARGV, $maybe_size;
            }
        }
    } else {
        # Just take the sizes as specified.
        $config->{'sizelist'} = [ ];
        foreach my $maybe_size (split(/[,:]+|\s+/, $config->{'size'})) {
            push @{$config->{'sizelist'}}, $maybe_size unless grep { /$maybe_size/ } @{$config->{'sizelist'}};
        }
    }
    if (@{$config->{'sizelist'}} == 0) {
        Log(0, "\nNo workload size specified!\n");
        do_exit(1);
    }

    # What's left are benchmark candidate selections.
    my @candidates = @ARGV;
    my %candidates = map { $_ => 1 } @candidates;

    if (@candidates+0 < 1 && exists $config->{'runlist'}) {
        push @candidates, split(/(?:\s+|\s*[,:]+\s*)/, $config->{'runlist'});
    }
    delete $config->{'runlist'};
    my ($errors, @configs) = resolve_user_selection($config, \@candidates);
    if (@configs == 0) {
        if (istrue($config->check_version)) {
            return undef;
        }
        elsif ($errors == 0) {
            # No errors, and no configs, so complain
            Log(0, "\n\nNo benchmark suite selected!");
            my @choices = ::expand_all('all');
            if ($choices[0] eq 'all') {
                # The set of valid benchsets for this benchmark is unknown
            } elsif (@choices > 1) {
                Log(0, "  Expected one or more of '".join("', '", @choices)."' or 'all'.");
            } elsif ($choices[0] ne '') {
                Log(0, "  Expected '$choices[0]' or 'all'.");
            } else {
                Log(0, "  Expected 'all'.");
            }
            Log(0,"\n");
            do_exit(1);
        }
    }

    return @configs;
}

## figure out which benchmarks are to be run
## and return them as a list.
sub resolve_user_selection {
    my ($config, $selection) = @_;
    my $files_ok = $config->{'bundleaction'} eq 'make';
    my %metric_names = ();
    my %metric_synonyms = ();
    my %benchsets_by_mode = ();
    my %modes_by_benchset = ();
    my %default_options = (
        'reportable' => istrue($config->reportable) ? 2 : 0,
        'power'      => istrue($config->power) ? 2 : 0,
        'runmode'    => $config->runmode,
        'tune'       => $config->tune,
        'tunelist'   => [ @{$config->tunelist} ],
        'size'       => $config->size,
        'sizelist'   => [ @{$config->sizelist} ],
    );
    my %options = (
        %default_options,
        'benchset_list'   => [ ],
        'benchmarks'      => [ ],
        'benchmarks_seen' => { },
        'bundle_files'    => [ ],
    );
    my @optsets = ();
    @$selection = ::expand_all(@$selection);

    # Generate a mapping of metric names and synonyms to benchset names,
    # as well as which run modes each benchset naturally supports.
    foreach my $bset (values %{$config->{'benchsets'}}) {
        my $name = $bset->{'name'};
        my $no__synonym;
        my $conflict = [];

        # Add the benchset's name to the list of synonyms, so that a potential
        # collision can be detected.  In practice this wouldn't cause a
        # problem, since benchset names take precedence over metric names/
        # synonyms.  It could avert some surprise, though.
        if (exists($metric_synonyms{lc($name)}) and $metric_synonyms{lc($name)} ne $name) {
            $conflict = [ $name, $name, $metric_synonyms{lc($name)} ];
        }
        else {
            $metric_synonyms{lc($name)} = $name;
        }

        # Benchsets that do not generate output by definition don't have
        # metrics and thus can't have metric synonyms.  They also shouldn't
        # get to participate in the mode selection game.
        if (@$conflict == 0 and $bset->output) {
            foreach my $metric (sort keys %{$bset->{'metric_names'}}) {
                if (exists($metric_names{lc($metric)}) and $metric_names{lc($metric)}->[0] ne $name) {
                    $conflict = [ $metric, $name, $metric_names{lc($metric)}->[0] ];
                    last;
                }
                $metric_names{lc($metric)} = [ $name, $bset->{'metric_names'}->{$metric}->[0] ];
                ($no__synonym = lc($metric)) =~ tr/_//d;
                foreach my $synonym (@{$bset->{'metric_names'}->{$metric}}, $no__synonym) {
                    ($no__synonym = $synonym) =~ tr/_//d;
                    foreach my $tag ($synonym, $no__synonym) {
                        if (exists($metric_synonyms{lc($tag)}) and $metric_synonyms{lc($tag)} ne $name) {
                            $conflict = [ $tag, $name, $metric_synonyms{lc($tag)} ];
                            last;
                        }
                        $metric_synonyms{lc($tag)} = $name;
                    }
                }
            }
            foreach my $mode (qw(rate speed)) {
                if ($bset->{$mode.'_multiplier'} > 0) {
                    $benchsets_by_mode{$mode}->{$name}++;
                    $modes_by_benchset{$name}->{$mode}++;
                }
            }
        }
        if (@$conflict) {
            Log(0, "ERROR: The metric name ($conflict->[0]) for the ".
                   $conflict->[1]."\n".
                "\tbenchset is the same as for the $conflict->[2]".
                " benchset.\nThis should never happen.\n");
            do_exit(1);
        }
    }
    Log(85, Data::Dumper->Dump([\%metric_names,\%metric_synonyms],[qw(benchset_to_metric_mapping benchset_to_synonym_mapping)])."\n") if Log(85);

    # Find out what benchmarks the user wants to run; knock out duplicates and
    # figure out how many different configurations there will be.
    my $error = 0;
    my %do_warn = (
        'reportable'    => 1,
        'notreportable' => 1,
    );

    foreach my $sel (@$selection) {
        my $no__sel = lc($sel);
        $no__sel =~ tr/_//d;
        my @bmarks_sel = ();
        my $not = 0;
        if ($sel =~ s/^\^+//) { # leading '^' indicates DEselection
            $not = 1;
        }
        %options = (
                %default_options,
                'benchset_list'   => [ ],
                'benchmarks'      => [ ],
                'benchmarks_seen' => { },
                'bundle_files'    => $options{'bundle_files'},
                );

        # Forcing the selection name to lowercase works because there are no
        # benchsets with names that contain uppercase.  This would break any
        # like that.
        if (exists $config->{'benchsets'}{lc($sel)}) {
            $sel = lc($sel);
            # The selection is the name of a benchset
            my $ref = $config->{'benchsets'}{$sel}{'benchmarks'};
            if ($config->{'benchsets'}{$sel}{'output'}) {
                # The benchset generates output, and must have a consistent
                # set of run mode and workload.
                push @{$options{'benchset_list'}}, $sel;
                push @bmarks_sel, values %$ref;
            } else {
                # The benchset is just shorthand for a collection of
                # benchmarks; treat them as if they'd all been specified
                # individually and restart the loop.
                push @{$selection}, sort keys %$ref;
                next;
            }
        }

        elsif (exists($metric_names{lc($sel)})
                or (exists($metric_synonyms{lc($sel)}) or exists($metric_synonyms{$no__sel}))) {
            # The selection is the exact name of a metric (case insensitive),
            # or is a metric synonym (case insensitive, ignoring underscores)
            my $bset;
            if (exists($metric_names{lc($sel)})) {
                $bset = $metric_names{lc($sel)}->[0];
                if ($do_warn{'reportable'} and !istrue($config->reportable)) {
                    Log(0, "\n".
                        "**********************************************************\n".
                        "INFO: This run will use the --reportable features, because\n".
                        "you selected SPEC $::suite metric '$sel'.\n".
                        "If you did not want a full reportable run, you could\n".
                        "stop this run now and instead say '".
                        $metric_names{lc($sel)}->[1]."'\n".
                        "**********************************************************\n".
                        "\n");
                    sleep 2;
                }
                $do_warn{'reportable'} = 0;
                $options{'reportable'} = 1;
            } else {
                $bset = $metric_synonyms{lc($sel)} || $metric_synonyms{$no__sel};
                if ($do_warn{'notreportable'} and !istrue($config->reportable)) {
                    Log(0, "\n".
                        "**********************************************************\n".
                        "INFO: This run will NOT use the --reportable features.\n".
                        "If you want them, you could add that switch.\n".
                        "**********************************************************\n".
                        "\n");
                    sleep 2;
                }
                $do_warn{'notreportable'} = 0;
            }
            push @{$options{'benchset_list'}}, $bset;
            my $ref = $config->{'benchsets'}{$bset}{'benchmarks'};
            push @bmarks_sel, map { $ref->{$_} } keys %$ref;

            # Names have power.  In this case, the power to set options.
            if ($options{'power'} < 2) {
                $options{'power'} = ($sel =~ /_energy/) ? 1 : 0;
            }
            if ($sel =~ /_(base|peak)/) {
                # Reportable checks will add base if necessary to a peak-only
                # run.
                $options{'tune'}     = $1;
                $options{'tunelist'} = [ $1 ];
            }
        }

        else {
            # maybe the selection is for a particular benchmark
            my $sel_bmark = find_benchmark($config, $sel);
            if (defined($sel_bmark) and ::ref_type($sel_bmark) ne 'ARRAY') {
                @bmarks_sel = ($sel_bmark);
            } else {
                if ($files_ok) {
                    # Windows users mustn't use wildcards -- the shell doesn't
                    # expand them, and the Win32 module expands them
                    # incompletely.
                    if (   $^O =~ /MSWin/
                        && ($sel =~ /\?/ || $sel =~ m#(?<![/\\])\*#)) {
                        Log(0, "\nERROR: Specification of files with wildcards is not supported on Windows.\n");
                        do_exit(1);
                    }
                    my @add = check_file($config, $sel);
                    $files_ok = 2 unless @add;
                    push @{$options{'bundle_files'}}, @add;
                    next;
                } else {
                    if (::ref_type($sel_bmark) eq 'ARRAY') {
                        Log(0, "Can't resolve '$sel' to a benchmark; too many matches: ".join(', ', sort map { $_->benchmark } @{$sel_bmark})."\n\n");
                    } else {
                        Log(0, "Can't find benchmark '$sel'\n");
                    }
                }
            }
        }

        # If no benchsets are noted, then either a single benchmark was
        # specified or a benchset that does not produce output was
        # specified.  Either way, we need to find the name of a benchset
        # that produces output to include, since that's how we figure out
        # what the run mode should be later.
        if (@{$options{'benchset_list'}} == 0 and @bmarks_sel > 0) {
            foreach my $bmark (@bmarks_sel) {
                my @bsets = $config->benchmark_in_sets(1, $bmark->benchmark);
                if (@bsets) {
                    push @{$options{'benchset_list'}}, @bsets;
                } else {
                    Log(0, "WARNING: Benchmark ".$bmark->benchmark." is not part of any SPEC $::suite metric; ignoring it\n");
                }
            }
        }

        if (!@bmarks_sel && ($files_ok == 0 || @{$options{'bundle_files'}} == 0)) {
            Log(0, "WARNING: Can't parse '$sel' into a single benchmark name, benchset name,\n\tor metric name.\n");
            next;
        }

        if ($not and istrue($options{'reportable'}) and
            $config->action =~ /(?:validate|report)/) {
            Log(0, "WARNING: Benchmark exclusion is not allowed for a reportable run; ignoring '^${sel}'\n");
            next;
        }

        # Get configs set up for all of the run modes that are native for the
        # benchsets discovered.
        # They'll be filtered later based on what's in $config->runmode, if
        # the user has specified anything.
        my $exclude = ($config->action =~ /build/) ? { 'runmode' => 1 } : {};
        foreach my $mode (qw(rate speed)) {
            my @bsets_in_mode = grep { exists($benchsets_by_mode{$mode}->{$_}) } @{$options{'benchset_list'}};
            if (@bsets_in_mode) {
                $options{'runmode'} = $mode;    # It's okay to set this here,
                                                # since it'll be reset next time
                                                # around the loop.
                my $match = option_set_match_or_make($config, \%options, \@optsets, $exclude);

                # At this point, $match is guaranteed to be valid
                my $benchset_list   = $optsets[$match]->{'benchset_list'};
                my $benchmarks      = $optsets[$match]->{'benchmarks'};
                my $benchmarks_seen = $optsets[$match]->{'benchmarks_seen'};

                # Update the list of benchsets
                @{$benchset_list} = sort(::unique_elems(@{$benchset_list}, @bsets_in_mode));

                ## process the temporary list of benchmarks
                foreach my $bench (sort { $a->benchmark cmp $b->benchmark } @bmarks_sel) {
                    my $name = $bench->benchmark;
                    if ($not) { ## delete this benchmark from the list
                        next if !$benchmarks_seen->{$name};
                        Log(4, "  '$name' removed\n");
                        $benchmarks_seen->{$name} = 0;
                        ## remove (filter) it from the benchmarks list
                        @{$benchmarks} = grep { $name ne $_->benchmark } @{$benchmarks};
                    } else { ## add it to the benchmark list
                        next if $benchmarks_seen->{$name};
                        push @{$benchmarks}, $bench;
                        $benchmarks_seen->{$name} = 1;
                        Log(24, "  '$name' added\n");
                    }
                }
            }
        }
    }

    if ($files_ok == 2) {
        # There was a file/dir not found while attempting to make a bundle
        Log(0, "\nNot all extra files specified for bundling were found; aborting\n");
        do_exit(1);
    }

    # Go through all of the option sets, resolving the selected workload
    # sizes and doing per-config checks to make sure that all of the various
    # crazy combinations and config adjustments are supported.
    my $do_die = 0;
    my @misconfigs = ();
    foreach my $optset (@optsets) {
        next unless defined($optset->{'config'});

        # Figure out which workload sizes to run.  The user may specify a
        # workload or a workload class (test, train, ref); if a class is
        # specified, sizes will be selected based on the benchsets being run
        # _that generate output_.  In the case where there's a conflict, the
        # configs will be split and a new one added to @optsets.  Additionally,
        # if this is a reportable run and not all of the benchsets support the
        # workload set chosen, then it'll be split into configs for benchsets
        # that do (and can produce reportable results) and don't.

        # Build a map of benchsets to sizes
        my %bset_sizes = ();
        foreach my $bset (@{$optset->{'benchset_list'}}) {
            foreach my $size (@{$optset->{'sizelist'}}) {
                if ($size =~/^(test|train|ref)$/i) {
                    # This is a size class to be expanded.
                    push @{$bset_sizes{$bset}}, $config->{'benchsets'}->{$bset}->{$size};
                } else {
                    push @{$bset_sizes{$bset}}, $size;
                }
            }
        }
        # Reverse the map
        my %size_bsets = ();
        foreach my $bset (keys %bset_sizes) {
            my $tag = '';
            if ($optset->{'reportable'} == 1 and !supports_workloads($config, $bset, $bset_sizes{$bset})) {
                # If the benchset doesn't support the selected sizes, then
                # the config must be split.
                $tag = 'split';
            }
            push @{$size_bsets{$tag.':'.join(',', @{$bset_sizes{$bset}})}}, $bset;
        }

        # Modify the current optset's sizelist, and split out other optsets
        # if necessary
        undef $optset->{'sizelist'};
        foreach my $sizeset (sort keys %size_bsets) {
            my ($tag) = ($sizeset =~ /^(\S*):/);
            if ($tag eq '' and !defined($optset->{'sizelist'})) {
                $optset->{'benchset_list'} = [ @{$size_bsets{$sizeset}} ];
                $optset->{'sizelist'}      = [ @{$bset_sizes{$size_bsets{$sizeset}->[0]}} ],
                $optset->{'size'}          = join(',', @{$bset_sizes{$size_bsets{$sizeset}->[0]}}),
            }
            else {
                # We need a new option set.  This will get processed too,
                # but shouldn't actually change.
                # Reportable is unset for new option sets that are split
                # because of workload incompatibility; otherwise this would be
                # an infinite loop.
                my $reportable = ($tag eq 'split') ? 0 : $optset->{'reportable'};
                push @optsets, (
                    {
                        %{$optset},
                        'benchset_list' => [ @{$size_bsets{$sizeset}} ],
                        'sizelist'      => [ @{$bset_sizes{$size_bsets{$sizeset}->[0]}} ],
                        'size'          => join(',', @{$bset_sizes{$size_bsets{$sizeset}->[0]}}),
                        'reportable'    => $reportable,
                        'config'        => ::copy_config($config, undef),
                    }
                );
            }
        }
        if (!defined($optset->{'sizelist'})) {
            # ALL of the option sets were split off to new ones, which most
            # likely means that there was some conflict between implicit
            # --reportable and explicitly-selected workload sizes.  That
            # conflict will have been resolved by clearing the implicit
            # reportable for that option set, so just mark the current one
            # as dead and continue.
            delete $optset->{'config'};
            next;
        }

        # Now filter out benchmarks in the config that aren't in any of its
        # benchsets.  This can happen when benchsets get split off into
        # a new config because of size specification differences.  It can't
        # happen during the selection resolution process, since every set of
        # [benchsets, benchmarks] is guaranteed to be related.
        my %ok_bmarks = ();
        foreach my $bset (@{$optset->{'benchset_list'}}) {
            my $ref = $config->{'benchsets'}{$bset}{'benchmarks'};
            foreach my $bmark (map { $_->benchmark } map { $ref->{$_} } keys %$ref) {
                $ok_bmarks{$bmark}++;
            }
        }
        $optset->{'benchmarks'} = [ grep { $ok_bmarks{$_->benchmark} } @{$optset->{'benchmarks'}} ];
        delete $optset->{'benchmarks_seen'};

        # Only do run mode and workload compatibility checks for runs that
        # will involve a run directory in some way.
        if ($config->action !~ /^(buildsetup|build|configpp|makebundle|usebundle)$/) {

            # By default, if the user specifies no run mode, the correct one
            # will be chosen.  But if $config->runmode isn't empty, then we
            # need to check that this option set matches.
            if ($config->runmode ne '' and $config->runmode ne $optset->{'runmode'}) {
                # It doesn't match... Queue up the information about the
                # misconfiguration for later, when it will be presented all at
                # once.
                # Collect the information necessary to report the problems
                push @misconfigs, (
                    map { [ $_, $config->runmode || $optset->{'runmode'}, $optset->{'size'} ] } ::get_metrics($config, $optset->{'power'}, @{$optset->{'benchset_list'}})
                );

                # If --noratios is on and --reportable was set automatically,
                # unset it.  It's okay to do this unconditionally, since if
                # --noratios is NOT on, then the run will terminate.
                $optset->{'reportable'} = 0 if ($optset->{'reportable'} == 1);

                # Also adjust the option set run mode; we're here because
                # the user DID request a specific mode and it doesn't match
                # what's in the current option set.
                $optset->{'runmode'} = $config->runmode;

                next;     # No need to continue processing the bad config
            }

            # If reportable is set, the list of benchmarks must make up at
            # least one full benchset.  The workloads selected must also
            # match what the benchset supports.
            # If neither of those conditions are not fulfilled, arrange to
            # complain later.
            if ($config->action =~ /(?:validate|report|makebundle)/) {
                if ($optset->{'reportable'}) {
                    # Make sure that each benchset has its full complement of benchmarks
                    FULL_BSET_CHECK: foreach my $bset (@{$optset->{'benchset_list'}}) {
                        my ($ok) = $config->is_full_benchset($bset, map { $_->benchmark } @{$optset->{'benchmarks'}});
                        unless ($ok) {
                            # Not all benchmarks in this benchset were found.
                            # That's bad.
                            Log(0, "\nERROR: A reportable run was requested; individual benchmark selection is not\n".
                                   "       allowed.  The benchmarks needed for ".join(', ', ::get_metrics($config, $optset->{'power'}, $bset))." are not all present.\n".
                                   "       If you really want to run only selected benchmarks, then add the switch\n".
                                   "        '--noreportable' to the command line.\n");
                            $do_die = 1;
                            last FULL_BSET_CHECK;
                        }
                    }
                }

                # Check to make sure each benchset supports the workloads
                # selected.  It's a metric/no-metric thing as opposed to
                # a reportable/not-reportable thing.
                foreach my $bset (@{$optset->{'benchset_list'}}) {
                    if (!supports_workloads($config, $bset, $optset->{'sizelist'})) {
                        push @misconfigs, (
                            map { [ $_, $config->runmode || $optset->{'runmode'}, $optset->{'size'} ] } ::get_metrics($config, $optset->{'power'}, $bset)
                        );
                    }
                }
            }
        }
    }

    # Filter out any "dead" option sets
    @optsets = grep { defined($_->{'config'}) } @optsets;

    if (@misconfigs) {
        # Now is when we either just complain (--noratios) or complain and
        # then die.
        my ($severity, $verb) = istrue($config->noratios) ? ('NOTICE:', 'will') : ('ERROR: ', 'would');
        my $reports = (@misconfigs > 1) ? (@misconfigs + 0).' reports' : 'a report';
        my @pre = (
            "$severity Selected benchmarks and options $verb create $reports that cannot produce valid SPEC $::suite metrics:"
        );

        my @details = ('');
        my $metric_width = max map { length($_) } ('Report Type', map { $_->[0] } @misconfigs);
        my $mode_width   = max map { length($_) } ('Mode',        map { $_->[1] } @misconfigs);
        my $size_width   = max map { length($_) } ('Workload',    map { $_->[2] } @misconfigs);
        push @details, sprintf("\t    %*s  Run", $metric_width, '');
        push @details, sprintf("\t    %*s  %*s  %*s",
                                -$metric_width, 'Report Type',
                                -$mode_width,   'Mode',
                                -$size_width,   'Workload');
        push @details, sprintf("\t    %*s  %*s  %*s",
                                -$metric_width, '-' x $metric_width,
                                -$mode_width,   '-' x $mode_width,
                                -$size_width,   '-' x $size_width);
        push @details, (
            map {
                sprintf("\t    %*s  %*s  %*s",
                        -$metric_width, $_->[0],
                        -$mode_width,   $_->[1],
                        -$size_width,   $_->[2]);
            } @misconfigs
        );
        push @details, '';

        my @post = ();
        if (istrue($config->noratios)) {
            my $reports = (@misconfigs > 1) ? 'reports' : 'report';
            push @post, (
                "\tYour $reports will include execution times in seconds.",
                "\tYour $reports will NOT include any comparable SPEC $::suite metrics.",
            );
        }
        else {
            push @post, (
                "\tThis run will now stop.  (If you really want to do a run that cannot produce valid metrics, use the --NoRatios command line switch.)"
            );
            $do_die = 1;
        }
        push @post, '';

        Log(0, "\n".join("\n", wrap_lines(\@pre, 78, "\t", 0, 1), @details, wrap_lines(\@post, 78, '', 0, 1))."\n");
    }

    if (Log(63)) {
        local $Data::Dumper::Sortkeys = sub { return [ grep { $_ !~ /^config$/ } (sort keys %{$_[0]}) ] };
        local $Data::Dumper::Maxdepth = 3;
        Log(63, Data::Dumper->Dump([\@optsets],['config_option_sets'])."\n");
    }

    # Don't actually die; the user is allowed to have a bogus run config if
    # the only thing being done is a version check.  resolve_choices() will
    # deal with that situation.
    return (@misconfigs+0, ()) if $do_die;

    # Fix up the config objects with the options in each option set.  Also add
    # appropriate options to the additional_cl_opts item in the config so that
    # runcpu instances spawned for preenv runs will also have the correct
    # options.
    foreach my $optset (@optsets) {
        # runlist gets set explicitly; mostly because I thought that using
        # 'benchmarks' in this routine was clearer than 'runlist'
        $optset->{'config'}->{'runlist'} = $optset->{'benchmarks'};
        # Sort the benchset list to enhance determinism
        $optset->{'config'}->{'benchset_list'} = [ sort @{$optset->{'benchset_list'}} ];
        foreach my $option (sort keys %{$optset}) {
            next if $option =~ /^(?:config|benchmark|benchset_list)/;
            if ($option eq 'reportable' or $option eq 'power') {
                # These options can be set implicitly; this just makes sure
                # that the values get clamped back to 1 or 0.
                $optset->{'config'}->{$option} = ($optset->{$option} == 2) ? 1 : $optset->{$option};
            } else {
                $optset->{'config'}->{$option} = $optset->{$option};
            }
        }

        # Take care of the options that aren't covered by runlist, etc.
        $optset->{'config'}->{'implicit_cl_opts'} = [];
        for my $switch (qw(reportable power)) {
            my $mod = $optset->{$switch} == 0 ? 'no' : '';
            if ($optset->{$switch} != 2) {
                push @{$optset->{'config'}->{'implicit_cl_opts'}}, '--'.$mod.$switch;
            }
        }
        # runmode is the only option that might be set that is single-valued
        if ($optset->{'runmode'} ne '') {
            push @{$optset->{'config'}->{'implicit_cl_opts'}}, '--runmode', $optset->{'runmode'};
        }
        # Now do the ones that may be multi-valued.  We use ':' as the
        # separator so it'll work on Windows too.
        for my $switch (qw(tune size)) {
            if (@{$optset->{$switch.'list'}}) {
                push @{$optset->{'config'}->{'implicit_cl_opts'}}, '--'.$switch, join(':', @{$optset->{$switch.'list'}});
            }
        }
    }

    return (0, map { $_->{'config'} } @optsets);
}

sub supports_workloads {
    my ($config, $bset, $sizes) = @_;
    if (reftype($bset) ne 'HASH') {
        $bset = $config->{'benchsets'}->{$bset};
        return 0 unless reftype($bset) eq 'HASH';
    }

    my $ok = 1;
    foreach my $size (@$sizes) {
        my $size_ok = 0;
        # The benchset is okay if at least one of its workloads matches
        # anything at all in @$sizes
        foreach my $class (qw(test train ref)) {
            $size_ok = 1 if ($size eq $bset->{$class});
        }
        $ok = 0 unless $size_ok;
    }

    return $ok;
}

sub option_set_match_or_make {
    my ($config, $options, $optsets, $exclude) = @_;
    $exclude = { } unless ref($exclude) eq 'HASH';
    $exclude->{'tune'}            = 1 unless exists($exclude->{'tune'});
    $exclude->{'tunelist'}        = 1 unless exists($exclude->{'tunelist'});
    $exclude->{'config'}          = 1 unless exists($exclude->{'config'});
    $exclude->{'benchmarks'}      = 1 unless exists($exclude->{'benchmarks'});
    $exclude->{'benchmarks_seen'} = 1 unless exists($exclude->{'benchmarks_seen'});
    $exclude->{'benchsets'}       = 1 unless exists($exclude->{'benchsets'});
    $exclude->{'bundle_files'}    = 1 unless exists($exclude->{'bundle_files'});

    # Figure out if the current options match any of the existing option
    # sets.
    my $match;
    for($match = 0; $match < @{$optsets}; $match++) {
        my $optsetref = $optsets->[$match];
        my $is_match = 1;
        foreach my $optkey (sort keys %{$options}) {
            next if $exclude->{$optkey};
            if (!exists($optsetref->{$optkey})) {
                # This should never happen
                $is_match = 0;
                last;
            }
            if (ref($options->{$optkey}) eq 'ARRAY' and ref($optsetref->{$optkey}) eq 'ARRAY') {
                if (@{$options->{$optkey}} != @{$optsetref->{$optkey}}) {
                    $is_match = 0;
                    last;
                }
                for(my $i = 0; $i < @{$options->{$optkey}} and $i < @{$optsetref->{$optkey}}; $i++) {
                    $is_match = 0 unless $options->{$optkey}->[$i] eq $optsetref->{$optkey}->[$i];
                }
                last if $is_match == 0;
            } elsif ($options->{$optkey} ne $optsetref->{$optkey}) {
                $is_match = 0;
                last;
            }
        }
        if ($is_match) {
            # Fix up the tune list, if necessary
            if ($options->{'tune'} ne $optsetref->{'tune'}) {
                # The sort will implicitly enforce the base,peak ordering
                $optsetref->{'tunelist'} = [ sort(::unique_elems(@{$options->{'tunelist'}}, @{$optsetref->{'tunelist'}})) ];
                $optsetref->{'tune'} = join(',', @{$optsetref->{'tunelist'}});
            }
            last;
        }
    }
    if ($match >= @{$optsets}) {
        # No existing option set is suitable; make a new one
        push @{$optsets}, (
            {
                %{$options},
                'config' => ::copy_config($config, undef),
            }
        );
        $match = @{$optsets} - 1;
    } else {
        # Match on $optsets[$match]
        if (!defined($optsets->[$match]->{'config'})) {
            # This can happen if none of the user's benchmark
            # specifications cause a change to run mode, etc...
            # No deep copy is made, since this will only
            # happen one time.
            $optsets->[$match]->{'config'} = $config;
        }
    }

    return $match;
}

sub check_file {
    my ($config, $file) = @_;
    my $top = $config->top;

    if ($^O =~ /MSWin/) {
        $top = Win32::GetLongPathName($top);
        $file = Win32::GetLongPathName($file);
        $file =~ s#[\\/]\.$##;   # If it refers to a directory, let that be it.
    }

    # Prepend $top to relative filenames
    my $path = $file;
    $path = jp($top, $file) unless $path =~ m#^(?:/|(?:[A-Z]:)?\\)#;

    # Strip $top from filenames so that they'll look nice later
    $file =~ s#^\Q$top\E[/\\]##;

    # Disallow inclusion of top-level dirs that could either
    # a) wreck the recipient's installation
    # b) make the bundle file huge and maybe a)
    my $check_re = '';
    $check_re = 'i' if ($^O =~ /MSWin/);
    $check_re = qr#^(?${check_re}:(?:\Q$top\E[/\\])?(?:benchspec(?:[/\\]\Q$::suite\E)?|bin(?:[/\\](?:lib|formats|formatter))?|result|config|Docs|redistributable_sources|tmp|tools|install_archives))#;
    if ($file =~ /$check_re/) {
        Log(0, "ERROR: Top-level $::suite directories and files under them may not be included\n");
        Log(0, "       in a bundle.  Ignoring \"$file\"\n");
        return ();
    }
    $check_re = '';
    $check_re = 'i' if ($^O =~ /MSWin/);
    $check_re = qr#^(?${check_re}:(?:\Q$top\E[/\\])?(?:Revisions|install\.bat|install\.sh|shrc|shrc\.bat|MANIFEST|README(?:\.txt)?|LICENSE(?:\.txt)|SUMS\.tools|cshrc|version\.txt|uninstall.sh))$#;
    if ($file =~ /$check_re/) {
        Log(0, "ERROR: Top-level $::suite files may not be overwritten by bundled files.\n       Ignoring \"$file\"\n");
        return ();
    }

    if (-d $path) {
        Log(24, "Adding files under directory \"$file\" to bundle list\n");
        # Completely expand the list of files, excluding all the directories.
        # This is so the hash-generation code in make_bundle() doesn't have to
        # do it.
        return ::list_all_files($path);
    } elsif (-f $path) {
        Log(24, "Adding file \"$file\" to bundle list\n");
    } else {
        Log(0, "ERROR: \"$file\" is neither a file nor a directory\n");
        return();
    }

    return $file;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
