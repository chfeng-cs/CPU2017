#
# config_common.pl
#
# Copyright 1999-2016 Standard Performance Evaluation Corporation
#
# $Id: config_common.pl 5012 2016-11-16 22:34:58Z CloyceS $
#

use strict;
use Scalar::Util qw(blessed);
require 'util_common.pl';
our %refmapping;

my $version = '$LastChangedRevision: 5012 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'config_common.pl'} = $version;

# Create a new object
sub new {
    my ($class) = @_;
    my $me = bless {}, $class;

    # These are used for accessor lookups.  Initialize to be the base level
    $me->{'refs'} = [ $me ];

    return $me;
}

# Return a list of sets that the benchmarks are in
sub benchmark_in_sets {
    my ($me, $output, @benchmarks) = @_;
    my %sets;
    for my $set (keys %{$me->{'benchsets'}}) {
        # If the caller asks for filtering based on whether a benchset
        # generates output or not, do it here.
        next if defined($output) and ::istrue($output) != ::istrue($me->{'benchsets'}{$set}{'output'});
        for my $bench (@benchmarks) {
            if (exists $me->{'benchsets'}{$set}{'benchmarks'}{$bench}) {
                $sets{$set}++;
            }
        }
    }
    return keys %sets;
}

# Sometimes a result is a Spec::Config and sometimes it's a Spec::Benchset
sub calc_ratio {
    my ($me, $size, $size_class, $reftime, $refpower) = @_;
    my $refenergy = $refpower * $reftime;

    if ($reftime != $me->{'reference'} or $refpower != $me->{'reference_power'}) {
        my $msg = sprintf("%16s:%s: ", $me->benchmark, $me->tune);
        my $change = ($reftime != $me->{'reference'}) ? $me->{'reference'}.' => '.$reftime : 'NO CHANGE';
        $msg .= sprintf("reftime (%-14s)\t", ::center($change, 14));
        $change = ($refpower != $me->{'reference_power'}) ? $me->{'reference_power'}.' => '.$refpower : 'NO CHANGE';
        $msg .= sprintf("refpower (%-14s)\t", ::center($change, 14));
        ::Log(0, "REFERENCE UPDATE: $msg\n");
    }

    # To figure out the multipler, get the list of benchset(s) that the
    # benchmark is in, and use the multiplier for the first one that generates
    # output that uses $size as its ref workload.
    my $mult = 0;
    my @bsets = $::global_config->benchmark_in_sets(1, $me->benchmark);
    my $bset = (grep { $::global_config->{'benchsets'}->{$_}->{$size_class} eq $size } @bsets)[0];
    if (!defined($bset) and @bsets) {
        # No output-generating benchset has $size as its ref workload, so just
        # pick one like we used to.
        $bset = $bsets[0];
    }
    if (!defined($bset)) {
        ::Log(0, "ERROR: ".$me->benchmark." was not found in any benchset that generates output!\n");
        $mult = 0;
    } elsif ($me->runmode =~ /rate$/) {
        $mult = $::global_config->{'benchsets'}->{$bset}->{'rate_multiplier'};
    } else {
        $mult = $::global_config->{'benchsets'}->{$bset}->{'speed_multiplier'};
    }
    # descmode() is only available to Spec::Benchset objects
    ::Log(80, "Selected multiplier of $mult for ".join(' ', $me->benchmark, $size, "($size_class)", $me->tune)."\n");

    $me->{'reference'}       = $reftime;
    $me->{'reference_power'} = $refpower;
    $me->{'ratio'}           = (defined($me->{'reported_time'}) && $me->{'reported_time'}) ? ::round($reftime / $me->{'reported_time'}, $me->{'dp'}) : 0;
    if (exists($me->{'energy_ratio'})) {
        # The value for energy already has the multiplication by run time incorporated
        $me->{'energy_ratio'}    = ($me->{'energy'} > 0) ? ::round($refenergy / $me->{'energy'}, $me->{'dp'}) : 0;
    }

    if ($me->runmode =~ /rate$/) {
        $me->{'ratio'} *= $me->{'copies'} * $mult;
        if (exists($me->{'energy_ratio'})) {
            $me->{'energy_ratio'} *= $me->{'copies'};
        }
    } else {
        $me->{'ratio'} *= $mult;
    }
}

sub default_lookup {
    my ($config, $key, $label, @sets) = @_;

    # Look up $key in specified sections in $config (if any), or in
    # $config itself
    return undef unless (blessed($config) && $config->isa('Spec::Config'));

    my $tmp = { 'refs' => [ reverse($config,
                $config->ref_tree('tmp',
                    ['default', @sets],
                    ['default', 'base'],
                    ['default', $label]))
        ] };
    bless $tmp, ref($config);

    return  $tmp->accessor_nowarn($key);
}

sub list_keys {
    my ($me) = @_;
    my @refs = ();
    my $config;
    if (ref($me) eq 'HASH') {
        if (exists($me->{'refs'}) && ref($me->{'refs'}) eq 'ARRAY') {
            @refs = @{$me->{'refs'}};
        } else {
            @refs = ($me);
        }
        $config = $me->{'config'} if defined($me->{'config'});
    } else {
        @refs = (@{$me->refs});
        $config = $me->accessor_nowarn('config');
    }
    if (defined($config) and ::reftype($config) eq 'HASH') {
        unshift @refs, $config->{'cl_opts'};
    }

    my %rc = map { $_ => 1 } map { keys %$_ } @refs;
    return sort keys %rc;
}

sub match_keys {
    my ($me, @pats) = @_;
    my @rc;
    for my $val (list_keys($me)) {
        for my $pat (@pats) {
            if ($val =~ m/^${pat}[0-9.]*$/) {
                push (@rc, $val);
                next;
            }
        }
    }
    return sort ::bytrailingnum @rc;
}

sub set_cl_override {
    my ($me, $what, $me_only) = @_;
    my $config = $me->accessor_nowarn('config') || $::global_config;
    my $oldval = undef;
    if (!defined($config)
            or !exists($config->{'cl_opts'})
            or !exists($config->{'cl_opts'}->{$what})) {
        # Nothing to override, or can't override it.
        return undef;
    }
    $config->{'cl_opt_override'} = {} unless ref($config->{'cl_opt_override'}) eq 'HASH';
    my $orref = $config->{'cl_opt_override'};

    if (exists($orref->{$what})) {
        $oldval = $orref->{$what};
    }
    if ($me_only) {
        $orref->{$what} = {} unless ref($orref->{$what}) eq 'HASH';
        $orref->{$what}->{$me}++;
    } else {
        $orref->{$what}++;
    }

    return $oldval;
}

sub unset_cl_override {
    my ($me, $what, $me_only) = @_;
    my $config = $me->accessor_nowarn('config') || $::global_config;
    if (defined($config)
            and exists($config->{'cl_opt_override'})
            and exists($config->{'cl_opt_override'}->{$what})) {

        my $orref = $config->{'cl_opt_override'};
        if ($me_only and ref($orref->{$what}) eq 'HASH') {
            delete $orref->{$what}->{$me};
        } else {
            delete $orref->{$what};
        }
    }
}

# Actually do the variable lookup.
# DO NOT call ::Log() from in here with a non-zero loglevel, as it will result
# in infinite recursion.
sub accessor_backend {
    my ($me, $warn, $what, @rest) = @_;
    my @old = ();
    my @refs;
    my %seen = ();
    my $stringify = 0;

    # If the current lookup isn't for 'config' and it's one of the things
    # specified on the command line, get the config object for the
    # caller so we can look up.
    if ($what ne 'config' and blessed($me) and $me->isa('Spec::Config')) {
        my $config = $me->accessor_nowarn('config') || $::global_config;
        if (defined($config)
                and exists($config->{'cl_opts'})
                and exists($config->{'cl_opts'}->{$what})
                and (!exists($config->{'cl_opt_override'})
                    or !exists($config->{'cl_opt_override'}->{$what})
                    or (ref($config->{'cl_opt_override'}->{$what} eq 'HASH')
                        and !exists($config->{'cl_opt_override'}->{$what}->{$me})))) {
#            print "Got command-line value of $what from $config for $me\n";
            return $config->{'cl_opts'}->{$what};
        }
    }

    return undef unless exists ($me->{'refs'}) && ref($me->{'refs'}) eq 'ARRAY';

    @refs = @{$me->{'refs'}};
#    print "refs for $me (".$refmapping{qq/$me/}."):\n\t".join("\n\t", map { $refmapping{qq/$_/} || qq/$_/ } @refs)."\n";
    while (defined(my $ref = shift @refs)) {
        if (exists $ref->{$what}) {
            if ((::ref_type($ref->{$what}) eq 'HASH') &&
                defined($ref->{$what}->{op}) &&
                $ref->{$what}->{op}=='+=') {
#                print "Got += value for $what from $ref (".$refmapping{qq/$ref/}.") for $me (".$refmapping{qq/$me/}.")\n";
                push @old, $ref->{$what}->{value};
                $stringify++;
            } else {
                if ($ref->{$what} eq '%undef%') {
                    @old = ( '%undef%' );
                } else {
#                    print "Got =  value for $what from $ref (".$refmapping{qq/$ref/}.") for $me (".$refmapping{qq/$me/}.")\n";
                    push @old, $ref->{$what};
                }
                last;
            }
        }
        $seen{$ref}++;
    }

    if (!@old) {
        if ($warn) {
            # Believe it or not, but all of the code down to the Log(...) is
            # there just to find the most recent non-eval caller.
            my ($pkg, $file, $ln, $subroutine, $hasargs,
                $wantarray, $evaltext, $is_require, $hints, $bitmask);
            my $lvl = 3;
            while (!defined($file) && $lvl >= 0) {
                ($pkg, $file, $ln, $subroutine, $hasargs,
                    $wantarray, $evaltext, $is_require, $hints, $bitmask) = caller($lvl);
#               printf("pkg=%s\tfile=%s\nln=%d\tsubroutine=%s\thasargs=%s\twantarray=%s\nevaltext=%s\nis_require=%d\thints=%s\tbitmask=%08x\n----------\n",
#                      $pkg, $file, $ln, $subroutine, $hasargs,
#                      $wantarray, $evaltext, $is_require, $hints, $bitmask);
                $lvl--;
            }
            $file = File::Basename::basename($file) if (defined($file) && $file ne '');
            Log(0, "WARNING: accessor '$what' not found; called from $pkg::$subroutine (call at $file line $ln) for object ".ref($me)."\n");
            $DB::single=$DB::signal=1 if $warn;
        }
        return undef if !@rest;
    }

    # Return nothing if the key is not supposed to exist
    if (@old == 1 && $old[0] eq '%undef%') {
        return undef;
    }

    if (@old==1 && @rest) {
        my $old = shift @old;
        my $firstref = undef;
        if (ref($me->{'refs'}) eq 'ARRAY') {
            $firstref = $me->{'refs'}->[0];
        }
        if (!defined($firstref)) {
            $firstref = $me;
        }
        if (ref($old) eq 'ARRAY') {
            $firstref->{$what} = [ @rest ];
        } elsif (ref($old) eq 'HASH') {
            $firstref->{$what} = { @rest };
        } else {
            $firstref->{$what} = $rest[0];
            Log(0, "accessor '$what' passed too much data for scalar!\n")
            if @rest > 1;
        }
    }

    return ($stringify) ? join(' ', reverse @old) : $old[0];
}

sub accessor {
    my $me = shift;
    $me->accessor_backend(1, @_);
}
sub accessor_nowarn {
    my $me = shift;
    $me->accessor_backend(0, @_);
}

# Automagically create new accessor functions for the class
AUTOLOAD {
    use vars qw($AUTOLOAD);
    my $name;
    my ($pkg,$func) = $AUTOLOAD =~ /(.*)::([^:]+)$/;
    if ($func eq 'DESTROY') {
        eval "package $pkg; sub $func {}";
    } else {
        eval "package $pkg; sub $func { shift->accessor('$func', \@_); }";
    }
    goto &$AUTOLOAD;
}

# Alias some main:: package functions into our namespace so we don't have to
# keep calling out the package
sub jp        { main::joinpaths(@_); }
sub istrue    { main::istrue(@_); }
sub Log       { main::Log(@_); }
sub uniq      { main::uniq(@_); }
sub deep_copy { main::deep_copy(@_); }
sub do_exit   { main::do_exit(@_); }
sub pluralize { main::pluralize(@_); }

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
