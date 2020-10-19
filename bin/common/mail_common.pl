#
#  mail.pl - common routines for sending mail
#  Copyright 2017 Standard Performance Evaluation Corporation
#
#  Authors:  Cloyce D. Spradling
#
# $Id: mail_common.pl 5472 2017-03-08 16:31:41Z CloyceS $

use strict;

use Mail::Mailer;
use MIME::Entity;

my $version = '$LastChangedRevision: 5472 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'mail_common.pl'} = $version;

# The path through this function should be kept very clean, as it may be used
# in ::do_exit().
sub send_email {
    my %args  = @_;

    $args{'to'} = [ $args{'to'} ] unless ref($args{'to'}) eq 'ARRAY';

    # If no recipients; bail
    return undef unless grep { $_ ne '' } @{$args{'to'}};

    my $agent = "SPEC ${main::suite} tools";
    $agent .= '('.$args{'agent_id'}.')' if $args{'agent_id'} ne '';
    $args{'from'} = $::global_config->username if defined($::global_config) and $args{'from'} eq '';
    $args{'from'} .= '@localhost' unless $args{'from'} =~ /@/;
    $args{'parts'} = [ $args{'parts'} ] unless ref($args{'parts'}) eq 'ARRAY';

    # Start the top-level entity
    my $top = MIME::Entity->build(
        From       => $args{'from'},
        To         => $args{'to'},
        Subject    => $args{'subject'},
        Type       => 'multipart/mixed',
        'X-Mailer' => $agent,
    );

    foreach my $part (@{$args{'parts'}}) {
        if (ref($part) eq 'HASH') {
            $top->attach(%$part);
        } elsif (-e $part) {
            $top->attach(
                Path     => $part,
                Encoding => '-SUGGEST',
            );
        } else {
            $top->attach(
                Data     => $part,
                Encoding => '-SUGGEST',
            );
        }
    }

    # If no parts, bail.
    return undef unless scalar($top->parts) > 0;

    $top->sync_headers(Length => 'COMPUTE');

#    print "\nFrom cloyce Tue Sep  7 11:28:42 1999\n";
#    $top->print(\*STDOUT);

    # Make sure the method is a sane one
    if ($args{'mailmethod'} !~ /^(?:sendmail|qmail|smtp|testfile)$/oi) {
        ::Log(0, "\nERROR: Mail method must be 'smtp', 'sendmail', or 'qmail'\n");
        return undef;
    }
    $args{'debug'}++ if lc($args{'mailmethod'}) eq 'testfile';

    my @mailer_args = (lc($args{'mailmethod'}));
    if ($mailer_args[0] eq 'smtp') {
        push @mailer_args, (
            'Server' => $args{'mailserver'},
            'Port'   => $args{'mailport'},
            'Debug'  => $args{'debug'},
        );
    }

    my $mailer;
    eval '$mailer = new Mail::Mailer @mailer_args;';
    if ($@) {
        ::Log(0, "\nERROR: When attempting to instantiate a mailer object, Mail::Mailer returned:\n");
        ::Log(0,"       $@\n");
        return undef;
    }
    eval '$mailer->open($top->head->header_hashref);';
    if ($@) {
        if (lc($args{'mailmethod'}) eq 'smtp' and $@ =~ /Invalid argument/i) {
            # It's likely that there's no mail server listening at the specified
            # address
            ::Log(0, "\nERROR: Mailer could not be opened.\n");
            ::Log(0, "      Is the SMTP server at ".$args{'mailserver'}.':'.$args{'mailport'}." off or unreachable?\n");
        } else {
            ::Log(0, "\nERROR: When attempting to open the mailer, Mail::Mailer returned:\n");
            ::Log(0,"       $@\n");
        }
        return undef;
    }
    print $mailer $top->stringify_body;
    $mailer->close();

    return @{$args{'to'}};
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
