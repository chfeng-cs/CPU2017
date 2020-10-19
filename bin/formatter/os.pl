#
# os.pm
#
# Copyright 1999-2019 Standard Performance Evaluation Corporation
#  All Rights Reserved
#
# $Id: os.pl 6093 2019-03-13 04:04:33Z CloyceS $

use strict;

my $version = '$LastChangedRevision: 6093 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'os.pl'} = $version;

# It's really _all_ common
require 'os_common.pl';

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
