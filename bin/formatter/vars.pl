#
# vars.pl
#
# Copyright 1995-2019 Standard Performance Evaluation Corporation
#
# $Id: vars.pl 6255 2019-06-11 15:37:45Z CloyceS $

##############################################################################
# Initialize Variables
##############################################################################

use strict;
use Config;
use Cwd;
use JSON::PP;

require 'util_common.pl';
require 'vars_common.pl';

# This gets the list of benchsets and benchmarks that will be used for the
# standalone result formatter at SPEC.
$fm::bmarklist = deserialize_file('bset_list', @INC);

# List of SPEC(r) trademarked strings, for use by the formatters
# Values are "r" (registered trademark), "t" (trademark), and "s" (service mark)
# If a mark should be recognized as part of a larger word (say, for the
# "SPEC MPI" in "SPEC MPIM2007"), then make the second element non-zero.
%::trademarks = (
    'Chauffeur'                     => [ 't', 0 ],
    'OMPM'                          => [ 't', 1 ],
    'PTDaemon'                      => [ 't', 0 ],
    'SERT'                          => [ 't', 0 ],
    'SPEC ACCEL'                    => [ 'r', 0 ],
    'SPEC CPU'                      => [ 'r', 1 ],
    'SPEC Cloud'                    => [ 'r', 0 ],
    'SPEC JMS'                      => [ 'r', 1 ],
    'SPEC MARK'                     => [ 't', 0 ],
    'SPEC MPI'                      => [ 'r', 1 ],
    'SPEC OMP'                      => [ 'r', 1 ],
    'SPEC OMPL'                     => [ 't', 1 ],
    'SPEC Power'                    => [ 'r', 0 ],
    'SPEC SDM'                      => [ 't', 0 ],
    'SPEC SFS'                      => [ 'r', 1 ],
    'SPEC SIP_Infrastructure'       => [ 'r', 0 ],
    'SPEC VIRT'                     => [ 'r', 1 ],
    'SPEC VIRT_SC'                  => [ 'r', 1 ],
    'SPEC'                          => [ 'r', 0 ],
    'SPECENV'                       => [ 't', 0 ],
    'SPECapc'                       => [ 'r', 0 ],
    'SPECchem'                      => [ 'r', 0 ],
    'SPECclimate'                   => [ 'r', 0 ],
    'SPECfp'                        => [ 'r', 0 ],
    'SPECglperf'                    => [ 't', 0 ],
    'SPECgpc'                       => [ 'r', 0 ],
    'SPEChpc'                       => [ 'r', 0 ],
    'SPECint'                       => [ 'r', 0 ],
    'SPECjAppServer'                => [ 'r', 1 ],
    'SPECjEnterprise'               => [ 'r', 1 ],
    'SPECjbb'                       => [ 'r', 1 ],
    'SPECjvm'                       => [ 'r', 1 ],
    'SPECmail'                      => [ 'r', 1 ],
    'SPECpower_ssj'                 => [ 'r', 1 ],
    'SPECrate'                      => [ 'r', 1 ],
    'SPECseis'                      => [ 'r', 0 ],
    'SPECspeed'                     => [ 'r', 1 ],
    'SPECviewperf'                  => [ 'r', 0 ],
    'SPECweb'                       => [ 'r', 1 ],
    'SPECworkstation'               => [ 't', 0 ],
    'SPECwpc'                       => [ 'r', 0 ],
);

# Build up the regexp for all trademarks.  This is to avoid marking
# the same text twice with multiple trademarks, as in:
# SPEC CPU2017 => SPEC CPU&reg;2017  (mark "SPEC CPU")
# SPEC CPU&reg;2017 = SPEC&reg; CPU&reg;2017 (mark "SPEC" in the same text)
# That's not right, as we don't have a trademark on "CPU".
if (%::trademarks) {
    my @mark_re_list = ();
    foreach my $tm (sort { length($b) <=> length($a) } keys %::trademarks) {
        if (::ref_type($::trademarks{$tm}) eq 'ARRAY' and $::trademarks{$tm}->[1]) {
            push @mark_re_list, '\Q'.${tm}.'\E';
        } else {
            push @mark_re_list, '\Q'.${tm}.'\E\b';
        }
    }
    $::mark_regexp = eval 'qr/\b('.join('|', @mark_re_list).')(\s|$)?/';
}

# Conversion of compiler variable combinations to short and long descriptions.
# The list of langs (compiler variables) is sorted, regardless of the order in object.pm.
%::langvar_to_long_desc = (
    'CC'        => 'C benchmarks',
    'CC CXX'    => 'Benchmarks using both C and C++',
    'CC CXXC'   => 'Benchmarks using both C and C++',
    'CC CXX FC' => 'Benchmarks using Fortran, C, and C++',
    'CC CXXC FC'=> 'Benchmarks using Fortran, C, and C++',
    'CXX'       => 'C++ benchmarks',
    'CXXC'      => 'C++ benchmarks',
    'F77'       => 'FORTRAN77 benchmarks',
    'F77C'      => 'FORTRAN77 benchmarks',
    'FC'        => 'Fortran benchmarks',
    'CC FC'     => 'Benchmarks using both Fortran and C',
    'CC F77'    => 'Benchmarks using both Fortran and C',
    'CC F77C'   => 'Benchmarks using both Fortran and C',
    'CXX FC'    => 'Benchmarks using both Fortran and C++',
    'CXXC FC'   => 'Benchmarks using both Fortran and C++',
    'CXX F77'   => 'Benchmarks using both Fortran and C++',
    'CXXC F77C' => 'Benchmarks using both Fortran and C++',
);
%::langvar_to_name = (
    'CC'        => 'C',
    'CXX'       => 'C++',
    'CXXC'      => 'C++',
    'F77'       => 'FORTRAN77',
    'F77C'      => 'FORTRAN77',
    'FC'        => 'Fortran',
);

my $version = '$LastChangedRevision: 6255 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'vars.pl'} = $version;

1;

__END__

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab colorcolumn=120:
