#
# flagutils.pl
#
# Copyright 2005-2019 Standard Performance Evaluation Corporation
#
# $Id: flagutils.pl 6093 2019-03-13 04:04:33Z CloyceS $

use strict;

require 'util.pl';

my $version = '$LastChangedRevision: 6093 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'flagutils.pl'} = $version;

# runcpu's requirements are actually quite modest
require 'flagutils_common.pl';

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
