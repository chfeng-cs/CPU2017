$benchnum  = '649';
$benchname = 'fotonik3d_s';
$exename   = 'fotonik3d_s';
$benchlang = 'F';
@base_exe  = ($exename);

$floatcompare = 1;
$obiwan       = 1;
$reltol       = 1e-10;
$abstol       = 1e-27;

$bench_flags='-I.';

%workloads = (
    'test'       => [ [ '549.fotonik3d_r' ] ],
    'train'      => [ [ '549.fotonik3d_r' ] ],
    'refspeed'   => [ [ '549.fotonik3d_r' ] ],
    'refrate'    => [ [ '549.fotonik3d_r' ] ],
);

$sources = '549.fotonik3d_r';

sub generate_inputs {
    return (
        { 
            'command'   => ::jp($ENV{SPEC}, "bin", "specxz"),
            'args'      => [ '-dc', 'OBJ.dat.xz' ],
            'output'    => 'OBJ.dat',
            'error'     => 'OBJ.dat.gen.err',
            'generates' => [ 
                [ "OBJ.dat", undef ]
            ]
        }
    );
}

sub invoke {
    my ($me) = @_;

    return ({
            'command' => $me->exe_file,
            'args'    => [ ],
            'output'  => $me->name.'.log',
            'error'   => $me->name.'.err',
        });
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
