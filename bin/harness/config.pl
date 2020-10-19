#
# config.pl
#
# Copyright 1999-2019 Standard Performance Evaluation Corporation
#
# $Id: config.pl 6266 2019-06-25 03:46:16Z CloyceS $
#
BEGIN {
    require 'setup_common.pl';  # For joinpaths

    # Fix up @INC to add the harness directory if it's not already there.
    # This is mostly just to allow 'specperl -c config.pl' to not barf;
    # runcpu will do this before using this module.
    unshift @INC, ::joinpaths($ENV{'SPEC'}, 'bin', 'harness') unless grep { /harness/ } @INC;
}

package Spec::Config;

use strict;
use IO::File;
use Safe;
use File::Basename;
use Text::Wrap;
use ConfigDumper;
use EmptyButTrue;
our %refmapping;
%refmapping = ();

my $version = '$LastChangedRevision: 6266 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'config.pl'} = $version;

require 'config_common.pl';
require 'util_common.pl';         # For bytrailingnum

# List of variables and settings that are only effective when set in the
# header section.
%::header_only = (
    'action'                   => 1,
    'allow_label_override'     => 1,
    'backup_config'            => 1,
    'bench_post_setup'         => 1,
    'check_version'            => 1,
    'command_add_redirect'     => 1,
    'device'                   => 1,
    'expand_notes'             => 1,
    'expid'                    => 1,
    'label'                    => 1,
    'flagsurl'                 => 1,
    'http_proxy'               => 1,
    'http_timeout'             => 1,
    'idledelay'                => 1,
    'idleduration'             => 1,
    'idle_current_range'       => 1,
    'idle_voltage_range'       => 1,
    'ignore_errors'            => 1,
    'ignore_sigint'            => 1,
    'info_wrap_columns'        => 1,
    'keeptmp'                  => 1,
    'line_width'               => 1,
    'link_input_files'         => 1,
    'locking'                  => 1,
    'absolutely_no_locking'    => 1,
    'log_line_width'           => 1,
    'log_timestamp'            => 1,
    'mail_reports'             => 1,
    'mailcompress'             => 1,
    'mailmethod'               => 1,
    'mailport'                 => 1,
    'mailserver'               => 1,
    'mailto'                   => 1,
    'mail_reports'             => 1,
    'mean_anyway'              => 1,
    'minimize_builddirs'       => 1,
    'minimize_rundirs'         => 1,
    'nobuild'                  => 1,
    'notes_wrap_columns'       => 1,
    'notes_wrap_indent'        => 1,
    'output_format'            => 1,
    'output_root'              => 1,
    'platform'                 => 1,
    'post_setup'               => 1,
    'power'                    => 1,
    'power_analyzer'           => 1,
    'preenv'                   => 1,
    'rate'                     => 1,
    'rebuild'                  => 1,
    'reportable'               => 1,
    'runlist'                  => 1,
    'section_specifier_fatal'  => 1,
    'setprocgroup'             => 1,
    'shrate'                   => 1,
    'size'                     => 1,
    'speed'                    => 1,
    'stagger'                  => 1,
    'sysinfo_program'          => 1,
    'table'                    => 1,
    'teeout'                   => 1,
    'temp_meter'               => 1,
    'tune'                     => 1,
    'unbuffer'                 => 1,
    'verbose'                  => 1,
    'verify_binaries'          => 1,
    'temp_meter'               => 1,
    'voltage_range'            => 1,
);

%::reserved_words = (
    'config_inc'      => 1,
    'benchmarks'      => 1,
    'benchsets'       => 1,
    'compile_error'   => 1,
    'config'          => 1,
    'files_read'      => 1,
    'flaginfo'        => 1,
    'oldhashes'       => 1,
    'orig_argv'       => 1,
    'orig_env'        => 1,
    'pptxtconfig'     => 1,
    'rawformat_opts'  => 1,
    'rawtxtconfig'    => 1,
    'rawtxtconfigall' => 1,
    'refs'            => 1,
    'seen_labels'     => 1,
    'setobjs'         => 1,
    'top'             => 1,
    'powermeterlist'  => 1,
    'tempmeterlist'   => 1,
);

# Dump the config object, resolving refs into human-readable (sort of) form:
sub dumpconf {
    my ($me, $name) = @_;

    my $dumper = new ConfigDumper([$me], ['*'.$name]);
    $dumper->Indent(1);
    $dumper->Translate([qw(config refs)]);
    $dumper->Refhash(\%refmapping);
    $dumper->Sortkeys(1);
    print $dumper->Dump;
}

# Load a file and merge it with the current data
sub merge {
    my ($me, $filename, $comment, $pp_macros, %opts) = @_;
    my ($include, $name, $value, @vals, $op);
    my @reflist = (::ref_type($opts{'reflist'}) eq 'ARRAY') ? @{$opts{'reflist'}} : ($me);
    my @tmpreflist = ();
    my $promote_to_header = 0;
    my @curr_sections = (::ref_type($opts{'curr_sections'}) eq 'ARRAY') ? @{$opts{'curr_sections'}} : ('header');
    my $continued = 0;
    my $appended = 0;
    my ($blockquote, $first_blockquote) = (undef, undef);
    my $eol_carp_done = 0;
    my @lastrefs = ();
    my %seen_labels = (::ref_type($opts{'seen_labels'}) eq 'HASH') ? %{$opts{'seen_labels'}} : ( 'default' => 1, 'none' => 1 );
    my $saved_filename = '';
    my %seen_machs = ();
    my $do_croak = 0;
    # List of files read.  In the case of config files, it also lists our
    # parent files (if we're in an include chain).
    $me->{'files_read'} = [] unless (::ref_type($me->{'files_read'}) eq 'ARRAY');
    # List of config files read.  This is used to keep track of which files
    # need to be included in bundles.
    $me->{'config_inc'} = {} unless (::ref_type($me->{'config_inc'}) eq 'HASH');
    my $included = (@{$me->{'files_read'}}+0 > 0);
    my $tmppath = ($filename =~ m#^/#) ? $filename : jp($me->top, $me->configdir, $filename);
    my $sysinfo_run = -1;        # Have we run the system information program?
    my $sysinfo_lines = -1;      # Hwo many lines did we get form it?
    my %sysinfo_dups = ();      # What settings did sysinfo stomp?
    my @pp_state = (1);         # 1 => include lines, 0 => don't
    my @pp_good = (1);          # Keep track of which nesting levels have true ifs
    my $used_macros = (::ref_type($opts{'used_macros'}) eq 'HASH') ? $opts{'used_macros'} : {};
    $opts{'used_macros'} = $used_macros;
    $pp_macros = {} unless ref($pp_macros) eq 'HASH';
    my @bmlist = ('default', keys %{$me->{'benchsets'}},
        map { $_->benchmark } values %{$me->{'benchmarks'}});
    my @tunelist = ('default', @{$me->{'valid_tunes'}});
    my $trimmedcomment = '';
    my $hashmode = 0;
    my (%sections, %variables);
    my %fixup_needed = (::ref_type($opts{'fixup_needed'}) eq 'HASH') ? %{$opts{'fixup_needed'}} : ();
    my %griped = ();
    my %seen_oldfields = (::ref_type($opts{'seen_oldfields'}) eq 'HASH') ? %{$opts{'seen_oldfields'}} : ( );
    my $pp_directive_re = qr/inform|info|warning|error|define|undef|ifdef|ifndef|else|elif|if|endif|dbgstop|dumpmacros/;

    $me->populate_predefined_pp_macros($pp_macros, $used_macros, $me->{'files_read'}, $filename);

    if (-f $tmppath) {
        # The name specified exists!  Yay!
        $filename = $tmppath;
    } else {
        # First try failed; does "$filename".cfg exist?
        if (-f $tmppath.'.cfg') {
            # Yes; use it
            $filename .= ".cfg";
            $filename = jp($me->top, $me->configdir, $filename) unless $filename =~ m#^/#;
        } else {
            if ($opts{'missing_ok'}) {
                # Don't complain about it.
                return 1;
            } else {
                # No.  Complain about it.
                if ($filename =~ m#^/#) {
                    Log(100, "Neither config file '$filename' nor '${filename}.cfg' exist!\n");
                } else {
                    Log(100, "Neither config file '$filename' nor '${filename}.cfg' exist in ".jp($me->top, $me->configdir)."!\n");
                }
                return 0;
            }
        }
    }

    # See if this is one of the default configs.
    if (!$::from_runcpu
            and !$included
            and !exists($ENV{"SPEC_${main::suite}_REGRESSION_TESTING_EXAMPLE_CONFIGS"})
            and (exists $::file_sums{$filename}
                or ($^O =~ /MSWin/ and grep { /\Q$filename\E$/i } keys %::file_sums))) {
        my $warning = <<"EOW";

=============================================================================
The config file you're using:
  $filename
is one of the pre-supplied examples from SPEC.  Please copy it to a new
file with some other name, and look for places marked EDIT within it.

Note: The examples supplied with SPEC $::suite may use different 
hardware / software than yours, and adjustments may be needed.

To learn about config files:
   https://www.spec.org/$::lcsuite/Docs/config.html
To see actual results, and download their config files:
   https://www.spec.org/$::lcsuite/
Troubleshooting:
   https://www.spec.org/$::lcsuite/Docs/config.html#troubleshooting
Technical support:
   https://www.spec.org/$::lcsuite/Docs/techsupport.html
Generally, issues with compiling should be directed to your compiler vendor.
=============================================================================
EOW
        Log(0, $warning);
        do_exit(1);
    }

    # Break include loops
    if ($included &&
        grep { $_ eq $filename } @{$me->{'files_read'}}) {
        Log(100, "ERROR: include loop detected.  Here is the include chain:\n    ".
            join("\n    ", (@{$me->{'files_read'}}, $filename))."\nIgnoring last entry - run will continue in 30 seconds.\n");
        sleep 30;       # Give them a chance to notice
        return 1;
    }

    $me->{'configpath'} = $filename unless $included;
    my $fh = new IO::File;
    if (!$fh->open($filename)) {
        Log(0, "ERROR: Can't read config file '$filename': $!\n");
        return 0;
    }
    push @{$me->{'files_read'}}, $filename;
    $me->{'config_inc'}->{$filename}++;

    Log(0, "Reading ".($included ? 'included ' : '')."config file '$filename'\n") unless ($::quiet || $::from_runcpu);

    if (!$included) {
        $me->{'oldhashes'} =  '';
        my @stuff = (
            "# Invocation command line:",
            "# $0 ".join(' ', @{$me->{'orig_argv'}}),
            '# output_root was not used for this run',
            "############################################################################");
        $me->{'rawtxtconfigall'} = [ @stuff ];
        $me->{'rawtxtconfig'} = [ @stuff ];
        $me->{'pptxtconfig'} = [ @stuff ];
    }
    if ($comment ne '') {
        my @comments = map { "# $_" } split(/(?:\r\n|\n)/, $comment);
        push @comments, '############################################################################';
        foreach my $list (qw(pptxtconfig rawtxtconfig rawtxtconfigall)) {
            push @{$me->{$list}}, @comments;
        }
    }

    my ($cfline, @cflines) = (<$fh>);
    my $cflinenum = 1;
    my $apparent_line; # different than $cflinenum for and after sysinfo
    while (defined($cfline)) {
        $cfline =~ tr/\012\015//d;
        if ($sysinfo_run >= 0) {
            if ($cflinenum - $sysinfo_run < $sysinfo_lines) {
                # While in the sysinfo lines, apparent_line should be relative
                # to the sysinfo output
                $apparent_line = $cflinenum - $sysinfo_run;
            } else {
                $apparent_line = $cflinenum - $sysinfo_lines;
            }
        } else {
            $apparent_line = $cflinenum;
        }

        # Strip unescaped trailing spaces
        $cfline =~ s/((?<!\\)\s)+$//g unless ($cfline =~ /^notes_wrap_indent/);
        # Strip escaping backslashes from trailing spaces
        $cfline =~ s/\\(\s)/$1/g;

        # Ignore old MD5-based exehash sections in all config files
        last if $cfline =~ m/^__MD5__$/o;

        if ($cfline =~ m/^__(?:END|HASH)__$/o) {
            if ($included) {
                last; # Ignore exehash sections in included files
            }
            if ($sysinfo_run < 0
                    and $me->action ne 'configpp'
                    and (!istrue($me->preenv) or $me->get_all_preenv() == 0)) {
                my ($sysinfo, $sysinfo_hash, @tmplines) = $me->get_sysinfo();
                $me->{'sysinfo_program'} = $sysinfo;
                $me->{'sysinfo_program_hash'} = $sysinfo_hash;
                $saved_filename = $filename;
                $filename = 'sysinfo output';
                if (@tmplines) {
                    $sysinfo_lines = @tmplines+2;
                    $sysinfo_run = $cflinenum;
                    unshift @cflines, "\n", @tmplines, $cfline;
                } else {
                    $sysinfo_run = $sysinfo_lines = 0;
                    $filename = $saved_filename;
                    $saved_filename = '';
                    redo;
                }
            } elsif ($cfline =~ m/^__END__$/) {
                last;
            } else {
                $hashmode = 1;
                $filename = $saved_filename if $saved_filename ne '';
            }
            goto NEXTLINE;
        }

        # Idiot guard
        if (!$::from_runcpu &&
            !defined($blockquote) && !$continued && !$appended &&
            !$eol_carp_done && $cfline =~ m#^\s*([-/])#) {
            my $eol_carp = <<"EOCarp";

   =====================================================================
   Notice: Found a line at line number $apparent_line that starts with "$1"
            in "$filename":

            $cfline

   This is not normally useful syntax in a SPEC $::suite config file.
   Have you perhaps passed a config file through a tool that
   thought it would be "helpful" to introduce an end-of-line
   character in the middle of a line that has a series of
   options?  (Some primitive email clients have been known to
   destroy technical content by doing so.)

   Only the first instance will receive this warning.  Lines
   like these will probably end up being ignored.

   Continuing in 10 seconds...
   =====================================================================

EOCarp
            ::Log(0, $eol_carp);
            $eol_carp_done = 1;
            sleep 10;
        }

        # Look for sysinfo sections left over from previous runs
        if ($sysinfo_run < 0
                and $cfline =~ /^# The following settings were obtained by running the sysinfo_program$/) {
            # Eat lines until the first blank line or EOF.  $cflinenum isn't
            # incremented because these lines are just going to plain go away.
            # Section settings will be remembered, in case there were lines
            # added afterwards that depend on it.
            my $section = '';
            while (defined($cfline) and
                   $cfline =~ /\S/ and
                   $cfline !~ /^# End of settings added by sysinfo_program/) {
                $cfline =~ tr/\012\015//d;
                $section = $cfline if ($cfline =~ m/^\s*[^\#=\s]+(?:=[^=\s]+)?(?:=[^=\s]+)?:\s*$/o);
                $cfline = shift(@cflines);
            }
            $cfline = shift(@cflines);
            # Now eat any blank lines that followed the sysinfo section
            while (defined($cfline) and $cfline =~ /^\s*$/) {
                $cfline = shift(@cflines);
            }
            if (@cflines == 0) {
                $cfline = '__END__'; # Give us a chance to run sysinfo
            } elsif ($section ne '' and
                     $cfline !~ m/^\s*[^\#=\s]+(?:=[^=\s]+)?(?:=[^=\s]+)?:\s*$/o) {
                # There's more after this, and it doesn't begin with a section
                # specifier, so add one that we've saved.
                unshift @cflines, $cfline;
                $cfline = $section;
            }
            next;
        }

        if ($hashmode) {
            $me->{'oldhashes'} .= $cfline;
        } else {
            # Save off this line but not protected comments that begin with '#>'
            push @{$me->{'rawtxtconfigall'}}, $cfline;
            if ($cfline =~ m/^\s*include:\s*\S+\s*$/i) {
                push @{$me->{'rawtxtconfig'}}, "#$cfline";
            } elsif ($cfline !~ m/^\s*\#>/) {
                push @{$me->{'rawtxtconfig'}}, $cfline;
            }
        }

        # Trim comments
        $trimmedcomment = '';
        # Bare # => comment; \# => #
        $trimmedcomment = $1 if ($cfline =~ s/(\s*(?<!\\)\#.*)//o);
        $cfline =~ s/\\\#/\#/og; # Unescape the escaped #

        # Do the preprocessor stuff
        if ($cfline =~ m/^%/o) {
            if ($hashmode) {
                # No preprocessor stuff in hash section
                goto NEXTLINE;
            }
            if ($cfline =~ m/^%\s*(${pp_directive_re})\s*(.*?)\s*$/o) {
                my ($what, $rest) = (lc($1), $2);

                # Handle conditionals first.  Since we must pay attention for
                # %endif to end an exclusionary block, we also must pay
                # attention to %if and %ifdef so that one of _their_ %endifs
                # doesn't improperly end an enclosing block.
                if ($what eq 'endif') {
                    shift @pp_state;
                    if (@pp_state+0 <= 0) {
                        Log(100, "ERROR: Unmatched %endif on line $apparent_line of $filename\n");
                        do_exit(1);
                    }

                } elsif ($what eq 'ifdef' || $what eq 'ifndef') {
                    # Make it possible to do this the easy way
                    if ($rest !~ /^%/) {   # ...and catch the common mistake
                        Log(100, "WARNING: Syntax error in %$what conditional on line $apparent_line of\n         $filename; should be '%{$rest}'\n");
                    } else {
                        $rest =~ /^(?<!\\)%\{([^%\{\}]+)\}/;
                        if ($1 ne '') {
                            # A simple match -- handle it
                            $rest = $1;
                        } else {
                            # Nested references... grr.  Try stripping off
                            # surrounding %{...} and then expanding it.
                            $rest =~ s/^(?<!\\)%\{//;
                            $rest =~ s/\}[^\}]*$//;
                            my $tmp = pp_macro_expand($rest, $pp_macros, 0, 0, $filename, $cflinenum, 1, 0, $used_macros, 0);
                            $rest = $tmp if defined($tmp) && $tmp ne '';
                        }
                    }
                    my $rc = istrue(exists($pp_macros->{$rest}));
                    $used_macros->{$rest}++;
                    $rc = 1 - $rc if $what eq 'ifndef';
                    unshift @pp_state, $pp_state[0] ? $rc : 0;
                    $pp_good[$#pp_state] = $pp_state[0];

                } elsif ($what eq 'else') {
                    shift @pp_state;
                    unshift @pp_state, $pp_good[$#pp_state + 1] == 0 ? $pp_state[0] : 0;
                    # Set this so that if someone puts _more_ else or elif
                    # blocks after that they don't get executed.
                    $pp_good[$#pp_state] = 1;

                } elsif ($what eq 'elif') {
                    # Evaluate the conditional to update $used_macros.
                    # Should be safe as no side-effects are allowed.
                    my $record_only = ($pp_good[$#pp_state] != 0 or $pp_state[1] == 0);
                    my $cond = eval_pp_conditional($rest, $pp_macros, $filename, $cflinenum, $used_macros, $record_only);

                    # Only use the return if no other blocks have been true
                    $pp_state[0] = $record_only ? 0 : $cond;
                    $pp_good[$#pp_state] = $pp_state[0] if (!$pp_good[$#pp_state]);

                } elsif ($what eq 'if') {
                    # Evaluate the conditional to update $used_macros.
                    # Should be safe as no side-effects are allowed.
                    my $cond = eval_pp_conditional($rest, $pp_macros, $filename, $cflinenum, $used_macros, !$pp_state[0]);

                    unshift @pp_state, $pp_state[0] ? $cond : 0;
                    $pp_good[$#pp_state] = $pp_state[0];
                }

                # If we're currently excluding lines, don't go any further in
                # order to avoid processing any directives that shouldn't be
                # seen.  Do run through macro expansion in order to update
                # $used_macros
                if (!$pp_state[0]) {
                    pp_macro_expand($cfline, $pp_macros, 0, 0, $filename, $cflinenum, 1, 0, $used_macros, 0);
                    goto NEXTLINE;
                }

                if ($what eq 'define') {
                    my ($symbol, $value) = $rest =~ m/(\S+)\s*(.*)/;
                    if (!defined($value) or ($value eq '')) {
                        $value = $EmptyButTrue::val;
                    } else {
                        my $tmpvalue = pp_macro_expand($value, $pp_macros, 1, 0, $filename, $cflinenum, 0, 0, $used_macros, 0);
                        # If the expanded value looks like something that
                        # isn't worth evaluating (i.e. a single word or a
                        # number), just return it.
                        if ($tmpvalue =~ /^(?:\w*$|[[:digit:].]+)$/) {
                            Log(85, "NOTICE: Skipping expression evaluation for '$symbol' on line $apparent_line of\n",
                                    "        $filename\n");
                            $value = $tmpvalue;
                        } else {
                            my $tryeval = pp_macro_expand($value, $pp_macros, 1, 0, $filename, $cflinenum, 0, 1, $used_macros, 0);
                            # Try to evaluate it.  If that fails, return the
                            # previously expanded version.
                            my ($expr_rc, $eval_rc) = safe_pp_eval($tmpvalue, $what);
                            if ($eval_rc) {
                                # Only log the failure if it isn't a
                                # 'subroutine dereference' problem -- that
                                # seems to usually be present when evaluating
                                # things not meant to be evaluated.
                                if (Log(86) or $eval_rc !~ /'subroutine dereference'/) {
                                    Log(85, "NOTICE: Expression evaluation for '$symbol' on line $apparent_line of\n",
                                        "        $filename failed.\n",
                                        "        Expression:     '$tmpvalue'\n",
                                        "        Returned value: '$expr_rc'\n",
                                        "        Eval returned:  '$eval_rc'\n");
                                }
                                $value = $tmpvalue;
                            } else {
                                Log(85, "NOTICE: Expression evaluation for '$symbol' on line $apparent_line of\n",
                                    "        $filename succeeded.\n",
                                    "        Expression:     '$tmpvalue'\n",
                                    "        Returned value: '$expr_rc'\n");
                                $value = $expr_rc;
                            }
                        }
                    }

                    # Restrict macro names to alphanumerics
                    if ($symbol !~ /^[A-Za-z0-9_-]+$/) {
                        Log(100, "\n",
                            "*************************************************************************\n",
                            "  ERROR: Macro names may contain only alphanumeric characters, underscores,\n",
                            "         and hyphens.\n",
                            "         Bad macro name \"$symbol\" on line $apparent_line of\n",
                            "         $filename\n",
                            "*************************************************************************\n",
                            "\n");
                        do_exit(1);
                    }

                    if ($symbol =~ m/^%\{(.*)\}$/) {
                        $symbol = $1;
                        Log(100, "Notice: Macro names should not be enclosed in '%{}' for definition.\n");
                        Log(100, "        Attempting to do the right thing on line $apparent_line of $filename\n");
                    }

                    if (exists ($pp_macros->{$symbol})) {
                        Log(100, "WARNING: Redefinition of preprocessor macro '$symbol' on line $apparent_line\n         of $filename\n");
                    }
                    $pp_macros->{$symbol} = $value;
                    $used_macros->{$symbol}++;

                } elsif ($what eq 'undef') {
                    if ($rest =~ /%\{/) {
                        # Run it through macro expansion to get the symbol to
                        # undefine
                        my $orig = $rest;
                        $rest = pp_macro_expand($rest, $pp_macros, 0, 0, $filename, $cflinenum, 1, 0, $used_macros, 0);
                        $rest = $orig unless (defined($rest) && $rest ne '');
                        Log(15, "Macro undef: \"$orig\" expanded to \"$rest\"\n");
                    }
                    if (exists ($pp_macros->{$rest})) {
                        delete $pp_macros->{$rest};
                        $used_macros->{$rest}++;
                    } else {
                        Log(100, "ERROR: Can't undefine nonexistent symbol '$rest' on line $apparent_line\n       of $filename\n");
                    }
                } elsif ($what eq 'error' or $what eq 'warning'
                        or $what eq 'inform' or $what eq 'info'
                        or $what eq 'dumpmacros') {
                    $what =~ s/inform/info/i;
                    local $Text::Wrap::columns = 72;
                    local $Text::Wrap::huge = 'overflow';
                    my @msgs;
                    if ($what eq 'dumpmacros') {
                        $Text::Wrap::columns = undef;
                        push @msgs, map { "$_: '".$pp_macros->{$_}."'" } sort grep { !/^ENV_/ } keys %$pp_macros;
                        if ($rest eq 'all') {
                            push @msgs, map { "$_: '".$pp_macros->{$_}."'" } sort grep { /^ENV_/ } keys %$pp_macros;
                        }
                        $what = 'dbg';
                    } else {
                        push @msgs, pp_macro_expand($rest, $pp_macros, 0, 0, $filename, $cflinenum, 1, 0, $used_macros, 0);
                    }
                    my $msgprefix = uc("  $what: ");
                    my $indent    = ' ' x length($msgprefix);
                    my $location  = "line $apparent_line of $filename";
                    my $starbar   = '';   # No stars at all for INFO lines
                    if ($what eq 'error' or $what eq 'warning') {
                        $starbar = "\n".('*' x (($what eq 'error') ? $Text::Wrap::columns : 3))."\n";
                    }
                    foreach my $msg (@msgs) {
                        if ($msg eq '') {
                            $msg = "$msgprefix on $location\n";
                        } elsif ($what eq 'error' or $what eq 'warning') {
                            # Only output location info for errors and warnings
                            if ($msg =~ m/[!.?]\s*$/) {
                                # Make the location a parenthetical if the message
                                # looks like a completed sentence.
                                $msg .= "\n(From $location.)";
                            } else {
                                # Otherwise, maybe just complete the sentence.
                                $msg .= " on $location.";
                            }
                        }
                        $msg = defined($Text::Wrap::columns) ? Text::Wrap::wrap($msgprefix, $indent, $msg) : $msgprefix.$msg;
                        # Do not output the message to the screen for runs
                        # started after preenv setup. (Messages will have
                        # been printed when the main runcpu initially read
                        # the config file.)
                        Log(($::from_runcpu == 2) ? 199 : 100, $starbar . $msg . $starbar . "\n");
                    }
                    do_exit(1) if $what eq 'error';
                } elsif ($what eq 'dbgstop') {
                    $DB::single = $DB::signal = 1;
                }

                # We've handled the preprocessor directive; start over.
                goto NEXTLINE;

            # Complain about unknown directives, not macro expansions
            } elsif ($cfline !~ /^%\s*\{/) {
                $cfline =~ m/^(%\s*\S+)/o;
                Log(100, "ERROR: Unknown preprocessor directive: \"$1\" on line $apparent_line\n");
                Log(100, "       of $filename\n");
                do_exit(1);
            }
        }
        elsif ($cfline =~ m/^\s+%\s*(${pp_directive_re})/o) {
            Log(100, "\nWARNING: Ignoring preprocessor directive \"$1\" with leading whitespace\n");
            Log(100, "         on line $apparent_line of $filename.\n\n");
        }

        # Here's the main place where we skip stuff if we're in an
        # exclusionary block.
        if (!$pp_state[0] && !$hashmode) {
            goto NEXTLINE;
        }

        # Expand any macros that may be present
        if (!$hashmode) {
            $cfline = pp_macro_expand($cfline, $pp_macros, 0, 0, $filename, $cflinenum, 1, 0, $used_macros, (!istrue($me->preenv) and $cfline =~ /^\s*preENV_/));
            my $tmpstr = $cfline;
            my $cnt = $tmpstr =~ tr/\015\012//d;
            $tmpstr .= $trimmedcomment;
            # Put "comments" back on notes lines
            if ($cfline =~ /^$::mpi_desc_re_id?notes/io) {
                $cfline .= $trimmedcomment;
            }
            if ($cfline =~ m/^\s*include:\s*\S+\s*$/i) {
                $tmpstr = "#$tmpstr";
            }
            push @{$me->{'pptxtconfig'}}, $tmpstr;
            push @{$me->{'pptxtconfig'}}, '' if $cnt;
        }

        # Handle <<EOT type blocks in config file
        if (defined $blockquote) {
            if ($cfline eq $blockquote) {
                undef $blockquote;
            } elsif ($first_blockquote) {
                map { $$_ .= $cfline } @lastrefs;
                $first_blockquote=0;
            } else {
                map { $$_ .= "\n$cfline" } @lastrefs;
            }

            # Handle continued lines with '\' at end of line
        } elsif ($continued) {
            $continued = 0;
            $appended = 1 if ($cfline =~ s/\\\\$//);
            $continued = 1 if ($cfline =~ s/\\$//);
            foreach my $lastline (@lastrefs) {
                if ($$lastline ne '') {
                    $$lastline .= "\n$cfline";
                } else {
                    # Don't prepend a newline to empty lines
                    $$lastline .= $cfline;
                }
            }

            # Handle appended lines with '\\' at end of line
        } elsif ($appended) {
            $cfline =~ s/^\s+//;
            $appended = 0;
            $appended = 1 if ($cfline =~ s/\\\\$//);
            $continued = 1 if ($cfline =~ s/\\$//);
            foreach my $lastline (@lastrefs) {
                if ($$lastline ne '') {
                    $$lastline .= " $cfline";
                } else {
                    # Don't prepend a space to empty lines
                    $$lastline .= $cfline;
                }
            }
            # Fix up the lines that were just present; doing this here
            # avoids lots of nastiness in the raw file parser.
            foreach my $list (qw(pptxtconfig rawtxtconfig rawtxtconfigall)) {
                pop @{$me->{$list}};
                if ($me->{$list}->[$#{$me->{$list}}] ne '') {
                    $me->{$list}->[$#{$me->{$list}}] .= " $cfline";
                } else {
                    # Don't prepend a space to empty lines
                    $me->{$list}->[$#{$me->{$list}}] .= $cfline;
                }
            }

            # Include a file
        } elsif (($include) = $cfline =~ m/^\s*include:\s*(\S+)\s*$/i) {
            if ($include =~ m/\$[\[\{]([^\}]+)[\}\]](\S*)\s*$/) {
                my ($tmpname, $rest) = ($1, $2);
                $include = $me->{$tmpname}.$rest;
            }
            @{$opts{'reflist'}} = @reflist;
            @{$opts{'curr_sections'}} = @curr_sections;
            %{$opts{'seen_labels'}} = %seen_labels;
            %{$opts{'sections'}} = %sections;
            %{$opts{'fixup_needed'}} = %fixup_needed;
            %{$opts{'seen_oldfields'}} = %seen_oldfields;
            if (! $me->merge($include, " ----- Begin inclusion of '$include'",
                    $pp_macros, %opts)) {
                Log(100, "Can't include file '$include'\n");
                do_exit(1);
            }
            @reflist = @{$opts{'reflist'}};
            @curr_sections = @{$opts{'curr_sections'}};
            %seen_labels = %{$opts{'seen_labels'}};
            %sections = %{$opts{'sections'}};
            %fixup_needed = %{$opts{'fixup_needed'}};
            %seen_oldfields = %{$opts{'seen_oldfields'}};

            # Check to see if the line is in the form of x=x=x=x:
            # if so, then emit an error as 'mach' is no longer A Thing
        } elsif ($cfline =~
            m/^(\s*[^\#=\s]+=[^=\s]+=[^=\s]+)=([^=\s]+):\s*$/o) {
            push @{$seen_machs{$2}->{$1}->{$filename}}, $apparent_line;

            # Check to see if the line is in the form of x=x=x: or some subset.
            # if so, then point the working reference pointer at that data.
            # Assume that multiple trailing colons are a typo.
        } elsif ((@vals) = $cfline =~
            m/^\s*([^\#=\s]+?)(?:=([^=\s]+?))?(?:=([^=\s]+?))?:+\s*$/o) {
            for (my $i = 0; $i < 3; $i++) {
                if (!defined($vals[$i]) or $vals[$i] =~ /^:*$/) {
                    $vals[$i] = [ 'default' ];
                    $sections{'default'}++;
                } elsif ($vals[$i] =~ /:/o) {
                    Log(100, "':' is not allowed in a section name:\n '$vals[$i]' in '$cfline'\n");
                    $vals[$i] =~ s/://go;
                    $vals[$i] = [ $vals[$i] ];
                } elsif ($vals[$i] =~ /,/o) {
                    # Handle multiple values, and make sure they're unique
                    $vals[$i] = [ uniq(map { (defined($_) && ($_ ne '')) ? $_ : 'default' } split(/,/, $vals[$i])) ];
                } else {
                    $vals[$i] = [ $vals[$i] ];
                }
            }
            my ($bench, $tune, $label) = @vals;
            @reflist = ();
            @curr_sections = ();
            foreach my $tb (@$bench) {
                $sections{$tb}++;
                if (!grep { $tb eq $_ } @bmlist) {
                    next if $hashmode;
                    Log(100, "ERROR: Unknown benchmark \'$tb\' specified on line $apparent_line\n       of $filename");
                    if (istrue($me->{'section_specifier_fatal'}) &&
                        !istrue($me->ignore_errors)) {
                        Log(100, "\n");
                        do_exit(1);
                    } else {
                        Log(100, "; ignoring\n");
                        $::keep_debug_log = 1;
                        next;
                    }
                }
                foreach my $tt (@$tune) {
                    $sections{$tt}++;
                    if (!grep { $tt eq $_ } @tunelist) {
                        next if $hashmode;
                        Log(100, "ERROR: Unknown tuning level \'$tt\' specified on line $apparent_line\n       of $filename");
                        if (istrue($me->{'section_specifier_fatal'})) {
                            Log(100, "\n");
                            do_exit(1);
                        } else {
                            Log(100, "; ignoring\n");
                            next;
                        }
                    }
                    foreach my $te (@$label) {
                        $seen_labels{$te}++;
                        $sections{$te}++;
                        if ($tb eq 'default' and $tt eq 'default' and $te eq 'default') {
                            # Global settings are stored in the top level, so
                            # no need to make a ref tree or add refs to $me
                            # (since a thing always has itself as a reference)
                            unshift @reflist, $me; # Make sure it's always first
                        } else {
                            $me->ref_tree(basename(__FILE__).':'.__LINE__,
                                          [$tb],[$tt],[$te]);
                            add_refs($me, $tb, $tt, $te);
                            push @reflist, $me->{$tb}{$tt}{$te};
                        }
                        push @curr_sections, "${tb}=${tt}=${te}";
                    }
                }
            }

            # Named pairs to current working reference
            # "src.alt" gets a special mention because I don't want to allow
            # periods in all variable names.
        } elsif (($name, $op, $value) = $cfline =~ m/^\s*([A-Za-z0-9_]+|src\.alt)\s*(\+\=|\=)(.*)/) {
            my $nonumname = $name;
            $nonumname =~ s/_?\d+$//;
            $nonumname =~ s/^(preENV_).*/$1/;

            # Fix up special cases
            if    ($name eq 'src.alt')   { $name = 'srcalt';   }
            elsif ($name eq 'envvars')   { $name = 'env_vars'; }
            elsif ($name eq 'pre_env')   { $name = 'preenv';   }
            elsif ($name eq 'verbosity') { $name = 'verbose';  }

            if ($op eq '+=' && ($name =~ /$::info_re/ ||
                    defined($::default_config->{$name}) ||
                    defined($::nonvolatile_config->{$name}) ||
                    $name =~ /submit|bind|srcalt|power_analyzer|temp_meter|notes/)
            ) {
                ::Log(0, "ERROR: Concatenation (+=) is not allowed for \"$name\" on line $apparent_line\n         of $filename. \n");
                do_exit(1);
            }

            $variables{$name}++;
            # Check for and remove nonvolatile config options if necessary
            # Just in case there has been an oversight and a nonvolatile
            # option has been inserted into the list of command line options,
            # throw it out and issue a warning.
            if (exists($::nonvolatile_config->{$nonumname})) {
                Log(100, "WARNING: The value for \"$name\" is immutable.  Illegal attempt to change\n         it on line $apparent_line of $filename; ignoring\n");
                goto NEXTLINE;
            }

            # Ditto for internal stuff
            if (exists($::reserved_words{$nonumname}) ||
                $name =~ /^cfidx_/) {
                Log(100, "WARNING: \"$name\" is reserved for use by runcpu.\n         Ignoring contents of line $apparent_line in $filename\n");
                goto NEXTLINE;
            }

            # Not-so-quietly ignore settings for test_date; it's now set
            # automatically, but may be edited in the raw file.
            if ($nonumname eq 'test_date') {
                Log(100, "WARNING: The value for \"test_date\" is set automatically from the system\n");
                Log(100, "         clock.  If necessary, the value may be changed in the raw file after\n");
                Log(100, "         the run.\n");
                Log(100, "        The settings on line $apparent_line of $filename\n");
                Log(100, "         will be ignored.\n");
                goto NEXTLINE;
            }

            # Not-so-quietly ignore settings for sw_auto_parallel; it's now set
            # automatically, and no longer appears in the raw file
            if (   $::lcsuite ne 'mpi2007'
                && $nonumname eq 'sw_auto_parallel') {
                Log(100, "WARNING: The field \"sw_auto_parallel\" has been retired.  Please see \n\n");
                Log(100, "              https://www.spec.org/$::lcsuite/Docs/config.html#parallelreporting\n\n");
                Log(100, "         for more information on how to indicate whether\n");
                Log(100, "         or not parallelism was active for the run.\n");
                Log(100,"        The settings on line $apparent_line of $filename\n         will be ignored.\n");
                goto NEXTLINE;
            }

            # Don't allow the user to set NC-related variables in the config
            # file.
            if ($nonumname =~ /^(nc\d*|nc_is(?:cd|na))$/) {
                Log(100, "ERROR: You may not set reasons for non-compliance, non-availability, or\n");
                Log(100, "       code defect in the config file.  The setting for \"$name\" on\n");
                Log(100, "       line $apparent_line of $filename will be ignored\n");
                goto NEXTLINE;
            }

            # Somewhat quietly ignore notes lines that look like they might be
            # from sysinfo (if there's no chance that they weren't)
            if ($sysinfo_run < 0
                    and $name =~ /^(notes\S*_sysinfo)(?:_?\d*)$/) {
                if (!exists($griped{$1})) {
                    Log(100, "ERROR: Notes lines that are marked as coming from sysinfo_program output\n");
                    Log(100, "       may not be set by hand.  The setting for \"$1\" on\n");
                    Log(100, "       line $apparent_line of $filename will be ignored\n");
                }
                $griped{$1}++;
                goto NEXTLINE;
            }

            # Check for and remove options that must be set in the header
            # section, unless one of the current refs is
            # default=default=default, in which case silently put it
            # in the header section and ignore the others.
            if ("@curr_sections" ne 'header'
                and (exists($::header_only{$name})
                    or exists($::header_only{$nonumname}))) {
                if (grep { /^default=default=default$/ } @curr_sections) {
                    if (@curr_sections > 1) {
                        # Temporarily set the whole reflist to just the top-level
                        $promote_to_header = 1;
                        @tmpreflist = @reflist;
                        @reflist = ( $me );
                    }
                } else {
                    Log(100, "\nWARNING: \"$name\" may be set only in the header section of the config file.\n");
                    if (@curr_sections > 1) {
                        Log(100, "  Current sections are ".join("\n                       ", @curr_sections)."\n");
                    } else {
                        Log(100, "  Current section is $curr_sections[0]\n");
                    }
                    Log(100, "Ignoring the setting on line $apparent_line of $filename.\n\n");
                    sleep 3;
                    goto NEXTLINE;
                }
            }

            # Note use of deprecated or obsolete fields
            if (exists($::deprecated_config{$nonumname}) or exists($::deprecated_config{$name})) {
                push @{$seen_oldfields{'deprecated'}->{$nonumname}->{$filename}}, $apparent_line;
            }
            if (exists($::obsolete_config{$nonumname}) or exists($::obsolete_config{$name})) {
                push @{$seen_oldfields{'obsolete'}->{$nonumname}->{$filename}}, $apparent_line;
            }

            # Everything except notes should have leading whitespace removed
            $value =~ s/^\s*//o unless ($name =~ /^$::mpi_desc_re_id?notes/io);

            # If it is the special case %undef% then remove the specified keys
            # from the working reference and replace them with the special
            # %undef% tag to block down-tree references
            if ($value =~ m/^\s*%undef%\s*$/io) {
                foreach my $ref (@reflist) {
                    for my $key (find_keys($ref, $name)) {
                        if (exists($ref->{$key})) {
                            delete $ref->{$key};
                            $ref->{$key} = '%undef%';
                        }
                    }
                    $ref->{$name} = '%undef%';
                }
            } elsif (!$hashmode &&
                ($name eq 'opthash' || $name eq 'exehash' ||
                    $name eq 'compile_options' || $name eq 'baggage' ||
                    $name eq 'raw_compile_options' or $name eq 'compiler_version')) {
                goto NEXTLINE; # We don't allow overwriting the stored hashes
            } elsif ($name eq 'rawtxtconfig' || $name eq 'rawtxtconfigall' ||
                $name eq 'pptxtconfig' || $name =~ /^cfidx_/) {
                goto NEXTLINE; # We don't allow overwriting the stored configs

            } elsif ($name =~ /^hw_ncpu$/) {
                # hw_ncpu is special because it's likely to appear in
                # (old) config files, but we construct it from other
                # things, so it should be ignored.
                ::Log(0, "\nWARNING: hw_ncpu setting on line $apparent_line of\n");
                ::Log(0, "         $filename is ignored.\n");
                ::Log(0, "         Please set values individually using hw_nchips, hw_ncores,\n");
                ::Log(0, "         and hw_nthreadspercore.\n\n");

            } else {


                if ($value=~ s/^\s*<<\s*(\S+)\s*$//) {
                    $blockquote = $1;
                    $first_blockquote = 1;
                    $value = '';
                } elsif ($value=~ s/\\\\\s*$//) {
                    $appended  = 1;
                    # Trim this from the saved line as well.
                    foreach my $list (qw(pptxtconfig rawtxtconfig rawtxtconfigall)) {
                        $me->{$list}->[$#{$me->{$list}}] =~ s/\\\\\s*$//;
                    }
                } elsif ($value=~ s/\\\s*$//) {
                    $continued  = 1;
                }

                if ($name eq 'label') {
                    # Check that the label doesn't contain any illegal
                    # characters, which as far as we know are :, =, and
                    # whitespace
                    if ($value =~ /[,:=\s]/) {
                        Log(100, "ERROR: label value contains ':', '=', or whitespace on line $apparent_line\n       of $filename\n");
                        do_exit(1);
                    }
                    # Mark it down as 'seen'
                    $seen_labels{$value}++;
                }

                @lastrefs = ();
                foreach my $ref (@reflist) {

                    if ($name =~ /^ ?(bind|srcalt|power_analyzer|temp_meter)(\d*)$/) {
                        my ($base, $idx) = ($1, $2);
                        # Keep track of which refs need fixups, and
                        # also which line numbers the settings came
                        # from.  This is to allow "overwrite" warnings
                        # if necessary.
                        $name = " $base" if ($idx eq '');
                        $fixup_needed{$base}->{$ref}->{'ref'} = $ref;
                        push @{$fixup_needed{$base}->{$ref}->{'pairs'}}, [ $name, $filename, $cflinenum ];
                    }

                    if ($name eq 'submit') {
                        # This'll get fixed up later
                        $name = 'submit_default';
                    }

                    # Deal with the order for MPI stuff
                    if ($name =~ /^$::mpi_desc_re/) {
                        my ($type, $which) = ($1, $2);
                        if (!exists($ref->{"${type}_${which}_order"})) {
                            $ref->{"${type}_${which}_order"} = 0;
                        }
                    }

                    if ($op eq '+=') {
                        if (defined($ref->{$name})) {
                            if ((::ref_type($ref->{$name}) eq 'HASH') && $ref->{$name}->{'op'} eq '+=') {
                                $ref->{$name}->{value} .= " $value";
                            } else {
                                $ref->{$name} .= " $value";
                            }
                        } else {
                            $ref->{$name} = {};
                            $ref->{$name}->{'value'} = $value;
                            $ref->{$name}->{'op'} =  '+=';
                        }
                    } else {
                        $ref->{$name} = $value;
                    }
                    if ($name =~ /$::info_re/) {
                        if (exists($ref->{'cfidx_'.$name})) {
                            if ($sysinfo_run < 0) {
                                ::Log(0, "WARNING: Duplicate setting for \"$name\" on line $apparent_line\n         of $filename\n");
                            } else {
                                push @{$sysinfo_dups{$name}}, $apparent_line;
                            }
                        }
                        $ref->{'cfidx_'.$name} = $#{$me->{'rawtxtconfig'}};
                    }
                    push @lastrefs, \$ref->{$name};

                    if ($promote_to_header) {
                        # Remove the temporary override of the reflist
                        @reflist = @tmpreflist;
                        $promote_to_header = 0;
                    }
                }
            }
        } elsif (!$appended && !$continued && !defined($blockquote) &&
            $cfline !~ /^\s*$/) {
            ::Log(0, "Notice: Ignored non-comment line in file $filename:\n  line $apparent_line: \"$cfline\"\n");
        }

        NEXTLINE:
        $cfline = shift(@cflines);
        $cflinenum++;
        if (!$included
                and !defined($cfline)
                and $me->action ne 'configpp'
                and $sysinfo_run < 0
                and (!istrue($me->preenv) or $me->get_all_preenv() == 0)) {
            # We're to the end of the file... is there a sysinfo program?
            my ($sysinfo, $sysinfo_hash, @tmplines) = $me->get_sysinfo();
            $me->{'sysinfo_program'} = $sysinfo;
            $me->{'sysinfo_program_hash'} = $sysinfo_hash;
            $saved_filename = $filename;
            $filename = 'sysinfo output';
            if (@tmplines) {
                $sysinfo_lines = $#tmplines+2;      # Account for the \n we add
                $sysinfo_run = $cflinenum;
                unshift @cflines, "\n", @tmplines;
                goto NEXTLINE;
            } else {
                $sysinfo_run = $sysinfo_lines = 0;
            }
        }
        if ($sysinfo_run
                and $saved_filename ne ''
                and $cflinenum >= $sysinfo_run + $sysinfo_lines) {
            $filename = $saved_filename;
            $saved_filename = '';
        }
    }

    if ($sysinfo_run >= 0) {
        if (%sysinfo_dups) {
            if (0) {
                # Long form output, with probably useless line numbers
                my @dupnames = sort { length($b) <=> length($a) } keys %sysinfo_dups;
                my $namelen = length($dupnames[0]);
                $namelen = 10 unless $namelen >= 10;
                ::Log(0, "\n\nWARNING: Your config file sets some fields that are also set by sysinfo.\n");
                ::Log(0, sprintf "\t%*s\tsysinfo output line\n", -$namelen, "Field name");
                ::Log(0, sprintf "\t%*s\t-------------------\n", -$namelen, "----------");
                foreach my $dupname (sort @dupnames) {
                    ::Log(0, sprintf "\t%*s\t%s\n", -$namelen, $dupname, join(', ', @{$sysinfo_dups{$dupname}}));
                }
            } else {
                # Short form output; fields only
                ::Log(0, "\n\nWARNING: Your config file sets some fields that are also set by sysinfo:\n");
                foreach my $fieldlist (::wrap_lines([join(', ', sort keys %sysinfo_dups)], 73, '', 0, 1)) {
                    ::Log(0, "  $fieldlist\n");
                }
            }
            ::Log(0, "To avoid this warning in the future, see\n");
            ::Log(0, "  https://www.spec.org/$::lcsuite/Docs/config.html#sysinfo\n\n\n");
        }
        if (istrue($me->reportable) and $sysinfo_run == 0) {
            ::Log(0, "ERROR: The sysinfo_program produced no output!\n"
                    ."       A working sysinfo_program is required for reportable runs.  Please contact\n"
                    ."       ${main::lcsuite}support\@spec.org for assistance.\n");
            ::do_exit(1);
        }
    }

    if ($blockquote) {
        ::Log(0, "ERROR: Unterminated block quote in $filename; '$blockquote' not found\n");
        ::do_exit(1);
    }

    if ($included) {
        my $eos = "# ---- End inclusion of '$filename'";
        push @{$me->{'rawtxtconfigall'}}, $eos;
        push @{$me->{'rawtxtconfig'}}, $eos;
        push @{$me->{'pptxtconfig'}}, $eos;
    } else {
        # Fix up items that become lists.  This includes srcalt and bind.
        # The idea is to walk through the elements that WOULD contribute to
        # the single value.  In these cases, they can be set all at once (as in
        # "bind = 1 2 4 foo"), or one by one (as in "bind0 = 1; bind1 = 2").
        # The objective is to end up with one element per ref, which will be
        # an array, and with all of the "contributing" items and their cfidx
        # deleted.
        if (exists($fixup_needed{'srcalt'})) {
            # srcalt is special because it's allowed to be
            # implicitly or explicitly multi-valued, and all values for a
            # particular section must be unique.
            foreach my $section (keys %{$fixup_needed{'srcalt'}}) {
                # Go through each key that was added and apply it to the
                # final value.
                my $ref = $fixup_needed{'srcalt'}->{$section}->{'ref'};
                my $final = undef;
                $final = $ref->{'srcalt'} if (::ref_type($ref->{'srcalt'}) eq 'ARRAY');
                my %kill_keys = ();
                foreach my $pair (@{$fixup_needed{'srcalt'}->{$section}->{'pairs'}}) {
                    my ($name, $file, $line) = @{$pair};
                    my $value = $ref->{$name};
                    $value =~ s/^\s+//;
                    $kill_keys{$name} = 1;

                    my @srcalts = grep { defined && !/%undef%/i } split(/[\s,]+/, $value);
                    undef $final if ($value =~ /%undef%/i);
                    if (!defined($final) || (::ref_type($final) ne 'ARRAY')) {
                        $final = [];
                    }
                    my %seensrcalts = map { $_ => 1 } @{$final};
                    foreach my $srcalt (@srcalts) {
                        next if $seensrcalts{$srcalt}++;
                        push @{$final}, $srcalt;
                    }
                }
                foreach my $key (keys %kill_keys) {
                    delete $ref->{$key};
                    delete $ref->{'cfidx_'.$key} if exists($ref->{'cfidx_'.$key});
                }
                $ref->{'srcalt'} = [ @{$final} ];   # Get a new ref
            }
        }

        # See the comments before the 'srcalt' block above to find out what's
        # going on here.
        foreach my $thing ('bind', 'power_analyzer', 'temp_meter') {
            # These things are special because they're allowed to be
            # implicitly or explicitly multi-valued, and order is important.
            if (exists($fixup_needed{$thing})) {
                my %change_count;
                foreach my $section (keys %{$fixup_needed{$thing}}) {
                    # Go through each key that was added and apply it to the
                    # final value.
                    my $ref = $fixup_needed{$thing}->{$section}->{'ref'};
                    my $final = undef;
                    $final = $ref->{$thing} if (::ref_type($ref->{$thing}) eq 'ARRAY');
                    my %kill_keys = ();
                    foreach my $pair (@{$fixup_needed{$thing}->{$section}->{'pairs'}}) {
                        my ($name, $file, $line) = @{$pair};
                        my $value = $ref->{$name};
                        $kill_keys{$name} = 1;
                        my $idx = undef;
                        if ($name =~ /^(?:power_analyzer|temp_meter|bind)(\d+)/) {
                            $name = $thing;
                            $idx = $1;
                        }
                        $change_count{$section}++;

                        if (!defined($idx) || $idx eq '') {
                            # Implicitly multi-valued
                            $value =~ s/^\s+//;
                            my @values = split(/[\n\s,]+/, $value);
                            ::Log(0, "Notice: $thing setting on line $line of $file\n        will override previously set value\n") if ($change_count{$section} > 1);
                            $final = [ @values ];
                        } else {
                            $idx = $idx + 0;    # Make it a proper number
                            $final->[$idx] = $value;
                        }
                    }
                    foreach my $key (keys %kill_keys) {
                        delete $ref->{$key};
                        delete $ref->{'cfidx_'.$key} if exists($ref->{'cfidx_'.$key});
                    }
                    $ref->{$thing} = [ @{$final} ];   # Get a new ref
                }
            }
        }

        # Make sure all of the benchmark sections have 'refs'
        foreach my $tb (@bmlist) {
            next unless ($sections{$tb}
                    and exists($me->{$tb})
                    and ref($me->{$tb}) eq 'HASH');
            my $ref = $me->{$tb};
            foreach my $tt (sort keys %{$ref}) {
                next unless ($sections{$tt}
                        and exists($ref->{$tt})
                        and ref($ref->{$tt}) eq 'HASH');
                $ref = $ref->{$tt};
                foreach my $te (sort keys %{$ref}) {
                    next unless ($sections{$te}
                            and exists($ref->{$te})
                            and ref($ref->{$te}) eq 'HASH');
                    if ($tb ne 'default' or $tt ne 'default' or $te ne 'default') {
                        # Global settings are stored in the top level, so
                        # no need to make a ref tree or add refs to $me
                        # (since a thing always has itself as a reference)
                        add_refs($me, $tb, $tt, $te);
                    }
                }
            }
        }

#       $me->dumpconf('initial_config'); exit;
        $me->expand_vars();

        # And make sure that the flagsurl is set properly
        if (   exists($me->{'flagsurl'})
            && (::ref_type($me->{'flagsurl'}) ne 'ARRAY')
            && $me->{'flagsurl'} ne '') {
            $me->{'flagsurl'} = [ $me->{'flagsurl'} ];
        } else {
            $me->{'flagsurl'} = [ ];
        }
        # Process flags URLs in reverse order so that multiples specified on
        # the same line will end up in the right order (and not overwritten
        # by later settings)
        my %flagsurl_seen = ();
        my @flagsurls = ();
        foreach my $item (reverse sort ::bytrailingnum grep { /^flagsurl\d*$/ } keys %{$me}) {
            my ($idx) = ($item =~ m/^flagsurl(\d*)$/);
            my @urls = grep { $_ ne '' and !exists($flagsurl_seen{$_}) } split(/[,\s]+/, join(',', ::allof($me->{$item})));
            if (@urls) {
                if (@flagsurls < $idx) {
                    # Grow the array if necessary
                    $flagsurls[$idx] = undef;
                }
                @flagsurl_seen{@urls}++;
                splice(@flagsurls, $idx, 1, @urls);
            }
        }
        $me->{'flagsurl'} = [ @flagsurls ];
        ::squeeze_undef($me->{'flagsurl'});

#       $me->dumpconf('expanded_config'); exit;

    }

    # Check for conflicts between variable names (including nonvolatile
    # and default config) and section names.  First, the stuff we know about:
    my $conflicts = '';
    foreach my $section (sort keys %sections) {
        if (exists($::nonvolatile_config->{$section})) {
            $conflicts .= " Section name '$section' (".pluralize($sections{$section}, 'occurrence').")\n  conflicts with the name of a non-volatile variable.\n";
        } elsif (exists($::default_config->{$section})) {
            $conflicts .= " Section name '$section' (".pluralize($sections{$section}, 'occurrence').")\n  conflicts with the name of a default variable.\n";
        } elsif (exists($variables{$section})) {
            $conflicts .= " Variable name '$section' (".pluralize($variables{$section}, 'occurrence').")\n  conflicts with section name (".pluralize($sections{$section}, 'occurrence').")\n";
        }
    }
    if ($conflicts ne '') {
        Log(100, "ERROR:  Variable/section name conflicts detected:\n\n");
        Log(100, $conflicts);
        $do_croak = 1;
    }

    if ($included) {
        # Put the opts back
        @{$opts{'reflist'}} = @reflist;
        @{$opts{'curr_sections'}} = @curr_sections;
        %{$opts{'seen_labels'}} = %seen_labels;
        %{$opts{'sections'}} = %sections;
        %{$opts{'fixup_needed'}} = %fixup_needed;
        %{$opts{'seen_oldfields'}} = %seen_oldfields;
        # Without this, multiple inclusion of the same file will fail.
        pop @{$me->{'files_read'}};
    } else {
        # Make the stored config texts back into strings
        foreach my $list (qw(pptxtconfig rawtxtconfig rawtxtconfigall)) {
            my $tmp = join("\n", @{$me->{$list}})."\n";
            $me->{$list} = $tmp;
        }

        # Store away the list of seen labels
        $me->{'seen_labels'} = \%seen_labels;

        # Add the list of config files seen to the list of files read
        map { delete $me->{'config_inc'}->{$_} } @{$me->{'files_read'}};
        push @{$me->{'files_read'}}, sort keys %{$me->{'config_inc'}};
        delete $me->{'config_inc'};

        if (%seen_oldfields) {
            # Gripe about deprecated/obsolete fields and then croak
            ::Log(0, "\nERROR: ".lcfirst(join(' and ', sort keys %seen_oldfields))." fields were found while reading the config file:\n");
            foreach my $type (sort keys %seen_oldfields) {
                foreach my $field (sort keys %{$seen_oldfields{$type}}) {
                    ::Log(0, "\t'${field}' ($type) seen in\n");
                    foreach my $file (sort keys %{$seen_oldfields{$type}->{$field}}) {
                        my @linenums = @{$seen_oldfields{$type}->{$field}->{$file}};
                        ::Log(0, "\t\t$file line".(@linenums > 1 ? 's ' : ' ').join(', ', @linenums)."\n");
                    }
                }
            }
            $do_croak = 1;
        }

        # Warn about command-line macros that were never used or referenced
        my @unused = sort grep { !exists($used_macros->{$_}) } keys %$pp_macros;
        foreach my $symbol (@unused) {
            Log(100, "WARNING: The preprocessor macro '$symbol' was defined on the\n".
                     "         command line but never referenced in the config file.\n");
        }

    }

    if (%seen_machs) {
        foreach my $mach (sort keys %seen_machs) {
            foreach my $section (sort keys %{$seen_machs{$mach}}) {
                foreach my $fname (sort keys %{$seen_machs{$mach}->{$section}}) {
                    my @lines = @{$seen_machs{$mach}->{$section}->{$fname}};
                    $section =~ s/(?:=default)*$//;
                    Log(100, "\nERROR: Obsolete machine type '$mach' found in section specifier\n");
                    Log(100, "       on ".($#lines ? 'lines' : 'line')." ".join(', ', @lines)." of $fname\n");
                    if ($mach eq 'default') {
                        Log(100, "       Change ".($#lines ? 'those lines' : 'that line')." to\n");
                        Log(100, "           $section:\n");
                        Log(100, "       in $fname.\n");
                    }
                    $do_croak = 1;
                }
            }
        }
    }

    $fh->close();

    do_exit(1) if $do_croak;

    if (@pp_state > 1) {
        Log(100, "ERROR: Unbalanced %if .. %endif in $filename\n");
        do_exit(1);
    }

    # A little insurance to make sure that all global settings are directly
    # in $me
    if (exists($me->{'default'})
            and exists($me->{'default'}{'default'})
            and exists($me->{'default'}{'default'}{'default'})) {
        if (::ref_type($me->{'default'}{'default'}{'default'}) eq 'HASH'
                and keys %{$me->{'default'}{'default'}{'default'}} > 0) {
            Log(100, "\nERROR: Internal default=default=default section in $me is not empty:\n");
            Log(100, Data::Dumper->Dump([$me->{'default'}{'default'}{'default'}],['default-default-default:'])."\n");
            Log(100, "\nThis is an internal error.  Please report it to ${main::lcsuite}support\@spec.org, and include\n");
            Log(100, "the config file and runcpu command that you used.\n");
            do_exit(1);
        } else {
            delete $me->{'default'}{'default'}{'default'};
        }
    }

    1;
}

sub populate_predefined_pp_macros {
    my ($me, $pp_macros, $used_macros, $configs_read, $current_config) = @_;

    # It turns out that the list of stuff in the config object that's a
    # simple string and can't be set in the config file itself is small.
    # (Things that can be set in the config file can be referenced by
    # one of the many forms of variable interpolation that we have.)
    for my $thing (qw(
            OS
            configfile
            endian
            hostname
            max_report_runs
            min_report_runs
            os_exe_ext
            runcpu
            top
            uid
            username
            )) {
        my $val = $me->accessor_nowarn($thing);
        if (defined($val)) {
            $pp_macros->{$thing} = $val;
            $used_macros->{$thing}++;
        }
    }

    # How about some built-in Perl stuff?
    for my $thing (qw(PROGRAM_NAME PID UID EUID GID EGID OSNAME BASETIME)) {
        my $val = eval "use English '-no_match_vars'; return \$${thing}";
        if (defined($val)) {
            $pp_macros->{$thing} = $val;
        } else {
            $pp_macros->{$thing} = 'unknown';
        }
        $used_macros->{$thing}++;
    }

    # And things useful for informational messages
    $pp_macros->{'current_config_file'} = $current_config;
    $pp_macros->{'config_nesting_level'} = @$configs_read;
    $pp_macros->{'top_config_file'} = @$configs_read > 0 ? $configs_read->[0] : $current_config;
    $pp_macros->{'parent_config_file'} = @$configs_read > 0 ? $configs_read->[-1] : '';
    for my $thing (qw(
        current_config_file config_nesting_level
        top_config_file parent_config_file
    )) {
        $used_macros->{$thing}++;
    }
}

sub add_refs {
    my ($ref, $tb, $tt, $te) = @_;

    my $tmpref = $ref->{$tb}{$tt}{$te};
    if (exists($tmpref->{'refs'})) {
#       print "add_refs: refs for $tb:$tt:$te already exist:\n";
#       dumpconf($tmpref);
        return;
    }

    my @sets = $ref->benchmark_in_sets(undef, $tb);
    unshift @sets, 'default' unless grep { $_ eq 'default' } @sets;
    my @tunes  = ('default');
    my @labels = ('default');

    push @sets,   $tb if $tb ne 'default';
    push @tunes,  $tt if $tt ne 'default';
    push @labels, $te if $te ne 'default';

    # Set up refs so that variable interpolation can be
    # performed.  This value will be blown away after
    # variable expansion so that there's no danger of
    # using a local copy of refs to get back to the
    # data in global_config.
    $tmpref->{'ref_added'} = basename(__FILE__).':'.__LINE__;
    $tmpref->{'refs'} = [
        $tmpref,
        reverse ($ref,
                 $ref->ref_tree(basename(__FILE__).':'.__LINE__,
                                [ @sets    ],
                                [ @tunes   ],
                                [ @labels  ],
                            )
                )
        ];
}

sub expand_vars {
    # This handles the first pass of runcpu variable substitution (aka
    # "square bracket" substitution).  The work is done in config_var_expand().
    my ($me) = @_;

    return if ref($me) !~ /^(?:HASH|Spec::Config)$/;

    # At this point, all of the sections' refs fields are filled in... do
    # the promised expansion
    foreach my $member (sort keys %{$me}) {
        # There are some settings which should not have variable expansion
        # applied
        next if (exists($::nonvolatile_config->{$member}) ||
            $member =~ /(?:txtconfig$|^orig_|^ref|^bench(?:mark|set)s)/o);
        if (ref($me->{$member}) ne '') {
            if (ref($me->{$member}) eq 'HASH') {
                expand_vars($me->{$member});
                delete ($me->{$member}->{'refs'});
            }
        } else {
            $me->{$member} = config_var_expand($me->{$member}, $me, 1);
        }
    }
}

sub eval_pp_conditional {
    my ($text, $macros, $file, $linenum, $used_macros, $record_only) = @_;

    # Resolve the values of all the macros in the line.
    $text = pp_macro_expand($text, $macros, 0, 1, $file, $linenum, 0, 1, $used_macros, 0);
    return 0 if $record_only;

    # In a construction like
    #    %if defined(%{foo})
    # where 'foo' is undefined, the resulting expression is
    #    defined()
    # which Perl very much does not like.  So fix it up, like this:
    $text =~ s/defined\(\)/defined(undef)/g;

    if ($text ne '') {
        my ($expr_rc, $eval_rc) = safe_pp_eval($text, 'conditional');
        if ($eval_rc) {
            Log(100, "WARNING: Evaluation of expression on line $linenum of $file\n",
                     "         failed.\n",
                     "The failed expression was\n",
                     "  ($text)\n");
            if ($eval_rc =~ /'([^']+)' trapped by operation mask/) {
                Log(100, "An illegal operation ($1) was attempted.\n");
                do_exit(1);
            } else {
                Log(100, "The error message from the parser was: $eval_rc\n");
                do_exit(1);
            }
        }
        # Try to figure out if $rc is true or false.
        if (!defined($expr_rc) or ($expr_rc eq '') or ($expr_rc =~ /^[-+]?0+(?:\.0+)?$/)) {
            return 0;
        } else {
            return 1;
        }
    }

    return 0;
}

sub safe_pp_eval {
    my ($text, $elem) = @_;

    my $compartment = new Safe;
    $compartment->permit_only(qw(:base_core :base_math :base_loop rv2gv));
    # What we're really after here are the Perl math and boolean operations
    # There MAY be a reference to $EmptyButTrue::var, so we can't disallow
    # ALL variable references; $EmptyButTrue::var uses overload, which
    # involves a bunch of weird stuff, which is why :base_loop is here too.
    $compartment->deny(qw(
        sassign
        rv2av aassign aeach aelem aelemfast aelemfast_lex akeys aslice av2arylen avalues kvaslice
        rv2hv helem hslice each values keys exists delete kvhslice
        preinc i_preinc predec i_predec
        postinc i_postinc postdec i_postdec
        trans transr chop schop chomp schomp
        splice push pop shift unshift reverse
        andassign dorassign
        warn die
        rv2cv anoncode prototype
        entersub leavesub leavesublv
        method method_named method_redir_super method_super
        goto));
    $compartment->deny('match') if $elem eq 'define';
    $compartment->permit(qw(concat padany));
    # Keep the args safe
    $_ = undef;
    @_ = ();
    %_ = ();
    my $rc;
    # This is all stuff needed to disable warnings
    $compartment->permit(qw(helem anoncode rv2cv refgen sassign leavesub));
    if ($text =~ /\$EmptyButTrue::val\b/) {
        # This is all stuff needed to make EmptyButTrue (via overload) work
        $compartment->permit(qw(method_named entersub require shift gv rv2av
            aassign postinc keys ref enteriter iter unstack leaveloop caller
            method delete aelem sprintf rv2hv regcreset die push next hslice
            exists last goto pop bless));
        $rc = $compartment->reval("use EmptyButTrue; no warnings; return ($text)", 'strict');
    } else {
        $rc = $compartment->reval("BEGIN { \$SIG{__WARN__} = sub {}; } return ($text)", 'strict');
    }
    return ($rc, $@);
}

sub pp_macro_expand {
    my ($line, $macros, $warn, $quoting, $file, $linenum, $noreplace, $for_eval, $used_macros, $mark_only) = @_;

    # Needed because we'll return this if $mark_only is set.
    my $origline = $line;
    $warn = 0 if $mark_only;

    if ($quoting) {
        # When quoting is on, if the user quotes a variable name then
        # we need to unquote it or the quoting will be doubled and then
        # there'll be trouble.
        $line =~ s/(['"])((?<![\\\xff])%\{[^%\{\}]+\})\1/$2/g;
    }
    do {
    } while
    $line =~ s/(?<![\\\xff])%\{([^%\{\}]+)\}/
        my $symbol = $1;
        # If the symbol is composed of the contents of several other
        # macros (resolved previously in this loop), and if quoting
        # is turned on, then the quotes will need to be removed in
        # order for the lookup to succeed.
        $symbol =~ s{'}{}g;
        if (exists($macros->{$symbol})) {
            # Try to figure out what it is and return the correct value

            # First note that the value was used
            $used_macros->{$symbol}++;

            # It's a true-but-empty value, so propagate that if the result
            # will be evaluated ($for_eval set); otherwise, it's the
            # empty string.
            if (ref($macros->{$symbol}) eq 'EmptyButTrue') {
                if ($for_eval) {
                    '$EmptyButTrue::val';
                } else {
                    '';
                }

            # It's a number
            } elsif ($macros->{$symbol}+0 != 0
                && $macros->{$symbol} =~ m{^[-+]?(?:\d+|\d+\.\d*|\d*\.\d+|\d+[eEgG][-+]?\d+)$}) {

                $macros->{$symbol}+0;

            # It's a zero!
            } elsif ($macros->{$symbol} =~ m{^[-+]?0+(?:\.0+)?$}) {
                0;

            # It's not a number...
            } else {
                if ($quoting) {
                    # Don't quote strings that might be references
                    # to other preprocessor macros, unless $noreplace
                    # is on.
                    if ($macros->{$symbol} =~ m{(?<![\\\xff])%\{[^%\{\}]+\}}
                        && !$noreplace) {
                        $macros->{$symbol};
                    } elsif ($macros->{$symbol} =~ m{^["'].*["']$}) {
                        $macros->{$symbol};
                    } else {
                        "'".$macros->{$symbol}."'";
                    }
                } else {
                    $macros->{$symbol};
                }
            }
        } else {
            Log(100, "ERROR: Undefined preprocessor macro '$symbol' referenced on line $linenum\n       of $file\n") if $warn;
            if ($noreplace and $symbol !~ m!^ENV_!) {
                "\xff\%{".$1.'}';
            } elsif ($for_eval) {
                'undef';
            } elsif ($quoting) {
                "''";
            } else {
                # Return an empty string; this should cause most
                # expressions to break in such a way that the user
                # will be alerted to their error. :)
                '';
            }
        }
    /egs;

    # Undo fixups that we've put in
    $line =~ s/\xff%\{/%{/g;
    return $mark_only ? $origline : $line;
}

sub config_var_expand {
    my ($line, $ref, $warn) = @_;

#    print "config_var_expand([$line], $ref, $warn)\n";
    return $line if ($line eq '' || ref($ref) !~ /^(?:HASH|Spec::Config)/);

    do {
#       print "line: {$line}\n";
    } while
    $line =~ s/(?<!\\)\$\[([^\$\[\]]+)\]/
        my $var = $1;
#        print "    var: $var\n";
        my $val = Spec::Config::accessor_backend($ref, 0, $var);
#        print "    val: $val\n";
        if (defined($val)) {
            # Well, then... try to figure out if it's a number or what
            if ($val+0 != 0) {
                # It's a number...numify it (well, this probably doesn't
                # matter too much, but if it needs to be a string, it'll
                # be re-stringified later)
                $val+0;
            } elsif ($val =~ m{^[-+]?0+(?:\.0+)?$}) {
                # It's a zero!
                0;
            } else {
                # It's not a number...
                $val;
            }
        } else {
            Log(100, "ERROR: Undefined config variable '$var' referenced during variable expansion\n") if $warn;
            # Return an empty string; this should cause most expressions to
            # break in such a way that the user will be alerted of their
            # error. :)
            '';
        }
    /egs;
#    print "return: {$line}\n";
    return $line;
}

sub get_sysinfo {
    my ($me) = @_;
    my @cflines = ();
    my @infolines = ();
    my %hashes = ();
    my ($sysinfo, $hashtxt);

    return() if ($::from_runcpu & 1);

    if (exists($me->{'sysinfo_program'})
            and $me->{'sysinfo_program'} ne '') {
        $sysinfo = $me->{'sysinfo_program'};
        # As a special case, do substitution for $[top] or ${top}, to make
        # specifying absolute paths easier.
        $sysinfo =~ s/\$\[top\]/$me->top/eg;
        $sysinfo =~ s/\$\{top\}/$me->top/eg;
        Log(0, "Running \"$sysinfo\" to gather system information.\n") unless ($::quiet && $::from_runcpu);

        # Get a temporary file for the output
        my $tmpdir = ::get_tmp_directory($me, 1);
        $tmpdir = '.' unless -d $tmpdir;
        my $outfile = ::jp($tmpdir, "sysinfo.$$.out");
        my $rc = ::runcpu_system($me, [ $sysinfo ],
                                [
                                     { 'name' => $outfile, 'callback' => sub { ::Log($1, 'sysinfo: '.$2."\n") while $_[0] =~ /^log\s+(\d+)\s+(.*)/mg; } },
                                ],
                                {
                                    'cleanup' => 0,
                                    'outfile' => $outfile,
                                },
        );
        if ($rc) {
            Log(0, "\nERROR: Could not run sysinfo_program \"$sysinfo\".\n       $sysinfo exited with error code $rc\n\n");
        } else {
            @infolines = map { tr/\015\012/\012/s; $_ } ::read_file($outfile);
            unlink($outfile);
            if (@infolines) {
                my @final_lines;
                foreach my $infoline (@infolines) {
                    next unless $infoline =~ /(?:^\s*#|$::info_re)/;
                    # Make an attempt to deal with some Unicode (well, UTF-8)
                    # things.  These are all encoded as hex as runcpu doesn't
                    # really _do_ Unicode, and making it do so is a task left
                    # for not so close to release.

                    # Hyphen-like things: U+2010-U+2012, U+203E
                    $infoline =~ s/\x{e2}\x{80}(?:\x{90}|\x{91}|\x{92}|\x{be})/-/g;

                    # Dash-like things: U+2013, U+2014
                    $infoline =~ s/\x{e2}\x{80}(?:\x{93}|\x{94})/--/g;

                    # Double-vertical-bar-like things: U+2016
                    $infoline =~ s/\x{e2}\x{80}\x{96}/||/g;

                    # Low-line-like things: U+2017
                    $infoline =~ s/\x{e2}\x{80}\x{97}/_/g;

                    # Single-quote-like things: U+2018-U+201B, U+2032, U+2035
                    $infoline =~ s/\x{e2}\x{80}(?:\x{98}|\x{99}|\x{9a}|\x{9b}|\x{b2}|\x{b5})/'/g;
                    $infoline =~ s/\x{e2}\x{80}(?:\x{b3}|\x{b6})/''/g;
                    $infoline =~ s/\x{e2}\x{80}(?:\x{b4}|\x{b7})/'''/g;

                    # Double-quote-like things: U+201C-U+201F
                    $infoline =~ s/\x{e2}\x{80}(?:\x{9c}|\x{9d}|\x{9e}|\x{9f})/"/g;

                    # Dot-like things
                    $infoline =~ s/\x{e2}\x{80}(?:\x{a4}|\x{a7})/./g;   # U+2024, U+2027
                    $infoline =~ s/\x{e2}\x{80}\x{a5}/../g;             # U+2025
                    $infoline =~ s/\x{e2}\x{80}\x{a6}/.../g;            # U+2026

                    # Bizarro-world punctutation that we'll never actually see
                    $infoline =~ s/\x{e2}\x{80}\x{bc}/!!/g;                   # U+203C
                    $infoline =~ s/\x{e2}(?:\x{80}\x{bd}|\x{81}\x{88})/?!/g;  # U+203D, U+2048
                    $infoline =~ s/\x{e2}\x{81}\x{87}/??/g;                   # U+2047
                    $infoline =~ s/\x{e2}\x{81}\x{89}/!?/g;                   # U+2049

                    # Now, having made our "best effort", just strip out any
                    # remaining characters with the high bit set
                    $infoline =~ tr/\x{80}-\x{ff}/?/;

                    push @final_lines, $infoline;
                }
                @infolines = @final_lines;
                Log(130, "Read ".(@infolines+0)." info lines from the sysinfo program.\n");
                # Try to get the sysinfo program into a bundle.  Assume there are
                # no spaces in the path, and add each word that exists as a file
                # (and whose path doesn't contain '/perl') to the list of files to
                # bundle.
                foreach my $trypath (split(/\s+/, $sysinfo)) {
                    next if $trypath =~ m#(?:[/\\]|^)(?:spec)?perl(?:[/\\]|\s|$)#;
                    if (-e $trypath) {
                        push @{$me->{'files_read'}}, $trypath;
                        my ($hash, $bits, $algo);
                        $bits = $me->accessor_nowarn('sysinfo_hash_bits');
                        ($hash, $bits, $algo) = ::filedigest($trypath, defined($bits) ? $bits : 256);
                        $algo =~ s/-\d+//;  # Implicit from length of hash
                        $hashes{basename($trypath)} = [ $algo, $hash ];
                    }
                }
                $hashtxt = join(';', map { join(':', ($_, @{$hashes{$_}})) } sort keys %hashes);

                # Fix up notes tags to ensure that the tag ends with 'sysinfo'
                foreach my $line (@infolines) {
                    if ($line =~ s/^notes([^\s=]*)(\s*)=//) {
                        my ($tag, $ws) = ($1, $2);
                        # Remove sysinfo from tag
                        $tag =~ s/sysinfo//g;
                        # Squash multiple underscores (possibly due to 'sysinfo' removal)
                        $tag =~ s/__+/_/g;
                        # Now add a sysinfo tag to the end
                        $tag =~ s/(_?\d+)?$/_sysinfo$1/;
                        $line = "notes${tag}${ws}=$line";
                    }
                }

                # If you change the comments output below, remember to change the
                # guard that checks for it in merge() above.
                push @cflines, "# The following settings were obtained by running the sysinfo_program\n";
                push @cflines, "# '".$me->{'sysinfo_program'}."' ($hashtxt)\n";
                push @cflines, "default:\n";
                push @cflines, @infolines;
                push @cflines, "# End of settings added by sysinfo_program\n";

            } else {
                Log(130, "Read _NO_ lines from the sysinfo program.  Perhaps there was a problem?\n");
            }
        }
    }

    return ($sysinfo, $hashtxt, @cflines);
}

# search keys of an array based on a limited wild card (*)
# and returns the list of keys that match/contain the pattern
sub find_keys {
    my ($me, $pat) = @_;
    my @temp;
    if ($pat =~ s/\*$//) { # if pattern ends in "*"
        @temp = sort ::bytrailingnum grep (m/^$pat[0-9.]*/, list_keys($me));
    } else {
        @temp = ($pat) if exists $me->{$pat};
    }
    return @temp;
}

sub bind {
    my $me = shift;

    if ($me->tune eq 'base') {
        # The binding is not allowed to vary on a per-benchmark
        # basis for base runs
        my $config = $me->{'config'};
        $config = $::global_config unless (blessed($config) && $config->isa('Spec::Config'));
        my @sets = $config->benchmark_in_sets(undef, $me->benchmark);
        my $rc = $config->default_lookup('bind', $me->{'label'}, @sets);
        return $rc;
    } else {
        my $tmp = $me->accessor_nowarn('bind');
        return $tmp;
    }
}

sub parallel_test {
    my ($me, %opts) = @_;

    if ($opts{'no_default'}) {
        my $rc = $me->accessor_nowarn('parallel_test');
        return (defined($rc) ? $rc : 0);
    }

    # No parallel test/train for OMP2012
    return 1 if $::lcsuite =~ /^omp/;

    my $rc = $me->accessor_nowarn('parallel_test');
    if (defined($rc) && $rc == 0) {
        # Default, not set on the command line
        $rc = $me->copies;
    } else {
        $rc = 1 unless defined($rc);
    }

    return $rc;
}

sub copies {
    my $me = shift;

    return 1 unless ($me->runmode =~ /rate$/);

    # The number of copies is not allowed to vary on a per-benchmark basis for
    # base runs, but runcpu should've already verified that, so it SHOULD be
    # okay to just do the normal lookup here.

    # The 'accessor_nowarn' is because sometimes copies is invoked on a non-
    # benchmark config object.
    my $rc = $me->accessor_nowarn('copies');
    return 1 unless defined($rc) and $rc > 1;
    return $rc;
}

sub threads {
    my $me = shift;

    return 1 unless ($me->runmode eq 'speed');

    # The number of threads is not allowed to vary on a per-benchmark basis for
    # base runs, but runcpu should've already verified that, so it SHOULD be
    # okay to just do the normal lookup here.

    my $rc = $me->accessor_nowarn('threads');
    return 1 unless defined($rc) and $rc > 1;
    return $rc;
}

sub ranks {
    my $me = shift;

    # The number of ranks is not allowed to vary on a per-benchmark basis for
    # base runs, but runcpu should've already verified that, so it SHOULD be
    # okay to just do the normal lookup here.

    my $rc = $me->accessor_nowarn('ranks');
    return 1 unless defined($rc) and $rc > 1;
    return $rc;
}

# Figure out if a given list of benchmarks is a superset of the benchmarks in
# the given benchset.
# Returns true if the benchset's benchmarks are all in the list
# Also returns a list ref for the list of benchmarks that were NOT in the
# bset, as well as a list ref for the list of benchmarks that WERE.
sub is_full_benchset {
    my ($me, $bset, @bmarks) = @_;

    # If a nonexistent benchset was specified, don't return anything, since
    # there's no way to convert the list of benchmark names back to benchmark
    # object references.
    return (0, [], []) unless exists($me->{'benchsets'}->{$bset});

    my %used = ();
    my %unused = map { $_ => 1 } @bmarks;

    my %leftovers = map { $_->benchmark => 1 } values %{$me->{'benchsets'}->{$bset}->{'benchmarks'}};
    foreach my $bmark (@bmarks) {
        if (exists($leftovers{$bmark})) {
            $used{$bmark}++;
            delete $leftovers{$bmark};
            delete $unused{$bmark};
        }
    }

    return ((keys %leftovers == 0), [ sort keys %unused ], [ sort keys %used ]);
}

# Return a hash of preENV settings for the current list of benchsets merged
# with any top-level settings
sub get_all_preenv {
    my ($me, @benchsets) = @_;

    my $label = $me->accessor_nowarn('label');
    my $benchsets = $me->accessor_nowarn('benchset_list') || [ @benchsets ];
    my %pre_env = $me->preenv_list(undef, $label);
    foreach my $bs (@$benchsets) {
        %pre_env = (%pre_env, $me->preenv_list($bs, $label));
    }

    return %pre_env;
}

# Return a hash of preENV settings for the given benchset, or the object if
# none is given.  $me is assumed to point to a top-level config object if
# $benchset is non-empty.
sub preenv_list {
    my $me = shift(@_);
    return $me->get_all_prefixed_variables('preENV_', @_);
}

sub get_all_prefixed_variables {
    my ($me, $prefix, $benchset, @labels) = @_;
    my %rc = ();
    my $savedrefs = undef;

    if (defined($benchset) and $benchset ne '' and $benchset ne 'default') {
        # Fake up refs which will result in the given benchset (assumed to be
        # under $me) being searched.
        $savedrefs = $me->{'refs'};
        unshift @labels, 'default' unless grep { $_ eq 'default' } @labels;
        $me->{'refs'} = [
            $me,
            reverse(
                $me->accessor_nowarn('config'),
                $me->ref_tree(basename(__FILE__).':'.__LINE__,
                    [ 'default', $benchset ],
                    [ 'default'            ],
                    [ @labels              ])
            ),
        ];
    }

    %rc = map { s/^\Q${prefix}\E//; $_ => $me->accessor($prefix.$_) } grep { /^\Q${prefix}\E/ } $me->list_keys;
    $me->{'refs'} = $savedrefs if defined($savedrefs);

    return %rc;
}

# Build a tree of references
sub ref_tree {
    my ($ref, $label, $leaves, @rest) = @_;
    my %seen;
    my @rc;
    return () unless ref($leaves) eq 'ARRAY';

    for my $leaf (@{$leaves}) {
        next unless defined($leaf);
        next if $seen{$leaf}++;
        $ref->{$leaf} = { } if ref($ref->{$leaf}) ne 'HASH';
        $refmapping{qq/$ref->{$leaf}/} = "$label:$leaf" if (!exists $refmapping{qq/$ref->{$leaf}/});
#print "ref_tree($ref, $label:$leaf, $leaves, [".join(',', @rest)."]) = ".$ref->{$leaf}."\n";
        push (@rc, $ref->{$leaf});
        push (@rc, ref_tree($ref->{$leaf}, "$label:$leaf", @rest)) if @rest > 0;
    }
    return @rc;
}

sub unshift_ref {
    my ($me, @refs) = @_;
    unshift (@{$me->{'refs'}}, @refs);
}
sub shift_ref {
    my ($me) = @_;
    my $out = shift @{$me->{'refs'}};
    return $out;
}
sub push_ref {
    my ($me, @refs) = @_;
    push (@{$me->{'refs'}}, @refs);
}
sub pop_ref {
    my ($me) = @_;
    my $out = pop @{$me->{'refs'}};
    return $out;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
