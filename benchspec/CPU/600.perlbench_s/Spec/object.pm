$benchnum  = '600';
$benchname = 'perlbench_s';
$exename   = 'perlbench_s';
$benchlang = 'C';
@base_exe  = ($exename);

%workloads = (
    'test'       => [ [ '500.perlbench_r' ] ],
    'train'      => [ [ '500.perlbench_r' ] ],
    'refspeed'   => [ [ '500.perlbench_r' ] ],
    'refrate'    => [ [ '500.perlbench_r' ] ],
);

$sources = '500.perlbench_r';

$need_math    = 'yes';
$floatcompare = 'yes';
$calctol      = 'no';
$nansupport   = 'no';  # No NaNs in output, so stringwise-equal is a good
                       # initial check for equality
$bench_flags = '-DPERL_CORE -I. -Idist/IO -Icpan/Time-HiRes -Icpan/HTML-Parser -Iext/re -Ispecrand -DDOUBLE_SLASHES_SPECIAL=0 -D_LARGE_FILES -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64';

if (($^O =~ /MSWin32/i || $ENV{'SPEC_USE_WINDOWS_SOURCES_ANYWAY'}) && !$ENV{'SPEC_NOT_REALLY_WINDOWS'}) {
    my @nt_sources = qw(win32.c win32io.c win32sck.c win32thread.c perllib.c);
    push @sources, map { "win32/$_" } @nt_sources;
    $bench_flags .= ' -Iwin32 -DPERLDLL -DWIN32_NO_SOCKETS';
}

use Carp;

sub invoke {
    my ($me) = @_;
    my $name;
    my @rc;

    my $exe = $me->exe_file;
    my $iswindows = ($^O =~ /MSWin32/i);

    for (sort $me->input_files_base) {
        next if m#/#o;  # Don't descend into subdirs
        if (($name) = m/(.*)\.(t|pl)$/) {
            # To avoid confusion, all tests are now run the same way.  This
            # means lots of unnecessary (on Unix) invocations of perlbench,
            # but it's less confusing this way.
            if ($name =~ /splitmail|perfect|diffmail|checkspam/) {
                # Suck the data from a file
                open(IN, "<$name.in") or next; # No .in file means no run intended
                my $params = '';
                while(defined($params = <IN>)) {
                    next if ($params =~ /^(#|$)/o);
                    my @params = split(/\s+/, $params);
                    push @rc, {
                        'command' => $exe,
                        'args' => [ '-I./lib', $_, @params ],
                        'output' => "$name.".join('.', @params).'.out',
                        'error' => "$name.".join('.', @params).'.err',
                    };
                }
            } else {
                my $cmdhash = {
                    'command' => $exe,
                    'args'    => [ '-I.', '-I./lib', $_ ],
                    'output'  => "$name.out",
                    'error'   => "$name.err",
                };
                if (-f "$name.in") {
                    $cmdhash->{'input'} = "$name.in";
                }
                push @rc, $cmdhash;
            }
        }
    }
    @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
