$benchnum  = '641';
$benchname = 'leela_s';
$exename   = 'leela_s';
$benchlang = 'CXX';
@base_exe  = ($exename);

%workloads = (
    'test'       => [ [ '541.leela_r' ] ],
    'train'      => [ [ '541.leela_r' ] ],
    'refspeed'   => [ [ '541.leela_r' ] ],
    'refrate'    => [ [ '541.leela_r' ] ],
);

$sources = '541.leela_r';

$bench_flags = '-I.';

sub invoke {
    my ($me) = @_;
    my $name;
    my @rc;

    my $exe = $me->exe_file;
    for ($me->input_files_base) {
        if (($name) = m/(.*).sgf$/) {
            push @rc, {
                'command' => $exe,
                'args'    => [ "$name.sgf" ],
                'output'  => "$name.out",
                'error'   => "$name.err",
            };
        }
    }
    return @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
