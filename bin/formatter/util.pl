#
# util.pl
#
# Copyright 1999-2019 Standard Performance Evaluation Corporation
#
# $Id: util.pl 6255 2019-06-11 15:37:45Z CloyceS $

use strict;
use Carp qw(carp);
use List::Util qw(min);

require 'listfile.pm';
require 'util_common.pl';

my $version = '$LastChangedRevision: 6255 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'formatter_util.pl'} = $version;

sub get_basepeak_parallel_info {
    my ($results, $config, $what) = @_;

    my $min = undef;
    my $basepeak = undef;       # Unless the results say otherwise...
    my %parallel = ();
    my $parallel = 'copies';
    if ($::lcsuite eq 'mpi2007') {
        $parallel = 'ranks';
    } elsif ($::lcsuite eq 'omp2012'
            or ($::lcsuite eq 'cpu2017' and $config->runmode eq 'speed')) {
        $parallel = 'threads';
    }

    # Scan the results to find the min and max copies/threads/ranks and whether
    # or not basepeak is going on...
    foreach my $tune (sort keys %{$results}) {
        next unless ref($results->{$tune});
        foreach my $run (@{$results->{$tune}->{'data'}}) {
            # Once it gets set, don't let it get unset (except when the
            # first run says it WAS, and the second run says it WASN'T).
            # It shouldn't happen.
            $basepeak = $run->{'basepeak'} unless defined($basepeak) and ($basepeak == 0);
            my @data = map { $run->{$_} } @$what;
            push @data, $min if defined($min);
            $min = min(@data);
            $parallel{$tune} = $run->{$parallel} if $run->{'selected'};
        }
    }
    # Even if basepeak is set, don't do the basepeak bar unless peak was run
    $basepeak = undef unless exists($results->{'peak'});

    return ($min, $basepeak, %parallel);
}

sub write_and_format_flags {
    my ($listfile, $entry, $basename, $flagtext, $flags) = @_;

    my $fh = new IO::File '>'.$basename.'.xml';
    if (!defined($fh)) {
        ::Log(0, "\nERROR: Could not open ${basename}.xml for writing: $!\n");
        my $cksum = $entry->{'hash'};
        $entry->delete();
        $listfile->remove_entry('hash' => $cksum);
        $listfile->update();
        $listfile->close();
        do_exit(1);
    }
    $fh->print($flagtext);
    $fh->close();

    # Now dump it.  Because of the advent of multiple flags files, it MAY
    # be the case that the structure in $flags is a superset of what's
    # described in $flagtext.  So just to be sure, re-parse $flagtext and
    # dump _that_.  (It's faster than just calling flag_dump.)
    if ($fh->open('>'.$basename.'.html')) {
        # It's okay if this fails, since it can be re-done by hand
        my $tmpflags = parse_flags($flagtext, $basename, 'user', 1, 'forbid' => [ 'mandatory' ], 'suiteversion' => 'select');
        if (defined($tmpflags) && exists($tmpflags->{'flagmap'})) {
            Spec::Format::flags::flags_to_html($tmpflags, $fh,
                                               !$::format_for_publication);
            $fh->close();
        } else {
            ::Log(0, "\nWARNING: Could not parse flags for ${basename}.html\n");
            $fh->close();
            unlink $basename.'.html';
        }
    } else {
        ::Log(0, "\nWARNING: Could not open ${basename}.html for writing: $!\n");
    }
}

sub store_flags_file {
    # Given some flags text, look in the flags storage area for an pre-existing
    # copy and point to it if it exists.  Otherwise write it there and return
    # a URL pointing to it.
    my ($flagtext, $flags, $rawpath) = @_;
    my @filelist = ();

    my @files = grep { $_ ne '' } split(/<\/flagsdescription>[\s\r\n]*/, $flagtext, -1);
    for(my $i = 0; $i < @files; $i++) {
        $files[$i] .= "</flagsdescription>\n";  # Eliminated by split earlier
        my $tmpflags = join("\n", split(/(?:\n\r|\n|\r\n|\r)/, $files[$i], -1));
        my $name = $flags->{'files_by_section'}->{'filelist'}->[$i];

        # We'll need the hash no matter what...
        my $cksum = ::scalardigest($tmpflags, 512);
        ::Log(15, "Storing or referencing a flags file with hash $cksum\n");

        # ...and the flag file's name.
        if (!defined($name) || $name eq '') {
            $name = $::suite.'_flags';
        }
        ::Log(15, "  User-requested name is \"$name\"\n");
        # Clean it up, if necessary
        $name = ::flag_filename_fixup($name);
        ::Log(15, "  Sanitized name is \"$name\"\n");

        # Make a list file
        my $listfile = Spec::Listfile->new($::flag_report_base, 'flagidx');
        # Change the permissions back to something reasonable; this isn't the
        # happy world of a running benchmark, after all.
        chmod 0664, ::jp($::flag_report_base, 'flagidx');

        # Look for a match
        my $entry = $listfile->find_entry($::flag_report_base, 'hash' => $cksum);
        my $flagperms = 0000; # No read, no write, nothing...
        if (defined($entry) and -f $entry->path.'.xml') {
            # Get the file's permissions
            $flagperms = stat($entry->path.'.xml')->mode;
        } else {
            $entry = $listfile->new_entry($name,
                                          'hash'         => $cksum,
                                          'num_width'    => 2,
                                          'num_optional' => 1,
                                          'num_is_date'  => 1);
        }

        # At this point, there's an entry that points to where our flags file
        # should go.  If the size doesn't match (or it doesn't exist at all),
        # write it out.
        my $filename = $entry->path.'.xml';
        if ( -s $filename != length($tmpflags) ) {
            # Before rewriting, attempt to unlink.  This is because the file that's
            # present _may_ be mode 000, which means no writing to it.  But we can
            # probably remove it and get around the problem that way...
            unlink $filename;

            write_and_format_flags($listfile, $entry, $entry->path, $tmpflags, $flags);
        }
        $listfile->update();

        if (!defined($::private_flag_dir) ||
            (defined($::private_flag_dir) && $rawpath !~ /$::private_flag_dir/)) {
            $flagperms |= 0664;
        }
        my $tries = 0;
        my $done = 0;
        while($done == 0 && $tries < 2) {
            my $current_perms = stat($entry->path.'.xml')->mode;
            if ($flagperms == $current_perms) {
                # Nothing to do
                $done = 1;
                last;
            }
            my $changed = chmod $flagperms, $entry->path.'.xml', $entry->path.'.html';
            if ($changed == 2) {
                $done = 1;
                last;
            } elsif ($tries == 0) {
                # *sigh* chmod failed, probably because we're not the owner of one
                # or more of the files.  On the (good) assumption that we can write
                # into the directory (hooray for group perms), try writing a new copy
                # of the file, remove the existing one, and rename the new copy.
                # The locking on the list file should ensure that we don't have too
                # much of this fun going on at the same time.

                my ($fn, $dir) = File::Basename::fileparse($entry->path);
                my $path = ::jp($dir, ".$$.".$fn);
                write_and_format_flags($listfile, $entry, $path, $tmpflags, $flags);
                foreach my $ext (qw(xml html)) {
                    unlink $entry->path.".$ext";
                    rename $path.".$ext", $entry->path.".$ext";
                }
            }
            $tries++;
        }
        $listfile->close();

        ::Log(15, "  Final flags URL is \"".$::flag_report_url_base.$entry->name.".xml\"\n");
        push @filelist, $::flag_report_url_base.$entry->name.'.xml';
    }
    return @filelist;
}

sub get_format {
    # Return a format object (from formatlist) based on the name (which must
    # be one of the synonyms that the format lists for itself).
    my ($formatlist, $name) = @_;

    if (::ref_type($formatlist) ne 'HASH') {
        carp "Bad formatlist '$formatlist' passed in to get_format\n";
        return;
    }

    foreach my $format (keys %{$formatlist}) {
        return $formatlist->{$format} if exists($formatlist->{$format}->{'synonyms'}->{lc($name)});
    }
    carp "No format found for '$name' in $formatlist";
    return;
}

sub trademark_lines {
    my ($indent, $wrap, %trademarks_done) = @_;
    $wrap = 75 unless defined($wrap) and $wrap > 0;

    my @tms_used = sort { length($a) <=> length($b) || $a cmp $b } keys %trademarks_done;
    my $line = $indent;
    if (@tms_used) {
        my @types = ();
        my %seen = ();
        my $types = '';
        foreach my $tm (@tms_used) {
            my $type = $::trademarks{$tm};
            $type = $type->[0] if (::ref_type($type) eq 'ARRAY');
            next if $seen{$type};
            my $what = undef;
            if ($type eq 'r') {
                $what = 'registered trademark';
            } elsif ($type eq 't') {
                $what = 'trademark';
            } elsif ($type eq 's') {
                $what = 'service mark';
            }
            $what .= "s" if (defined($what) && @tms_used > 1);
            push @types, $what;
            $seen{$type}++;
        }
        if (@types) {
            my $last_type = pop @types;
            if (@types) {
                $types = join(', ', @types);
                $types .= ',' if @types > 1;
                $types .= ' or '.$last_type;
            } else {
                $types = $last_type;
            }
        }
        if (@tms_used > 1) {
            my $last_tm = pop @tms_used;
            $line .= join(', ', @tms_used);
            $line .= ',' if @tms_used > 1;
            $line .= " and $last_tm are $types";
        } else {
            $line .= $tms_used[0].' is a '.$types;
        }
        $line .= " of the Standard Performance Evaluation Corporation.  All other";
    } else {
        $line .= "All";
    }
    $line .= " brand and product names appearing in this result are trademarks or registered trademarks of their respective holders.\n";

    return ::wrap_lines([$line], $wrap, $indent, 0, 1);
}

sub copyright_dates {
    my $this_year = localtime->year() + 1900;
    if ($this_year < 2012) {
        ::Log(0, "\nERROR: The current year returned by the system is ${this_year}, which is in the past.\nPlease correct the system clock and re-run the formatter.\n");
        ::do_exit(1);
    }

    if ($this_year == $::release_year) {
        return $this_year;
    } elsif ($this_year > $::release_year) {
        return "${main::release_year}-${this_year}";
    } elsif ($this_year < $::release_year) {
        # Whoa, this should NEVER happen after the suite is released
        if (::is_release($::suite_version)) {
            ::Log(0, "\nWARNING: Current year ($this_year) is earlier than suite release year ($::release_year).  Please check the clock on this system.\n");
        }
        return "${this_year}-${main::release_year}";
    }
}

# Fill a hash with tester info, with keys corresponding to the CPU names
sub get_result_fields_hash {
    my ($r, @things) = @_;
    my %things = ();
    foreach my $thing (@things) {
        $things{$thing} = [ grep { defined } ::allof($r->accessor_nowarn($thing)) ];
    }

    return %things;
}

# Fill a hash with tester info, with keys corresponding to the CPU names
sub get_tester_info {
    my ($r) = @_;
    my %things = get_result_fields_hash($r, qw( tester test_sponsor hw_vendor hw_model hw_accel_name system_vendor system_name ));

    # MPI2007 cheat sheet:
    # hw_vendor => system_vendor
    # hw_model  => system_name
    if ($::lcsuite eq 'mpi2007') {
        $things{'hw_vendor'} = $things{'system_vendor'};
        $things{'hw_model'} = $things{'system_name'};
    }

    return %things;
}

# Munge the metric names to allow easier trademark marking
sub munge_metric {
    my ($str, $mode) = @_;

    if ($str =~ /C(INT|FP)/) {
        # CPU result; make it verbose
        my %namemap = (
            'INT' => 'Integer',
            'FP'  => 'Floating Point',
        );
        $str = $::suite.' '.$namemap{$1};
        $str .= ' '.ucfirst($mode) if (defined($mode) and $mode ne '');
    } else {
        # Right now, just remove underscores
        $str =~ s/_/ /g;
    }

    return $str;
}

sub significant_base {
    my ($value, $min_log, $returnlog, $hack, $debug) = @_;
    $debug = 0 unless defined($debug);
    print "significant(value=\"$value\", min_log=\"$min_log\", returnlog=\"$returnlog\", hack=\"$hack\")\n" if $debug;
    my ($log);
    $min_log = 2 if !defined $min_log;
    if ($value <= 0) {
        if ($value eq '0' || $value !~ /[\d.]/) {
            if ($returnlog == 0) {
                print "  not a number; returning \"0.00\"\n" if $debug;
                return '0.00';
            } elsif($returnlog) {
                return 2;
            }
        } elsif ($value < 0) {
            ::Log(0, "NOTICE: Not taking log of negative number ($value); significant_base($value,...) called from ".join(':', caller())."\n");
            if ($returnlog) {
                return 0;
            } else {
                return $value;
            }
        }
    } elsif ($value > 0) {
        $log = ::floor(log($value)/log(10));
    }
    print "  old log = $log\n" if $debug;

    if ($returnlog == 1) {
        print "  returnlog set to 1; returning \"$log\"\n" if $debug;
        return $log;
    }

    if (!$hack or $value < 1000) {
        # Return of the
        # STUPID STUPID HACK which circumvents the whole idea of 3 significant digits,
        # but only if $hack is set.
        $value = int($value / (10**($log-$min_log))+.5) * (10**($log-$min_log));
        print "  value rounded to \"$value\"\n" if $debug;
    } else {
        # Round up; there won't be any decimal places
        $value = int($value + 0.5);
        print "  value without dp; rounded to \"$value\"\n" if $debug;
    }

    # The number has been changed; re-figure its log (it'll change if, for
    # example, a number less than 1 gets rounded up to 1)
    if ($value > 0) {
        $log = ::floor(log($value)/log(10));
        print "  new log = $log\n" if $debug;
    }
    if ($log < $min_log) {
        $value = sprintf ("%.*f", $min_log-$log, $value) if ($log < $min_log);
        print "  reformatted value = \"$value\"\n" if $debug;
    }
    if ($returnlog == 2) {
        # Just get the number of places after the decimal
        return 0 unless $value =~ s/^[^\.]*\.//;
        print "  returning dp value of ".length($value)."\n" if $debug;
        return length($value);
    }

    print "  returning \"$value\"\n" if $debug;
    return $value;
}

sub result_to_hash {
    my ($res, $size_class, $is_nc, $invalid) = @_;
    my %resultinfo = ();

    my @fieldlist = qw(
                        copies ratio selected valid reference_power
                        reported_time ranks threads reference
                    );
    if (::istrue($res->power)) {
        push @fieldlist, qw(
                            avg_power max_power avg_temp min_temp
                            avg_hum max_hum energy energy_ratio
                            avg_uncertainty max_uncertainty
                         );

    }
    foreach my $field (@fieldlist) {
        $resultinfo{$field} = $res->accessor($field);
    }
    # Fix up thread count if it's at the default (-1)
    $resultinfo{'threads'} = 1 if $resultinfo{'threads'} <= 0;
    $resultinfo{'ranks'} = 1 if $resultinfo{'ranks'} <= 0;

    # Handle fields whose name isn't the same as their accessor's
    $resultinfo{'ref_power'} = $resultinfo{'reference_power'};
    $resultinfo{'time'} = $resultinfo{'reported_time'};
    $resultinfo{' ranks'} = $resultinfo{'ranks'};
    $resultinfo{'  ranks'} = $resultinfo{'ranks'};
    $resultinfo{' copies'} = $resultinfo{'copies'};
    $resultinfo{' thrds'} = $resultinfo{'threads'};
    $resultinfo{' ref. '} = $resultinfo{'reference'};

    if (::istrue($res->power)) {
        # Also derived fields
        $resultinfo{'energykJ'} = $resultinfo{'energy'} / 1000;
    }

    # Nuke the ratio if the run was not a success
    $resultinfo{'ratio'} = '' unless $resultinfo{'valid'} eq 'S';

    # Nuke it harder if the result is invalid
    $resultinfo{'ratio'} = $resultinfo{'time'} = 'X' if $invalid;

    # The "selected" column is only '*' when the run is both good and ref.
    # Otherwise, it's the "invalid" code.
    $resultinfo{'selected'} = $resultinfo{'valid'};
    if ($res->selected && $size_class eq 'ref') {
        if ($resultinfo{'valid'} eq 'S') {
            $resultinfo{'selected'} = '*';
        } elsif ($is_nc) {
            $resultinfo{'selected'} = ' ';
        }
    }

    return %resultinfo;
}

sub make_meter_sections {
    my ($r, %power_info) = @_;
    my %thinglabel = (
        '0general'    => 'Power',
        '1settings'   => 'Power Settings',
        '2related_hw' => 'Power-Relevant Hardware',
        'power'       => 'Power Analyzer',
        'temperature' => 'Temperature Meter'
    );
    my @rc = ();

    if (::istrue($r->power)) {
        foreach my $section (sort keys %power_info) {
            push @rc, [ $thinglabel{$section}, @{$power_info{$section}} ];
        }
        foreach my $powerthing (qw(power temperature)) {
            for(my $i = 0; $i < @{$r->{'meterlist'}->{$powerthing}}; $i++) {
                my $instance = (@{$r->{'meterlist'}->{$powerthing}} > 1) ? ' #'.($i + 1) : '';
                push @rc, [ $thinglabel{$powerthing}.$instance, $r->info_format($r->{'meters'}->{$powerthing}->{$r->{'meterlist'}->{$powerthing}->[$i]}) ];
            }
        }
    }

    return @rc;
}

# List the various fields for each suite and configuration
sub get_results_table_field_list {
    my ($r, $rate, $what) = @_;
    my $by_tune = 0;
    my @fields = ();

    # NOTE: In all cases, the first field MUST be the benchmark name.  That's
    #       an explicit assumption in the HTML and PS/PDF formatters.
    if (::istrue($r->power)) {
        if ($::lcsuite ne 'omp2012'
                and $::lcsuite ne 'accel'
                and $::lcsuite ne 'cpu2017') {
            #                Base   Base    Base    Base       Peak   Peak    Peak    Peak
            #Benchmarks     $what_ Energy  RunTime $rmode     $what_ Energy  RunTime $rmode
            #-------------- ------ ------- ------- -------    ------ ------- ------- -------
            @fields = (
                { 'val' => 'name',                  'notune' => 1, 'noheader' => 1, 'border' => [ 1 ],      'label' => 'Benchmark', },
                $rate ? { 'val' => lc($what),       'num_convert' => '%d',          'border' => [ 0.9 ], } : undef,
                { 'val' => 'energykJ', 'max_dp' => 3, 'result' => 1, 'edge' => 'l',                         'label' => 'Energy', },
                { 'val' => 'time',     'max_dp' => 3, 'result' => 1, 'edge' => 'l',                         'label' => 'Seconds', 'sig_hack' => 1, },
                { 'val' => 'ratio',    'max_dp' => 3, 'result' => 1, 'edge' => 'r', 'border' => [ 0.3, 1 ], },
            );
        } else {
            #               $tune   $tune  $tune  $tune  $tune  $tune  $tune
            #Benchmarks     $what_ RunTime $rmode Energy MaxPwr AvgPwr ERatio
            #-------------- ------ ------- ------ ------ ------ ------ ------
            @fields = (
                { 'val' => 'name',                  'notune' => 1, 'noheader' => 1,     'border' => [ 1 ],      'label' => 'Benchmark'},
                $rate ? { 'val' => lc($what),       'num_convert' => '%d',              'border' => [ 0.9 ], } : undef,
                { 'val' => 'time',         'max_dp' => 3, 'result' => 1, 'edge' => 'l',                         'label' => 'Seconds', 'sig_hack' => 1, },
                { 'val' => 'ratio',        'max_dp' => 3, 'result' => 1, },
                { 'val' => 'energykJ',     'max_dp' => 3, 'result' => 1,                                        'label' => "Energy\n(kJ)", },
                { 'val' => 'energy_ratio', 'max_dp' => 3, 'result' => 1,                                        'label' => "Energy\nRatio", },
                { 'val' => 'avg_power',    'max_dp' => 3, 'result' => 1,                                        'label' => "Average\nPower", },
                { 'val' => 'max_power',    'max_dp' => 3, 'result' => 1, 'edge' => 'r', 'border' => [ 0.3, 1 ], 'label' => "Maximum\nPower", },
            );
            $by_tune = 1;       # Separate tables for base and peak
        }

    } else {
        #                Base     Base       Base        Peak     Peak       Peak
        #Benchmarks     $what_  Run Time    $rmode      $what_  Run Time    $rmode
        #-------------- ------  ---------  ---------    ------  ---------  ---------
        @fields = (
            { 'val' => 'name',                  'notune' => 1, 'noheader' => 1, 'border' => [ 1 ],     'label' => 'Benchmark', },
            $rate ? { 'val' => lc($what),       'num_convert' => '%d',          'border' => [ 0.9 ], } : undef,
            { 'val' => 'time',    'max_dp' => 3, 'result' => 1, 'edge' => 'l',                          'label' => 'Seconds', 'sig_hack' => 1, },
            { 'val' => 'ratio',   'max_dp' => 3, 'result' => 1, 'edge' => 'r',  'border' => [ 0.3, 1 ], },
        );
    }
    @fields = grep { defined } @fields;
    foreach my $fieldref (grep { !exists($_->{'label'}) } @fields) {
        $fieldref->{'label'} = ucfirst($fieldref->{'val'});
    }

    my $num_tune_fields = (grep { !$_->{'notune'} } @fields)+0;
    my $num_result_fields = (grep { $_->{'result'} } @fields)+0;
    my $tune_cols = $num_tune_fields + ($num_result_fields * 2);        # Three sets of results
    my $table_cols = 1 + ($tune_cols * ($by_tune ? 1 : 2));

    return ($by_tune, $num_tune_fields, $num_result_fields, $tune_cols, $table_cols, @fields);
}

# This populates the per-benchmark results table (%$results) as well as
# populating a list of per-column maximum decimal places (@$dp_list).
# %$residx is an internal state variable that needs to be preserved in case
# marshall_results() is called twice to populate a combined base/peak
# table.
sub marshall_results {
    my ($r, $tune, $fields, $nc_str, $by_tune, $tune_active, $results, $residx, $dp_list, $debug) = @_;

    foreach my $bench (sort keys %{$r->benchmarks}) {
        $residx->{$bench} = 0 if $by_tune or !exists($residx->{$bench});
        if ($nc_str eq '' and $tune_active) {
            my @results = $r->benchmark_results_list($bench, $tune);
            my @idx = (0, 1, 2);
            if (@results+0 > 3) {
                # Sigh.  Find min/median/max.  We are in _trouble_ if
                # more than (n-3) of the results are exactly the same.
                my ($min, $median, $max) = (1 << 31, undef, -1);
                my $count = 0;
                foreach my $res (sort { $a->{'iteration'} <=> $b->{'iteration'} } @results) {
                    if ($res->{'selected'} && !defined($idx[1])) {
                        $idx[1] = $count;
                    }
                    if ($res->{'ratio'} < $min) {
                        $min = $res->{'ratio'};
                        $idx[0] = $count;
                    }
                    if ($res->{'ratio'} > $max) {
                        $max = $res->{'ratio'};
                        $idx[2] = $count;
                    }
                    $count++;
                }
            }

            foreach my $idx (sort @idx) {
                if (!defined($idx) or (::ref_type($results[$idx]) ne 'HASH')) {
                    my $tmp_result = ::empty_temp_result($tune, $fields, $idx != $idx[0], '');
                    push @{$results->{$bench}}, @{$tmp_result};
                    $residx->{$bench} += @{$tmp_result};
                    next;
                }

                my $res = $results[$idx];
                my %reshash = ::result_to_hash($res, $r->size_class, $nc_str ne '', !$r->valid($bench, $tune));
                print "\%reshash = (",join(', ', map { "$_ => ".$reshash{$_} } keys %reshash),")\n" if ($debug & 2);

                $reshash{'ratio'} = undef if ($r->size_class ne 'ref');
                my $selected = $reshash{'selected'} eq '*' ? ' selected' : '';

                foreach my $fieldref (@$fields) {
                    next if $fieldref->{'noheader'};
                    next unless ($fieldref->{'result'} or $idx == $idx[0]);
                    my $tune_class = "${tune}col ";
                    if ($fieldref->{'notune'}) {
                        next unless $tune eq 'base';
                        $tune_class = '';
                    }
                    my $name = $fieldref->{'val'};
                    my $edge = $fieldref->{'edge'} ? ' '.$fieldref->{'edge'}.'_edge' : '';
                    my $value = $reshash{$name};
                    $value = sprintf $fieldref->{'num_convert'}, $value if defined($fieldref->{'num_convert'}) && $fieldref->{'num_convert'} ne '';
                    my $dp = undef;
                    my $preformatted = $fieldref->{'preformatted'} + 0;
                    if (defined($fieldref->{'max_dp'})
                            and defined($value) and $value >= 0) {
                        # The -1 on max_dp is because significant_base()
                        # implicitly increases it by one.  Doing the
                        # subtraction in significant_base() results in rounding
                        # values to one fewer decimal place than desired.
                        $dp = ::significant_base($value, $fieldref->{'max_dp'}-1, 2, $fieldref->{'sig_hack'}, ($debug & 4));
                        $dp_list->[$residx->{$bench}] = $dp if ($dp > $dp_list->[$residx->{$bench}]);
                    } else {
                        $preformatted = defined($fieldref->{'preformatted'}) + defined($fieldref->{'num_convert'}) + 0;
                    }
                    $results->{$bench}->[$residx->{$bench}] = {
                        'name'          => $name,
                        'value'         => $value,
                        'rounded_value' => ::significant_base($value, undef, undef, $fieldref->{'sig_hack'}, ($debug & 4)),
                        'dp'            => $dp,
                        'preformatted'  => $preformatted,
                        'tune'          => $fieldref->{'notune'} ? '' : $tune,
                        'selected'      => ($fieldref->{'result'} and $selected ne ''),
                        'class'         => $tune_class.$name.$edge.$selected,
                        'sig_hack'      => $fieldref->{'sig_hack'},
                        'is_result'     => $fieldref->{'result'},
                    };
                    $residx->{$bench}++;
                }
            }
        } else {
            for(my $i = 0; $i < 3; $i++) {
                my $tmp_result = ::empty_temp_result($tune, $fields, $i, $nc_str);
                push @{$results->{$bench}}, @{$tmp_result};
                $residx->{$bench} += @{$tmp_result};
            }
        }
    }
}

sub empty_temp_result {
    my ($tune, $fields, $idx, $str) = @_;
    my $tmpres = [];

    foreach my $fieldref (@{$fields}) {
        next unless ($fieldref->{'result'} or $idx == 0);
        next if $fieldref->{'noheader'};
        my $tune_class = "${tune}col ";
        if ($fieldref->{'notune'}) {
            next unless $tune eq 'base';
            $tune_class = '';
        }
        my ($name, $label, $edge) = ($fieldref->{'val'}, $fieldref->{'label'}, $fieldref->{'edge'} ? ' '.$fieldref->{'edge'}.'_edge' : '');
        push @{$tmpres}, {
            'name'         => $name,
            'value'        => $str,
            'preformatted' => 1,
            'tune'         => $fieldref->{'notune'} ? '' : $tune,
            'selected'     => 0,
            'class'        => $tune_class.$name.$edge,
            'is_result'    => $fieldref->{'result'},
        };
    }

    return $tmpres;
}

sub get_display_value {
    my ($results, $bench, $column) = @_;

    if ($results->{$bench}->[$column]->{'preformatted'}) {
        return $results->{$bench}->[$column]->{'value'};
    } else {
        return $results->{$bench}->[$column]->{'rounded_value'};
    }
}

sub get_means {
    my ($r, $nc) = @_;
    my $meandp;

    my $nc_str = '';
    if ($nc == 3) {
        $nc_str = 'CD';
    } elsif ($nc == 2) {
        $nc_str = 'NA';
    } elsif ($nc) {
        $nc_str = 'NC';
    }

    my %means = (
        map {
                my $mean = eval "\$r->${_}mean";
                my $unit = eval "\$r->${_}units";
                $_ => {
                    'mean'    => $mean,
                    'ispower' => ($_ =~ /energy/) ? 1 : 0,
                    'units'   => $unit,
                    'dp'      => significant_base($mean, undef, 2, 0),
                }
            } qw(base baseenergy peak peakenergy)
    );
    if ($nc) {
        $means{'peak'}->{'mean'} = $means{'peakenergy'}->{'mean'} = $nc_str if $means{'peak'}->{'mean'} =~ /\d/;
        $means{'base'}->{'mean'} = $means{'baseenergy'}->{'mean'} = $nc_str if $means{'base'}->{'mean'} =~ /\d/;
    } else {
        $meandp = max(map { $_->{'dp'} } values %means);
        foreach my $meanref (values %means) {
            if (::istrue($r->power) or $meanref->{'ispower'} == 0) {
                if ($meanref->{'mean'} =~ /\d/) {
                    $meanref->{'formatted'} = significant_base($meanref->{'mean'}, $meandp, undef, 0);
                } else {
                    $meanref->{'formatted'} = $meanref->{'mean'};
                }
            } else {
                $meanref->{'formatted'} = '--';
            }
        }
    }

    return ($meandp, %means);
}

# Look in the input string for trademarks and mark them up as appropriate.
# Also keep track of which ones were used so that they can be mentioned in
# the result page footer.
# This implementation is only suitable for strings where the marking can be inserted directly.
sub fixup_trademarks {
    my ($str, $marked, $codes) = @_;

    if (defined($::mark_regexp)) {
        $str =~ s{$::mark_regexp}{
                                    my $k = $1; # The trademark to possibly mark
                                    my $s = $2; # Whitespace following it (if any)
                                    my $code = $codes->{$::trademarks{$k}->[0]} // $::trademarks{$k}->[0];
                                    $marked->{$k}++;
                                    if ($marked->{$k} > 1 and defined($s)) {
                                        # No mark for this instance; it's separated from whatever follows
                                        # and has already been marked.
                                        $code = '';
                                    }
                                    "${k}${code}${s}"
                                  }gep;
    }

    return $str;
}

sub byformat {
    # Sort formats lexically, except for raw, which always goes first,
    # and screen, which always goes last.  Oh yeah... mail and check go before
    # screen and after everything else.  Finally, flags goes second (and
    # isn't optional).
    # Finally finally, until HTML SVG graphs work, PDF goes before HTML (so
    # that HTML can reference it as necessary).  If this stays in after the
    # HTML graphs are done (#59), it won't be a big deal.

    # Make sure that we won't have a run-time error below
    return -1 if ((::ref_type($a) ne 'HASH') && (::ref_type($b) eq 'HASH'));
    return  1 if ((::ref_type($a) eq 'HASH') && (::ref_type($b) ne 'HASH'));
    return  0 if ((::ref_type($a) ne 'HASH') && (::ref_type($b) ne 'HASH'));

    my ($an, $bn) = (lc($a->{'name'}), lc($b->{'name'}));

    foreach my $format (qw(raw flags)) {
        return -1 if ($an eq $format);
        return  1 if ($bn eq $format);
    }
    return  1 if ($an eq 'screen'     and $bn =~ /mail|check/);
    return -1 if ($an =~ /mail|check/ and $bn eq 'screen'    );
    return  1 if ($an eq 'html'       and $bn eq 'pdf'       );
    return -1 if ($an eq 'pdf'        and $bn eq 'html'      );
    foreach my $format (qw(screen mail check)) {
        return  1 if ($an =~ /\Q$format\E/i);
        return -1 if ($bn =~ /\Q$format\E/i);
    }
    return $an cmp $bn;
}

sub PDF_ok {
    # Here's where we decide if it's okay to have PDF output
    # (assuming the PostScript format is also loaded)

    return 1 if ::istrue($ENV{'SPEC_TRY_PDF'});
    return 0 if ::istrue($ENV{'SPEC_NEVER_TRY_PDF'});

    $::PDF_ok = 1 unless defined($::PDF_ok);
    return $::PDF_ok;
}

sub CSV_ok {
    # Here's where we decide if it's okay to have CSV output

    return 1 if ::istrue($ENV{'SPEC_TRY_CSV'});
    return 0 if ::istrue($ENV{'SPEC_NEVER_TRY_CSV'});

    eval 'use Text::CSV_XS;';

    return $@ eq '';
}

sub PostScript_ok {
    # Here's where we decide if it's okay to have PostScript output

    return 1 if ::istrue($ENV{'SPEC_TRY_PS'});
    return 0 if ::istrue($ENV{'SPEC_NEVER_TRY_PS'});

    return 1;
}

sub HTML_ok {
    # Here's where we decide if it's okay to have HTML output

    return 1 if ::istrue($ENV{'SPEC_TRY_HTML'});
    return 0 if ::istrue($ENV{'SPEC_NEVER_TRY_HTML'});

    return 1;
}

sub Text_ok {
    # Here's where we decide if it's okay to have ASCII output

    return 1 if ::istrue($ENV{'SPEC_TRY_TXT'});
    return 0 if ::istrue($ENV{'SPEC_NEVER_TRY_TXT'});

    return 1;
}

sub Screen_ok {
    # Here's where we decide if it's okay to have ASCII output to the screen

    return 0 unless ($Spec::Format::Text::name ne '');
    return 1 if ::istrue($ENV{'SPEC_TRY_SCREEN'});
    return 0 if ::istrue($ENV{'SPEC_NEVER_TRY_SCREEN'});

    return 1;
}

sub config_ok {
    # Here's where we decide if it's okay to have config file output

    return 1 if ::istrue($ENV{'SPEC_TRY_CONFIG'});
    return 0 if ::istrue($ENV{'SPEC_NEVER_TRY_CONFIG'});

    return 1;
}

sub mail_ok {
    # Here's where we decide if it's okay to mail results

    return 1 if ::istrue($ENV{'SPEC_TRY_MAIL'});
    return 0 if ::istrue($ENV{'SPEC_NEVER_TRY_MAIL'});

    return 1;
}

sub raw_ok {
    # raw output is *always* okay
    return 1;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab colorcolumn=120:
