#
# log.pl
#
# Copyright 1999-2019 Standard Performance Evaluation Corporation
#
# $Id: log.pl 6093 2019-03-13 04:04:33Z CloyceS $

use strict;

my $version = '$LastChangedRevision: 6093 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'log.pl'} = $version;

$::log_handle = undef;

require 'log_common.pl';

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
