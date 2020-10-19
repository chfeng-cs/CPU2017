#
#  mail.pl - mails result files to configurable addresses
#  Copyright 2004-2017 Standard Performance Evaluation Corporation
#
#  Authors:  Cloyce D. Spradling
#
# $Id: mail.pl 5462 2017-03-07 19:37:23Z CloyceS $

use strict;

use IO::Compress::Bzip2 qw(:all);
use IO::File;
use File::Basename;
require 'mailutil.pl';

our ($name, $extension, $synonyms, $part_of_all, $non_default, $debug);

$name      = 'mail';
$extension = undef;
$synonyms  = { map { lc($_) => 1 } ($name, qw(mailto email)) };

$non_default = 1;       # You must ask for it by name
my $mail_version = '$LastChangedRevision: 5462 $ '; # Make emacs happier
$mail_version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'mail.pl'} = $mail_version;

sub format {
    my($me, $r, $fn, $files) = @_;

    my @nc = ::allof($r->{'nc'});

    if (!defined($r->mail->{'mailto'}) or $r->mail->{'mailto'} eq '') {
        return (undef, undef);
    }

    # Squeeze undefined values from the file list
    $files = [ grep { defined($_) } @{$files} ];

    my $m = (@{$files} > 1) ? 's' : '';
    my $invalid = ($r->{'invalid'}
                   || ((ref($r->{'errors'}) eq 'ARRAY') && @{$r->{'errors'}}));

    # Make a summary list of success codes
    my %codes = ();
    for my $bench (sort keys %{$r->{'results'}}) {
        my $benchres = $r->{'results'}{$bench};
        for my $tune (sort keys %{$r->{'results'}{$bench}}) {
            $benchres = $r->{'results'}{$bench}{$tune}{'data'};
            my $tmp;
            for my $res (@{$benchres}) {
                $codes{$res->valid}++;
            }
        }
    }

    # Now construct the subject
    my $subject = '';
    if (keys %codes) {
        # Likely
        $subject = '['.join(', ', map { "$codes{$_} $_" } sort bycode keys %codes).'] ';
    }
    if (::istrue($::global_config->reportable)) {
        # John suggests only shouting if the result was supposed to be reportable
        $subject .= 'INVALID ' if $invalid;
        $subject .= $r->metric;
        $subject .= ' '.uc($r->runmode);
        $subject .= ' RESULTS ';
    } else {
        $subject .= $r->metric;
        $subject .= ' '.$r->runmode;
        $subject .= ' results ';
        $subject .= '(invalid for publication) ' if $invalid;
    }
    $subject .= "(${main::lcsuite}test #".$r->mail->{'lognum'}.')';

    # Attach a short description
    my @parts = (
        {
            Data => [
                "This message contains the result file$m from ${main::suite} run #".$r->mail->{'lognum'}.".\n",
                "The runs were of ".$r->metric." using the ".$r->size." workload.\n",
                "\n",
                "runcpu: ".$r->mail->{'runcpu_argv'}."\n",
                "\n",
                "A results summary follows:\n",
                map { "$_\n" } Spec::Format::Text::screen_format($me, $r, $fn, 0, !!$invalid, \@nc),
                "\n",
                "--------------------------------------------------------------------------\n",
                "This mail was generated on ".scalar(localtime)."\n",
                "\n",
            ],
            Encoding => '-SUGGEST',
        }
    );

    # Figure out which files we're going to want.
    my @want_extensions;
    if ($r->mail->{'mail_reports'} =~ /\ball\b/) {
        @want_extensions = ();
    } else {
        foreach my $report (split(/[,\s]+/, $r->mail->{'mail_reports'})) {
            if (lc($report) eq 'log') {
                push @want_extensions, '.log';
            } else {
                my $e = ::get_format($::global_config->formats, $report)->{'extension'};
                push @want_extensions, '.'.$e if (defined($e));
            }
        }
    }

    # Now attach each of the files
    foreach my $file (@{$files}) {
        if (@want_extensions) {
            # Check to see if the current file is one that we're interested in
            next unless grep { $file =~ /\Q$_\E$/ } @want_extensions;
        }
        if (!::istrue($r->mail->{'compress'})) {
            push @parts, $file;
        } else {
            # Compress it and send it along
            my $ifh = new IO::File '<'.$file;
            next unless defined($ifh);
            my $oldeol = $/;
            undef $/;
            my $compressed;
            my $status = bzip2 $ifh => \$compressed;
            next unless $status;
            push @parts, {
                Encoding => 'Base64',
                Type     => 'application/x-bzip2',
                Data     => $compressed,
                Filename => basename($file).'.bz2',
            };
            $/ = $oldeol;
        }
    }
    return ([], undef) unless @parts > 1; # Don't send empty mail

    my @to = ::send_email(
        'subject'    => $subject,
        'from'       => $r->mail->{'username'},
        'to'         => [ split(/[,\s]+/, $r->mail->{'mailto'}) ],
        'agent_id'   => "mailto formatter $mail_version",
        'parts'      => [ @parts ],
        'mailmethod' => lc($r->mail->{'mailmethod'}),
        'mailserver' => $r->mail->{'mailserver'},
        'mailport'   => $r->mail->{'mailport'},
        'debug'      => $debug,
    );

    if (@to) {
        return ([], [@to]);
    } else {
        return ([], undef);
    }
}

sub bycode {
    # Sort return codes with 'S' first
    return -1 if $a eq 'S';
    return 1 if $b eq 'S';
    return $a cmp $b;
}

1;
# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
