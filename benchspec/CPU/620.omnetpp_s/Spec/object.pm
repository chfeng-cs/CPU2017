$benchnum  = '620';
$benchname = 'omnetpp_s';
$exename   = 'omnetpp_s';
$benchlang = 'CXX';
$need_math = 'yes';
$reltol    = 0.00001;
$abstol    = 0.000001;
@base_exe  = ($exename);

$bench_flags = '-Isimulator/platdep -Isimulator -Imodel -DWITH_NETBUILDER';

%workloads = (
    'test'       => [ [ '520.omnetpp_r' ] ],
    'train'      => [ [ '520.omnetpp_r' ] ],
    'refspeed'   => [ [ '520.omnetpp_r' ] ],
    'refrate'    => [ [ '520.omnetpp_r' ] ],
);

$sources = '520.omnetpp_r';

sub invoke {
    my ($me) = @_;
    my (@rc);

    my @temp = main::read_file('control');
    my $exe = $me->exe_file;

    for (@temp) {
        next if m/^\s*(?:#|$)/;
        my ($configname, $runnumber) = split;
        push @rc, {
            'command' => $exe,
            'args'    => [ "-c", $configname, "-r", $runnumber ],
            'output'  => "omnetpp.$configname-$runnumber.out",
            'error'   => "omnetpp.$configname-$runnumber.err",
        };
    }
    return @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
