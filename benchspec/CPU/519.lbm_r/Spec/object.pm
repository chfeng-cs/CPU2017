$benchnum  = '519';
$benchname = 'lbm_r';
$exename   = 'lbm_r';
$benchlang = 'C';
@base_exe  = ($exename);

$abstol =  0.0000001;

@sources = qw( lbm.c main.c );

$bench_flags = '-DSPEC_AUTO_SUPPRESS_OPENMP';
$need_math = 'yes';

sub invoke {
    my ($me) = @_;
    my $name = $me->name;
    $name =~ s/_[rs]$//;
    my ($arguments, @temp) = main::read_file("${name}.in");
    chomp($arguments);

    return ({ 'command' => $me->exe_file,
            'args'    => [ split(/\s+/, $arguments) ],
            'error'   => "$name.err",
            'output'  => "$name.out",
        });
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
