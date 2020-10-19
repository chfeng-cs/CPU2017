#
# parse.pl
#
# Copyright 1999-2019 Standard Performance Evaluation Corporation
#
# $Id: parse.pl 6277 2019-07-06 21:58:23Z CloyceS $

use strict;
use Getopt::Long;
use Text::ParseWords;
use Date::Parse;
use EmptyButTrue;
use List::MoreUtils qw(distinct);
use Scalar::Util qw(looks_like_number);
require 'flagutils.pl';
require 'util.pl';

my $version = '$LastChangedRevision: 6277 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'formatter_parse.pl'} = $version;

sub parse_commandline {
    my ($config, $cl_opts) = @_;
    my @flagsurls = ();
    my $bp_bench = undef;

    if (exists $ENV{'SPEC_RUNSPEC'}) {
        unshift @ARGV, shellwords($ENV{'SPEC_RUNSPEC'});
    }

    # Here's a hack:
    # This is called each time before rawformatting a result.
    # So save @ARGV before we munge it, and reuse it if appropriate
    if (exists $ENV{'SPEC_SAVED_ARGC_DONT_EVER_SET_THIS'}) {
        # Restore @ARGV
        ::Log(88, "Restoring \@ARGV: before = ".join('', @ARGV)."\n");
        @ARGV = split(/\|\|/, $ENV{'SPEC_SAVED_ARGC_DONT_EVER_SET_THIS'});
        ::Log(88, "Restoring \@ARGV: after = ",join('', @ARGV),"\n");
    } else {
        # Save @ARGV
        ::Log(88, "Saving \@ARGV: before = ",join('', @ARGV),"\n");
        $ENV{'SPEC_SAVED_ARGC_DONT_EVER_SET_THIS'} = join('||', @ARGV);
        ::Log(88, "Saving \@ARGV: after = ",join('', @ARGV),"\n");
    }

    Getopt::Long::config("no_ignore_case");
    my @actions = ();
    my $rc = GetOptions ($cl_opts, qw(
                            rawformat|R
                            from_runcpu
                            help|h|?
                            output_format|output-format|o=s
                            failflags
                            unbuffer|f
                            verbose|debug|v=i
                            version|V
                            table!
                            nc=s
                            na=s
                            cd=s
                            test
                            update:s
                            graph_min|graph-min|graphmin=f
                            graph_max|graph-max|graphmax=f
                            graph_auto|graph-auto!
                            http_proxy|http-proxy=s
                            http_timeout|http-timeout=i
                            review!
                            opts-file=s
                            recalc|recalculate!
                            reselect!
                            action=s
                            nopeak|baseonly|no-peak|base-only
                            nopower
                            ),
                            'basepeak:s@' => sub { if (!defined($_[1]) || $_[1] eq '') { $bp_bench = 'full'; } else { push @$bp_bench, $_[1]; } },
                            'flagsurl|flags|F=s' => \@flagsurls,
                        );

    # Throw away extra or unused options
    delete $cl_opts->{'rawformat'};
    delete $cl_opts->{'action'};

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

    # Run the Perl test suite, if asked
    if (exists $cl_opts->{'test'} && $cl_opts->{'test'}) {
        print "Running the Perl test suite...\n";
        chdir main::jp($ENV{'SPEC'}, 'bin');
        exec "./specperl", main::jp('test', 'TEST');
    }

    # Read and erase the opts file, if found
    if (exists($cl_opts->{'opts-file'})
            and $cl_opts->{'opts-file'} ne ''
            and -f $cl_opts->{'opts-file'}) {
        my $ifh = new IO::File '<'.$cl_opts->{'opts-file'};
        if (defined($ifh)) {
            my %opts_file_ok = map { $_ => 1 } qw(
                mailto mailmethod mailserver
                mailport username lognum logname
                mail_reports runcpu_argv
                mailcompress
                notes_wrap_columns
                notes_wrap_indent
                review
                table
            );
            while(defined(my $line = <$ifh>)) {
                next unless $line =~ m/^([a-z_]+)=(.+)/;
                next unless $opts_file_ok{$1};
                $config->{'cl_opts'}->{$1} = $2;
            }
            $ifh->close();
            unlink $cl_opts->{'opts-file'};
        } else {
            Log(110, "Couldn't open options file \"$cl_opts->{'opts-file'}\" for reading: $!\n");
        }
    }

    # Try to be reasonably helpful
    foreach my $what (qw(nc na cd)) {
        if (exists($cl_opts->{$what})) {
            if (!defined($::website_formatter) || $::website_formatter == 0) {
                die "The --$what flag is not for you.\nStopped";
            } elsif (! -e $cl_opts->{$what}) {
                die "Please specify an existing file for the ".uc($what)." text!\nStopped";
            } else {
                $config->{'cl_opts'}->{'nc_is_na'} = ($what eq 'na');
                $config->{'cl_opts'}->{'nc_is_cd'} = ($what eq 'cd');
                open(TMP, '<'.$cl_opts->{$what}) || die "Can't open '".$cl_opts->{$what}."' for reading: $!\nStopped";
                my $eol = $/;
                undef $/;
                $config->{'cl_opts'}->{'nc'} = [ split(/[\r\n]+/, <TMP>) ];
                $/ = $eol;
            }
        }
    }

    # Take care of the flags file(s)
    # Fix up URLs so that they're not affected by the split on :
    # This would be easier and cleaner with variable-length negative lookback.
    # Oh, well...
    foreach my $url (@flagsurls) {
        $url =~ s/(http|file):/$1\177/g;
        if ($^O =~ /MSWin/) {
            # Windows users might still be using drive letters...
            $url =~ s/\b([c-zC-Z]):/$1\177/g;
        }
    }
    @flagsurls = split(/[,:]+/, join(',', @flagsurls));
    foreach my $url (@flagsurls) {
        $url =~ s/\177/:/g;
    }
    $cl_opts->{'flagsurl'} = [];
    if (@flagsurls) {
        if (!grep { /^noflags$/ } @flagsurls) {
            foreach my $url (@flagsurls) {
                $url =~ s|\\|/|g; # Change \ to / for Windows users
                if ($url !~ m|^[^:]+://|) {
                    if (! -e $url) {
                        Log(0, "ERROR: Specified flags file ($url) could not be found.\n");
                        Log(0, "       To get a flags report, you must re-format generated results with a\n");
                        Log(0, "       valid flags file.\n");
                        next;
                    }
                } elsif ($url !~ /^(http|file):/) {
                    die "ERROR: Unsupported flags file URL scheme in \"$url\";\n       please use file: or http:.\nStopped";
                }
                push @{$cl_opts->{'flagsurl'}}, $url;
            }
        } else {
            $cl_opts->{'flagsurl'} = [ 'noflags' ];
        }
    }
    if (@{$cl_opts->{'flagsurl'}} == 0) {
        # No flags files found
        delete $cl_opts->{'flagsurl'};
    }

    # Format for review?
    if (defined($::website_formatter) && $::website_formatter && !$::format_for_publication) {
        $config->{'cl_opts'}->{'review'} = 1;
    } else {
        $config->{'cl_opts'}->{'review'} = $cl_opts->{'review'} if exists($cl_opts->{'review'});
    }

    # Unset the http proxy?
    if (defined($cl_opts->{'http_proxy'}) && $cl_opts->{'http_proxy'} eq 'none') {
        delete $ENV{'http_proxy'};
        $config->{'cl_opts'}->{'http_proxy'} = '';
    }

    # Note --nopower and --nopeak for later, or note that they were unset
    foreach my $thing (qw(nopower nopeak)) {
        if (!istrue($cl_opts->{$thing})) {
            $config->{'cl_opts'}->{$thing} = 0;
        }
    }

    # If --update gets no argument, it will exist but not be empty, so make it
    # true.
    if (exists($cl_opts->{'update'}) and $cl_opts->{'update'} eq '') {
        $cl_opts->{'update'} = $EmptyButTrue::val;
    }

    if (!$rc || istrue($cl_opts->{'help'})) {
        print "For help, type \"rawformat --help\"\n";
        #usage();
        exit (!$rc ? 1 : 0);
    }

    # Store persistent command line options (ones that will be referenced
    # later) into the config object itself.  Not all possible options fall
    # into this category.  This also isn't the complete list; some options
    # (such as --review) are handled separately.
    foreach my $clopt (qw(
            cd
            failflags
            from_runcpu
            graph_auto
            graph_max
            graph_min
            http_timeout
            na
            nc
            nopeak
            nopower
            opts-file
            recalc
            reselect
            table
            unbuffer
            update
            verbose
        )) {
        $config->{'cl_opts'}->{$clopt} = $cl_opts->{$clopt} if exists($cl_opts->{$clopt});
    }

    return 1;
}

sub munge_user_format_choices {
    my ($choice, $default_formats, $all_formats) = @_;

    # If 'all' is explicitly requested, change the list of default formats
    if ($choice =~ /\ball\b/i) {
        @$default_formats = @$all_formats;
    }

    # If 'default' is requested, that's like 'all', but without the change
    # of list.
    $choice =~ s/default/all/i;

    return $choice;
}

sub resolve_choices {
    my ($config, $cl_opts) = @_;

    my $default_formats = [ grep { eval "die if \$Spec::Format::${_}::non_default"; !$@ } keys %{$config->formats} ];
    my $all_formats = [ grep { eval "die unless \$Spec::Format::${_}::part_of_all"; !$@ } keys %{$config->formats} ];

    # This is a list of all the possible names for all of the output formats
    my @synonyms = map { keys %{$config->formats->{$_}->{'synonyms'}} } keys %{$config->formats};

    my $user_choices = munge_user_format_choices($config->output_format, $default_formats, $all_formats);

    # Put the selected list of formats into a hash to weed out duplicates
    my ($choices, $antichoices) = choose_strings('Output',
                                                 $user_choices,
                                                 $default_formats,
                                                 [ @synonyms ],
                                                 1);
    my @choices = grep { $_ ne '' } map { ::get_format($config->formats, $_)->{'name'} } @$choices;
    my @antichoices = grep { $_ ne '' } map { ::get_format($config->formats, $_)->{'name'} } @$antichoices;
    if (@choices == 0 && @antichoices > 0) {
        # The user has only asked for some formats to NOT be generated, so
        # pretend that they also asked for the full set of default formats
        $user_choices = munge_user_format_choices($::default_config->{'output_format'}, $default_formats, $all_formats);
        @choices = choose_strings('Output', $user_choices, $default_formats, [ @synonyms ], 0);
    }

    my %formatlist = map { $_ => 1 } @choices;

    # For runcpu-sponsored runs, a raw file will already exist, so don't
    # produce that.
    delete $formatlist{$Spec::Format::raw::name} if $::from_runcpu;

    # Add HTML flag report if PDF or HTML (or other linkable output format) is
    # requested.
    if (exists $formatlist{'HTML'} || exists $formatlist{'PDF'}) {
        $formatlist{::get_format($config->formats, 'flags')->{'name'}}++;
    }

    # @$choices shouldn't contain anything that's in @$antichoices, but
    # just in case...
    foreach my $antichoice (@antichoices) {
        delete $formatlist{$antichoice};
    }

    # Make the final list of outputs to be generated
    $config->{'formatlist'} = [ sort ::byformat map { ::get_format($config->formats, $_)  } keys %formatlist ];

    # Make the list of files to format.
    $config->{'runlist'} = [ @ARGV ];

    return 1;
}

sub parse_raw {
    my ($fh, $config, $rawfn) = @_;
    my $prefix = $Spec::Format::raw::prefix;
    my $bsname = 'Who knows?';
    my $ignoreflags = 0;
    my $compopts = {};
    my $compvers = {};
    my %seennote = ();

    # Suck in the raw file
    my @raw = <$fh>;
    foreach my $ln (@raw) {
        if ($ln =~ /\Q$prefix\E\.name:\s+(\S+)/o) { $bsname = $1; last; }
    };
    if ($bsname eq 'Who knows?') {
        Log(0, "   Not a valid ${main::suite} raw result file\n\n");
        return undef;
    }

    my $r = $config->{'benchsets'}->{$bsname};
    if (::ref_type($r) ne 'HASH') {
        Log(0, "  \"$bsname\" is not a valid benchset name; this file cannot be formatted\n");
        return undef;
    }

    # Weed out benchmarks that should not be output
    foreach my $bm (sort keys %{$r->{'benchmarks'}}) {
        delete $r->{'benchmarks'}->{$bm} if exists ($config->{'benchsets'}->{$bsname}->{'no_output'}->{$bm});
    }

    my $rawfile = '';
    foreach (@raw) {
        $rawfile .= $_;
        tr/\012\015//d;         # Hooray for Microsoft!
    }
    (undef, $r->{'rawfile'}, $r->{'compraw'}) = ::compress_encode($rawfile);
    if (defined($r->{'compraw'})) {
        delete $r->{'rawfile'};
    } else {
        delete $r->{'compraw'};
    }

    # If flagsurl is set, use it; reformatting with a different flags file
    # will probably be a common thing.
    my $flagsurls = $config->accessor_nowarn('flagsurl');
    if (::ref_type($flagsurls) eq 'ARRAY') {
        $r->{'flagsurl'} = [];
        $ignoreflags++;
        # flags will actually be loaded later, once the result version is
        # known.
    }

    my ($tag, $value) = ('', undef);
    my (%seen) = (()); # clear, at least
    my $hashrecord = '';
    my %hashfields = ();
    my $ctx = undef;

    # Examine the raw file lines and reconstruct a result object from it.
    while(defined($_ = shift(@raw))) {
        next if /^\s*$/o;
        ($tag, $value) = /^$prefix\.([^:]+):[   ](\s*.*)/o;
        $tag = '' unless defined($tag);
        $value = '' unless defined($value);

        # Strip trailing whitespace from the value
        $value =~ s/\s+$//;

        # This handles the submission info that the email handler tacks on
        if (/^-SUBMIT-$/o) {
            if (defined($::website_formatter) && $::website_formatter &&
                defined($::format_for_publication)) {
                # Handle the submission information specially
                my $submittedby_line = shift(@raw);
                my $submitdate_line = shift(@raw);
                if (!$::format_for_publication) {
                    # These aren't appended to the notes on the public side
                    # The tools will want to helpfully renumber these, so they're
                    # given a (hopefully) unique tag and indices.
                    push @{$r->{'notes'}->{'zzzzsubmitinfo'}}, (
                        [ 'notes_zzzzsubmitinfo_86', '' ],
                        [ 'notes_zzzzsubmitinfo_87', $submittedby_line ],
                        [ 'notes_zzzzsubmitinfo_88', $submitdate_line ],
                        [ 'notes_zzzzsubmitinfo_89', shift(@raw) ]
                    );
                } else {
                    shift(@raw);  # Consume the filename
                }
                $submittedby_line =~ s/^[^:]+:\s+//;
                $submitdate_line =~ s/^[^:]+:\s+//;
                $r->{'Submitted_by'} = $submittedby_line;
                $r->{'Submit_date'} = $submitdate_line;
            } else {
                shift(@raw);    # submitted_by
                shift(@raw);    # submit date
                shift(@raw);    # result filename
            }
            next;
        }

        # Check for/add to the result file hash
        if ($hashrecord ne '') {
            tr/\015\012//d;
            $ctx->add($_) if ($tag !~ /^(?:raw|ext)hash/);
            if (/^$prefix\.(\S+?)_?(\d*): (.*)/o) {
                my ($field, $idx) = $tag =~ /^(\S+?)_?(\d*)$/;
                $idx = ((defined($idx) && $idx ne '') ? $idx+0 : 0);      # Make it a number
                $hashfields{$field}->[$idx] = $value;
            }
        }

        if ($tag eq 'rawhash' && !defined($ctx)) {
            my ($bits, $hashalgo);
            ($ctx, $bits, $hashalgo) = ::get_hash_context(length($value) * 4);
            if (!defined($ctx)) {
                Log(0, "  \"$hashalgo\" is not a known hash algorithm; this file cannot be formatted\n");
                return undef;
            }
            $hashrecord = $hashalgo;
        }

        # Comment lines (if any) have already been added to the hash
        next unless (defined($tag) && defined($value) && ($tag ne ''));

        # The What-Goes-Where Heuristic: if $tag has no periods, it is an
        # 'info' thing.  If it does, it is a 'result' thing.
        if ($tag !~ /\./o) { # 'info' thing
            next if ($ignoreflags && $tag =~ /^(?:raw|comp)?flags(?:url|[0-9:])/o);
            # Don't allow things that go below the fence to be set above it
            if ($hashrecord eq '' and $tag !~ /$::info_re/) {
                ::Log(0, "Warning: '$tag' may not be present in the editable portion of the result file.\n");
                next;
            }

            # Silently skip parallel notes; they're generated
            # automatically later.
            next if $tag =~ /^$::mpi_desc_re_id?notes_auto2par/o;

            # Note MPI system description sections seen
            if ($tag =~ /($::mpi_desc_re)/) {
                $r->{'mpi_items'}->{$1} = [ $2, $3 ];
            }

            # Note power analyzers/temperature meters seen
            if ($tag =~ /^(power(?!_management)|temperature)_([^_]+)_version/) {
                # This will be uniqified later
                push @{$r->{'meterlist'}->{$1}}, $2;
            }

            if ($tag =~ /^(.*?)_?(\d+)$/o) {
                # an ARRAY 'info' thing
                my ($what, $which) = ($1, $2);

                if ($what =~ /^$::mpi_desc_re_id?notes/) {
                    # Now that there are so many different kinds of notes
                    # to choose from, things are more complicated.
                    my $found = 0;
                    foreach my $notere (@::notes_regexps) {
                        if ($tag =~ /$notere/) {
                            my ($section, $key, $num) = ($1, $2, $3);
                            $found = 1;
                            $r->{$section} = {} unless (exists($r->{$section})
                                && (::ref_type($r->{$section}) eq 'HASH'));
                            $r->{$section}->{$key} = [] unless (exists($r->{$section}->{$key})
                                && (::ref_type($r->{$section}->{$key}) eq 'ARRAY'));
                            if (defined($r->{$section}->{$key}->[$num]) &&
                                $r->{$section}->{$key}->[$num] ne '' &&
                                $r->{$section}->{$key}->[$num]->[1] ne $value) {
                                Log(0, "WARNING: notes line $tag is duplicated!\n".
                                    "     Original: [".$r->{$section}->{$key}->[$num]->[1]."]\n".
                                    "  Replacement: [$value]\n".
                                    "The original value will be used.\n");
                                next;
                            } else {
                                $r->{$section}->{$key}->[$num] = [ $tag, $value ];
                                $seennote{$tag} = $r->{$section}->{$key}->[$num];
                            }
                            last;
                        }
                    }
                    next if $found;

                    # If $tag didn't match _any_ of the notes regexps, it
                    # must be some other informational array that starts with
                    # 'notes'.  (What could that be?)  Anyway, just let it
                    # fall through.
                }
                $r->{$what} = [] unless (exists ($r->{$what}) &&
                    ref($r->{$what}) eq 'ARRAY');
                $r->{$what}->[$which] = $value;
            } else {
                if ($tag eq 'size') {
                    if ($value =~ /^(\S+) \((\S+)\)$/) {
                        $r->{'size'} = $1;
                        $r->{'size_class'} = $2;
                    } else {
                        $r->{'size'} = $value;
                        $r->{'size_class'} = $value;
                    }
                } elsif ($tag eq 'notes') {
                    # Shouldn't happen, but does.  People.
                    push @{$r->{'notes'}->{''}}, [ 'notes_xyzzybadentrynoindex_000', $value ];

                } elsif ($tag eq 'unitbase') {
                    # Results from pre-RC6 will have this, and it'll be wrong.
                    # Since it's already in $r, we can just ignore it and not
                    # override the right value with the wrong one.

                } else {
                    $r->{$tag} = $value;
                }
            }
        } else {
            # Don't allow things that go below the fence to be set above it
            next if $hashrecord eq '';
            # a 'result' or 'options' thing
            my @comps = split(/\./, $tag);
            # The first element tells what it is...
            my $what = (($#comps != 2) && ($#comps != 4)) ? '!' : shift(@comps);
            if ($what eq 'results')  {
                my ($bench, $tune, $idx, $key) = @comps;
                if (exists($r->{'iterations'}) && ($idx+1 > $r->{'iterations'})) {
                    $r->{'iterations'} = $idx+1;
                }
                $bench =~ s/_/./;
                if (!exists $seen{"$bench|$tune|$idx"}) {
                    # Make it.
                    $r->{'results'}->{$bench}->{$tune}->{'data'}->[$idx] =
                    new Spec::Config();
                    my $tmpref = $r->{'results'}->{$bench}->{$tune}->{'data'}->[$idx];
                    # Set up 'refs', so references to members will work
                    $tmpref->{'refs'}  = [ $tmpref, $r, $config ];
                    # Set up 'errors', so it's there even if there aren't any
                    $tmpref->{'errors'} = [];
                    # Say what tuning was used
                    $tmpref->{'tune'} = $tune;
                    # Keep track of which one it was
                    $tmpref->{'iteration'} = $idx + 0;
                    # Remember that it was made
                    $seen{"$bench|$tune|$idx"} = 1;
                }
                my $rref = $r->{'results'}->{$bench}->{$tune}->{'data'}->[$idx];
                if ($key eq 'reference') {
                    if (exists $r->{'reference'}->{$bench}) {
                        if ($r->{'reference'}->{$bench} != $value) {
                            Log(0, "Whoa!  Reference time for iteration $idx of $bench ($value) doesn't match the\npreviously recorded reference time of ".$r->{'reference'}->{$bench}."\n");
                        }
                    } else {
                        $r->{'reference'}->{$bench} = $value;
                    }
                }
                if ($key =~ /^(.*?)(\d+)$/o) {
                    # It's an ARRAY 'result' thing
                    $rref->{$1}->[$2] = $value;
                } else {
                    # It's a SCALAR 'result' thing
                    $rref->{$key} = $value;
                }
            } elsif ($what =~ /^compopts(\d+)$/o) {
                my $idx = $1;
                my ($bench, $tune) = @comps;
                $bench =~ s/_/./;
                $compopts->{$bench}->{$tune}->[$idx] = $value;
            } elsif ($what =~ /^compvers(\d+)$/o) {
                my $idx = $1;
                my ($bench, $tune) = @comps;
                $bench =~ s/_/./;
                $compvers->{$bench}->{$tune}->[$idx] = $value;
            } elsif ($what eq 'exehash') {
                my ($bench, $tune) = @comps;
                $bench =~ s/_/./;
                $r->{'results'}->{$bench}->{$tune}->{'exehash'} = $value;
            } else {
                Log(0, "Hey!  Wierd line in raw file:\n$_\n");
                next; # return undef; ?
            }
        }
    }

    my $do_reselect = 0;

    if (istrue($r->{'power'}) && !istrue($config->nopower)) {
        # Make items in the meters list unique
        if (exists($r->{'meterlist'})) {
            foreach my $thing (keys %{$r->{'meterlist'}}) {
                my %tmp = map { $_ => 1 } @{$r->{'meterlist'}->{$thing}};
                $r->{'meterlist'}->{$thing} = [ sort keys %tmp ];
            }
            # Set up the power-related fields
            ::power_info_munge($r);

            # Fix up PTD version strings that may not have been properly
            # populated when the benchmark was run
            ptd_version_fix($r);
        }
    } else {
        # Get rid of all the analyzer/meter-related stuff, and all the
        # calculated fields.
        delete $r->{'meterlist'};
        foreach my $key (keys %{$r}) {
            if ($key =~ /^(?:
                           power_(?!management)
                          |temperature_
                          |[sh]w_power_
                          |hw_temperature_
                          |hw_psu
                          |hw_line_standard$
                          |hw_power_provisioning$
                          |hw_backplane$
                          |hw_other_storage$
                          |hw_storage_model$
                          |hw_other_model$
                          |hw_memory_mode$
                          |hw_nics
                          |fw_management$
                          |test_elevation$
                          |idle_(?:min|avg|max)_hum$
                          |idle_(?:min|avg|max)_temp$
                          |idle_(?:min|avg|max)_power$
                          |(?:min|avg|max)_hum$
                          |(?:min|avg|max)_temp$
                          |(?:min|avg|max)_power$
                          |idle_(?:amp|volt)_range\d*$
                          |(?:amp|volt)_range\d*$
                          )/x) {
                delete $r->{$key};
            }
        }
        $r->{'baseenergymean'} = $r->{'peakenergymean'} = '--';
    }

    # Reconstitute compressed things (or delete them)
    foreach my $key (sort grep { /^compnotes_/ } keys %{$r}) {
        (my $what = $key) =~ s/^compnotes_//;
        my ($orig, $decode, $decomp) = decode_decompress(join("\n", @{$r->{$key}}));
        if (!defined($orig) or !defined($decode) or !defined($decomp)) {
            Log(0, "ERROR: Compressed notes section '$what' could not be extracted.\n");
            Log(0, "\nFormatting aborted\n\n");
            return undef;
        }
        foreach my $noteline (split(/\n/, $decomp)) {
            my ($tag, $val) = ($noteline =~ /^([^:]+): (.*)/);
            my $found = 0;
            foreach my $notere (@::notes_regexps) {
                if ($tag =~ /$notere/) {
                    my ($section, $key, $num) = ($1, $2, $3+0);
                    $found = 1;
                    $r->{$section}->{$key}->[$num] = [ $tag, $val ];
                    $seennote{$tag} = $r->{$section}->{$key}->[$num];
                }
                last if $found;
            }
        }
        delete $r->{$key};
    }

    $r->{'meterranges'} = {};
    foreach my $bench (sort keys %{$r->{'results'}}) {
        foreach my $tune (sort keys %{$r->{'results'}->{$bench}}) {
            my $tref = $r->{'results'}->{$bench}->{$tune}->{'data'};
            next unless (ref($tref) eq 'ARRAY');
            my $all_valid = 1;
            my $median_found = 0;
            foreach my $res (@{$tref}) {
                foreach my $thing (qw(power temp uncertainty hum)) {
                    if (istrue($r->{'power'}) && !istrue($config->nopower)) {
                        # No sample list for uncertainty or humidity
                        next if $thing eq 'uncertainty' || $thing eq 'hum';
                        my $lines = $res->{"${thing}samples"};
                        $lines = join("\n", @{$lines}) if ref($lines) eq 'ARRAY';
                        my ($orig, $decode, $decomp) = decode_decompress($lines);
                        if (!defined($orig) or !defined($decode) or !defined($decomp)) {
                            Log(0, "ERROR: Compressed $thing samples could not be extracted.\n",
                                   "       If you would like to create reports without power, you could try:\n",
                                   "         rawformat --nopower $rawfn\n\n",
                                   "Formatting aborted\n\n");
                            return undef;
                        }
                        $res->{"${thing}samples"} = (defined($decomp)) ? $decomp : $decode;
                    } else {
                        delete $res->{"${thing}samples"};
                        # Go ahead and delete the other power info
                        for my $tmp (qw(min max avg)) {
                            delete $res->{$tmp.'_'.$thing};
                        }
                        delete $res->{'amp_range'};
                        delete $res->{'volt_range'};
                    }
                }
                if (istrue($r->{'power'}) && !istrue($config->nopower)) {
                    ($res->{'powersamples'}, my %tmpranges) = ::extract_ranges($res, $res->{'powersamples'}, '', @{$r->{'meterlist'}->{'power'}});
                    if (%tmpranges) {
                        # Update the hash of ranges used per-meter
                        foreach my $metertag (keys %tmpranges) {
                            $r->{'meterranges'}->{$metertag}->{'amp'}->{$tmpranges{$metertag}->{'amp'}}++;
                            $r->{'meterranges'}->{$metertag}->{'volt'}->{$tmpranges{$metertag}->{'volt'}}++;
                        }
                    }
                    # Re-serialize temperature samples into JSON if necessary
                    $res->{'tempsamples'} = ::reserialize($res->{'tempsamples'});
                } else {
                    delete $res->{'energy'};
                    delete $res->{'energy_ratio'};
                    $res->{'valid'} = 'S' if ($res->{'valid'} =~ /^(?:PE|EE)$/);
                    # Remove PE/EE errors from the per-benchmark errors list.
                    if (exists($res->{'errors'})) {
                        $res->{'errors'} = [ grep { !/^\((?:PE|EE)\)/ } @{$res->{'errors'}} ];
                        delete $res->{'errors'} unless @{$res->{'errors'}};
                    }
                    # Remove 'Run of <benchmark> (<tune>) was not valid; status is PE' messages from the master errors
                    # list.
                    $r->{'errors'} = [ grep { !/$res->{'benchmark'} \($tune\).*status is (?:PE|EE)(?:\s|$)/ } @{$r->{'errors'}} ];
                }
                $all_valid = 0 if $res->{'valid'} ne 'S';
                $median_found = 1 if $res->{'selected'};
            }
            $do_reselect = 1 if ($all_valid == 1 and $median_found == 0);
            if ($all_valid == 1 and exists($r->{'errors'})) {
                # Remove '<benchmark> (<tune>) had invalid runs!' messages from the master errors list.
                $r->{'errors'} = [ grep { !/$tref->[0]->{'benchmark'} \($tune\) had invalid runs!$/ } @{$r->{'errors'}} ];
            }
        }
    }
    delete $r->{'errors'} unless exists($r->{'errors'}) and @{$r->{'errors'}};
    if ($config->nopower) {
        $r->{'invalid'} = 0 if !exists($r->{'errors'});
    }

    # Also deal with the idle power samples and derived data
    foreach my $thing (qw(power temp uncertainty)) {
        if (istrue($r->{'power'}) && !istrue($config->nopower)) {
            next if $thing eq 'uncertainty'; # No sample list
            my $lines = $r->{'idle_'.$thing.'samples'};
            $lines = join("\n", @{$lines}) if ref($lines) eq 'ARRAY';
            my ($orig, $decode, $decomp) = decode_decompress($lines);
            if (!defined($orig) or !defined($decode) or !defined($decomp)) {
                Log(0, "ERROR: Compressed idle $thing samples could not be extracted.\n",
                       "       If you would like to create reports without power, you could try:\n",
                       "         rawformat --nopower $rawfn\n\n",
                       "Formatting aborted\n\n");
                return undef;
            }
            $r->{'idle_'.$thing.'samples'} = (defined($decomp)) ? $decomp : $decode;
        } else {
            delete $r->{'idle_'.$thing.'samples'};
            for my $tmp (qw(min max avg)) {
                delete $r->{'idle_'.$tmp.'_'.$thing};
            }
        }
    }
    if (istrue($r->{'power'}) && !istrue($config->nopower)) {
        ($r->{'idle_powersamples'}, my %tmpranges) = ::extract_ranges($r, $r->{'idle_powersamples'}, 'idle_', @{$r->{'meterlist'}->{'power'}});
        if (%tmpranges) {
            # Update the hash of ranges used per-meter
            foreach my $metertag (keys %tmpranges) {
                $r->{'meterranges'}->{$metertag}->{'amp'}->{$tmpranges{$metertag}->{'amp'}}++;
                $r->{'meterranges'}->{$metertag}->{'volt'}->{$tmpranges{$metertag}->{'volt'}}++;
            }
        }
        # Re-serialize temperature samples into JSON if necessary
        $r->{'idle_tempsamples'} = ::reserialize($r->{'idle_tempsamples'});
    }

    # Shove the list of ranges into the meter areas so they can be reported
    if (istrue($r->{'power'}) && !istrue($config->nopower)) {
        foreach my $metertag (keys %{$r->{'meterranges'}}) {
            $r->{'power_'.$metertag.'_current_range'} = join(', ', list_ranges('A', keys %{$r->{'meterranges'}->{$metertag}->{'amp'}}));
            $::generated_fields{'power_'.$metertag.'_current_range'}++;
            $r->{'power_'.$metertag.'_voltage_range'} = join(', ', list_ranges('V', keys %{$r->{'meterranges'}->{$metertag}->{'volt'}}));
            $::generated_fields{'power_'.$metertag.'_voltage_range'}++;
        }
    }

    # Now load flags if necessary
    if ($ignoreflags) {
        foreach my $flagsurl (grep { defined($_) && $_ ne '' } @{$flagsurls}) {
            if ($flagsurl eq 'noflags') {
                Log(2, "Ignoring existing stored flags file.\n");
                $r->{'flaginfo'}->{'user'} = {};
                $r->{'flags'} = '';
                $r->{'flagsurl'} = [];
                last;
            } else {
                Log(2, "Retrieving flags file ($flagsurl)...\n");
                my ($flags, $flaginfo) = get_flags_file($flagsurl,
                    'user', 0,
                    $config->http_timeout,
                    $config->http_proxy,
                    $r->{'suitever'});
                if (!defined($flaginfo)) {
                    Log(0, "ERROR: No usable flag description found in $flagsurl.\n");
                    Log(0, "\nFormatting aborted\n\n");
                    return undef;
                }
                push @{$r->{'flagsurl'}}, $flagsurl;
                $r->{'flags'} = '' unless $r->{'flags'} ne '';
                $r->{'flaginfo'}->{'user'} = {} unless (::ref_type($r->{'flaginfo'}->{'user'}) eq 'HASH');
                my $rc = merge_flags($flags, \$r->{'flags'}, $flaginfo, $r->{'flaginfo'}->{'user'}, $flagsurl);
                if (!$rc) {
                    Log(0, "ERROR: Flag descriptions in $flagsurl\n       could not be merged with previously read flag descriptions.\n");
                    Log(0, "\nFormatting aborted\n\n");
                    return undef;
                }
            }
        }
        my $compflags = ::compress_encode($r->{'flags'});
        $compflags = '*'.main::encode_base64($r->{'flags'}) if !defined($compflags);
        $r->{'rawflags'} = [ split(/\n/, $compflags) ];
        $r->{'new_flagsurl_used'} = 1;
    }

    # Let's make sure some things are set properly
    if (!exists($r->{'invalid'})) {
        if (exists($r->{'errors'})) {
            if ((ref($r->{'errors'}) eq 'ARRAY') &&
                (@{$r->{'errors'}}+0) > 0) {
                $r->{'invalid'} = 1;
            }
        }
        $r->{'invalid'} = 0 unless $r->{'invalid'};
    } else {
        $r->{'invalid'} = 0 if (!defined($r->{'invalid'}));
    }

    # If 'invalid' was set to indicate a possibly temporary condition (like
    # forbidden or unknown flags used), reset it now.  If the condition
    # persists, it'll get re-set.
    $r->{'invalid'} = 0 if $r->{'invalid'} == 2;

    # Check to see if the overall rawhash matches
    if (exists($r->{'rawhash'}) and exists($r->{'exthash'})) {
        my $genhash = $ctx->hexdigest();

        my $rc = 0;
        my @msgs = ();
        my @failure_header = (
            "\nError: corrupt result file; unable to format.",
            "       (This problem may occur if you edited your raw file using an editor",
            "       that changed the non-user-editable portions of the file.  If you have",
            "       a backup of the original, please restore it and try a different",
            "       editor.)",
        );
        if (lc($r->{'rawhash'}) ne lc($genhash)) {
            push @msgs, @failure_header;
            $rc = 1;
        }

        # Do per-item checking
        my ($exthash, $bits) = unpack_exthash($r->{'exthash'});
        if (!defined($exthash) || ref($exthash) ne 'HASH') {
            push @msgs, "\nError: The result file extended verification checksum information could";
            push @msgs, "       not be reconstructed.";
        } else {
            my ($bad, $added, $changed, $removed) = check_per_item_hash(\%hashfields, $exthash, $bits);
            foreach my $item (@{$added}) {
                push @msgs, "\tThe '$item' field was added.";
            }
            foreach my $item (@{$removed}) {
                push @msgs, "\tThe '$item' field was removed.";
            }
            foreach my $changedref (@{$changed}) {
                my ($item, $stored, $generated) = @{$changedref};
                push @msgs, "\tThe '$item' field was changed.";
                push @msgs, "\t\t  Stored: '$stored'";
                push @msgs, "\t\tObserved: '$generated'";
            }
        }
        if (@msgs) {
            if ($rc == 0) {
                # This only happens if the overall rawhash matches, but
                # the individual items don't.  That should be a HUGE
                # red flag.
                unshift @msgs, @failure_header;
                $rc = 1;
            }
            Log(0, join("\n", @msgs)."\n");
        }
        return undef if $rc;
    } else {
        Log(0, "\nERROR: corrupt result file; unable to format.\n");
        Log(0, "(The file to be formatted contains no checksums.)\n");
        return undef;
    }

    if (exists($r->{'suitever'})) {
        if (!$::from_runcpu) {
            if (($r->{'suitever'} ne 'unknown') &&
                (::normalize_version($r->{'suitever'}) < ::normalize_version($::current_version))) {
                Log(0, "This result was produced by a version of the ${main::suite} suite that is\n  older than the latest production version.\n");
            } elsif (::is_devel($r->{'suitever'})) {
                Log(0, "This result was produced by a NON-RELEASE version of the ${main::suite} suite.\n");
            } elsif ($r->{'suitever'} =~ /dev$/) {
                Log(0, "This result was produced by a DEVELOPMENT version of the ${main::suite} suite.\nIt may not be published.");
            }
        }
    } else {
        Log(0, "The version of the ${main::suite} suite used to produce this result is unknown.  It\n  might not be a release version!\n") unless $::from_runcpu;
        $r->{'suitever'} = 'unknown';
    }
    if (exists($r->{'runcpuver'})) {
        if (($r->{'runcpuver'} ne 'unknown') &&
            ($r->{'runcpuver'} < $::current_runcpu) &&
            !$::from_runcpu) {
            Log(0, "This result was produced by a version of the ${main::suite} tools that is\n  older than the latest production version.\n");
        }
    } else {
        Log(0, "The version of the ${main::suite} tools used to produce this result is unknown.  It\n  might not be a release version!\n") unless $::from_runcpu;
        $r->{'runcpuver'} = 'unknown';
    }

    # Re-serialize toolvers for pre-v1.1 results
    if (exists($r->{'toolvers'}) and ::reftype($r->{'toolvers'}) eq 'ARRAY') {
        my $text = join('', @{$r->{'toolvers'}});
        $r->{'toolvers'} = ::deserialize($text);
        if (!defined($r->{'toolvers'})) {
            # It's a pre-v1.1 thing; pull the versions out into a hash and serialize it
            my ($orig, $decode, $decomp) = ::decode_decompress($text);
            if (!defined($orig) or !defined($decode) or !defined($decomp)) {
                Log(0, "ERROR: Compressed tools version section could not be extracted.\n");
                Log(0, "\nFormatting aborted\n\n");
                return undef;
            }
            my $tmpvers = (defined($decomp)) ? $decomp : $decode;
            $tmpvers = { map { split(/:/) } split(/,/, $tmpvers) };
            $r->{'toolvers'} = [ split(/\n/, scalar(::serialize($tmpvers, 1))) ];
        }
    }

    # Handle command-line NC and NA markings
    if (::ref_type($config->nc) eq 'ARRAY' and
        @{$config->nc} > 0) {
        $r->{'nc'} = $config->nc;
        $r->{'nc_is_na'} = istrue($config->nc_is_na);
        $r->{'nc_is_cd'} = istrue($config->nc_is_cd);
    }

    if ($r->{'size_class'} eq 'ref') {
        # Check the reference time/power information against what is stored
        # in the result object, and either update and recalculate (--recalc)
        # or die if they're different.
        # Probably always a no-op.  If not, something is Wrong

        # We'll also do the base_copies fixup here, for the blind submission
        # runs.
        my $base_copies = undef;

        my $error = 0;
        for my $bench (sort keys %{$r->{'results'}}) {
            my $reftime  = $::global_config->{'benchmarks'}->{$bench}->{'references'}->{$r->{'size'}}->{'time'};
            my $refpower = $::global_config->{'benchmarks'}->{$bench}->{'references'}->{$r->{'size'}}->{'power'};
            for my $tune (sort keys %{$r->{'results'}->{$bench}}) {
                next unless exists($r->{'results'}->{$bench}->{$tune}->{'data'});
                for my $obj (@{ $r->{'results'}{$bench}{$tune}{'data'} }) {
                    next unless ($obj->valid eq 'S');
                    if ($tune eq 'base' and $obj->{'runmode'} =~ /rate$/) {
                        $base_copies = $obj->{'copies'} unless defined($base_copies);
                        if ($obj->{'copies'} != $base_copies and $base_copies > 0) {
                            # Something is wrong
                            ::Log(0, "ERROR: Inconsistent number of copies in base ($base_copies seen); $obj->{'copies'} from $bench:$tune\n");
                            $base_copies = -1;
                        }
                    }
                    if ($obj->{'reference'} != $reftime
                            or $obj->{'reference_power'} != $refpower) {
                        if (istrue($config->accessor_nowarn('recalc'))
                                or (defined($::website_formatter) and $::website_formatter)) {
                            # Get the overall ratios recalculated
                            $do_reselect = 1;
                            $obj->calc_ratio($r->{'size'}, $r->{'size_class'}, $reftime, $refpower);
                        } else {
                            ::Log(0, "ERROR: Reference data mismatch for $bench:$tune; reformat with --recalculate to fix (scores will be recalculated)\n");
                            $error = 1;
                        }
                    }
                }
            }
        }
        $r->{'base_copies'} = $base_copies if $base_copies > 0;
        if ($error) {
            ::Log(0, "\nFormatting aborted\n\n");
            return undef;
        }
    }

    if ($do_reselect or istrue($config->accessor_nowarn('reselect'))) {
        # We are being asked to reselect medians and re-calc ratios.  Probably
        # always a no-op.

        my $multiplier = ($r->runmode eq 'speed') ? $::speed_multiplier : $::rate_multiplier;
        if ($r->runmode eq 'speed' and $r->{'base_copies'} != 1) {
            # This shouldn't be possible
            Log(0, "\nERROR: Multiple copies found recorded in speed result\n");
            return undef;
        }

        my $peakseen = 0;
        foreach my $key (keys %seen) {
            $peakseen = 1 if ($key =~ /\|peak\|/io);
        }
        if ($r->runmode eq 'speed') {
            ($r->{'basemean'}, $r->{'baseenergymean'}) = $r->calc_mean_speed('base');
            ($r->{'peakmean'}, $r->{'peakenergymean'}) = $r->calc_mean_speed('peak') if $peakseen;
        } else {
            ($r->{'basemean'}, $r->{'baseenergymean'}) = $r->calc_mean_rate('base');
            ($r->{'peakmean'}, $r->{'peakenergymean'}) = $r->calc_mean_rate('peak') if $peakseen;
        }
    }

    # If a flags file was NOT specified on the command line, go ahead and
    # parse the flags in the raw file.
    if (!$ignoreflags) {
        my $rawflags = (ref($r->{'rawflags'}) eq 'ARRAY') ? join("\n", @{$r->{'rawflags'}}) : $r->{'rawflags'};
        my $parsed = 0;
        if (exists $r->{'flagsurl'} && (::ref_type($r->{'flagsurl'}) ne 'ARRAY')) {
            my $flagsurl = $r->{'flagsurl'};
            $r->{'flagsurl'} = [];
            push @{$r->{'flagsurl'}}, $flagsurl if $flagsurl ne '';
        }
        if ($rawflags ne '' &&
            (!exists($r->{'flagsurl'}) ||
                (exists $r->{'flagsurl'} &&
                    !grep { /^noflags$/ } @{$r->{'flagsurl'}}))) {
            my ($orig, $decode, $decomp) = decode_decompress($rawflags);
            if (!defined($orig) or !defined($decode) or !defined($decomp)) {
                Log(0, "ERROR: Compressed flags files could not be extracted.\n");
                Log(0, "\nFormatting aborted\n\n");
                return undef;
            }
            $r->{'flags'} = (defined($decomp)) ? $decomp : $decode;
            if ($r->{'flags'} =~ /<flagsdescription>/) {
                $r->{'flaginfo'}->{'user'} = main::parse_flags( $r->{'flags'}, undef, 'user', undef, 'forbid' => [ 'mandatory' ], 'suiteversion' => $r->{'suitever'} );
                if (!defined($r->{'flaginfo'}->{'user'})) {
                    Log(0, "ERROR: No usable flag description found.\n");
                    Log(0, "\nFormatting aborted\n\n");
                    return undef;
                }
                $parsed = 1;
            }
        }
        if ($parsed == 0) {
            if (exists($r->{'flagsurl'}) && @{$r->{'flagsurl'}}) {
                foreach my $flagsurl (grep { defined($_) && $_ ne '' } @{$r->{'flagsurl'}}) {
                    if ($flagsurl eq 'noflags') {
                        $r->{'flags'} = '';
                        $r->{'flagsurl'} = [];
                        $r->{'flaginfo'}->{'user'} = {};
                        delete $r->{'rawflags'};
                        last;
                    } else {
                        Log(2, "Retrieving flags file ($flagsurl)...\n");
                        my ($flags, $flaginfo) = get_flags_file($flagsurl,
                            'user', 0,
                            $config->http_timeout,
                            $config->http_proxy);
                        if (!defined($flaginfo)) {
                            Log(0, "ERROR: No usable flag description found in $flagsurl.\n");
                            Log(0, "\nFormatting aborted\n\n");
                            return undef;
                        }
                        $r->{'flags'} = '' unless $r->{'flags'} ne '';
                        $r->{'flaginfo'}->{'user'} = {} unless (::ref_type($r->{'flaginfo'}->{'user'}) eq 'HASH');
                        my $rc = merge_flags($flags, \$r->{'flags'}, $flaginfo, $r->{'flaginfo'}->{'user'}, $flagsurl);
                        if (!$rc) {
                            Log(0, "ERROR: Flag descriptions in $flagsurl\n       could not be merged with previously read flag descriptions.\n");
                            Log(0, "\nFormatting aborted\n\n");
                            return undef;
                        }
                    }
                }
                my $compflags = ::compress_encode($r->{'flags'});
                $compflags = '*'.main::encode_base64($r->{'flags'}) if !defined($compflags);
                $r->{'rawflags'} = [ split(/\n/, $compflags) ];
            } else {
                Log(0, "\nWARNING: Neither stored flags information nor flags file URL was found.\n") unless ($::from_runcpu);
                # But be sure to put an object in anyway...
                $r->{'flaginfo'}->{'user'} = {};
            }
        }
    }
    # Make sure the result gets copies of the other flaginfos, too:
    foreach my $flaggroup (keys %{$config->{'flaginfo'}}) {
        next if $flaggroup eq 'user';
        $r->{'flaginfo'}->{$flaggroup} = $config->{'flaginfo'}->{$flaggroup};
    }

    # If being published at SPEC, grab the publication or acceptance date from
    # the pathname.
    my $rawpath = File::Basename::dirname(::unrel_path($rawfn));
    if (defined($::website_formatter) && $::website_formatter) {
        if ($rawpath =~ m#/appr(\d{4})(\d{2})(\d{2})(?:/|$)#) {
            $r->{'accepted_date'} = str2time("$1:$2:$3T00:00:00.00");
        }
        if ($rawpath =~ m#/pub(\d{4})(\d{2})(\d{2})(?:/|$)#) {
            $r->{'published_date'} = str2time("$1:$2:$3T00:00:00.00");
        }
    }

    # At SPEC, store the flags files in a common place.  If there's already
    # a copy there, use it!  If not, make one and be sure to format it so
    # that it can be linked.
    if (defined($::website_formatter) && $::website_formatter) {
        # Empty out the lists of previously seen flags filenames, since we have
        # definitely already processed these files once before, and thus the
        # checks that these variables enable have already been made.
        %::seen_flags_filenames = ();
        %::seen_flags_files = ();

        if (defined($r->{'flags'}) && $r->{'flags'} ne '') {
            $r->{'flagsurl'} = [ ::store_flags_file($r->{'flags'}, $r->{'flaginfo'}->{'user'}, $rawpath) ];
        } else {
            $r->{'flagsurl'} = [];
        }
    } else {
        delete $r->{'flags'};
    }

    # Put the compile options back into the result object
    foreach my $bench (keys %{$compopts}) {
        next unless ref($compopts->{$bench}) eq 'HASH';
        foreach my $tune (keys %{$compopts->{$bench}}) {
            next unless ref($compopts->{$bench}->{$tune}) eq 'ARRAY';
            my ($opts, $decode, $decomp) =
                decode_decompress(join("\n", @{$compopts->{$bench}->{$tune}}));
            if (!defined($opts) or !defined($decode) or !defined($decomp)) {
                Log(0, "ERROR: Compressed compiler options for $bench $tune could not be extracted.\n");
                Log(0, "\nFormatting aborted\n\n");
                return undef;
            }
            my $compile_options = defined($decomp) ? $decomp : defined($decode) ? $decode : $opts;
            $r->{'compile_options'}->{$bench}->{$tune} = '';
            # In some cases in CPU2006 it was observed that cmd.exe's echo
            # built-in would omit the trailing line ending when certain escaped
            # characters were printed.  This resulted in some compile options
            # lines that should have been parsed being appended to lines that
            # were not parsed, and as a result caused flag reporting errors for
            # some benchmarks.
            # The code below is meant to recover somewhat from that situation.
            # Most (99.2%) of the time this should not do anything.
            foreach my $line (split(/\n/, $compile_options)) {
                $line =~ s/[^[:print:] \t]/?/g;
                if ($line =~ s/(.)\b([CPO]: [^[:space:]=]+.*)/$1/) {
                    $r->{'compile_options'}->{$bench}->{$tune} .= $line."\n";
                    $line = $2;
                    redo;
                } else {
                    $r->{'compile_options'}->{$bench}->{$tune} .= $line."\n";
                }
            }
        }
    }

    # Put the compiler version info back into the result object
    foreach my $bench (keys %{$compvers}) {
        next unless ref($compvers->{$bench}) eq 'HASH';
        foreach my $tune (keys %{$compvers->{$bench}}) {
            next unless ref($compvers->{$bench}->{$tune}) eq 'ARRAY';
            my ($opts, $decode, $decomp) =
                decode_decompress(join("\n", @{$compvers->{$bench}->{$tune}}));
            if (!defined($opts) or !defined($decode) or !defined($decomp)) {
                Log(0, "ERROR: Compressed compiler version information for $bench $tune could not be extracted.\n");
                Log(0, "\nFormatting aborted\n\n");
                return undef;
            }
            $r->{'compiler_version'}->{$bench}->{$tune} = defined($decomp) ? $decomp : defined($decode) ? $decode : $opts;
        }
    }

    # Grab the mail settings...
    $r->{'mail'} = {};
    foreach my $key (qw(mailto mailmethod mailserver mailport username
        lognum logname mail_reports)) {
        $r->{'mail'}->{$key} = $config->accessor_nowarn($key);
    }
    $r->{'mail'}->{'compress'} = istrue($config->accessor_nowarn('mailcompress'));
    $r->{'mail'}->{'runcpu_argv'} = $config->accessor_nowarn('runcpu_argv') || 'Command line not available';

    # Fix up the raw file indices
    if (exists($r->{'cfidx'})) {
        my $text = join('', @{$r->{'cfidx'}});
        my $cfidx = ::deserialize($text);
        if (!defined($cfidx)) {
            # pre-v1.1 this had home-made serialization
            (my $orig, my $decode, $text) = ::decode_decompress($text);
            if (!defined($orig) or !defined($decode) or !defined($text)) {
                Log(0, "ERROR: Compressed config file line info could not be extracted.\n");
                Log(0, "\nFormatting aborted\n\n");
                return undef;
            }
            $cfidx = { map { split(/:/) } split(/,/, $text) };
        }
        foreach my $item (keys %$cfidx) {
            $r->{'cfidx_'.$item} = $cfidx->{$item};
        }

    }
    delete $r->{'cfidx'};

    # Deal with the [hw_vendor, test_sponsor, tester] mess up front, instead of
    # making the formatters deal with it.
    my $hw_vendor_tag = 'hw_vendor';
    if ($::lcsuite eq 'mpi2007') {
        $hw_vendor_tag = 'system_vendor';
    }
    my @hw_vendor    = ::allof($r->accessor_nowarn($hw_vendor_tag));
    my @test_sponsor = ::allof($r->accessor_nowarn('test_sponsor'));
    my @tester       = ::allof($r->accessor_nowarn('tester'));
    if (   @hw_vendor > 0 && defined($hw_vendor[0])
        && (@test_sponsor <= 0 || $test_sponsor[0] =~ /^(|--)$/)) {
        if (@hw_vendor == 1) {
            $r->{'test_sponsor'} = $hw_vendor[0];
        } else {
            $r->{'test_sponsor'} = [ @hw_vendor ];
        }
        @test_sponsor = @hw_vendor;
    }
    if (   @test_sponsor > 0 && defined($test_sponsor[0])
        && (@tester <= 0 || $tester[0] =~ /^(|--)$/)) {
        if (@test_sponsor == 1) {
            $r->{'tester'} = $test_sponsor[0];
        } else {
            $r->{'tester'} = [ @test_sponsor ];
        }
    }

    # Compress the notes -- they will probably have gaps in them
    foreach my $section (grep { /^$::mpi_desc_re_id?notes/ } keys %{$r}) {
        next unless (::ref_type($r->{$section}) eq 'HASH');
        foreach my $key (keys %{$r->{$section}}) {
            next unless (::ref_type($r->{$section}->{$key}) eq 'ARRAY');
            ::squeeze_undef($r->{$section}->{$key});
        }
    }

    if ($config->info_wrap_columns) {   # Most likely!
        # Split long lines for informational fields.
        # These changes will be propagated back into the config file.
        foreach my $system ('', keys %{$r->{'mpi_items'}}) {
            my $itemre;
            if ($system eq '') {
                $itemre = qr/^(?:hw_|sw_)/;
            } else {
                $itemre = qr/^\Q$system\E(?:hw_|sw_|interconnect|label)/;
            }
            foreach my $item (sort ::bytag grep { /$itemre/ } keys %{$r}) {
                my $value = $r->{$item};
                # The default (50 characters) seems like a reasonable limit for
                # things that will only get half the width of a page.
                if (ref($value) eq 'ARRAY') {
                    # It's already multiple lines!
                    for(my $i = 0; $i < @{$value}; $i++) {
                        next if length($value->[$i]) <= $config->info_wrap_columns;
                        Log(0, "\nNOTICE: $item$i is longer than ".$config->info_wrap_columns." characters and will be split\n");
                        my @newlines = ::wrap_lines([$value->[$i]], $config->info_wrap_columns, '', 0, 1);
                        if (@newlines > 1) {
                            # A wrap happened; splice it back in to the array
                            splice @{$value}, $i, 1, @newlines;
                        }
                    }
                } else {
                    next if length($value) <= $config->info_wrap_columns;
                    Log(0, "\nNOTICE: $item is longer than ".$config->info_wrap_columns." characters and will be split\n");
                    my @newlines = ::wrap_lines([$value], $config->info_wrap_columns, '', 0, 1);
                    if (@newlines > 1) {
                        # A wrap happened; the value is now an array
                        $r->{$item} = [ @newlines ];
                    }
                }
            }
        }
    }

    if ($::lcsuite eq 'mpi2007') {
        # These will get back-propagated into the config file, but life is
        # hard like that sometimes
        unless (grep { /^node_/ } keys %{$r->{'mpi_items'}}) {
            Log(0, "\nWARNING: There are no node descriptions present!  A fake one will be provided.\n\n");
            $r->{'mpi_items'}->{'node_forgotten_'} = [ 'node', 'forgotten' ];
            $r->{'node_forgotten_label'} = 'Nonexistent Node';
            $r->{'node_forgotten_notes'}->{''} = [ [ 'notes0', 'I forgot to describe any nodes in my config file or raw file!' ] ];
        }
    }

    # Now (whee!) fix up the stored config file, if any of the lines don't
    # match any more.
    my @idxitems = reverse sort ::bytag grep { s/^cfidx_// } keys %{$r};
    my ($orig, $decode, $decomp) = ::decode_decompress(join("\n", @{$r->{'rawconfig'}}));
    if (!defined($orig) or !defined($decode) or !defined($decomp)) {
        Log(0, "ERROR: Stored configuration file could not be extracted.\n");
        Log(0, "\nFormatting aborted\n\n");
        return undef;
    }
    $r->{'txtconfig'} = [ split(/\n/, $decomp, -1) ];
    delete $r->{'rawconfig'};
    if (exists($r->{'origconfig'})) {
        my ($orig, $decode, $decomp) = ::decode_decompress(join("\n", @{$r->{'origconfig'}}));
        if (!defined($orig) or !defined($decode) or !defined($decomp)) {
            Log(0, "ERROR: Stored original configuration file could not be extracted.\n");
            Log(0, "\nFormatting aborted\n\n");
            return undef;
        }
        $r->{'orig_raw_config'} = [ split(/\n/, $decomp, -1) ];
        $r->{'orig_raw_good'} = 1;
    } else {
        # Save off a copy of the orig config (if one isn't already done).
        # Later on we'll delete it if orig_raw_good isn't set.  This is done
        # because now it sometimes gets modified before update_stored_config
        # sees it.
        @{$r->{'orig_raw_config'}} = @{$r->{'txtconfig'}};
    }

    # First go through and fix up any lines that still exist.  Also notice
    # which are gone.
    my %missing = ();
    foreach my $idxitem (@idxitems) {
        next unless exists($r->{'cfidx_'.$idxitem});  # Might have been deleted
        my ($now, $is_missing) = (undef, 0);
        my $old = $idxitem;
        my $line = $r->{'cfidx_'.$idxitem};
        my $was = $r->{'txtconfig'}->[$line];
        if ($idxitem =~ /^(.*?)(\d+)$/) {
            # An array thing.
            my ($item, $idx) = ($1, $2);
            if (!exists($seennote{$idxitem}) && !exists($r->{$item})) {
                # It's gone in the raw file.  Mark it for deletion.
                $is_missing = 1;
            } elsif ($idxitem !~ /^$::mpi_desc_re_id?notes/ &&
                (::ref_type($r->{$item}) ne 'ARRAY') &&
                $idx != 0) {
                if (exists($r->{'cfidx_'.$item})) {
                    # A bug in pre-relase tools could cause duplicate indices
                    # to be inserted for single-element items with indices > 0
                    # in the config file.  Rewriting will fail because the
                    # tags are similar, so just suppress the original.
                    delete $r->{'cfidx_'.$item};
                    next;
                }
                # It was a single thing in the config file, but has become a
                # multi thing in the raw file.  Mark it for deletion.
                $is_missing = 1;
            } else {
                if ($item =~ /^$::mpi_desc_re_id?notes/) {
                    # Notes are special because their indices do not (except
                    # for notes000) correspond to their array positions.
                    # Also, notes are arrays internally.
                    $now = $seennote{$idxitem}->[1];
                } else {
                    if (ref($r->{$item}) ne 'ARRAY') {
                        $idxitem = $item;
                        $now = $r->{$item};
                    } else {
                        $now = $r->{$item}->[$idx];
                    }
                }
            }
        } else {
            # An easy, normal single thing
            if (!exists($r->{$idxitem})) {
                # Item no longer present or has become multi-valued; mark its
                # line for deletion.
                $is_missing = 1;
                if ($idxitem eq 'tools_added_default_section' &&
                    $r->{'txtconfig'}->[$r->{'cfidx_'.$idxitem}] =~ /^\s*default[=:]/) {
                    # Oh, it's not missing after all...
                    $is_missing = 0;
                }
            } else {
                $now = $r->{$idxitem};
                if (ref($r->{$idxitem}) eq 'ARRAY') {
                    $now = $r->{$idxitem}->[0];
                    $idxitem .= '000';
                }
            }
        }
        if ($is_missing) {
            # Put it on the dead list
            $missing{$idxitem} = 1;
        } else {
            # Get the position of the current line (if it exists); it'll
            # be used in a few different places below.
            my $pos = exists($r->{'cfidx_'.$idxitem}) ? $r->{'cfidx_'.$idxitem} : undef;

            # Strip any block quote markers, as they may cause the match
            # to falsely fail.  This will also save the marker, because
            # if the value really _has_ changed we'll have to strip everything
            # to the marker from the config file.  This is really only
            # a concern for single-value block quotes, as the notes splitter
            # will take care of the others.
            my $blockquote = undef;
            if ($was =~ s/^(\s*\Q${idxitem}\E\s*=\s*)<<(\S+)\s*$/$1/) {
                $blockquote = $2;
                # What's more, the value that the tools will think should be
                # on that line is actually on the _next_ line.  So fake it
                # up here... if it's been changed, it'll all get munged anyway.
                if ($r->{'txtconfig'}->[$pos+1] !~ /^$blockquote\s*$/) {
                    # If the next line is the end marker, then the note is
                    # empty; otherwise it's what's here.
                    $was .= $r->{'txtconfig'}->[$pos+1];
                }
            }
            # See if the old and the new values match.  The config file
            # line has the variable _and_ the value, so take that into
            # account.
            if ($idxitem ne 'tools_added_default_section' &&
                $was !~ /^\s*\Q${idxitem}\E\s*=\s*\Q${now}\E(?:\s*#.*)?$/) {
                # It changed, so update it
                if (defined($blockquote) && $blockquote ne '' &&
                    defined($pos) && $pos ne '') {
                    # We know that the line that started the block will
                    # be changed or deleted, so go ahead and erase up to
                    # and including the end marker.
                    my $lines = 1;
                    while($r->{'txtconfig'}->[$pos+$lines] !~ /^$blockquote\s*$/) {
                        $lines++;
                    }
                    splice @{$r->{'txtconfig'}}, $pos+1, $lines;
                    ::shift_indices($r, $pos+1, -$lines);
                }
                my $curr_action;
                if (defined($now) && $now ne '') {
                    ::Log(15, "Stored config: Updating \"$idxitem\"".($old ne $idxitem ? " (formerly \"$old\")" : '')."\n");
                    $curr_action = 'Update';
                } else {
                    ::Log(15, "Stored config: Deleting \"$idxitem\"\n");
                    $curr_action = 'Deletion';
                }
                if (!::update_stored_config($r, $old, $idxitem, $now, 1)) {
                    ::Log(0, "ERROR: Edit of stored config file failed; $curr_action of $idxitem failed.\n");
                } elsif ($was =~ /\\\s*$/) {
                    # The line we just fixed up was part of a continuation,
                    # so it's important to remove the rest of them.
                    $pos = $r->{'cfidx_'.$idxitem};  # Might be different now
                    if (defined($pos) && $pos ne '') {  # Just in case
                        my $lines = 1;
                        while($r->{'txtconfig'}->[$pos + $lines] =~ /\\\s*$/) {
                            $lines++;
                        }
                        # It is intentional that this removes one more line
                        # than ends with a backslash.
                        splice @{$r->{'txtconfig'}}, $pos+1, $lines;
                        ::shift_indices($r, $pos+1, -$lines);
                    }
                }
            }
        }
    }

    # Process additions of non-notes items
    foreach my $info_item (grep { /$::info_re/ } sort ::bytag keys %{$r}) {
        next if $info_item =~ /^$::mpi_desc_re_id?notes/; # Notes are special
        next if exists($::generated_fields{$info_item});  # Skip generated ones
        next if ($info_item eq 'sw_auto_parallel');
        if (ref($r->{$info_item}) eq 'ARRAY') {
            # Process each item separately
            for (my $i = 0; $i < @{$r->{$info_item}}; $i++) {
                my $tag = sprintf '%s%03d', $info_item, $i;
                my $neighbor = undef;
                my $text = $r->{$info_item}->[$i];
                next unless defined($text) && $text ne '';

                if (!exists($r->{'cfidx_'.$tag})) {
                    $neighbor = get_neighbor_idx($r, $r->{$info_item}, $i, $info_item);

                    if (defined($neighbor) && $neighbor ne '') {
                        $tag = "$tag:$neighbor";
                        ::Log(15, "Stored config: Adding new \"$tag\" \@ $neighbor\n");
                    } else {
                        ::Log(15, "Stored config: Adding new \"$tag\" \@ EOF\n");
                    }
                    if (!::update_stored_config($r, undef, $tag, $text, 1)) {
                        ::Log(0, "ERROR: Addition of '$tag' to stored config file failed.\n");
                    }
                }
            }
        } else {
            # It's just a single thing.
            if ($r->{$info_item} ne '--' && $r->{$info_item} ne '' &&
                !exists($r->{'cfidx_'.$info_item})) {
                my $pos = find_singleton_pos($r, $info_item);
                my $tag = $info_item;
                ::Log(15, "Stored config: Adding new \"$tag\" \@ ".(defined($pos) ? $pos : 'EOF')."\n");
                $tag .= ":$pos" if defined($pos);
                if (!::update_stored_config($r, undef, $tag, $r->{$info_item}, 1)) {
                    ::Log(0, "ERROR: Addition of '$info_item' to stored config file failed.\n");
                }
            }
        }
    }

    # Go through all notes, wrapping (if necessary), doing additions, and
    # renumbering.
    foreach my $section (grep { /^$::mpi_desc_re_id?notes/ } keys %{$r}) {
        next unless ref($r->{$section}) eq 'HASH';
        foreach my $key (keys %{$r->{$section}}) {
            my $notesref = $r->{$section}->{$key};
            next unless ref($notesref) eq 'ARRAY';
            for (my $i = 0; $i < @{$notesref}; $i++) {
                my $neighbor = undef;
                my $tag = $notesref->[$i]->[0];
                my $text = $notesref->[$i]->[1];

                if (!exists($r->{'cfidx_'.$tag})) {
                    my $neighbor = get_neighbor_idx($r, $notesref, $i, undef, 0);
                    if (defined($neighbor) && $neighbor ne '') {
                        $tag = "$tag:$neighbor";
                        ::Log(15, "Stored config: Adding new \"$tag\" \@ $neighbor\n");
                    } else {
                        ::Log(15, "Stored config: Adding new \"$tag\" \@ EOF\n");
                    }
                    if (!::update_stored_config($r, undef, $tag, $text, 1)) {
                        ::Log(0, "ERROR: Addition of '$tag' to stored config file failed.\n");
                    }
                }
            }

            # So that it's possible to fix up the stored config file and the
            # associated indices, wrap the notes lines one by one
            if ($config->notes_wrap_columns > 0) {
                for(my $i = 0; $i < @{$notesref}; $i++) {
                    my ($tag, $note) = @{$notesref->[$i]};
                    if (length($note) >= $config->notes_wrap_columns) {
                        my @repl;
                        ($note, undef) = ::protect_notes_links($note, \@repl);
                        my @newlines = main::wrap_lines( [ $note ],
                                                         $config->notes_wrap_columns,
                                                         $config->notes_wrap_indent,
                                                         1, 0);
                        @newlines = map { ::unprotect_notes_links($_, \@repl) } @newlines;
                        if (@newlines > 1) {
                            # A line was wrapped
                            $seennote{$tag} = $notesref->[$i] = [ $tag, shift(@newlines) ];
                            splice @{$notesref}, $i + 1, 0, map { [ undef, $_ ] } @newlines;
                        }
                    }
                }
            }
        }
    }

    # Process deletions
    foreach my $idxitem (sort ::bytag keys %missing) {
        ::Log(15, "Stored config: Deleting \"$idxitem\"\n");
        if (!::update_stored_config($r, $idxitem)) {
            ::Log(0, "ERROR: Edit of stored config file failed; Could not delete line for $idxitem\n");
        }
    }

    # Actually do the renumbering now.  It's important to process deletions
    # first to handle the case where an existing notes line wants to be
    # renumbered to the name of a line that's been deleted in the raw file
    ::renumber_notes($r, 2, 0);

    # Add in the ever-present and immutable submit notes line
    if ($r->{'submit'}) {
        $r->{'notes_submit'} = {} unless (::ref_type($r->{'notes_submit'}) eq 'HASH');
        my $fullnotes = '';
        my $notes = $r->{'notes_submit'};
        foreach my $key (sort keys %{$r->{'notes_submit'}}) {
            next unless (::ref_type($notes->{$key}) eq 'ARRAY');
            my $val = $notes->{$key};
            for (my $i = 0; $i < @$val; $i++) {
                $fullnotes .= ' '.$val->[$i]->[1];
            }
        }
        # Compress whitespace
        $fullnotes =~ tr/ \011\012\015/ /s;
        my $submitnote = "The config file option 'submit' was used";
        if ($fullnotes !~ /$submitnote/i) {
            if ($config->notes_wrap_columns > 0
                    and length($submitnote)+1 > $config->notes_wrap_columns) {
                my @newlines = main::wrap_lines( [ "${submitnote}." ],
                    $config->notes_wrap_columns,
                    $config->notes_wrap_indent,
                    1, 0);
                unshift @{$r->{'notes_submit'}->{''}}, map { [ undef, $_ ] } @newlines;
            } else {
                unshift @{$r->{'notes_submit'}->{''}}, [ undef, "${submitnote}." ];
            }
        }
    }

    # Any of the transformations that remove or replace result information
    # should produce ONLY a raw file as output.  That makes it difficult to
    # not notice that the transformation was done.
    # To enforce raw-only output, it's necessary to twiddle a few things in
    # $config...
    my $rawhandle;
    if (   (istrue($config->nopower) && istrue($r->{'power'}))
        || (istrue($config->nopeak) && grep { /^peak$/ } @{$r->{'tunelist'}})
        || (exists($config->{'bp_bench'}) && ($r->{'basepeak'} >= 0 && $r->{'basepeak'} <= 2))
    ) {
        $rawhandle = ::get_format($config->formats, 'raw');
        $config->{'formatlist'} = [ $rawhandle ];
    }

    # Finish getting rid of power info
    if (istrue($config->nopower) && istrue($r->{'power'})) {
        $r->{'power'} = 0;
        # Make sure that the raw file has a unique name (though this _is_ a bad
        # way to go about it...
        $rawhandle->{'extension'} = 'nopower.'.$rawhandle->{'extension'} unless $rawhandle->{'extension'} =~ /nopower/;
    }

    # Do basepeak (if asked nicely)
    if (exists($config->{'bp_bench'}) &&
        ($r->{'basepeak'} >= 0 && $r->{'basepeak'} <= 2)) {
        my @benchmarks = (ref($config->{'bp_bench'}) eq 'ARRAY') ? ::expand_all(@{$config->bp_bench}) : ();
        my @bp_message = (
            '# The following setting was inserted automatically as a result of',
            '# post-run basepeak application.',
            'basepeak = 1',
            ''
        );
        # Make sure that the raw file has a unique name (though this _is_ a bad
        # way to go about it...
        $rawhandle->{'extension'} = 'basepeak.'.$rawhandle->{'extension'} unless $rawhandle->{'extension'} =~ /basepeak/;

        if (!@benchmarks && $config->{'bp_bench'} eq 'full') {
            # --basepeak was specified, but without arguments
            $r->{'basepeak'} = 1;
            if (!grep { /^peak$/ } @{$r->{'tunelist'}}) {
                push @{$r->{'tunelist'}}, 'peak';
            }
            ::basepeak_munge($r);
            # Total basepeak results have no peak flags
            foreach my $bench (@benchmarks) {
                delete $r->{'compile_options'}->{$bench}->{'peak'};
                delete $r->{'compiler_version'}->{$bench}->{'peak'};
            }
            # Fix up the config file; add bp_message on the first line
            # following comments
            my $i = 0;
            for($i = 0; $i < $#{$r->{'txtconfig'}}; $i++) {
                last unless $r->{'txtconfig'}->[$i] =~ /^\#/;
            }
            splice @{$r->{'txtconfig'}}, $i, 0, ('', @bp_message);
            # Now fix up all the indices that we've shifted
            ::shift_indices($r, $i, @bp_message+1);
        } else {
            if (grep { /\|peak\|/ } keys %seen) {
                for(my $i = 0; $i < @benchmarks; $i++) {
                    if (exists($config->{'benchsets'}->{$benchmarks[$i]})) {
                        splice @benchmarks, $i, 1, sort keys %{$config->{'benchsets'}->{$benchmarks[$i]}->{'benchmarks'}};
                        redo;
                    }
                    my $temp = find_benchmark($config, $benchmarks[$i]);
                    if (!defined($temp) || ::ref_type($temp) eq 'ARRAY') {
                        if (::ref_type($temp) eq 'ARRAY') {
                            Log(0, "Could not parse '$benchmarks[$i]' into a benchmark; too many matches: ".join(', ', @{$temp})."\n");
                        } else {
                            Log(0, "Could not parse '$benchmarks[$i]' into a benchmark!\n");
                        }
                        splice @benchmarks, $i, 1;
                        redo if $i < @benchmarks;
                    } else {
                        splice @benchmarks, $i, 1, $temp->benchmark;
                    }
                }
                # Per-benchmark basepeak results have copies of base flags
                # Also, put in a config section for them.
                my $insert_point = @{$r->{'txtconfig'}}+0;
                if (exists($r->{'cfidx_tools_added_default_section'})) {
                    $insert_point = $r->{'cfidx_tools_added_default_section'};
                }
                foreach my $bench (@benchmarks) {
                    $r->{'compile_options'}->{$bench}->{'peak'} = $r->{'compile_options'}->{$bench}->{'base'};
                    $r->{'compiler_version'}->{$bench}->{'peak'} = $r->{'compiler_version'}->{$bench}->{'base'};
                    splice @{$r->{'txtconfig'}}, $insert_point, 0, ('', "${bench}:", @bp_message);
                    # Now fix up all the indices that we've shifted
                    ::shift_indices($r, $insert_point, @bp_message+2);
                }
                $r->{'basepeak'} = 2;
                ::basepeak_munge($r, 1, @benchmarks);
            } else {
                Log(0, "ERROR: Cannot apply per-benchmark basepeak to base-only run!\n");
                return undef;
            }
        }
        if ($r->runmode eq 'speed') {
            ($r->{'basemean'}, $r->{'baseenergymean'}) = $r->calc_mean_speed('base');
            ($r->{'peakmean'}, $r->{'peakenergymean'}) = $r->calc_mean_speed('peak');
        } else {
            ($r->{'basemean'}, $r->{'baseenergymean'}) = $r->calc_mean_rate('base');
            ($r->{'peakmean'}, $r->{'peakenergymean'}) = $r->calc_mean_rate('peak');
        }
    }

    # Or just get rid of peak stuff altogether...
    elsif (istrue($config->nopeak) && grep { /^peak$/ } @{$r->{'tunelist'}}) {
        # Make sure that the raw file has a unique name (though this _is_ a bad
        # way to go about it...
        $rawhandle->{'extension'} = 'nopeak.'.$rawhandle->{'extension'} unless $rawhandle->{'extension'} =~ /nopeak/;

        # Take peak out of the tunings list
        @{$r->{'tunelist'}} = grep { !/^peak$/ } @{$r->{'tunelist'}};

        # Base-only results have neither peak flags nor results
        foreach my $bench (keys %{$r->benchmarks}) {
            delete $r->{'compile_options'}->{$bench}->{'peak'};
            delete $r->{'compiler_version'}->{$bench}->{'peak'};
            delete $r->{'results'}->{$bench}->{'peak'};
        }

        # Likewise, no other peak-specific fields
        $r->{'peakmean'} = 'Not Run';
        $r->{'peakenergymean'} = 'Not Run';
        $r->{'sw_peak_ptrsize'} = 'Not Applicable';

        # The config file should probably be fixed up to do base-only, but
        # that'd be a big worthless pain.
    }

    make_compiler_version_notes($r, $config->notes_wrap_columns);

    make_environment_notes($r, $config->notes_wrap_columns);

    # Remove the mailto addresses from the stored configs
    if (defined($::website_formatter) && $::website_formatter) {
        my $re = '(?:mailto';
        foreach my $strip_item (qw(http_proxy ftp_proxy)) {
            $re .= "|$strip_item";
        }
        $re = qr/^(\s*$re)\s*=).*/;
        foreach my $cfg (qw(txtconfig orig_raw_config)) {
            next unless (exists($r->{$cfg}) && (::ref_type($r->{$cfg}) eq 'ARRAY'));
            $r->{$cfg} = [ map { s/$re/$1/; $_ } @{$r->{$cfg}} ];
        }
    }

    # Finally, restore the rawconfig
    $r->{'rawconfig'} = [ grep { $_ ne ''} split(/\n/, ::compress_encode(join("\n", @{$r->{'txtconfig'}})), -1) ];
    delete $r->{'txtconfig'};
    if ($r->{'orig_raw_good'}) {
        $r->{'origconfig'} = [ split(/\n/, ::compress_encode(join("\n", @{$r->{'orig_raw_config'}}))) ];
    }
    delete $r->{'orig_raw_good'};

    # If different graph settings have been specified, copy them in
    foreach my $what (qw(graph_min graph_max graph_auto)) {
        if (defined($config->accessor_nowarn($what))) {
            $r->{$what} = $config->accessor_nowarn($what);
        }
    }

    # Break up the MPI-specific system descriptions for the formatters
    foreach my $key (keys %{$r}) {
        next unless ($key =~ m/$::mpi_desc_re(.+)/);
        my ($type, $tag, $item) = ($1, $2, $3);
        $r->{$type}->{$tag}->{$item} = $r->{$key};
    }

    if ($::lcsuite eq 'mpi2007') {
        ::generate_mpi_totals($r, $r);
        ::min_max_base_ranks($r, [qw(peak base)]);
    } else {
        ::min_max_base_threads($r);
        # Assemble the hw_ncpu field from the various components
        $r->{'hw_ncpu'} = ::assemble_cpu_description($r);
    }

    return $r;
}

# Produce a sorted list of range values with units appended.  Negative values are converted to the word "Auto".
sub list_ranges {
    my ($unit, @vals) = @_;
    @vals = map {
                    if (looks_like_number($_)) {
                        if ($_ < 0) {
                            "Auto"
                        } else {
                            $_+0
                        }
                    } else {
                        $_
                    }
                } @vals;
    return (
        (                 sort { $a cmp $b } grep { !looks_like_number($_) } @vals),
        (map { $_.$unit } sort { $a <=> $b } grep {  looks_like_number($_) } @vals),
    );
}

sub deserialize_env {
    my ($envref) = @_;
    my $text;

    if (ref($envref) ne 'HASH') {
        $text = (ref($envref) eq 'ARRAY') ? join('', @{$envref}) : $envref;
        if ($text eq '') {
            return {};
        }
        else {
            my $tmp = ::deserialize($text);
            return $tmp if (defined($tmp) and ref($tmp) eq 'HASH');
        }
    }
    return $envref;
}

sub note_env_info {
    my ($r, $envref, $columns, $label) = @_;
    return unless ref($envref) eq 'HASH' and %$envref;

    my @newlines = main::wrap_lines([ $label ], $columns, '', 0, 0);
    push @newlines, main::wrap_lines(
        [ map { "$_ = \"$envref->{$_}\"" } sort keys %$envref ],
        $columns, '     ', 0, 0);
    push @newlines, '';
    push @{$r->{'notes_envvars'}->{''}}, map { [ undef, $_ ] } @newlines;
}

# Add in notes about environment variables set by the tools at user request (preENV_* or ENV_*).
# This has the side-effect of deserializing the data if necessary.
sub make_environment_notes {
    my ($r, $columns) = @_;
    my $text;

    # Even if no notes_wrap_column is set, wrap the compiler version stuff
    # at a place that makes it look reasonable in PDF.
    $columns = 78 if $columns <= 0;

    $r->{'notes_envvars'} = {};
    $r->{'notes_envvars'}->{''} = [];

    # First, preenv...
    $r->{'env'} = deserialize_env($r->{'env'});
    note_env_info($r, $r->{'env'}, $columns, 'Environment variables set by runcpu before the start of the run:');

    # Then all of the benchmark stored environment
    foreach my $bench (sort keys %{$r->{'results'}}) {
        for my $tune (sort keys %{$r->{'results'}{$bench}}) {
            next unless (::ref_type($r->{'results'}{$bench}{$tune}{'data'}) eq 'ARRAY');
            # Only log settings from either the first selected iteration, or the first one run if none are selected.
            # They SHOULD all be the same, but I think it might be possible to sneak an iteration number in there or
            # something like that, so just in case.
            my @selected = (
                (grep { $_->{'selected'} } @{$r->{'results'}{$bench}{$tune}{'data'}}),
                @{$r->{'results'}{$bench}{$tune}{'data'}},
            );
            $selected[0]->{'env'} = deserialize_env($selected[0]->{'env'});
            note_env_info($r, $selected[0]->{'env'}, $columns,
                "Environment variables set by runcpu during the $bench $tune run:");
        }
    }
}


# Add in the compiler version notes.  Shorten them to the extent possible.
# Hopefully it won't become common practice to use different compilers
# for different FDO passes, or this will get even longer and uglier.
sub make_compiler_version_notes {
    my ($r, $columns) = @_;

    # Even if no notes_wrap_column is set, wrap the compiler version stuff
    # at a place that makes it look reasonable in PDF.
    $columns = 78 if $columns <= 0;

    # Gather up compiler info by benchmark and tuning level.  Make two
    # maps -- one from version info string to benchmarks that use it,
    # and one from bench/lang/pass to text.  If the text for all lang/pass
    # match, then we can omit the pass information.  Otherwise, not.
    my %used_by = ();
    my %vers_seen = ();
    my %print_pass = ();

    my $note_version_info = sub {
        my ($vers, $lang, $bench, $tune, $pass) = @_;
        return unless ref($vers) eq 'ARRAY' and @$vers;

        my $vers_string = join("\n", @$vers);
        push @{$used_by{$vers_string}->{$lang}->{$bench}->{$tune}}, $pass;
        if (exists($vers_seen{$bench.$tune.$lang})) {
            $print_pass{$bench.$tune}++ if $vers_string ne $vers_seen{$bench.$tune.$lang};
        } else {
            $vers_seen{$bench.$tune.$lang} = $vers_string;
        }
    };

    my $long_lang_len = 0;
    foreach my $bench (sort keys %{$r->{'compiler_version'}}) {
        my $bench_vers = $r->{'compiler_version'}->{$bench};
        foreach my $tune (sort keys %{$bench_vers}) {
            my ($pass, $lang, @langs, @vers);
            $print_pass{$bench.$tune} = 0;
            foreach my $line (split(/\012|\015/, $bench_vers->{$tune})) {
                if ($line =~ /^\s*$/) {
                    next;
                } elsif ($line =~ /^(?:PASS(\d+)[_ ])?\s*([^_]+)_VERSION_OPTION:$/) {
                    my ($newpass, $newlang) = ($1 + 0, $2);
                    push @langs, $newlang;
                    $lang = join(', ', (map { $::langvar_to_name{$_} } distinct @langs));
                    &{$note_version_info}(\@vers, $lang, $bench, $tune, $pass);
                    @vers = ();
                    $pass = $newpass;
                } else {
                    push @vers, $line;
                }
            }
            $long_lang_len = length($lang) if (length($lang) > $long_lang_len);
            &{$note_version_info}(\@vers, $lang, $bench, $tune, $pass);
        }
    }

    $r->{'notes_compvers'} = {};
    $r->{'notes_compvers'}->{''} = [];
    my $lang_sep    = '='x$columns;
    my $section_sep = '-'x$columns;
    # It's a little more work to order sections by language, but let's do it because otherwise it's not obvious that
    # the sections are ordered by the text of the compiler version output.
    my @langs = sort map { keys %$_ } values %used_by;
    foreach my $lang (@langs) {
        foreach my $opts (sort keys %used_by) {
            next unless exists($used_by{$opts}->{$lang});
            my $langref = $used_by{$opts}->{$lang};
            my @benchlist;
            foreach my $bench (sort keys %{$langref}) {
                my $benchref = $langref->{$bench};
                my @tunes = (sort keys %{$benchref});
                my @tunelist = ();
                foreach my $tune (@tunes) {
                    if ($print_pass{$bench.$tune}) {
                        push @tunelist, map { "$tune pass $_" } @{$benchref->{$tune}};
                    } else {
                        push @tunelist, $tune;
                    }
                }
                my $tunelist = join(', ', @tunelist);
                push @benchlist, $bench.'('.join(', ', @tunelist).')';
            }
            push @{$r->{'notes_compvers'}->{''}}, [ undef, $lang_sep ];
            my $fullnotes = sprintf "%*s | %s", -$long_lang_len, $lang, join(' ', @benchlist);
            my @newlines = ($fullnotes);
            if (length($fullnotes) > $columns) {
                @newlines = main::wrap_lines([@newlines], $columns,
                                            (' 'x$long_lang_len).' | ', 0, 1);
            }
            push @newlines, $section_sep;
            push @newlines, main::wrap_lines([split(/\n/, $opts)], $columns,
                                            '  ', 0, 1);
            push @newlines, $section_sep;
            push @newlines, '';
            push @{$r->{'notes_compvers'}->{''}}, map { [ undef, $_ ] } @newlines;
        }
    }
    # Get rid of the last trailing blank line
    pop @{$r->{'notes_compvers'}->{''}} if @{$r->{'notes_compvers'}->{''}};
}

sub get_neighbor_idx {
    my ($r, $itemarray, $idx, $tag, $tagidx) = @_;
    my $neighbortag;
    my $neighbor = 0;

    # Figure out which neighbor should provide position info
    # for us.
    # If there's a previous thing, put it right after.
    # If there's a next thing, put it right before.
    # Otherwise just put it at the end.

    if ($idx > 0 && defined($itemarray->[$idx - 1])) {
        $neighbor = -1;
    } elsif ($idx < @{$itemarray} - 1 &&
        defined($itemarray->[$idx + 1])) {
        $neighbor = 1;
    }
    if (!defined($tagidx)) {
        # Make up the tag
        $neighbortag = sprintf 'cfidx_%s%03d', $tag, $idx + $neighbor;
    } else {
        # Get the tag from item
        return undef unless ref($itemarray->[$idx + $neighbor]) eq 'ARRAY';
        $neighbortag = 'cfidx_'.$itemarray->[$idx + $neighbor]->[$tagidx];
    }
    $neighbor = exists($r->{$neighbortag}) ? $r->{$neighbortag} - $neighbor : undef;

    return $neighbor;
}

sub find_singleton_pos {
    # Find a neighbor for $tag.  Since it's not part of an array, we can't
    # find the previous or next item of the same thing.  So...
    my ($r, $tag) = @_;
    my ($i, $p, $n) = 0;
    for ($i = 0; $i < @::field_order && $::field_order[$i] ne $tag; $i++) {
    }
    # Now $i points to the position within @::field_order
    for (my $diff = 1; $diff < @::field_order / 2; $diff++) {
        # Go for the next line after the previous field first
        if ($i - $diff >= 0) {
            if (exists($r->{'cfidx_'.$::field_order[$i - $diff]})) {
                my $newpos = $r->{'cfidx_'.$::field_order[$i - $diff]} + 1;
                ::Log(98, "Using line after ".$::field_order[$i - $diff]." for $tag (line number $newpos)\n");
                return $newpos;
            }
        }
        # If that's no good, try for the line before the next field
        if ($i + $diff <= $#::field_order) {
            if (exists($r->{'cfidx_'.$::field_order[$i + $diff]})) {
                my $newpos = $r->{'cfidx_'.$::field_order[$i + $diff]};
                ::Log(98, "Using line before ".$::field_order[$i + $diff]." for $tag (line number $newpos)\n");
                return $newpos;
            }
        }
    }

    return undef;
}

# In at least some versions of ACCEL and possibly other benchmarks,
# the composite PTD version field that should be populated at run
# time isn't.  The components should all be present, though, so
# it can be fixed up in the formatter.
sub ptd_version_fix {
    my ($r) = @_;

    return unless exists($r->{'meterlist'});
    foreach my $powerthing (qw(power temperature)) {
        foreach my $meter (@{$r->{'meterlist'}->{$powerthing}}) {
            my $tag = $powerthing.'_'.$meter.'_';
            if (exists($r->{$tag.'version'}) && $r->{$tag.'version'} =~ /^(?:--)?$/) {
                $r->{$tag.'version'} = $r->{$tag.'ptd_full_version'}.' ('.$r->{$tag.'ptd_crc'}.'; '.$r->{$tag.'ptd_build_date'}.')';
                if ($r->{$tag.'version'} eq ' (; )') {
                    # i.e. no other information was available
                    $r->{$tag.'version'} = '--';
                    ::Log(3, "WARNING: Failed to regenerate PTD version string for ${powerthing}_$meter\n");
                } else {
                    ::Log(7, "Successfully regenerated PTD version string for ${powerthing}_$meter (".$r->{$tag.'version'}.")\n");
                }
            }
        }
    }
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab colorcolumn=120:
