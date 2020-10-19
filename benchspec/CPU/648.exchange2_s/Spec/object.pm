$benchnum  = '648';
$benchname = 'exchange2_s';
$exename   = 'exchange2_s';
$benchlang = 'F';
@base_exe  = ($exename);

%workloads = (
    'test'       => [ [ '548.exchange2_r' ] ],
    'train'      => [ [ '548.exchange2_r' ] ],
    'refspeed'   => [ [ '548.exchange2_r' ] ],
    'refrate'    => [ [ '548.exchange2_r' ] ],
);

$sources = '548.exchange2_r';

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
