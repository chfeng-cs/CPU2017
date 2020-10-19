$benchnum  = '999';
$benchname = 'specrand_ir';
$exename   = 'specrand_ir';
$benchlang = 'C';
@base_exe  = ($exename);

$floatcompare = 1;
$calctol = 0;           # No tolerance will ever be set, so don't waste time
$nansupport = 0;        # No NaNs in output, so stringwise-equal is a good
                        # initial check for equality

%workloads = (
    'refspeed' => [ 'refrate' ],
);

$bench_flags = '-Ispecrand-common';
@sources = (qw(main.c specrand-common/specrand.c));

sub invoke {
    my ($me) = @_;
    my (@rc);

    my @temp = main::read_file('control');
    my $exe = $me->exe_file;

    for (@temp) {
        my ($seed, $count) = split;
        next if m/^\s*#/ || m/^\s*$/;
        push @rc, {
            'command' => $exe,
            'args'    => [ $seed, $count ],
            'output'  => "rand.$count.out",
            'error'   => "rand.$count.err",
        };
    }
    return @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
