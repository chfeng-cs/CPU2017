$benchnum  = '619';
$benchname = 'lbm_s';
$exename   = 'lbm_s';
$benchlang = 'C';
@base_exe  = ($exename);

$abstol =  0.0000001;

%workloads = (
    'refrate'    => [ [ '519.lbm_r' ] ],
);

$sources = '519.lbm_r';

$bench_flags = '-DLARGE_WORKLOAD';
$need_math = 'yes';

sub invoke {
    my ($me) = @_;
    my $name = $me->name;
    $name =~ s/_[rs]$//;
    my ($arguments, @temp) = main::read_file("${name}.in");
    chomp($arguments);

    return ({
            'command' => $me->exe_file,
            'args'    => [ split(/\s+/, $arguments) ],
            'error'   => "$name.err",
            'output'  => "$name.out",
        });
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
