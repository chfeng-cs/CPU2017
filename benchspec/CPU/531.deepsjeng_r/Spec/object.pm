$benchnum  = '531';
$benchname = 'deepsjeng_r';
$exename   = 'deepsjeng_r';
$benchlang = 'CXX';
@base_exe  = ($exename);

$obiwan = 1;

$bench_flags = '-DSMALL_MEMORY -DSPEC_AUTO_SUPPRESS_OPENMP';

@sources = (qw(
    attacks.cpp
    bitboard.cpp
    bits.cpp
    board.cpp
    draw.cpp
    endgame.cpp
    epd.cpp
    generate.cpp
    initp.cpp
    make.cpp
    moves.cpp
    neval.cpp
    pawn.cpp
    preproc.cpp
    search.cpp
    see.cpp
    sjeng.cpp
    state.cpp
    ttable.cpp
    utils.cpp
    ));

sub invoke {
    my ($me) = @_;
    my $name;
    my @rc;

    my $exe = $me->exe_file;
    for ($me->input_files_base) {
        if (($name) = m/(.*).txt$/) {
            push @rc, {
                'command' => $exe,
                'args'    => [ "$name.txt" ],
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
