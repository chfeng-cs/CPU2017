#!/usr/bin/perl -w

# Test that SPECPERLLIB is propogated from the harness process to the test
# process.

use strict;
use warnings;
use lib 't/lib';
use Config;

my $path_sep = $Config{path_sep};

sub has_crazy_patch {
    my $sentinel = 'blirpzoffle';
    local $ENV{SPECPERLLIB} = $sentinel;
    my $command = join ' ',
      map {qq{"$_"}} ( $^X, '-e', 'print join q(:), @INC' );
    my $path = `$command`;
    my @got = ( $path =~ /($sentinel)/g );
    return @got > 1;
}

use Test::More (
      $^O eq 'VMS' ? ( skip_all => 'VMS' )
    : has_crazy_patch() ? ( skip_all => 'Incompatible @INC patch' )
    : ( tests => 1 )
);

use Test::Harness;
use App::Prove;

# Change SPECPERLLIB so we ensure it's preserved.
$ENV{SPECPERLLIB} = join(
    $path_sep, 'wibble',
    $ENV{SPECPERLLIB} || ''
);

open TEST, ">perl5lib_check.t.tmp";
print TEST <<"END";
#!/usr/bin/perl
use strict;
use Test::More tests => 1;
like \$ENV{SPECPERLLIB}, qr/(^|${path_sep})wibble${path_sep}/;
END
close TEST;

END { 1 while unlink 'perl5lib_check.t.tmp'; }

my $h = TAP::Harness->new( { lib => ['something'], verbosity => -3 } );
ok( !$h->runtests('perl5lib_check.t.tmp')->has_errors );

1;
