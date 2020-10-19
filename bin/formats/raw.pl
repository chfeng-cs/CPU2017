#
#  raw.pl - produces RAW output
#  Copyright 1995-2019 Standard Performance Evaluation Corporation
#
#  Authors:  Christopher Chan-Nui
#            Cloyce D. Spradling
#
# $Id: raw.pl 6278 2019-07-06 22:10:10Z CloyceS $

use strict;
use IO::File;
require 'util_common.pl';

our ($name, $extension, $synonyms, $prefix, $part_of_all, $non_default);

$name      = 'raw';
$extension = 'rsf';
$synonyms  = { map { lc($_) => 1 } ($name, $extension) };
$prefix = "spec.$::lcsuite";

my $version = '$LastChangedRevision: 6278 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'raw.pl'} = $version;
$part_of_all = 1;    # Part of '-o all' (just to be clear)

sub format {
    my($me, $r, $fn) = @_;
    my @output;
    my $written = [];
    # Some keys should not be put into the raw file, so mark them as already
    # dumped.
    my %dumped = map { $_ => 1 } qw(
                                    benchmarklist datestr rawfile compraw
                                    rawhash flagsinfo output orig_raw_config
                                    do_dump graph_min graph_max graph_auto
                                    forbiddenused unknownused
                                    accepted_date published_date
                                    allow_extension_override output_root
                                    expid review topdir flags test train ref
                                    size_class mpi_items orig_raw_good
                                    speed_multiplier rate_multiplier exthash
                                    nopeak nopower recalc reselect
                                    metricbase unitbase
                                   );
    $dumped{$$.'auto2par'} = 1;
    # Figure out whether to dump or ignore the sw_auto_parallel setting
    if ($::lcsuite eq 'mpi2007') {
        $dumped{'sw_auto_parallel'} = 1;  # Keep it out of the editable section
    }

    my @keys = grep { !/(^refs|^benchmarks|auto2par)$/ } $r->list_keys;

    # Make sure that the suite versions exist and are integrated properly
    if (!grep { /^suitever$/o } @keys) {
        $r->{'suitever'} = $::suite_version;
        push @keys, 'suitever';
    }
    if (!grep { /^suitehash$/o } @keys) {
        $r->{'suitehash'} = ::get_suitehash(::jp($ENV{'SPEC'}, 'MANIFEST'));
        push @keys, 'suitehash';
    }
    if (!grep { /^runcpuver$/o } @keys) {
        $r->{'runcpuver'} = $::version;
        # Strip off the leading 'v' that's added to make other outputs nice.
        $r->{'runcpuver'} =~ s/^\D*//;
        push @keys, 'runcpuver';
    }
    if (!grep { /^toolset$/o } @keys) {
        $r->{'toolset'} = $::toolset_name;
        push @keys, 'toolset';
    }
    if (!grep { /^toolshash$/o } @keys) {
        $r->{'toolshash'} = $::file_sums{'manifest|TOOLS.sha512'};
        push @keys, 'toolshash';
    }


    # Likewise, power measurements
    if ($::lcsuite eq 'mpi2007' and $r->{'suitever'} < 1.1) {
        $dumped{'power'} = 1;
        $dumped{'powersamples'} = 1;
        $dumped{'tempsamples'} = 1;
    }

    if ($::lcsuite eq 'cpu2017') {
        # These shouldn't be present, but just in case...
        $dumped{'ranks'} = 1;
        $dumped{'base_ranks'} = 1;
        $dumped{'system_class'} = 1;
        $dumped{'hw_total_nodes'} = 1;
        $dumped{'hw_total_chips'} = 1;
        $dumped{'hw_total_cores'} = 1;
        $dumped{'hw_total_threads'} = 1;
        $dumped{'hw_total_memory'} = 1;
        $dumped{'max_ranks'} = 1;
        $dumped{'max_peak_ranks'} = 1;
    } elsif ($::lcsuite eq 'mpi2007') {
        # These shouldn't be present, but just in case...
        $dumped{'copies'} = 1;
        $dumped{'base_copies'} = 1;
        $dumped{'threads'} = 1;
        $dumped{'base_threads'} = 1;
        $dumped{'max_threads'} = 1;
        $dumped{'max_peak_threads'} = 1;
    } elsif ($::lcsuite =~ /^omp/) {
        # These shouldn't be present, but just in case...
        $dumped{'copies'} = 1;
        $dumped{'base_copies'} = 1;
        $dumped{'ranks'} = 1;
        $dumped{'base_ranks'} = 1;
        $dumped{'max_ranks'} = 1;
        $dumped{'max_peak_ranks'} = 1;
    }
    my $base_fn = $fn;
    $base_fn =~ s/\.\Q${extension}\E$//;
    $base_fn =~ s/\.\Q${extension}\E$// if $::rawformat_time && $::from_runcpu;

    # Generated fields should not be dumped, or people will think that they
    # can be edited in the raw file.
    foreach my $genfield (keys %::generated_fields) {
        $dumped{$genfield} = 1 if ($::generated_fields{$genfield} == 1);
    }

    # Dump configuration info
    for my $key (sort main::bytrailingnum @keys) {
        next if $dumped{$key};
        next if exists $::generated_fields{$key} && $::generated_fields{$key};
        next unless ($key =~ /$::info_re/);
        next if $key =~ /^$::mpi_desc_re_id?notes/;   # Notes are special now.
        next if $key =~ /^flagsurl\d*$/;                  # As are flagsurls
        $dumped{$key} = 1;
        my $val = $r->accessor($key);
        # Fix up dynamic entries for missing items
        if ($key =~ /!/) {
            $key =~ s/!/MISSING/;
            $dumped{$key} = 1;
        }
        if ((::ref_type($val) eq 'ARRAY')) {
            for (my $i = 0; $i < @$val; $i++) {
                next unless defined($val->[$i]);        # Handle holes
                push @output, sprintf("%s.%s%03d: %s", $prefix, $key, $i, $val->[$i]);
            }
        } elsif (ref $val eq '') {
            push (@output, sprintf "%s.%s: %s", $prefix, $key, $val);
        }
    }

    # Dump the notes (except for sysinfo).  We do this separately so that the
    # numbers can be spaced properly.
    (my $tmpnotes, undef) = dump_notes($r, \%dumped, $base_fn, $written, undef, qr/^sysinfo$/, 0);
    push @output, @{$tmpnotes};

    # Trim trailing whitespace from all fields.  This shouldn't be necessary,
    # as the config file and raw file parsers should remove them.  But just
    # in case someone manages to sneak one through...
    foreach my $line (@output) {
        $line =~ tr/\015\012//d; # More reliable than the double chomp
        # Strip all trailing whitespace
        $line =~ s/\s+$//;
        # Put one space back if it needs to be there
        $line =~ s/^(\Q${prefix}\E\.[\.A-Za-z0-9_-]+:)$/$1 /;
    }

    # Print a little delimiter
    push @output, '# =============== do not edit below this point ===================';

    # From here on in, we make a hash of all the lines, as well as each item
    my ($ctx, $bits, $hashalgo) = ::get_hash_context($::global_config->accessor_nowarn('rawhash_bits') + 0);
    return undef unless defined($ctx);
    my @hashlist = ();          # Here's where we store the info to be hashed
    my %hashfields = ();        # Same, (no comments), as array per field

    if ($r->{'invalid'} == 0) {
        # If any of the individual runs were not valid, the whole result should
        # be not valid
        my %seen = ();
        for my $bench (sort keys %{$r->{'results'}}) {
            for my $tune (sort keys %{$r->{'results'}{$bench}}) {
                next unless (::ref_type($r->{'results'}{$bench}{$tune}{'data'}) eq 'ARRAY');
                foreach my $res (@{$r->{'results'}{$bench}{$tune}{'data'}}) {
                    next unless (::ref_type($res) eq 'HASH');
                    if ($res->{'valid'} ne 'S') {
                        if (!$seen{$bench.$tune}) {
                            # When changing this error message, also update the raw file parser or
                            # 'rawformat --nopower' will break.
                            push @{$r->{'errors'}}, "Run of $bench ($tune) was not valid; status is $res->{'valid'}";
                            $seen{$bench.$tune} = 1;
                            $r->{'invalid'} = 1;
                            $r->{'valid'} = 'X';
                            if (!grep { /^errors$/o } @keys) {
                                push @keys, 'errors';
                            }
                        }
                    }
                }
            }
        }
    }

    if (!grep { /^invalid$/o } @keys) {
        # Make sure that invalid results have an invalid tag:
        if (!exists($r->{'invalid'})) {
            if (exists($r->{'errors'})) {
                if ((ref($r->{'errors'}) eq 'ARRAY') &&
                    (@{$r->{'errors'}}+0) > 0) {
                    $r->{'invalid'} = 1;
                    $r->{'valid'} = 'X';
                }
            } else {
                $r->{'invalid'} = 0;
            }
        } else {
            $r->{'invalid'} = 0 if (!defined($r->{'invalid'}));
        }
        push @keys, 'invalid';
    }

    # If the result is otherwise fine, but forbidden or unknown flags were
    # used, mark it as 'temporarily invalid'.  This will get stored in the
    # raw file so that the submission handler can see it, but is treated by
    # the formatter the same as if it were set to 0.
    if ($r->{'invalid'} == 0) {
        $r->{'invalid'} = 2 if ($r->{'forbiddenused'} || $r->{'unknownused'});
    }

    if (0
        # CVT2DEV: || 1
    ) {
        if (!exists($r->{'errors'})
            || (exists($r->{'errors'}) && (::ref_type($r->{'errors'}) eq 'ARRAY')
                && !grep { /This result was run using a development tree/ } @{$r->{'errors'}}
               )
           ) {
            push @{$r->{'errors'}}, 'This result was run using a development tree; results from this may not be',
                                    'published or used externally.';
            if (!grep { /^errors$/o } @keys) {
                push @keys, 'errors';
            }
        }
    }
    if (!grep { /^lognum$/o } @keys) {
        $r->{'lognum'} = $::global_config->accessor_nowarn('lognum') || 'Unknown';
        push @keys, 'lognum';
    }

    # Put all the cfidx items together.  In most cases it will make them take
    # less space.
    my ($enc, $raw) = ::serialize({ map { $dumped{$_}++; substr($_, 6) => $r->accessor($_) } sort ::bytag grep { /^cfidx_/ } @keys }, 1);
    my @complines = split(/\n/, (defined($enc) and $enc ne '') ? $enc : $raw);
    $r->{'cfidx'} = [ @complines ];
    push @keys, 'cfidx';

    if (!exists($r->{'toolvers'}) or ref($r->{'toolvers'}) ne 'ARRAY') {
        if (!exists($r->{'toolvers'})) {
            # Mash up the various file versions
            ($enc, $raw) = ::serialize(\%::tools_versions, 1);
        } else {
            # Just serialize what's there
            ($enc, $raw) = ::serialize($r->{'toolvers'}, 1);
        }
        @complines = split(/\n/, (defined($enc) and $enc ne '') ? $enc : $raw);
        $r->{'toolvers'} = [ @complines ];
        push @keys, 'toolvers';
    }

    # Some things simply _must_ be dumped
    foreach my $important_thing (@{$r->{'do_dump'}}) {
        delete $dumped{$important_thing};
    }

    # Dump non-configuration, non-result info (leftovers)
    for my $key (sort @keys) {
        next if $dumped{$key};
        my $val = $r->accessor($key);
        if ($key eq 'size') {
            my $class = $r->accessor('size_class');
            $val = "$val ($class)" if ($val ne $class);
        }
        # For flagsurls, put a little warning comment above them
        if ($key eq 'flagsurl') {
            if ((::ref_type($val) eq 'ARRAY')) {
                # Eliminate holes
                $val = [ grep { defined($_) && $_ ne '' } @$val ];
            }
            if (   ((::ref_type($val) eq 'ARRAY') && @$val >= 1)
                || ((::ref_type($val) ne 'ARRAY') && $val ne '')) {
                if ((::ref_type($val) eq 'ARRAY') && @$val > 1) {
                    push @hashlist, '# This result was formatted with the flags files mentioned on the following';
                    push @hashlist, '# lines. Please do NOT attempt to apply a new flags file by changing them;';
                } else {
                    push @hashlist, '# This result was formatted with the flags file mentioned on the following';
                    push @hashlist, '# line. Please do NOT attempt to apply a new flags file by changing it;';
                }
                push @hashlist, '# to load new flag definitions, you need to use "rawformat --flagsurl".';
            }
        }
        # For power/temp-related raw records, squeeze them down
        elsif ($key =~ /(?:power|temp)samples$/) {
            $val = squeeze_data_structure($key, $val);
        }
        elsif ($key =~ /env$/) {
            if (ref($val) eq 'HASH' and %$val) {
                $val = squeeze_data_structure($key, $val);
            } else {
                $val = '';
            }
        }

        if ((::ref_type($val) eq 'ARRAY')) {
            for (my $i = 0; $i < @$val; $i++) {
                push @hashlist, sprintf("%s.%s%03d: %s", $prefix, $key, $i, $val->[$i]);
            }
            $hashfields{$key} = [ @{$val} ] if @{$val};
        } elsif (ref $val eq '') {
            push @hashlist, sprintf("%s.%s: %s", $prefix, $key, $val);
            $hashfields{$key}->[0] = $val;
        }
        $dumped{$key} = 1;
    }

    # Dump the sysinfo notes.
    ($tmpnotes, my $tmphashlist) = dump_notes($r, \%dumped, $base_fn, $written, qr/^sysinfo$/, qr/.?/, 1);
    if (@{$tmpnotes}) {
        push @hashlist, @{$tmpnotes};
        foreach my $hkey (keys %{$tmphashlist}) {
            $hashfields{$hkey} = $tmphashlist->{$hkey};
        }
    }

    # Make sure there are stored compile options...
    if (!exists($r->{'compile_options'})) {
        Log(0, "\nERROR: No saved compile options in the result object!\n");
        main::do_exit(1);
    }

    # Dump result info
    for my $bench (sort keys %{$r->{'results'}}) {
        my $benchname = $bench;
        $benchname =~ y/\./_/;
        for my $tune (sort keys %{$r->{'results'}{$bench}}) {
            next unless (::ref_type($r->{'results'}{$bench}{$tune}{'data'}) eq 'ARRAY');
            my @tmp = sort { $a->{'iteration'} <=> $b->{'iteration'} } @{$r->{'results'}{$bench}{$tune}{'data'}};
            for (my $i = 0; $i < @tmp; $i++) {
                for my $key (sort keys %{$tmp[$i]}) {
                    next if $key eq 'ref' || $key eq 'refs' || $key eq 'tune';
                    # For power/temp-related raw records, squeeze them down
                    my $val = $tmp[$i]->{$key};
                    if ($key =~ /^(?:power|temp)samples$/) {
                        $val = squeeze_data_structure($key, $val);
                    }
                    elsif ($key =~ /env$/) {
                        if (ref($val) eq 'HASH' and %$val) {
                            $val = squeeze_data_structure($key, $val);
                        } else {
                            $val = '';
                        }
                    }
                    my $partkey = sprintf 'results.%s.%s.%03d.%s', $benchname, $tune, $i, $key;
                    if (ref($val) eq 'ARRAY') {
                        my @tmp2 = @{$val};
                        for (my $j = 0; $j < @tmp2; $j++) {
                            push @hashlist, sprintf("%s.%s%03d: %s",
                                                   $prefix, $partkey, $j, $tmp2[$j]);
                        }
                        $hashfields{$partkey} = [ @tmp2 ] if @tmp2;
                    } else {
                        push @hashlist, sprintf("%s.%s: %s",
                                               $prefix, $partkey, $tmp[$i]->{$key});
                        $hashfields{$partkey} = [ $tmp[$i]->{$key} ];
                    }
                }
            }

            # Dump the compile options so that flag reports can be generated
            # with just the raw file.
            if (exists($r->{'compile_options'}->{$bench}) &&
                exists($r->{'compile_options'}->{$bench}->{$tune})) {
                my $opts = $r->{'compile_options'}->{$bench}->{$tune};
                if ($opts =~ /:/o) {
                    # It's probably not compressed or anything...
                    $opts = ::compress_encode($opts);
                }
                my @optlist = split(/\n+/, $opts);
                for (my $i = 0; $i < @optlist; $i++) {
                    my $partkey = sprintf 'compopts%03d.%s.%s', $i, $benchname, $tune;
                    push @hashlist, sprintf("%s.%s: %s",
                                           $prefix, $partkey, $optlist[$i]);
                    $hashfields{$partkey} = [ $optlist[$i] ];
                }
            }

            # Dump the compiler version info for later inspection.
            if (exists($r->{'compiler_version'}->{$bench}) &&
                exists($r->{'compiler_version'}->{$bench}->{$tune})) {
                my $vers = $r->{'compiler_version'}->{$bench}->{$tune};
                if ($vers =~ /:/o) {
                    # It's probably not compressed or anything...
                    $vers = ::compress_encode($vers);
                }
                my @verslist = split(/\n+/, $vers);
                for (my $i = 0; $i < @verslist; $i++) {
                    my $partkey = sprintf 'compvers%03d.%s.%s', $i, $benchname, $tune;
                    push @hashlist, sprintf("%s.%s: %s",
                                           $prefix, $partkey, $verslist[$i]);
                    $hashfields{$partkey} = [ $verslist[$i] ];
                }
            }
        }
    }

    foreach my $line (@hashlist) {
        $line =~ tr/\015\012//d; # More reliable than the double chomp
        # Also remove trailing spaces, etc...
        $line =~ s/\s+$//;
        # Put one space back if it needs to be there
        $line =~ s/^(\Q${prefix}\E\.[\.A-Za-z0-9_-]+:)$/$1 /;
    }
    $ctx->add(@hashlist);
    push @output, "$prefix.rawhash: ".$ctx->hexdigest();
    $bits =$::global_config->accessor_nowarn('exthash_bits') + 0;
    if ($bits > 0) {
        my @exthash = ::generate_exthash(\%hashfields, $bits);
        for(my $i = 0; $i < @exthash; $i++) {
            push @output, sprintf "$prefix.exthash%03d: %s", $i, $exthash[$i];
        }
    }
    push @output, @hashlist;

    # Make sure we save a copy of the rawfile in the result object:
    if (!exists $r->{'compraw'}) {
        my (undef, $comp, $enc) = ::compress_encode(join("\n", @output)."\n");
        if (defined($comp)) {
            $r->{'rawfile'} = undef;
            $r->{'compraw'} = $enc;
        } else {
            $r->{'rawfile'} = $enc;
            $r->{'compraw'} = undef;
        }
    }

    # If forbidden or unknown flags were used, add a note to errors.
    # This isn't done before, because we don't want to permanently mark
    # them as invalid (for that reason only) in the raw file.
    if ($r->{'forbiddenused'}) {
        push @{$r->{'errors'}}, 'Forbidden flags were used!';
    }
    if ($r->{'unknownused'}) {
        if (!exists $r->{'errors'}
            || (::ref_type($r->{'errors'}) ne 'ARRAY')
            || @{$r->{'errors'}} == 0) {
            push @{$r->{'errors'}}, 'Your run was marked invalid because it has one or more flags in the',
                                    '"unknown" category. You might be able to resolve this problem without',
                                    're-running your test; see',
                                    "     $::docs_url_base/runcpu.html#flagsurl",
                                    'for more information.';
        } else {
            # There are other errors, so do not hold out the false hope of
            # correction without a re-run.
            push @{$r->{'errors'}}, 'Unknown flags were used! See',
                                    "     $::docs_url_base/runcpu.html#flagsurl",
                                    'for information about how to get rid of this error.';
        }
    }

    if (exists($r->{'flags'}) && $r->{'flags'} ne '' &&
        $r->{'flags'} =~ /<flagsdescription>/) {
        # Save off a copy of the flags file source
        my $flag_file = $base_fn.'.xml';
        my $ofh = new IO::File '>'.$flag_file;
        if (defined($ofh)) {
            $ofh->print($r->{'flags'});
            $ofh->close();
            push @{$written}, $flag_file;
        } else {
            ::Log(0, "Couldn't open $flag_file for writing: $!\n");
        }
    }

    return (\@output, $written);
}

sub Log { main::Log(@_) }

sub squeeze_data_structure {
    my ($key, $val) = @_;

    my ($raw, $enc);
    if (ref($val) ne '') {
        ($enc, $raw) = ::serialize($val, 1);
    }
    elsif (::is_encoded($val)) {
        $enc = $val;
    }
    else {
        ($raw, my $comp, $enc) = ::compress_encode($val);
    }
    return [ split(/\n/, (defined($enc) and $enc ne '') ? $enc : $raw) ];
}

# Dump the notes.
# It should always be an array, but just in case it isn't, give it the
# full treatment.
sub dump_notes {
    my ($result, $dumped, $base_fn, $written, $tag_inc_re, $tag_excl_re, $compress) = @_;
    my $output = [];
    my $hashfields = {};

    # 'nowarn' because there might not be any notes
    foreach my $system ('', keys %{$result->{'mpi_items'}}) {
        foreach my $section (map { $_->[0] } @::notes_info) {
            next unless (::ref_type($result->{$system.$section}) eq 'HASH');
            $dumped->{$system.$section} = 1;
            next if "$system$section" =~ /notes_auto2par/;
            foreach my $key (sort keys %{$result->{$system.$section}}) {
                my $val = $result->{$system.$section}->{$key};
                next unless (::ref_type($val) eq 'ARRAY');
                next if defined($tag_excl_re) and $key =~ /$tag_excl_re/ and !(defined($tag_inc_re) and $key =~ /$tag_inc_re/);
                my $rawtext = '';
                for (my $i = 0; $i < @$val; $i++) {
                    my ($tag, $text) = @{$val->[$i]};
                    next unless defined($tag);
                    if (!defined($result->accessor_nowarn('config'))  # True on initial generation
                            or (grep { $_->{'name'} ne 'Reportable Check' } @{$result->config->formatlist}) > 1) {
                        # If formats other than just raw are being generated,
                        # look in the line for ATTACH statements, and deal with
                        # the files if necessary
                        $text = ::handle_ATTACH($text, $base_fn, $written);
                    }
                    if ($compress) {
                        # Just accumulate the text; it will be compressed later
                        $rawtext .= "$tag: $text\n";
                    } else {
                        # Store them normally
                        push @{$output}, "$prefix.$tag: $text";
                        $text =~ s/\s+$//;
                        ($tag, my $idx) = $tag =~ /(\S+?)_?(\d*)$/;
                        $hashfields->{$tag}->[$idx+0] = $text;
                    }
                }
                if ($compress) {
                    # Compress the stored raw text and dump that
                    my ($raw, $comp, $enc) = ::compress_encode($rawtext);
                    my @complines = split(/\n/, (defined($enc) && $enc ne '') ? $enc : $raw);
                    for(my $i = 0; $i < @complines; $i++) {
                        push @{$output}, sprintf "$prefix.compnotes_$key%03d: $complines[$i]", $i;
                        $hashfields->{"compnotes_$key"}->[$i] = $complines[$i];
                    }
                }
            }
        }
    }
    return ($output, $hashfields);
}

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab colorcolumn=120:
