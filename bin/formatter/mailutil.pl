#
# mailutil.pl
#
# Copyright 2017 Standard Performance Evaluation Corporation
#  All Rights Reserved
#
# $Id: mailutil.pl 5462 2017-03-07 19:37:23Z CloyceS $

use strict;

my $version = '$LastChangedRevision: 5462 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'mailutil.pl'} = $version;

# It's really _all_ common
require 'mail_common.pl';

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
