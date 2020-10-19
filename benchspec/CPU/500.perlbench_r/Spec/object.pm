$benchnum  = '500';
$benchname = 'perlbench_r';
$exename   = 'perlbench_r';
$benchlang = 'C';
@base_exe  = ($exename);

%workloads = (
               'refspeed' => [ 'refrate' ],
             );

@sources=qw(av.c caretx.c deb.c doio.c doop.c dump.c globals.c gv.c hv.c keywords.c locale.c
            mg.c numeric.c op.c pad.c perl.c perlapi.c perlio.c perlmain.c
            perly.c pp.c pp_ctl.c pp_hot.c pp_pack.c pp_sort.c pp_sys.c
            regcomp.c regexec.c run.c scope.c sv.c taint.c toke.c
            universal.c utf8.c util.c reentr.c mro_core.c mathoms.c
            specrand/specrand.c
            dist/PathTools/Cwd.c
            dist/Data-Dumper/Dumper.c
            ext/Devel-Peek/Peek.c
            cpan/Digest-MD5/MD5.c
            cpan/Digest-SHA/SHA.c
            DynaLoader.c
            dist/IO/IO.c
            dist/IO/poll.c
            cpan/MIME-Base64/Base64.c
            Opcode.c
            dist/Storable/Storable.c
            ext/Sys-Hostname/Hostname.c
            cpan/Time-HiRes/HiRes.c
            ext/XS-Typemap/stdio.c
            ext/attributes/attributes.c
            cpan/HTML-Parser/Parser.c
            ext/mro/mro.c
            ext/re/re.c
            ext/re/re_comp.c
            ext/re/re_exec.c
            ext/arybase/arybase.c
            ext/PerlIO-scalar/scalar.c
            ext/PerlIO-via/via.c
            ext/File-Glob/bsd_glob.c
            ext/File-Glob/Glob.c
            ext/Hash-Util/Util.c
            ext/Hash-Util-FieldHash/FieldHash.c
            ext/Tie-Hash-NamedCapture/NamedCapture.c
            cpan/Scalar-List-Utils/ListUtil.c
           );

$need_math    = 'yes';
$floatcompare = 'yes';
$calctol      = 'no';
$nansupport   = 'no';  # No NaNs in output, so stringwise-equal is a good
                       # initial check for equality

$bench_flags = '-DPERL_CORE -I. -Idist/IO -Icpan/Time-HiRes -Icpan/HTML-Parser -Iext/re -Ispecrand -DDOUBLE_SLASHES_SPECIAL=0 -DSPEC_AUTO_SUPPRESS_OPENMP -D_LARGE_FILES -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64';

if (($^O =~ /MSWin32/i || $ENV{'SPEC_USE_WINDOWS_SOURCES_ANYWAY'}) && !$ENV{'SPEC_NOT_REALLY_WINDOWS'}) {
  my @nt_sources=qw(win32.c win32io.c win32sck.c win32thread.c perllib.c);
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
                    push @rc, { 'command' => $exe,
                        'args' => [ '-I./lib', $_, @params ],
                        'output' => "$name.".join('.', @params).'.out',
                        'error' => "$name.".join('.', @params).'.err',
                    };
                }
            } else {
                my $cmdhash = { 'command' => $exe,
                    'args'    => [ '-I.', '-I./lib', $_ ],
                    'output'  => "$name.out",
                    'error'   => "$name.err" };
                if (-f "$name.in") {
                    $cmdhash->{'input'} = "$name.in";
                }
                push @rc, $cmdhash;
            }
        }
    }
    @rc;
}

# If you include perl.h, you also include all this stuff...
my @perl_h_deps = qw(perl.h
                     config.h spec_config.h embed.h handy.h iperlsys.h
                     perlio.h regexp.h sv.h util.h form.h gv.h pad.h cv.h
                     opnames.h op.h cop.h av.h hv.h mg.h scope.h warnings.h
                     utf8.h perly.h thread.h pp.h proto.h pp_proto.h opcode.h
                     embedvar.h intrpvar.h perlvars.h patchlevel.h
                     parser.h overload.h uudmap.h perl-orig-config.h);
%srcdeps = (
  'win32/win32thread.c' => [
    'win32/win32.h',
    'win32/win32iop.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'pp_ctl.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'scope.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'taint.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'ext/Time/HiRes/HiRes.c' => [
    'ext/Time/HiRes/const-c.inc',
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'gv.c' => [
    'overload.inc',
    'EXTERN.h',
    @perl_h_deps
  ],
  'universal.c' => [
    'vxs.inc',
    'perliol.h',
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'hv.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'win32/win32.c' => [
    'win32/win32iop.h',
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'ext/IO/poll.c' => [
    'ext/IO/poll.h',
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'perlmain.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'ext/Data/Dumper/Dumper.c' => [
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'perlio.c' => [
    'perlsdio.h',
    'perliol.h',
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'mg.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'ext/Sys/Hostname/Hostname.c' => [
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'regcomp.c' => [
    'dquote.c',
    'invlist_inline.h',
    'INTERN.h',
    'regcomp.h',
    'regcharclass.h',
    'regnodes.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'op.c' => [
    'keywords.h',
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'perly.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'perlhost.h' => [
    'iperlsys.h',
    'vmem.h',
    'vdir.h',
    'perlio.h'
  ],
  'perlapi.c' => [
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'ext/attrs/attrs.c' => [
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'ext/Digest/MD5/MD5.c' => [
    'XSUB.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'cpan/Digest-SHA/src/sha.c' => [
    'cpan/Digest-SHA/src/sha.h',
    'cpan/Digest-SHA/src/sha64bit.h',
    'cpan/Digest-SHA/src/sha64bit.c',
  ],
  'ext/Digest/SHA/SHA.c' => [
    'cpan/Digest-SHA/src/sha.c',
    'XSUB.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'pp.c' => [
    'reentr.h',
    'keywords.h',
    'specrand/specrand.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'XSUB.h' => [
    'perlapi.h'
  ],
  'util.c' => [
    'vutil.c',
    'specrand/specrand.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'globals.c' => [
    'INTERN.h',
    'perlapi.h',
    @perl_h_deps
  ],
  'ext/Devel/Peek/Peek.c' => [
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'pp_sys.c' => [
    'time64.c',
    'reentr.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'reentr.c' => [
    'reentr.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'win32/win32sck.c' => [
    'win32/win32iop.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'non-core-ext/HTML/Parser/hparser.c' => [
    'hctype.h',
    'tokenpos.h'
  ],
  'doop.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'pp_hot.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'numeric.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'ext/Cwd/Cwd.c' => [
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'doio.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'pp_sort.c' => [
    'specrand/specrand.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'run.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'config.h' => [
    'spec_config.h',
    'perl-orig-config.h'
  ],
  'regexec.c' => [
    'invlist_inline.h',
    'regcomp.h',
    'regcharclass.h',
    'regnodes.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'ext/MIME/Base64/Base64.c' => [
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'xsutils.c' => [
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'win32/win32io.c' => [
    'perliol.h',
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'pad.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'toke.c' => [
    'dquote.c',
    'keywords.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'av.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'utf8.c' => [
    'invlist_inline.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'non-core-ext/HTML/Parser/Parser.c' => [
    'non-core-ext/HTML/Parser/hparser.h',
    'non-core-ext/HTML/Parser/parser-util.c',
    'non-core-ext/HTML/Parser/hparser.c',
    'non-core-ext/HTML/Parser/hctype.h',
    'non-core-ext/HTML/Parser/tokenpos.h',
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'ext/Storable/Storable.c' => [
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'pp_pack.c' => [
    'packsizetables.inc',
    'EXTERN.h',
    @perl_h_deps
  ],
  'dump.c' => [
    'mg_names.inc',
    'regcomp.h',
    'regcharclass.h',
    'regnodes.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'locale.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'perl.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'iperlsys.h' => [
    'perlio.h'
  ],
  'sv.c' => [
    'regcomp.h',
    'regcharclass.h',
    'regnodes.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'ext/IO/IO.c' => [
    'ext/IO/poll.h',
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'deb.c' => [
    'EXTERN.h',
    @perl_h_deps
  ],
  'proto.h' => [
    'pp_proto.h'
  ],
  'win32/perllib.c' => [
    'XSUB.h',
    'perlapi.h',
    'EXTERN.h',
    @perl_h_deps
  ],
  'ext/File-Glob/Glob.c' => [
    'ext/File-Glob/const-c.inc',
    @perl_h_deps
  ],
  'ext/re/re_exec.c' => [
    'invlist_inline.h',
  ],
  'ext/re/re_comp.c' => [
    'regcomp.c',
  ],
);

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
