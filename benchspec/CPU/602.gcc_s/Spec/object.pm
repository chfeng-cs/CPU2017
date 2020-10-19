$benchnum  = '602';
$benchname = 'gcc_s';  # if you change this, also edit diagnostic.c
$exename   = 'sgcc';
$benchlang = 'C';
@base_exe  = ($exename);

$floatcompare = 1;
$calctol      = 0;
$nansupport   = 'no';  # No NaNs in output, so stringwise-equal is a good
                       # initial check for equality
$need_math = 'yes';
$bench_flags = '-I. -I./include -I./spec_qsort -DSPEC_602';

# These were in both the Windows build batch file and mjp.cfg, so...
$bench_flags .= ' -DIN_GCC -DHAVE_CONFIG_H';

$sources = '502.gcc_r';

%workloads = (
    'test'     => [ [ '502.gcc_r' ] ],
    'train'    => [ [ '502.gcc_r' ] ],
    'refspeed' => [ [ '502.gcc_r' ] ],
    'refrate'  => [ [ '502.gcc_r' ] ],
);

use File::Basename;

sub invoke {
    my ($me) = @_;
    my $name;
    my (@rc);
    my $exe = $me->exe_file;

    my @runs = grep { !m/^\s*#/ } main::read_file('control');
    foreach my $run (@runs) {
        my ($src, @opts) = split(/\s+/, $run);
        my $out = basename($src, '.c').'.opts'.join('_', @opts);
        $out =~ s/=/_/g;
        push @rc, {
            'command' => $exe,
            'args'    => [ $src, @opts, '-o', "${out}.s" ],
            'output'  => "${out}.out",
            'error'   => "${out}.err",
        };
    }

    return @rc;
}

no strict;

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
