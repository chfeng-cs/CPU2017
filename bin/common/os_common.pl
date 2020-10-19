#
# os.pm
#
# Copyright 1999-2016 Standard Performance Evaluation Corporation
#  All Rights Reserved
#
# $Id: os_common.pl 4696 2016-07-28 16:16:46Z CloyceS $

use strict;

my $version = '$LastChangedRevision: 4696 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'os_common.pl'} = $version;

sub initialize_os {
    my ($config) = @_;
    if ($::from_runcpu == 0 and istrue($config->setprocgroup)) {
        eval 'setpgrp';
        ::Log(0, "NOTICE: setpgrp failed: $@\n") if $@ ne '' and $@ !~ /unimplemented/i;
    }
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
