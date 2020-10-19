#
# monitor.pl
#
# Copyright 1999-2016 Standard Performance Evaluation Corporation
#
# $Id: monitor.pl 4713 2016-08-05 17:34:34Z CloyceS $

use strict;

my $version = '$LastChangedRevision: 4713 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'monitor.pl'} = $version;

sub monitor_shell {
    my ($name, $config, @refs) = @_;
    my @cmds = ();
    foreach my $line (grep { /^\Q$name\E\d*$/ } $config->list_keys) {
        my ($idx) = $line =~ m/^\Q$name\E(\d*)$/;
        my $val = $config->accessor($line);
        $cmds[$idx] = $val;
    }
    # The linefeeds will be substituted with the correct command join
    # character ('&&' for Windows cmd, ';' for all others)
    my $cmd = join("\n", @cmds);
    # Arrange for mini-batch files to work
    if (   $^O =~ /MSWin/
        && $cmd !~ /^\s*$/
        && $cmd !~ /^cmd /) {
        $cmd = 'cmd /E:ON /D /C "'.$cmd.'"';
    }
    if ($cmd =~ m#^cmd # && $^O =~ /MSWin/) {
        # Convert line feeds into && for cmd.exe
        $cmd =~ s/[\r\n]+/\&\&/go;
    } else {
        $cmd =~ s/[\r\n]+/;/go;
    }

    my $rc = undef;

    # Cull out non-hash entries
    @refs = [ grep { (::ref_type($_) eq 'HASH') } @refs ];

    if (defined($cmd) && ($cmd ne '')) {
        Log(0, "Executing $name: $cmd\n");
        $rc = log_system($cmd,
                    {
                        'basename' => $name,
                        'combined' => 1,
                        'fake'     => istrue($config->accessor_nowarn('fake')),
                        'repl'     => [ $config, @refs ],
                    });
        if ($rc) {
            Log(0, "$name returned non-zero exit code ($rc)\n");
            do_exit(1);
        }
    }
}

sub monitor_pre        { monitor_shell('monitor_pre',        @_); }
sub monitor_pre_run    { monitor_shell('monitor_pre_run',    @_); }
sub monitor_pre_bench  { monitor_shell('monitor_pre_bench',  @_); }
sub monitor_post_bench { monitor_shell('monitor_post_bench', @_); }
sub monitor_post       { monitor_shell('monitor_post',       @_); }

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
