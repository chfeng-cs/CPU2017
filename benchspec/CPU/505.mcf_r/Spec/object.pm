$benchnum  = '505';
$benchname = 'mcf_r';
$exename   = 'mcf_r';
$benchlang = 'C';
@base_exe  = ($exename);

%workloads = (
    'refspeed' => [ 'refrate' ],
);

@sources = (qw(
    mcf.c
    mcfutil.c
    readmin.c
    implicit.c
    pstart.c
    output.c
    treeup.c
    pbla.c
    pflowup.c
    psimplex.c
    pbeampp.c

    spec_qsort/spec_qsort.c
    ));

$need_math='yes';
$bench_cflags='-Ispec_qsort -DSPEC_AUTO_SUPPRESS_OPENMP';

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
