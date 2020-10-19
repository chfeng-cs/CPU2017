$benchnum  = '548';
$benchname = 'exchange2_r';
$exename   = 'exchange2_r';
$benchlang = 'F';
@base_exe  = ($exename);

%workloads = (
    'refspeed' => [ 'refrate' ],
);

$bench_flags = '-DSPEC_AUTO_SUPPRESS_OPENMP';

@sources = (qw (
    exchange2.F90
    ));

sub invoke {
    my ($me) = @_;
    my (@rc);

    my @temp = main::read_file('control');
    my $exe = $me->exe_file;

    for (@temp) {
        my ($numgames) = split;
        next if m/^\s*#/ || m/^\s*$/;
        push @rc, {
            'command' => $exe,
            'args'    => [ $numgames ],
            'output'  => "exchange2.txt",
            'error'   => "exchange2.err",
        };
    }
    return @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
