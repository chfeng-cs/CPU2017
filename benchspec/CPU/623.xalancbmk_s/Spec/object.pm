#
# object.pm -- benchmark description file for 623.xercesc
#
# This file is Perl source code.  You can check the validity of your syntax
# by running
#
#    specperl -cw object.pm
#

$benchnum  = '623';
$benchname = 'xalancbmk_s';
$exename   = 'xalancbmk_s';
$benchlang = 'CXX';
@base_exe  = ($exename);

%workloads = (
    'test'       => [ [ '523.xalancbmk_r' ] ],
    'train'      => [ [ '523.xalancbmk_r' ] ],
    'refspeed'   => [ [ '523.xalancbmk_r' ] ],
    'refrate'    => [ [ '523.xalancbmk_r' ] ],
);

$calctol = 0;   # Output is not numeric

$sources = '523.xalancbmk_r';

$bench_cxxflags = '-DAPP_NO_THREADS -DXALAN_INMEM_MSG_LOADER -I. -Ixercesc -Ixercesc/dom -Ixercesc/dom/impl -Ixercesc/sax -Ixercesc/util/MsgLoaders/InMemory -Ixercesc/util/Transcoders/Iconv -Ixalanc/include -DPROJ_XMLPARSER -DPROJ_XMLUTIL -DPROJ_PARSERS -DPROJ_SAX4C -DPROJ_SAX2 -DPROJ_DOM -DPROJ_VALIDATORS -DXML_USE_INMEM_MESSAGELOADER';

# For windows add the no_asm just to make sure. It would not be invoked anyway
# if WIND64 is defined. But in testing, the itanium compiler did not have it.
$bench_cxxflags .= ' -DXERCES_NO_ASM' if ($^O =~ /MSWin32/i);

use File::Basename;

sub invoke {
    my ($me) = @_;
    my $name;
    my @rc;

    my $exe = $me->exe_file;

    for my $file ($me->input_files_base) {

        # The following regexp matches anything that ends in '.lst' and saves
        # the part leading up to it in $name
        if (($name) = ($file =~ m/(.*)\.lst$/)) {
            my @xml_files = main::read_file($file);
            chomp(@xml_files);
            push @rc, (
                map { {
                'command' => $exe,
                'args'    => [ qw( -v ), $_, 'xalanc.xsl' ],
                'output'  => "${name}-".basename($_, '.xml').'.out',
                'error'   => "${name}-".basename($_, '.xml').'.err',
                } } @xml_files
            );
        }
    }
    return @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
