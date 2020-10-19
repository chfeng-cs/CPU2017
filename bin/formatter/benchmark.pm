#
# benchmark.pm
# Copyright 1999-2019 Standard Performance Evaluation Corporation
#
# $Id: benchmark.pm 6093 2019-03-13 04:04:33Z CloyceS $
#

package Spec::Benchmark;

use strict;
use vars '@ISA';

@ISA = (qw(Spec::Config));

my $version = '$LastChangedRevision: 6093 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'benchmark.pm'} = $version;

sub new {
    no strict 'refs';
    my ($class, $topdir, $config, $num, $name) = @_;
    my $me       = bless {}, $class;

    $me->{'name'}        = ${"${class}::benchname"};
    $me->{'num'}         = ${"${class}::benchnum"};

    if (!defined(${"${class}::benchlang"}) || ${"${class}::benchlang"} eq '') {
        %{$me->{'BENCHLANG'}} = %{"${class}::benchlang"};
        @{$me->{'allBENCHLANG'}}= ();
        # Fix up the benchlang lists (so that they're lists), and make the
        # full list of all benchlangs
        foreach my $exe (keys %{$me->{'BENCHLANG'}}) {
            if (ref($me->{'BENCHLANG'}->{$exe}) eq 'ARRAY') {
                push @{$me->{'allBENCHLANG'}}, @{$me->{'BENCHLANG'}->{$exe}};
            } else {
                my @langs = split(/[\s,]+/, $me->{'BENCHLANG'}->{$exe});
                $me->{'BENCHLANG'}->{$exe} = [ @langs ];
                push @{$me->{'allBENCHLANG'}}, @langs;
            }
        }
    } else {
        @{$me->{'BENCHLANG'}}= split(/[\s,]+/, ${"${class}::benchlang"});
        @{$me->{'allBENCHLANG'}}= @{$me->{'BENCHLANG'}};
    }
    if ($::lcsuite eq 'cpu2017'
            and grep { $_ eq 'F77' } @{$me->{'allBENCHLANG'}}) {
        # SPEC CPU uses F variables for F77 codes
        push @{$me->{'allBENCHLANG'}}, 'F';
    }

    $me->{'benchmark'}   = $me->{'num'}.'.'.$me->{'name'};
    $me->{'path'}        = $topdir;
    $me->{'config'}      = $config;
    $me->{'refs'}        = [ $me, $config ];
    $me->{'result_list'} = [ ];

    return $me;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
