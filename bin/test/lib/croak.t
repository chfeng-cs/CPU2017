#!./perl

use TestInit; #chdir 't' if -d 't';
#@INC = '../lib';

$FATAL = 1; # we expect all the tests to croak
require '../test/lib/common.pl'; #require "../t/lib/common.pl";
