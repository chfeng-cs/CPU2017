$benchnum  = '644';
$benchname = 'nab_s';
$exename   = 'nab_s';
$benchlang = 'C';
@base_exe  = ($exename);

$reltol = 0.01;
$skipreltol = 2;

%workloads = (
    'test'       => [ [ '544.nab_r' ] ],
    'train'      => [ [ '544.nab_r' ] ],
    'refspeed'   => [ [ '544.nab_r' ] ],
    'refrate'    => [ [ '544.nab_r' ] ],
);

$sources = '544.nab_r';

$need_math = 'yes';
$bench_flags = "-Ispecrand -Iregex-alpha -DNDEBUG -DNOPERFLIB -DNOREDUCE";

sub invoke {
    my ($me) = @_;
    my (@rc);

    my @temp = main::read_file('control');
    my $exe = $me->exe_file;

    for my $line (@temp) {
        my ($dirname, $seed, $steps) = split(/\s+/, $line);
        $steps = 1000 unless defined($steps) && ($steps > 0);
        next if $dirname =~ m/^\s*(?:#|$)/;
        push @rc, {
            'command' => $exe,
            'args'    => [ $dirname, $seed, $steps ],
            'output'  => "$dirname.out",
            'error'   => "$dirname.err",
        };
    }
    return @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
