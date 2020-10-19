$benchnum  = '541';
$benchname = 'leela_r';
$exename   = 'leela_r';
$benchlang = 'CXX';
@base_exe  = ($exename);

%workloads = (
    'refspeed' => [ 'refrate' ],
);

@sources = (qw(
    FullBoard.cpp
    KoState.cpp
    Playout.cpp
    TimeControl.cpp
    UCTSearch.cpp
    GameState.cpp
    Leela.cpp
    SGFParser.cpp
    Timing.cpp
    Utils.cpp
    FastBoard.cpp
    Matcher.cpp
    SGFTree.cpp
    TTable.cpp
    Zobrist.cpp
    FastState.cpp
    GTP.cpp
    MCOTable.cpp
    Random.cpp
    SMP.cpp
    UCTNode.cpp
    ));

$bench_flags = '-I. -DSPEC_AUTO_SUPPRESS_OPENMP';

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
