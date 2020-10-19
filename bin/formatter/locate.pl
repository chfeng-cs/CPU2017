#
# locate.pm
#
# Copyright 1999-2019 Standard Performance Evaluation Corporation
#
# $Id: locate.pl 6093 2019-03-13 04:04:33Z CloyceS $

use strict;
use IO::Dir;
use Time::HiRes qw(time);
use Symbol qw(delete_package);
use Scalar::Util qw(blessed);

require 'vars.pl';
require 'flagutils.pl';
require 'setup_common.pl';

my $version = '$LastChangedRevision: 6093 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'formatter_locate.pl'} = $version;

sub locate_benchmarks {
    my ($config) = @_;

    if (ref($fm::bmarklist) ne 'HASH' or keys %{$fm::bmarklist} == 0) {
        ::Log(0, "\n\nERROR: The formatter has no benchmark information for $::suite\n\n");
        ::do_exit(1);
    }

    $config->{'formats'} = {} if !exists $config->{'formats'};

    my $benchdir = jp($config->top, $config->benchdir);
    my %seen;
    # We're just formatting, so don't bother to look for the
    # benchmark directories; use the hardcoded list instead
    foreach my $bset (sort keys %{$fm::bmarklist}) {
        my $setclass = "Spec::Benchset::${bset}";
        eval "package $setclass; \@${setclass}::ISA = (qw(Spec::Benchset));";
        my $setobj = $setclass->new($config, 'empty_ok' => 1);
        for my $var (keys %{$fm::bmarklist->{$bset}}) {
            next if $var =~ /^(?:benchmarks|benchmarklist)/;
            $setobj->{$var} = $fm::bmarklist->{$bset}->{$var};
        }
        $config->{'benchsets'}->{$setobj->name} = $setobj;
        foreach my $bmark (sort @{$fm::bmarklist->{$bset}->{'benchmarklist'}}) {
            my $bmarkref = $fm::bmarklist->{$bset}->{'benchmarks'}->{$bmark};
            my ($benchlang, $refinfo);
            if (::ref_type($bmarkref) eq 'HASH') {
                $benchlang = $bmarkref->{'langs'};
                $refinfo   = $bmarkref->{'references'};
            } else {
                $benchlang = '?';
                $refinfo   = { '?' => '?' };
            }
            $bmark =~ /(\d+).(.*)/o;
            my ($num, $name) = ($1, $2);
            my $bmarkclass = "Spec::Benchmark::${name}${num}";
            # There's no need to instantiate this multiple times if the
            # benchmark is included in multiple benchsets
            if (!exists($config->{'benchmarks'}->{$bmark})) {
                # Strip off leading zeroes to prevent the number from being treated
                # as octal...
                my $tmpnum = $num;
                $tmpnum =~ s/^0+//;
                eval "
                    package $bmarkclass;
                    \@${bmarkclass}::ISA       = (qw(Spec::Benchmark));
                    \$${bmarkclass}::benchnum  = $tmpnum;
                    \$${bmarkclass}::benchname = \'$name\';
                    \$${bmarkclass}::benchlang = \'$benchlang\';
                    \@${bmarkclass}::base_exe  = (\'foo\');
                ";
                if ($@) {
                    Log(0, "\nError building benchmark class for '$bmark': $@\n");
                    next;
                }
                my $bmobj = $bmarkclass->new("$num.$name", $config, $num, $name);
                # Just stuff the reference info in
                $bmobj->{'references'} = $refinfo;
                $config->{'benchmarks'}->{$bmark} = $bmobj;
                my $flags_file;
                if (defined($::website_formatter) && $::website_formatter) {
                    $flags_file = jp($::flag_base, $bmark.'.flags.xml');
                } else {
                    $flags_file = jp($benchdir, $setobj->{'topdir'}, $bmark, 'Spec', 'flags.xml');
                }
                if (-e $flags_file) {
                    my $objectstarttime = Time::HiRes::time;
                    (undef, $config->{'flaginfo'}->{$bmark}) =
                    main::get_flags_file($flags_file, $bmark);
                    Log(90, sprintf("    Reading + parsing $flags_file took %8.9fs\n", Time::HiRes::time - $objectstarttime));
                } else {
                    Log(0, "\nERROR: The flags file for $bmark ($flags_file) does not exist.\n");
                    do_exit(1);
                }
                if (!defined($config->{'flaginfo'}->{$bmark})) {
                    Log(0, "\nERROR: The flags file for $bmark ($flags_file) could not be parsed.\n");
                    do_exit(1);
                }
            } else {

                # Benchmark object presumably exists; make sure it's the right
                # kind of thing.
                if (!blessed($config->{'benchmarks'}->{$bmark})
                        or !$config->{'benchmarks'}->{$bmark}->isa($bmarkclass)) {
                    Log(0, "\nERROR: The benchmark class for '$bmark' is not the expected '$bmarkclass'\n");
                    do_exit(1);
                }
            }
            push @{$setobj->{'benchmarklist'}}, $bmark;
        }
    }
    my $error = 0;
    for my $set (keys %{$config->{'benchsets'}}) {
        my $obj = $config->{'benchsets'}{$set};
        my $ref = {};
        $config->{'benchsets'}{$set}{'benchmarks'} = $ref;
        my @benchmarks = @{$obj->{'benchmarklist'}};
        for my $bench (@benchmarks) {
            if (!exists $config->{'benchmarks'}{$bench}) {
                Log(0, "\nBenchmark Set '$set' calls for nonexistent benchmark '$bench'\n");
                $obj->{'valid'} = 'X';
                $error++;
            } else {
                $ref->{$bench} = $config->{'benchmarks'}{$bench};
            }
        }
    }
    ::do_exit(1) if $error;
    $config->{'setobjs'} = [ map {$config->{'benchsets'}{$_}} keys %{$config->{'benchsets'}} ];
}

sub locate_formats {
    my ($config, $quiet) = @_;

    my @formats = list_files(jp($config->top, 'bin', 'formats'));
    @formats = grep (m|\/[^.][^/\\]*\.p[lm]$|o, @formats);

    my $logged = 0;
    for(my $i = 0; $i < @formats; $i++) {
        my $pm = $formats[$i];
        my $tmppkg = 'TMPFORMAT'.$i;
        # This doesn't get the special Safe treatment because if you can
        # change an output format source file, you can just as easily change
        # any of the other tools files directly.
        if ($::check_integrity and !::check_files(\%::file_sums, $pm)) {
            Log(0, "\nERROR: The output format file (".basename($pm)." in ".jp($config->top, 'bin', 'formats').") is corrupt!\n");
            next;
        }
        eval "package $tmppkg; require '$pm';";
        if ($@) {
            Log(102, "\nError requiring output format from $pm: $@\nContinuing with output formats...");
            $logged = 0;
            next;
        }
        my $name = eval "\$${tmppkg}::name";    # Let the output format name itself
        delete_package($tmppkg);
        if (!defined($name) || $name eq '') {
            # ... but if it doesn't, just use the filename
            ($name) = $pm =~ m|([^/]+)\.p[lm]$|o;
        }
        $name =~ tr/A-Za-z0-9/_/c;

        my $ok = 0;
        eval "\$ok = ::${name}_ok();";
        $ok = 1 if ($@ && $@ =~ /undefined subroutine/i);
        if (($@ && $@ !~ /undefined subroutine/i) || !$ok) {
            Log(2, ', ') if $logged && !$quiet;
            Log(2, "$name (DISABLED)") unless $quiet;
            Log(8, " [$@]") if $@;
            $logged++;
            next;
        }
        # Arrange for the file to be re-parsed
        delete $INC{$pm};
        eval "
            package Spec::Format::${name};
            \@Spec::Format::${name}::ISA = (qw(Spec::Format));
            require '$pm';
        ";
        if ($@) {
            Log(102, "\nError requiring $pm for output format $name: $@\nContinuing with output formats...");
            $logged = 0;
            next;
        }

        my $class= "Spec::Format::${name}";

        if (!$class->can('new')) {
            Log(12, "\nNo 'new' function for class '$class' in '$pm'\n");
            next;
        }

        ## run the creation method for the object, i.e., "new"
        my $obj = $class->new;
        if (!defined($obj) || !ref($obj)) {
            Log(12, "\nError initializing format object\n");
            next;
        }

        $config->{'formats'}{$name} = $obj;
        Log(2, ', ') if $logged && !$quiet;
        Log(2, $obj->{'name'}) unless $quiet;
        $logged++;
    }
    Log(2, "\n") unless $quiet;

    # Check that we got raw output; it's required, and other stuff uses
    # variables that it declares.
    if (!exists($config->{'formats'}{'raw'})) {
        ::Log(0, "\n\nERROR: The raw result file output format was not found.\n\n");
        ::do_exit(1);
    }
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
