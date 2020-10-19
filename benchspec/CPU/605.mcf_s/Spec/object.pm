$benchnum  = '605';
$benchname = 'mcf_s';
$exename   = 'mcf_s';
$benchlang = 'C';
@base_exe  = ($exename);

%workloads = (
    'test'       => [ [ '505.mcf_r' ] ],
    'train'      => [ [ '505.mcf_r' ] ],
    'refspeed'   => [ [ '505.mcf_r' ] ],
    'refrate'    => [ [ '505.mcf_r' ] ],
);

$sources = '505.mcf_r';
$bench_cflags='-Ispec_qsort -DSPEC_AUTO_SUPPRESS_OPENMP';

$need_math='yes';

sub invoke {
    my ($me) = @_;
    my (@rc);

    my @temp = main::read_file('control');
    my $exe = $me->exe_file;

    foreach my $input (@temp) {
        chomp($input);
        $input =~ /(.*).in/;
        my $name = $1;
        my $outnum = '';
        if ($name =~ /.*\.(\d)/) {
           $outnum = $1;
        }
        push (@rc, { 'command' => $exe,
                'args'    => [ $input, $outnum ],
                'output'  => "$name.out",
                'error'   => "$name.err",
            });
    }
    return @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
