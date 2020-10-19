#
# util_common.pl - Utility functions used by both runcpu and rawformat
#
# Copyright 1999-2019 Standard Performance Evaluation Corporation
#
# $Id: util_common.pl 6269 2019-06-25 17:33:48Z CloyceS $

my $version = '$LastChangedRevision: 6269 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'util_common.pl'} = $version;

use strict;
use Carp qw(cluck);
use Cwd qw(abs_path);
use Digest::MD5;
use Digest::SHA;
use IO::Dir;
use IO::File;
use IO::Compress::Bzip2 qw(:all);
use IO::Uncompress::Bunzip2 qw(:all);
use Compress::Zlib;
use MIME::Base64;
use Text::Wrap;
use Text::Tabs;
use URI;
use File::Spec;
use File::stat;
use File::Path;
use File::Temp ();
use File::Copy;
use Fcntl qw(:flock :seek);
use POSIX qw(:sys_wait_h);
use Storable qw(dclone);
use Time::HiRes qw(time sleep);
use Scalar::Util qw(reftype blessed);
use List::Util qw(min max first);
use Safe;
use JSON::PP;
eval { require HTTP::Tiny; HTTP::Tiny->import() };
my $http_tiny = $@ eq '';
require 'setup_common.pl';

# Older List::Util (as supplied with system Perl on RHEL 6) doesn't have any()
if (!eval { defined(&main::any) || List::Util->import("any"); 1 }) {
  eval {
      sub main::any(&@) {
          my $func = shift;
          &$func && return 1 for @_;
          0;
      }
  };
}

our ($exited, $timeout, $ua);

$Text::Wrap::unexpand = 0;

# Make an RE to match either 'notes' or 'NOTES' with all the high bits set
my $isnotes = 'notes';
$isnotes =~ s/(.)/chr(ord(uc($1)) | 0x80)/ge;
$isnotes = qr/(?:notes|$isnotes)/;

sub update_suite {
    # Get updates for the suite, which could be new or changed flag
    # descriptions, tools, toolsets, benchmark sources, src.alts, etc. from
    # SPEC, or apply a pre-downloaded update.
    my ($config, $timeout, $proxy) = @_;

    # All paths in updates will be relative to $SPEC
    chdir $config->top;

    Log(0, "\n$::suite update mode selected\n");

    # Get a temporary directory to store downloads, etc, in.
    my $tmpdir = ::get_tmp_directory($config, 1, 'updates');
    if ( ! -d $tmpdir ) {
        # Something went wrong!
        Log(0, "ERROR: Temporary directory \"$tmpdir\" couldn't be created\n");
        return undef;
    }

    # Check to see what argument (if any) was given to --update.
    # Possibilities include:
    #
    # A set of zero or more colon-separated options:
    # fake/dryrun - just show selected update and give stats
    # force - proceed without confirmation even if verification of existing
    #         files fails
    # version=<nnn> - request upgrade to specific version <nnn>
    # noconfirm - skip confirmation of update application
    # (* indicates options not yet implemented)
    #
    # Followed by an optional update source specification:
    # - URL to an update area => download metadata, download update, install
    # - URL to an update file => download, check metadata, install
    # - Path to a downloaded update file => check metadata and install
    #
    # The default action (no argument to --update) is equivalent to specifying
    # --update release:$default_config->{'update_url'}

    my %opts = (
        'version' => -1,
        'force'   => 0,
        'confirm' => 1,
        'fake'    => 0,
        'path'    => $config->update_url,
    );

    # Parse the options (if any)
    my @updateargs = split(/:/, $config->update, -1);
    while (@updateargs) {
        my $arg = shift(@updateargs);

        if ($arg =~ /^version=(.*)/) {
            $opts{'version'} = $opts{'origversion'} = $1;
            if ($opts{'version'} !~ /^[[:digit:].-]+$/) {
                Log(0, "\nERROR: Version specification given to --update is not a number\n");
                return undef;
            }
            if (normalize_version($opts{'version'}) < normalize_version($::current_version)) {
                ::Log(0, "\nERROR: Downgrade is not supported; current version ($::current_version) is newer than requested version ($opts{'version'})\n");
                return undef;
            }
        }
        elsif ($arg eq 'noconfirm') {
            $opts{'confirm'} = 0;
        }
        elsif ($arg eq 'force') {
            $opts{'force'} = 1;
        }
        elsif ($arg eq 'fake' or $arg eq 'dryrun') {
            $opts{'fake'} = 1;
        }

        # If it's not an option, it's part of the path or URL or whatever, so
        # just put everything back together.
        else {
            $opts{'path'} = join(':', $arg, @updateargs);
            last;
        }
    }

    my %updates;

    # If the user has supplied a path that is a bare file, attempt to just
    # apply it.
    if (-f $opts{'path'}) {
        # It's a pre-downloaded update; read it in and apply it
        return apply_update($opts{'path'}, undef, \%opts, $config->top);

    # Otherwise, treat it like a URL and try to fetch it
    } else {
        if ($opts{'path'} eq $config->update_url) {
            # The user hasn't modified the base URL, so append 'devel' or
            # 'release' as appropriate.
            $opts{'path'} =~ s#/+$##;
            $opts{'path'} .= is_devel($::current_version) ? '/devel' : '/release';
        }
        Log(0, "Downloading update information");
        Log(30, "from $opts{'path'}");
        Log(0, "...\n");
        (my $status, %updates) = get_update_list($opts{'path'}, $timeout, $proxy, { 'include_same' => 0 });
    }
    ::Log(50, Data::Dumper->Dump([\%updates],['avail_updates'])."\n");
    if (%updates == 0) {
        ::Log(0, "Update: No updates available for current version ".human_version($::current_version)."\n");
        return undef;
    }

    my $selected = select_update(\%updates, \%opts);
    return undef unless defined($selected);

    my ($metadata, $updatefname) = download_update($selected, \%opts, $proxy, $timeout, $tmpdir);
    return undef unless defined($metadata);

    return apply_update($updatefname, $metadata, \%opts, $config->top);
}

sub download_update {
    my ($selected, $opts, $proxy, $timeout, $tmpdir) = @_;

    my $upd_select = ($selected->{'comp_dl_size'} > 0) ? 'comp' : 'update';
    my $dlsize = $selected->{$upd_select.'_dl_size'};
    Log(0, "\nSelected update:\n".
           "\tFrom ".human_version($::current_version).' to '.human_version($selected->{'to'})."\n".
           "\tUpdate size: ".humanize($dlsize, 'B', 10)."\n".
           "\n");

    # Define the callback we'll use to show download progress
    my $progress_start = time;
    my $progress_msg = '';
    my $progress_stats = '';
    my $progress_size = 0;
    my $progress_cursize = 0;
    my $progress_fd = undef;
    my $progress_sub = sub {
        my ($chunk, $res) = @_;
        $progress_cursize += length($chunk);
        if (defined($progress_fd)) {
            $progress_fd->print($chunk);
        } else {
            $res->{'content'} .= $chunk;
        }
        my $elapsed = time - $progress_start;
        $elapsed++ unless $elapsed;
        if ($progress_size > 0) {
            $progress_stats = sprintf("%s/%s (%d%%; %s/s)",
                humanize($progress_cursize, 'B', 10),
                humanize($progress_size, 'B', 10),
                int($progress_cursize/$progress_size * 100),
                humanize($progress_cursize / $elapsed, 'B', 10));
        } else {
            $progress_stats = sprintf("%s (%s/s)",
                humanize($progress_cursize, 'B', 10),
                humanize($progress_cursize / $elapsed, 'B', 10));
        }
        print "\r$progress_msg $progress_stats\r";
    };

    # Fix up the download URL so we only have to put file extensions on the end
    my $base = URI->new($opts->{'path'});
    my @segs = $base->path_segments;
    push @segs, $selected->{'updatename'};
    $base->path_segments(@segs);

    # Download the update metadata
    $progress_size = 0;
    $progress_msg = 'Downloading update metadata';
    $progress_msg .= " from ${base}.meta" if Log(30);
    $progress_msg .= ':';
    Log(0, "\n$progress_msg");
    $progress_start = time;
    my $res = ::get_url(\$ua, $base.'.meta', $timeout, $proxy, $progress_sub);
    Log(0, " $progress_stats\n");
    if (!$res->{'success'}) {
        Log(0, "ERROR: Update metadata download failed");
        ::explain_http_error($res, 0);
        Log(0, "\n");
        return undef;
    }

    my ($metadatastr, $metahash) = verify_metadata($res->{'content'}, $selected->{'metahash'});
    return undef unless defined($metadatastr) and $metadatastr ne '';
    my $metadata = parse_metadata($metadatastr);
    return undef unless defined($metadata);
    Log(0, "Update metadata downloaded and verified.\n\n");

    # Do the file checks now, before downloading the update.  If confirmation
    # is needed and not granted, it will exit.
    Log(0, "Checking files that will be changed or removed by the update...\n");
    confirm_update_application($metadata, $opts);
    Log(0, "Checks completed.\n");

    return ($metadata, '') if $opts->{'fake'};

    # Download the update itself
    my $updext = '.upd';
    $updext .= '.xz' if $upd_select eq 'comp';
    my $tmp_update = jp($tmpdir, $selected->{'updatename'}.$updext);
    # Dump the update to a temporary file
    my $updfd = new IO::File '>'.$tmp_update;
    if (!defined($updfd)) {
        Log(0, "ERROR: Couldn't open temporary update file '$tmp_update' for writing: $!\n");
        return undef;
    }
    # Set up parameters for the data callback
    $progress_size = $dlsize;
    $progress_fd = $updfd;
    $progress_msg = 'Update: Downloading update';
    $progress_msg .= " from ${base}${updext}" if Log(30);
    $progress_msg .= ':';
    Log(0, "\n$progress_msg");
    $progress_start = time;
    $res = ::get_url(\$ua, $base.$updext, $timeout, $proxy, $progress_sub);
    Log(0, " $progress_stats\n");
    $updfd->close();
    if (!$res->{'success'}) {
        Log(0, "ERROR: Update download failed;");
        ::explain_http_error($res, 0);
        Log(0, "\n");
        return undef;
    }

    # Check that the download wasn't corrupted
    my $updhash = filedigest($tmp_update, length($selected->{$upd_select.'hash'}) * 4);
    if ($updhash ne $selected->{$upd_select.'hash'}) {
        Log(0, "\nERROR: The downloaded update was corrupted\n");
        return undef;
    }
    Log(0, "Update downloaded and verified.\n\n");

    return ($metadata, $tmp_update);
}

sub verify_metadata {
    my ($compmeta, $expected_hash) = @_;

    # Metadata is likely compressed.  Either way, decode_decompress will
    # give us plain text.
    my $metadata = decode_decompress($compmeta);
    # Check that the metadata isn't corrupt
    my $metahash = scalardigest($metadata, length($expected_hash) * 4);
    if ($metahash ne $expected_hash) {
        Log(0, "\nERROR: The update metadata was corrupted\n");
        return undef;
    }
    return ($metadata, $metahash);
}

sub select_update {
    my ($updates, $opts) = @_;
    my $selected = undef;

    if ($opts->{'version'} > 0) {
        # User has requested a specific version; see if it's available
        if($opts->{'version'} =~ /^(\d+)\.(\d{1,3})$/) {
            # Only major.minor was specified, so find the biggest number that
            # matches
            my $desired = sprintf '%d.%03d', $1, $2;
            my ($ver) = sort { $b <=> $a } grep { /^\Q$desired\E\d+/ } keys %$updates;
            ::Log(30, "Found version '".denormalize_version($ver)."' for requested version '$opts->{'version'}' ('$opts->{'origversion'}')\n");
            $opts->{'version'} = $ver if $ver ne '';
        }
        $selected = $updates->{normalize_version($opts->{'version'})};
        if (!defined($selected)) {
            ::Log(0, "Update: No update available to requested version '$opts->{'origversion'}'\n");
            return undef;
        }
    }

    else {
        # User has not expressed a preference, so select the latest release
        # or if there is none, the latest dev release
        my ($tover) = (sort {
                if    (is_devel($a) and is_release($b)) {  1 }
                elsif (is_release($a) and is_devel($b)) { -1 }
                else { $b <=> $a }
            } keys %$updates);
        ::Log(30, "Selected update to version '$tover' (available were ".join(', ', sort keys %$updates).")\n");
        $selected = $updates->{$tover};

        # In case there are multiple (there shouldn't be), select the one
        # with the smallest download size.
        my ($tmpfrom) = sort { $selected->{$a}->{'comp_dl_size'} <=> $selected->{$b}->{'comp_dl_size'} || $a cmp $b } keys %$selected;
        $selected = $selected->{$tmpfrom};
    }
    Log(50, Data::Dumper->Dump([$selected],['selected_update'])."\n");

    if (!defined($selected)) {
        Log(0, "\nUpdate: No updates found\n");
        return undef;
    }

    return $selected;
}

# Phone home (usually to SPEC) to get the list of available updates.
sub get_update_list {
    my ($url, $timeout, $proxy, $opts) = @_;
    my %updates;
    $timeout ||= 30;

    # Slap 'updateindex' on the end of the URL if it isn't there already
    $url =~ s#/+$##;
    $url .= '/updateindex' unless $url =~ m#/updateindex$#;

    my $res = ::get_url(\$ua, $url, $timeout, $proxy, undef);
    if ($res->{'success'}) {
        foreach my $line (split(/[\r\n]+/, $res->{'content'})) {
            next if $line =~ /^\s*(#|$)/;
            my ($fromver, $tover, $basename, @fields) = split(/\s+/, $line);
            my $reason = '';
            if (normalize_version($fromver) > normalize_version($::current_version)) {
                $reason = 'too old';
            }
            elsif (normalize_version($::current_version) > normalize_version($tover)) {
                $reason = 'newer';
            }
            elsif (! $opts->{'include_same'} and normalize_version($::current_version) == normalize_version($tover)) {
                $reason = 'the same';
            }
            elsif (is_release($fromver) and is_devel($::current_version)) {
                $reason = 'not a release version';
            }
            if ($reason ne '') {
                ::Log(30, "Omitting ${fromver}->${tover} ($basename) from consideration because the running version ($::current_version) is $reason\n");
                next;
            }
            $updates{$tover}->{$fromver} = {
                'from'           => $fromver,
                'to'             => $tover,
                'updatename'     => $basename,
                'updatehash'     => shift @fields,
                'update_dl_size' => shift @fields,
                'comphash'       => shift @fields,
                'comp_dl_size'   => shift @fields,
                'metahash'       => shift @fields,
                'release_date'   => shift @fields,
            };
        }
    } else {
        Log(0, "\nNOTICE: Could not retrieve update metadata;");
        ::explain_http_error($res, 0);
        Log(0, "\n");
    }

    return ($res, %updates);
}

# Apply an update file present locally.  If $metadata is present, it will be
# preferred over the metadata present in the update file.
sub apply_update {
    my ($updatefname, $metadata, $opts, $top) = @_;

    my $compfname = undef;
    if ($updatefname =~ /\.xz$/) {
        # Compressed update needs to be uncompressed before we can work on it
        $compfname = $updatefname;
        $updatefname =~ s/\.xz$//;
        # We can expect that specxz is in the PATH, since this is running
        # from runcpu
        Log(0, "Uncompressing update file\n");
        unlink $updatefname;
        system "specxz -dc $compfname > $updatefname";
        if ($? != 0) {
            Log(0, "ERROR: Decompression failed\n");
            unlink $updatefname;
            return undef;
        }
    }

    if (!defined($metadata) or ref($metadata) ne 'HASH') {
        $metadata = extract_metadata($updatefname);
        return undef unless defined($metadata) and ref($metadata) eq 'HASH';
        Log(0, "Checking files that will be changed or removed by the update...\n");
        confirm_update_application($metadata, $opts);
        Log(0, "Checks completed.\n");
    }

    if ($opts->{'fake'}) {
        Log(0, "\nUpdate dry run completed.\n");
        return 2;
    }

    if ($opts->{'confirm'}) {
        Log(0, "\nProceed with update? (y/n)\n");
        if (!read_confirmation()) {
            Log(0, "\nUpdate aborted.\n");
            do_exit(0);
        }
    }

    my @postapply = @{$metadata->{'postapply'}} if exists($metadata->{'postapply'});
    # CVT2DEV: push @postapply, 'convert_to_development';

    # Now it's time to apply the update.
    # Rather than rely on tar to overwrite files properly, we will do this in
    # three steps:
    # 1. Files and directories to be removed will be renamed
    # 2. The update tarball will be extracted
    # 3. Previously renamed files and directories will actually be removed
    # If there's any failure at any point, the previously performed actions
    # will be rolled back.
    my @undo = ();

    # First rename directories to be removed
    foreach my $dir (@{$metadata->{'rmdir'}}) {
        next unless (-d $dir) and ($dir ne '.');
        my $dest = jp(dirname($dir), ".$$.".basename($dir));
        if (move($dir, $dest)) {
            # Success!
            push @undo, [ $dest, $dir ];
        } else {
            push @undo, [ $dest, undef ] if -d $dest;
            Log(0, "ERROR: Error preparing '$dir' for removal: $!\n");
            return abort_update(\@undo);
        }
    }
    # Then rename existing files that will be removed or changed
    foreach my $file (@{$metadata->{'rmfile'}}, @{$metadata->{'chgfile'}}) {
        next unless -f $file;
        my $dest = jp(dirname($file), ".$$.".basename($file));
        if (move($file, $dest)) {
            # Success!
            push @undo, [ $dest, $file ];
        } else {
            Log(0, "ERROR: Error preparing '$file' for removal: $!\n");
            return abort_update(\@undo);
        }
    }

    # Now actually extract the tarball.  Archive::Tar is used because it's
    # possible to get a list of files extracted from it, and it's easy to
    # tell when there's an error.
    my $at = Archive::Tar->new();
    if (!defined($at)) {
        Log(0, "ERROR: Could not get Archive::Tar object for update\n");
        return abort_update(\@undo);
    }
    my @extracted = $at->read($updatefname, undef, {
            'extract'   => 1,
            'filter_cb' => sub {
                return 0 if $_[0]->name =~ /^\Q$::suite\E.*\.meta(?:hash)?$/;
                return 1; }
        });
    if (@extracted != @{$metadata->{'addfile'}} + @{$metadata->{'chgfile'}}) {
        if (@extracted == 0) {
            # Archive::Tar error
            Log(0, "ERROR: Could not extract files from update package:\n\t".$at->error()."\n");
        } else {
            Log(0, "ERROR: Did not extract exepcted number of files from update package.\n");
        }
        return abort_update(\@undo);
    }
    # Also make sure that the lists of files are the same.  Archive::Tar
    # returns only the filename part; for future-proofing, take the basename
    # of all the files.
    my %expected = map { basename($_) => 1 } (@{$metadata->{'addfile'}}, @{$metadata->{'chgfile'}});
    foreach my $file (@extracted) {
        delete $expected{basename($file)};
    }
    if (keys %expected > 0) {
        Log(0, "ERROR: Extracted files do not match expected.\n");
        Log(50, "Files expected that were not extracted:\n\t".join("\n\t", sort keys %expected)."\n");
        return abort_update(\@undo);
    }

    # Check that the extracted files were extracted properly.  MANIFEST is
    # guaranteed to be one of the extracted files, so read it in.
    my ($tmphash, $tmpsize) = ({}, {});
    read_manifest($top, 'MANIFEST', undef, $tmphash, $tmpsize);
    my @check_files = (@{$metadata->{'addfile'}}, @{$metadata->{'chgfile'}});
    if (defined($metadata->{'tohash'}) and $metadata->{'tohash'} ne '') {
        $tmphash->{'MANIFEST'} = $metadata->{'tohash'};
    } else {
        @check_files = grep { $_ ne 'MANIFEST' } @check_files;
    }
    my ($ok, $file) = check_files($tmphash, @check_files);
    if (!$ok) {
        Log(0, "ERROR: Extracted file '$file' was corrupted.\n");
        Log(50, "\tExpected hash '$tmphash->{$file}'\n");
        return abort_update(\@undo);
    }

    # Now remove the files that were previously renamed.  Failure at this
    # point just leaves junk laying around, which is not good.  Best case
    # is that there's no effect.  Worst case is that it causes benchmarks
    # to fail (cruft in data directories) or masks failures somehow.
    # Because of the potential for mayhem, abort if any part of this goes
    # wrong.
    foreach my $action (@undo) {
        my ($old) = @$action;
        my $err = [];
        File::Path::remove_tree($old, { 'safe' => 0, 'error' => \$err });
        if (@$err) {
            Log(0, "\nUNRECOVERABLE: An unrecoverable error has happened while attempting to clean\n".
                    "up after extraction of the update.\n".
                    "\n".
                    "The benchmark must be reinstalled from scratch.\n".
                    "\n");
            do_exit(1);
        }
    }

    # XXX This stuff needs to be converted to a script which can be
    # XXX run independent of the tools (so /bin/sh on *ix and
    # XXX batch or Powershell on Windows)
    my $actions = 0;
    if (grep { /^install/ } @postapply) {
        Log(0, "\nAfter completion, please re-install the tools by running\n");
        if ($^O =~ /MSWin/) {
            Log(0, "\tcd %SPEC%\n".
                   "\tinstall.bat\n");
        } else {
            Log(0, "\t".$ENV{'SPEC'}."/install.sh -u $::toolset_name -f\n");
        }
        Log(0, "\n".
               "If the re-run of the installer fails, you will need to begin again by re-\n".
               "installing from the ISO image and attempt to re-apply the update\n");
        $actions++;
    }
    if (grep { /^convert/ } @postapply) {
        if ($actions) {
            Log(0, "\nAfter reinstalling the tools, please also run\n");
        } else {
            Log(0, "\nAfter completion, please also run\n");
        }
        Log(0, "\tconvert_to_development\n");
    }

    return 1;
}

# Something has gone wrong; the actions performed so far must be un-done
# before exiting.
sub abort_update {
    my ($actions) = @_;

    Log(0, "\nAborting update...\n");
    my $warn_reinstall = 0;
    foreach my $actref (reverse @$actions) {
        my ($from, $to) = @$actref;
        if (defined($to)) {
            if (-e $from and -e $to) {
                # Remove the destination to be sure the move back will work
                my $err = [];
                File::Path::remove_tree($to, { 'safe' => 0, 'error' => \$err });
                if (-d $to and @$err) {
                    # Having a destination directory around means that the
                    # subsequent move() will NOT do the right thing and
                    # that the update is now officially hosed.
                    Log(0, "\nUNRECOVERABLE: An unrecoverable error has happened while attempting to roll\n".
                           "back application of the update.\n".
                           "\n".
                           "The benchmark must be reinstalled from scratch.\n".
                           "\n");
                    do_exit(1);
                }
            }
            if (!move($from, $to)) {
                Log(0, "\nERROR: Restoration of '$to' failed: $!\n");
                $warn_reinstall = 1;
            }
        }
    }

    if ($warn_reinstall) {
        Log(0, "\nIt will likely be necessary to re-install the $::suite benchmark from scratch.\n");
    }

    return undef;
}

sub confirm_update_application {
    my ($metadata, $opts) = @_;

    # Output any messages and ask for confirmation if necessary.  It is
    # assumed that the message does not include the prompt.
    if (@{$metadata->{'msg'}}) {
        Log(0, "\n".join("\n", @{$metadata->{'msg'}})."\n");
        if ($metadata->{'msgtype'} eq 'confirm' and $opts->{'confirm'}
                and !$opts->{'fake'}) {
            Log(0, "Proceed with update? (y/n)\n");
            if (!read_confirmation()) {
                Log(0, "\nUpdate aborted.\n");
                do_exit(0);
            }
        } elsif ($metadata->{'msgtype'} eq 'install') {
            unless (grep { /^install:\S+/ } @{$metadata->{'postapply'}}) {
                push @{$metadata->{'postapply'}}, 'install:'.$::toolset_name;
            }
        }
    }

    # Check to see if we need to ask about doing a post-application install
    if ((grep { $_ eq "install:$::toolset_name" } @{$metadata->{'postapply'}})
            or (exists($metadata->{'actions'}->{'install'})
                and $metadata->{'actions'}->{'install'}->{$::toolset_name})) {
        Log(0, "\nApplication of this update will require that the tools binaries be reinstalled.\n");
        if ($opts->{'confirm'} and !$opts->{'fake'}) {
            Log(0, "If that is not acceptable, the update process will be aborted.\n".
                   "Proceed with update? (y/n)\n");
            if (!read_confirmation()) {
                Log(0, "\nUpdate aborted.\n");
                do_exit(0);
            }
        }
        unless (grep { /^install:\S+/ } @{$metadata->{'postapply'}}) {
            push @{$metadata->{'postapply'}}, 'install:'.$::toolset_name;
        }
    }

    # Check that existing files that will be changed or removed don't have
    # any local changes.
    my $needs_confirmation = 0;
    my @filelist = check_changed(@{$metadata->{'chgfile'}});
    if (@filelist) {
        Log(0, "\nThe following files contained in the update have local changes which will be\n".
               "overwritten:\n".
               "\t".join("\n\t", @filelist)."\n");
        $needs_confirmation = 1;
    }

    # Only individually check files to be removed that don't reside in
    # directories to be removed.
    my @rmfiles = @{$metadata->{'rmfile'}};
    foreach my $rmdir (@{$metadata->{'rmdir'}}) {
        @rmfiles = grep { !m#^\Q$rmdir\E/# } @rmfiles;
    }
    @filelist = check_changed(@rmfiles);
    if (@filelist) {
        Log(0, "The following files with local changes will be removed by this update:\n".
               "\t".join("\n\t", @filelist)."\n");
        $needs_confirmation = 1;
    }

    # For directories that will be removed, check both for files that have
    # been changed as well as files not tracked.
    @filelist = check_rmdirs(@{$metadata->{'rmdir'}});
    if (@filelist) {
        Log(0, "The following changed or new files are in directories that will be removed\n".
               "by this update:\n".
               "\t".join("\n\t", @filelist)."\n");
        $needs_confirmation = 1;
    }

    if ($needs_confirmation and !$opts->{'force'} and !$opts->{'fake'}) {
        Log(0, "\nIf that is not acceptable, the update process will be aborted.\n");
        Log(0, "Proceed with update? (y/n)\n");
        if (!read_confirmation()) {
            Log(0, "\nUpdate aborted.\n");
            do_exit(0);
        }
    }
}

sub check_changed {
    my (@files) = @_;

    # Assume that in most cases everything will check out.  If it doesn't,
    # some files will be hashed twice, but that should add minimal time.
    my ($ok, $fn) = check_files(\%::file_sums, @files);
    return () if $ok;

    # Check each file one at a time.  If it's not present, that's not an error.
    my @changed = ();
    foreach my $file (@files) {
        next unless -f $file;
        ($ok, $fn) = check_files(\%::file_sums, $file);
        push @changed, $file unless $ok;
    }
    return @changed;
}

sub check_rmdirs {
    my (@dirs) = @_;
    my @changed = ();

    # Make list of all files in @dirs that either aren't in %::filesums or
    # which have been changed.
    foreach my $dir (@dirs) {
        my @files = list_all_files($dir);
        next unless @files;
        push @changed, check_changed(@files);
    }

    return @changed;
}

sub read_confirmation {
    my $choice = <>;
    return ($choice =~ /^(?i:y|yes|si|hai|ja|da)\s*$/i);
}

sub extract_metadata {
    my ($fname) = @_;

    # Extract the metadata file from the archive
    Log(0, "Extracting metadata from update archive\n");
    my $fh = new IO::File '<'.$fname;
    if (!defined($fh)) {
        Log(0, "ERROR: Couldn't open requested update file '$fname' for reading: $!\n");
        return undef;
    }

    my $at = Archive::Tar->new();
    if (!defined($at)) {
        Log(0, "ERROR: Couldn't acquire Archive::Tar object\n");
        return undef;
    }
    my @metafiles = $at->read($fh, undef, { 'filter' => qr/\.meta(?:hash)?$/ });
    Log(50, Data::Dumper->Dump([\@metafiles],['metadata_files'])."\n");

    my ($metafile) = grep { $_->name =~ /^\Q$::suite\E\..*\.meta$/ } @metafiles;
    if (!defined($metafile)) {
        Log(0, "Expected metadata file not found in update\n");
        return undef;
    }
    my ($metahashfile) = grep { $_->name =~ /^\Q$::suite\E\..*\.metahash$/ } @metafiles;
    if (!defined($metafile)) {
        Log(0, "Expected metadata hash file not found in update\n");
        return undef;
    }
    my ($metadatastr) = verify_metadata($metafile->get_content(), $metahashfile->get_content());
    if (!defined($metadatastr) or $metadatastr !~ /^START/) {
        Log(0, "ERROR: Update metadata file is corrupt\n");
        return undef;
    }
    Log(0, "Update metadata verified.\n\n");

    my $metadata = parse_metadata($metadatastr);
    return undef unless defined($metadata);

    return $metadata;
}

sub parse_metadata {
    my ($s) = @_;
    my %metadata = (
        'actions' => {},
        'msg'     => [],
        'addfile' => [],
        'chgfile' => [],
        'rmdir'   => [],
        'rmfile'  => [],
    );
    my $started = 0;
    my $ios = IO::String->new($s);
    if (!defined($ios)) {
        Log(0, "ERROR: Could not get IO::String for provided metadata\n");
        return undef;
    }
    while(defined(my $line = $ios->getline())) {
        next unless $started or $line =~ /^START$/;
        $line =~ tr/\012\015//d;
        if ($line eq 'START') {
            if ($started) {
                Log(0, "ERROR: Metadata is corrupt (double start tags)\n");
                return undef;
            }
            $started = 1;
        }
        elsif ($line =~ /^FROM:\s+(\S+) \(([[:xdigit:]]{32,128})\)$/) {
            $metadata{'fromhash'} = $2;
            $metadata{'fromver'} = normalize_version($1);
        }
        elsif ($line =~ /^TO:\s+(\S+)(?: \(([[:xdigit:]]{32,128})\))?$/) {
            $metadata{'tohash'} = $2;
            $metadata{'tover'} = normalize_version($1);
        }
        elsif ($line =~ /^RMDIRS:\s+(\d+)$/) {
            $metadata{'rmdir_count'} = $1+0;
        }
        elsif ($line =~ /^RMDIR:(.+)$/) {
            push @{$metadata{'rmdir'}}, $1;
        }
        elsif ($line =~ /^RMS:\s+(\d+)$/) {
            $metadata{'rmfile_count'} = $1+0;
        }
        elsif ($line =~ /^RM:(.+)$/) {
            push @{$metadata{'rmfile'}}, $1;
        }
        elsif ($line =~ /^CHANGED:\s+(\d+)$/) {
            $metadata{'chgfile_count'} = $1+0;
        }
        elsif ($line =~ /^CHG:(.+)$/) {
            push @{$metadata{'chgfile'}}, $1;
        }
        elsif ($line =~ /^ADDED:\s+(\d+)$/) {
            $metadata{'addfile_count'} = $1+0;
        }
        elsif ($line =~ /^ADD:(.+)$/) {
            push @{$metadata{'addfile'}}, $1;
        }
        elsif ($line =~ /^MSG:\s+(.*)$/) {
            push @{$metadata{'msg'}}, $line;
        }
        elsif ($line =~ /^MSGTYPE:\s+(\S+)$/) {
            $metadata{'msgtype'} = $1;
        }
        elsif ($line =~ /^ACTION:\s+(.*)$/) {
            foreach my $action (split(/\s+/, $1)) {
                my ($act, $target) = split(/:/, $action, 2);
                $metadata{'actions'}->{$act}->{$target} = 1;
            }
        }
        elsif ($line eq 'END') {
            $started = 2;
            last;
        }
    }
    if ($started != 2) {
        Log(0, "ERROR: Metadata is incomplete\n");
        return undef;
    }

    # Do sanity checks on the metadata
    my $ok = 1;
    if ($metadata{'addfile_count'} != @{$metadata{'addfile'}}) {
        Log(0, "ERROR: Metadata is corrupt (added file count does not match number of added files)\n");
        $ok = 0;
    }
    if ($metadata{'chgfile_count'} != @{$metadata{'chgfile'}}) {
        Log(0, "ERROR: Metadata is corrupt (changed file count does not match number of changed files)\n");
        $ok = 0;
    }
    if ($metadata{'rmfile_count'} != @{$metadata{'rmfile'}}) {
        Log(0, "ERROR: Metadata is corrupt (removed file count does not match number of files to be removed)\n");
        $ok = 0;
    }
    if ($metadata{'rmdir_count'} != @{$metadata{'rmdir'}}) {
        Log(0, "ERROR: Metadata is corrupt (removed directory count does not match number of directories to be removed)\n");
        $ok = 0;
    }
    if ($metadata{'msgtype'} !~ /^(?:none|confirm|install)$/
            and @{$metadata{'msg'}}) {
        Log(0, "ERROR: Metadata is corrupt (unknown message type '$metadata{'msgtype'}')\n");
        $ok = 0;
    }
    if (normalize_version($metadata{'fromver'}) > normalize_version($::current_version)) {
        Log(0, "ERROR: Update for ".human_version($metadata{'fromver'})." is not applicable to running version (".human_version($::current_version).")\n");
        $ok = 0;
    }
    foreach my $action (keys %{$metadata{'actions'}}) {
        if ($action ne 'install') {
            Log(0, "ERROR: Action '$action' is unknown\n");
            $ok = 0;
        }
    }

    if (!$ok) {
        # Errors already logged
        return undef;
    }

    Log(0, "Update metadata parsed successfully.\n");
    Log(50, Data::Dumper->Dump([\%metadata],['metadata_parsed'])."\n");
    Log(0, "\n".
           "Update summary:\n".
           "\tFiles to remove: ".$metadata{'rmfile_count'}."\n".
           "\tDirectories to remove: ".$metadata{'rmdir_count'}."\n".
           "\tFiles to change: ".$metadata{'chgfile_count'}."\n".
           "\tFiles to add: ".$metadata{'addfile_count'}."\n");

    return \%metadata;
}

sub get_hash_context {
    my ($bits) = @_;
    $bits = defined($bits) ? $bits + 0 : 0;
    my $algo = '';
    my $ctx = undef;

    if ($bits >= 256) {
        $ctx = Digest::SHA->new($bits);
        $algo = "SHA-$bits";
        if (!defined($ctx)) {
            ::Log(0, "\nWarning: Could not find algorithm for SHA-$bits".Carp::longmess()."\n");
            $bits = 256;
            $algo = "SHA-$bits";
            $ctx = new Digest::SHA->new($bits); # Failsafe?
            ::Log(0, "\nERROR: Could not find algorithm for SHA-$bits either.\n") unless defined($ctx);
        }
    } else {
        $bits = 128;
        $ctx = new Digest::MD5;
        $algo = 'MD5';
    }
    return wantarray ? ($ctx, $bits, $algo) : $ctx;
}

sub filedigest {
    my ($fname, $bits) = @_;
    (my $ctx, $bits, my $algo) = get_hash_context($bits);

    if (defined($ctx) and (-e $fname)) {
        my $ifh = new IO::File $fname, O_RDONLY|O_BINARY;
        if (!defined($ifh)) {
            Log(0, "ERROR: Could not open $fname for reading: $!\n");
            return undef;
        }
        $ctx->addfile($ifh);
        return wantarray ? ($ctx->hexdigest, $bits, $algo) : $ctx->hexdigest;
    }

    return undef;
}

sub diffdigest {
    # Like filedigest, but with guaranteed consistent line endings
    # (as will be produced by applying the diff)
    my ($file, $bits) = @_;
    (my $ctx, $bits, my $algo) = get_hash_context($bits);

    if (defined($ctx) and -e $file) {
        my $fh  = new IO::File $file, O_RDONLY|O_BINARY;
        if (!defined($fh)) {
            Log(0, "ERROR: Couldn't open $file for reading: $!\n");
            return undef;
        } else {
            my $contents;
            { local $/ = undef; $contents = <$fh>; }
            my @file = map { tr{\012\015}{\012\012}s; $_ } split(/(?:\n|\r\n)/, $contents);
            $ctx->add(join("\012", @file)."\012");
            $fh->close();
        }
        return $ctx->hexdigest();
    }

    return undef;
}

sub scalardigest {
    my ($string, $bits) = @_;
    $bits = (defined($bits) and $bits >= 128) ? $bits : 512;
    (my $ctx, $bits, my $algo) = get_hash_context($bits);

    if (defined($ctx)) {
        $ctx->add($string);
        return wantarray ? ($ctx->hexdigest, $bits, $algo) : $ctx->hexdigest;
    }

    return undef;
}

# List files in a directory.
# Note that the directory handle is closed upon exit from the subroutine
sub list_files {
    my $dir = new IO::Dir "$_[0]";
    return sort grep { !/^\.\.?$/ && ($_[0] eq '.' || s%^%$_[0]/%) } $dir->read() if (defined $dir);
    return undef;
}

# List all normal files in a directory and its subdirectories
sub list_all_files {
    my ($dir) = @_;
    my @rc = ();

    foreach my $file (list_files($dir)) {
        next unless defined($file);
        if (-d $file) {
            push @rc, ::list_all_files($file);
        } elsif (-f $file) {
            push @rc, $file;
        }
    }

    return @rc;
}

sub istrue {
    my $val = shift @_;
    return 0 unless defined($val);
    $val = lc($val);
    return ($val eq 'y' || $val eq 'yes' || $val eq 't' || $val eq 'true' ||
        $val eq 'o' || $val eq 'on'  || $val+0 != 0) ? 1 : 0;
}

sub choose_string {
    my($string, @choices) = @_;
    my($match);
    # This could be done with a map, generating a hash, and then an existence
    # check, but the loop is faster for the found case and not any slower
    # for the not-found case.
    foreach my $choice (@choices) {
        return $choice if lc($choice) eq lc($string);
    }
    for (@choices) {
        if (m/^$string/i) {
            return undef if defined $match;
            $match = $_;
        }
    }
    return $match if defined $match;
    undef;
}

# Given a list of choices as a comma-, colon-, or whitespace-delimited string,
# return the list that appear either in @{$default_choices} or @{$all_choices}.
# Returns the individual selections as a list.  If $allow_negate is set, also
# return the list of choices that were preceded by "no" or "no-" or "no_".
# Order in the output lists is not preserved or guaranteed.
sub choose_strings {
    my ($name, $string, $default_choices, $all_choices, $allow_negate) = @_;

    my %results = ();
    my %antiresults = ();
    my @antichoices = ();
    my @temp = split(/\s*[,:\s]\s*/, $string);

    foreach my $choice (@{$default_choices}, @{$all_choices}) {
        # I don't know why I can't do this with map
        push @antichoices, "no$choice", "no-$choice", "no_$choice";
    }

    for my $choice (@temp) {
        my $selection = choose_string($choice, @{$default_choices}, @{$all_choices}, "all");
        if (!defined $selection) {
            if ($allow_negate) {
                $selection = choose_string($choice, @antichoices);
                if (defined($selection)) {
                    (my $prochoice = $selection) =~ s/^no[-_]?//;
                    delete $results{$prochoice};
                    $antiresults{$prochoice}++;
                    next;
                }
            }
            Log(0, "$name does not support '$choice'\n");
        } elsif ($selection eq "all") {
            for (@{$default_choices}) {
                delete $antiresults{$_};
                $results{$_}++;
            }
        } else {
            delete $antiresults{$choice};
            $results{$choice}++;
        }
    }
    if ($allow_negate) {
        return [ keys %results ], [ keys %antiresults ];
    } else {
        return keys %results;
    }
}

# Run a command, taking care of teeing and logging and everything
# Log messages and errors at 180; 0 if teeout is on (to make sure it goes
# to the screen too)
# Parameters:
# $cmd:    the command to execute.  If there are multiples, the caller is
#          responsible for pasting them together in a way that's appropriate
#          for the shell on the target platform.  Otherwise the elements
#          of the array (if it is an array) are treated as separate elements
#          of a single command and are passed as-is to exec.
# $files:  an (optional) list of hash refs or bare filenames to monitor.
#          see the comments for file_tail() to see what the options for each
#          file are.
# $opts:   a hash ref of various options:
#    - basename: base name for output files if names are not specified
#                explicitly.  If omitted, one will be generated.
#    - outfile:  filename for stdout.  If omitted (undef), one will be
#                generated from the basename.  If empty, stdout will be
#                discarded.
#    - errfile:  filename for stderr.  If omitted (undef), stderr will be
#                merged with stdout into outfile.  If empty, stderr will be
#                discarded.
#    - tee:      whether to send output from the command to the screen/log as
#                well as the designated output files.  This really only has
#                an effect for files without callbacks or destination
#                filehandles (i.e. the common case).  Defaults to false.
#    - cleanup:  whether to remove outfile and errfile files when the process
#                completes.  Defaults to true.
sub runcpu_system {
    my ($config, $cmd, $files, $opts) = @_;
    my @cmd = (ref($cmd) eq 'ARRAY') ? @$cmd : ($cmd);
    my @files = (ref($files) eq 'ARRAY') ? @$files : ($files);
    my $exitcode = 0;
    my $strcmd = join(' ', @cmd);       # Pretty much just for Windows

    # By default clean up output files
    $opts->{'cleanup'} = 1 unless defined($opts->{'cleanup'});
    # By default do not tee output
    $opts->{'tee'} = 0 unless defined($opts->{'tee'});
    # Get a basename
    $opts->{'basename'} = File::Temp::tempnam('.', 'runcpu_system') unless defined($opts->{'basename'});

    my $loglevel = 0;
    if ($opts->{'tee'} == 0) {
        # Log only
        $loglevel = 180;
    } elsif ($opts->{'tee'} < 0) {
        # NO output
        $loglevel = -1;
    }
    my $logsub = undef;

    if ($loglevel >= 0) {
        # We only need to set up temporary files if the output will also be
        # logged.  Otherwise it can just be sent to the screen.
        $logsub = eval "sub { ::Log($loglevel, \\\@_) }";

        # Figure out names
        if (!defined($opts->{'outfile'})) {
            # Get a temporary file for the output
            my $tmpdir = ::get_tmp_directory($config, 1);
            $tmpdir = '.' unless -d $tmpdir;
            $opts->{'outfile'} = ::jp($tmpdir, $opts->{'basename'}.'.out');
        }
        if ($opts->{'outfile'} eq '') {
            # Throw the output away
            $strcmd .= ' >NUL:';
        } else {
            $strcmd .= ' >'.$opts->{'outfile'};
            push @files, { 'name' => $opts->{'outfile'}, 'callback' => $logsub, };
        }
        if (!defined($opts->{'errfile'})) {
            $opts->{'errfile'} = $opts->{'outfile'};
            $strcmd .= " 2>&1";
        } elsif ($opts->{'errfile'} eq '') {
            $strcmd .= ' 2>NUL:';
        } else {
            $strcmd .= ' 2>'.$opts->{'errfile'};
            push @files, { 'name' => $opts->{'errfile'}, 'callback' => $logsub, };
        }
    }

    # Actually start the subprocess.

    if ($^O =~ /MSWin/) {
        # Windows is handled so differently that all that stuff is in a
        # separate function.
        return runcpu_system_windows($loglevel, $opts->{'outfile'}, $opts->{'errfile'}, $strcmd, \@files);
    }

    my ($worker, $teepid);
    if ($worker = fork()) {
        # Parent; spawn the file tailer.  The tee (or not) is already reflected
        # in the value for $loglevel.
        $teepid = file_tail(@files);

        # Now just wait for the worker to exit
        my $exited = 0;
        while (!$exited) {
            my $rc = waitpid($worker, 0);       # DO wait for the exit
            if ($rc == $worker) {
                # The child was harvested at this point
                $exitcode = $?;
                $exited = 1;
            } elsif ($rc != 0) {
                ::Log(0, "Unexpectedly handled exit of child $rc with exit code $exitcode (exit status=".WEXITSTATUS($exitcode).', signal='.WTERMSIG($exitcode).")\n");
            }
        }

        # Wait for two tee sleep periods so it definitely has a chance to pick
        # up changes to the files written by the worker.  If the worker exits
        # very quickly (as would be the case if it were just an "echo", which
        # can happen for --fake runs), there's a chance that the tee process
        # will miss it.
        sleep (($::tee_loop_sleep > 0) ? ($::tee_loop_sleep * 1.5) : 1);

        if ($opts->{'cleanup'}) {
            # Remove the files, which should cause the file tailer to exit
            if ($opts->{'outfile'} ne '') {
                my $count = 10;
                do { sleep 0.1 } while (unlink($opts->{'outfile'}) == 0 and $count--);
            }
            if ($opts->{'errfile'} ne '' and $opts->{'errfile'} ne $opts->{'outfile'}) {
                my $count = 10;
                do { sleep 0.1 } while (unlink($opts->{'errfile'}) == 0 and $count--);
            }
        }

        # But kill it just to be sure, or in case we didn't remove the files,
        # or in case there was no timeout (which is the default).
        kill('TERM', $teepid);

        # And then clean it up
        waitpid($teepid, 0);
    } else {
        # Child; open the output files, redirect stdout and stderr, and exec.
        if ($loglevel >= 0) {
            if ($opts->{'outfile'} eq '') {
                close(STDOUT);  # Discard output
            } else {
                open(STDOUT, '>'.$opts->{'outfile'}) or die "Can't redirect stdout to '".$opts->{'outfile'}."': $!\n";
            }
            if ($opts->{'errfile'} eq '') {
                close(STDERR);  # Discard output
            } elsif ($opts->{'errfile'} eq $opts->{'outfile'}) {
                open(STDERR, '>&STDOUT') or die "Can't dup stdout for stderr: $!\n";
            } else {
                open(STDERR, '>'.$opts->{'errfile'}) or die "Can't redirect stderr to '".$opts->{'errfile'}."': $!\n";
            }
        }
        if (!exec @cmd) {
            # Command didn't exist _and_ no shell was involved
            print STDERR "exec(".join(' ', @cmd).") failed: $!\n";
            exit 1;
        }
    }

    return $exitcode;
}

sub runcpu_system_windows {
    my ($loglevel, $outfile, $errfile, $cmd, $files) = @_;

    # Command should already be fully prepared; run it
    my $rc = system $cmd;

    # Look for files to stuff into the log
    foreach my $logfile (grep { defined($_->{'outfh'}) } @$files) {
        log_direct_impl($logfile->{'name'}, $logfile->{'outfh'});
    }

    if ($loglevel >= 0) {
        # Log contents of the output and error files (if any)
        foreach my $logfile (grep { $_->{'name'} eq $outfile or $_->{'name'} eq $errfile } @$files) {
            my $ifh = new IO::File '<'.$logfile->{'name'};
            if (!defined($ifh)) {
                ::Log(0, "Couldn't open '".$logfile->{'name'}." for reading: $!\n");
            } else {
                ::Log($loglevel, <$ifh>);
                $ifh->close();
            }
        }
    }

    return $rc;
}

sub log_direct_impl {
    my ($file, $fh) = @_;

    return unless -f $file and -s $file;
    return unless defined($fh);

    my $ifh = new IO::File '<'.$file;
    if (!defined($ifh)) {
        ::Log(0, "Couldn't open '$file' for reading: $!\n");
    } else {
        $fh->print(<$ifh>);
        $ifh->close();
    }
}

# Takes an array of filenames or hash references, each of which describes a file
# to tail and (optionally) what to do with the data that comes out of it.
# Fields for the hash ref:
# name (required): The path to the file to be monitored
# timeout (optional): How long to wait for the file to show up before giving up.
#                     0 disables the timeout (and ensures that the tailing
#                     process will never exit if the file never shows up)
# callback (optional): A code ref which will receive as its only arguments
#                      the string(s) read from the file.  Since this will
#                      execute as a subprocess of runcpu, changes to internal
#                      data structures won't be persistent.  IOW, logging
#                      is about the only reasonable thing to do here.
# outfh (optional): A filehandle to which to write the string(s) that are read
#
# The default action, if no outfh or callback is specified, is to just print
# to the screen.  This is what's done for the bare filenames.
#
# This function will work on Windows, but because of issues related to not
# flushing I/O from other pseudo-processes, it should not be used.
sub file_tail {
    my (@files) = @_;

    my $opentimeout = 0;        # How long to wait for a file to appear before giving up on it
    $::tee_loop_sleep = 0.1;    # How much time to wait if nothing happens
    my $openflags = O_RDONLY;
    my $is_windows = $^O =~ /MSWin/;

    # Run in the background; it's up to the caller to wait for the child
    my $pid = fork();
    return $pid if $pid;

    # Attempt to do non-blocking operations if it's supported
    eval { $openflags |= O_NONBLOCK };

    # Keep Windows stat() from having to open the file each time.  The files
    # we tail will not have or be hard links, so this is safe.
    local ${^WIN32_SLOPPY_STAT} = 1 if $is_windows;

    # Set up the defaults for each of the files.  This also detects
    # duplicates, which we don't allow.  There's enough flexiblilty
    # in the options spec to handle multiple different actions for
    # data from a single file.
    my %seenfiles = ();
    foreach my $file (grep { defined } @files) {
        if (ref($file) ne 'HASH') {
            $file = { 'name' => $file };
        }
        if ($seenfiles{$file->{'name'}}) {
            $file = undef;
        } else {
            $seenfiles{$file->{'name'}}++;
            $file->{'pos'} = 0 unless exists($file->{'pos'});
            $file->{'open'} = 0;
            $file->{'outfh'} = undef unless blessed($file->{'outfh'}) and $file->{'outfh'}->isa('IO::Handle');
            $file->{'callback'} = undef unless ref($file->{'callback'}) eq 'CODE';
            $file->{'timeout'} = $opentimeout unless defined($file->{'timeout'});
        }
        $file = undef unless $file->{'name'} ne '';
    }

    # The basic idea of this is to stat() each file to see if there's unread
    # data available.  If the stat() fails for more than $opentimeout seconds,
    # the file will be removed from the list.
    #
    # If the stat() succeeds and indicates that there's new data to read, the
    # new data is read and handled.
    # "New" data is indicated by either:
    #  - current filesize reported by stat() is different than the current file
    #     position
    #  - the device:inode combination has changed, which means that the file has
    #     been replaced
    # If the current size is less than the current position, the file will be
    # treated as if it had been replaced; that is, the contents will be
    # completely re-read.  device:inode are not usable on Windows, but they
    # don't change randomly either.  This just means that on Windows we can't
    # reliably detect when a file has been removed and replaced by another with
    # the same name.
    #
    # If no data from any file is handled, the loop will pause for
    # $::tee_loop_sleep seconds before going around again.
    #
    # When there are no more files to watch, the script will exit.

    my $skipsleep = 1;
    while(any(sub { defined }, @files)) {
        sleep $::tee_loop_sleep unless $skipsleep;
        $skipsleep = 0;

        for my $file (grep { defined } @files) {
            $file->{'firstlook'} = time unless exists($file->{'firstlook'});
            my $stat = stat($file->{'name'});

            # stat failed; the file probably isn't there.
            if (!defined($stat)) {
                $file->{'lastlook'} = time;

                # File WAS present and isn't now
                if ($file->{'open'}) {
                    ::Log(115, "Info: file_tail($$): file '".$file->{'name'}."' was removed and will no longer be followed.  No action is required.\n");
                    close($file->{'fh'}) if exists($file->{'fh'});
                    $file = undef;


                # file never showed up within the timeout interval
                } elsif ($file->{'timeout'} > 0
                        and $file->{'lastlook'} - $file->{'firstlook'} > $file->{'timeout'}) {
                    ::Log(115, "Notice: file_tail($$): file '".$file->{'name'}."' did not appear in $file->{'timeout'} seconds and will not be followed if it shows up subsequently.\n");
                    close($file->{'fh'}) if exists($file->{'fh'});
                    $file = undef;
                }

            } else {
                # File exists; see if there's new data

                # If the file has been opened but now contains LESS data than
                # we read previously, or if the dev:inode has changed, assume
                # that the file is all new.  Close it out so it'll be reopened.
                # dev:inode is not any kind of indicator on Windows, but it
                # looks like it's constant so it shouldn't mess anything up
                # either.
                if ($file->{'open'}
                        and ($stat->size < $file->{'pos'}
                            or $stat->dev != $file->{'dev'}
                            or $stat->ino != $file->{'inode'})) {
                    close($file->{'fh'}) if exists($file->{'fh'});
                    delete $file->{'fh'};
                    delete $file->{'dev'};
                    delete $file->{'inode'};
                    $file->{'open'} = $file->{'pos'} = 0;
                }
                if ($stat->size > $file->{'pos'}) {
                    if ($is_windows or !$file->{'open'}) {
                        # On Windows we generally keep the file closed so that it can be
                        # unlinked without trouble.  On non-Windows systems the code above
                        # might have closed the file, or maybe it's just never been opened
                        # before.
                        if (sysopen($file->{'fh'}, $file->{'name'}, $openflags)) {
                            $file->{'dev'}   = $stat->dev;
                            $file->{'inode'} = $stat->ino;
                            $file->{'open'}  = 1;
                            if ($file->{'pos'} > 0) {
                                # File is opened; get back to where we were
                                sysseek($file->{'fh'}, $file->{'pos'}, SEEK_SET);
                            } else {
                                $file->{'pos'} = 0;
                            }
                        } else {
                            ::Log(115, "NOTICE: Couldn't open $file->{'name'} for reading: $!\n");
                            $file->{'open'} = 0;
                            next;
                        }
                    }
                    # The explicit size specification is because we can't be
                    # sure that the read will be non-blocking.  (Actually on
                    # Windows we can be sure that O_NONBLOCK doesn't exist,
                    # but reads DO seem to not block.  OTOH I don't want to
                    # rely on that.  If new data comes in after this read,
                    # we'll get it next time through the loop.
                    my $rc = sysread($file->{'fh'}, my $buf, $stat->size - $file->{'pos'});

                    if ($rc) {
                        # Arrange for the next trip through the loop to be soon
                        $skipsleep++;

                        # Handle the data we just read
                        if (!defined($file->{'callback'}) and !defined($file->{'outfh'})) {
                            # No callbacks or other destination; just print it
                            print $buf;
                        } else {
                            if (defined($file->{'callback'})) {
                                &{$file->{'callback'}}($buf);
                            }
                            if (defined($file->{'outfh'})) {
                                $file->{'outfh'}->print($buf);
                            }
                        }

                        # Get our current position, in case we're about to close
                        # the file (Windows).
                        $file->{'pos'} = sysseek($file->{'fh'}, 0, SEEK_CUR);
                    }

                    # On Windows, close the file so that it can be unlinked
                    # even while we're tailing it.
                    if ($is_windows) {
                        close($file->{'fh'});
                        delete $file->{'fh'};
                    }
                }
            }
        }
    }
    exit;
}

sub squeeze_undef {
    # Squeeze undefined values from an array
    my ($ary) = @_;

    return [] unless @{$ary};

    for(my $i = 0; $i < @{$ary}; $i++) {
        next if defined($ary->[$i]);
        # undef => remove it
        splice @{$ary}, $i, 1;
        redo if $i < @{$ary};   # $ary->[$i] is now the next element
    }

    return $ary;
}

sub wrap_lines {
    my ($lines, $columns, $indent, $warn, $overflow) = @_;
    $warn ||= 0;

    my @orig = @$lines;
    $lines = [];
    foreach my $line (@orig) {
        if (length($line) <= $columns) {
            push @$lines, $line;
        } else {
            $line =~ s/^(\s*)//o;
            my $baseindent = $1;
            local $Text::Wrap::columns = $columns;
            local $Text::Wrap::huge = ($warn || $overflow) ? 'die' : 'wrap';
            my $newline = '';
            eval '$newline = Text::Wrap::wrap($baseindent, $baseindent.$indent, $line);';
            if ($@) {
                if ($overflow) {
                    local $Text::Wrap::huge = 'overflow';
                    $newline = Text::Wrap::wrap($baseindent, $baseindent.$indent, $line);
                } elsif ($warn) {
                    # There was an element that was _so_ large that it was
                    # larger than the maximum number of columns.  So log a
                    # warning and leave the line unchanged.
                    Log(0, "WARNING: the following line:\n".
                           "-----\n".
                           "$line\n".
                           "-----\n".
                           "contains an element longer than $columns columns and could not be split.\n");
                    $newline = undef;
                }
            }
            if (defined($newline)) {
                my @newlines = split(/\n+/, $newline);
                push @$lines, @newlines;
            } else {
                push @$lines, $line;
            }
        }
    }

    return @{$lines};
}

sub wrap_join {
    # Take a list of things and return a list of strings with as many items
    # as can fit in $maxlen columns, indented with $ident and terminated by
    # $eol, except for the last string, which will be unterminated.
    my ($maxlen, $sep, $indent, $eol, @items) = @_;

    my @lines = ();
    my $currstring = shift @items;
    foreach my $item (@items) {
        if ($currstring ne '' &&
            length($currstring) + length($sep) + length($item) >= $maxlen ||
            length($currstring) + length($eol)                 >= $maxlen) {
            push @lines, $currstring.$eol;
            $currstring = $indent.$item;
        } else {
            $currstring .= $sep.$item;
        }
    }

    push @lines, $currstring if ($currstring ne '');
    return @lines;
}

sub new_user_agent {
    my (%opts) = @_;
    return undef unless $http_tiny;
    if (!defined($opts{'proxy'}) && defined($::global_config)) {
        $opts{'proxy'} = $::global_config->http_proxy;
    }
    delete $opts{'proxy'} unless defined($opts{'proxy'}) and $opts{'proxy'} ne '';
    if (!defined($opts{'timeout'}) && defined($::global_config)) {
        $opts{'timeout'} = $::global_config->http_timeout;
    }
    delete $opts{'timeout'} unless defined($opts{'timeout'}) and $opts{'timeout'} > 0;
    my $newua = HTTP::Tiny->new(
            'agent' => "${main::suite}/${main::suite_version} ",
            %opts,
            );
    return $newua;
}

sub update_manifest {
    my (@files) = @_;
    my %files = map { $_ => 1 } @files;
    my @lines;

    # First read in the contents of the MANIFEST
    my $fh = new IO::File '<'.jp($ENV{'SPEC'}, 'MANIFEST');
    if (!defined($fh)) {
        Log(0, "\nERROR: Could not open MANIFEST for reading: $!\n\n");
        do_exit(1);
    }
    while (my $line = <$fh>) {
        my ($cksum, $sizehex, $file) = $line =~ m/^([[:xdigit:]]{128}) (?:\*| ) ([[:xdigit:]]{16}) (.*)$/o;
        next if exists $files{$file};
        push @lines, $line;
    }
    $fh->close();

    # Now rewrite it with the just the lines that aren't the files we want
    $fh = new IO::File '>'.jp($ENV{'SPEC'}, 'MANIFEST');
    if (!defined($fh)) {
        Log(0, "\nERROR: Could not open MANIFEST for writing: $!\n\n");
        do_exit(1);
    }
    $fh->print(@lines);

    # Now run specsha512sum to generate sums for the new files
    if (!open(HASHFD, '-|', 'specsha512sum', '-e', @files)) {
        $fh->close();   # Flush what we got
        do_exit(1);
    }
    $fh->print(<HASHFD>);
    $fh->close();
    close HASHFD;
}

sub shift_indices {
    my ($obj, $index, $delta) = @_;

    return if $delta == 0;

    my @idxkeys = grep { /^cfidx_/ } keys %{$obj};
    foreach my $idxkey (@idxkeys) {
        if ($obj->{$idxkey} >= $index) {
            $obj->{$idxkey} += $delta;
        }
    }

}

sub renumber_notes {
    my ($result, $format, $backup) = @_;

    foreach my $section (grep { /^$::mpi_desc_re_id?notes/ } keys %{$result}) {
        next unless ref($result->{$section}) eq 'HASH';
        foreach my $key (sort keys %{$result->{$section}}) {
            next unless ref($result->{$section}->{$key}) eq 'ARRAY';
            my $notesref = $result->{$section}->{$key};
            my @newnotes = ();

            # Do the notes renumbering in two passes to avoid trashing
            # unrenumbered lines with newly renumbered lines.
            my $cfline = undef;
            for(my $i = 0; $i < @{$notesref}; $i++) {
                next unless ref($notesref->[$i]) eq 'ARRAY';
                my ($updateline, $oldtag, $note);
                if ($format == 3) {
                    ($updateline, $oldtag, $note) = @{$notesref->[$i]};
                } else {
                    $updateline = 1;
                    ($oldtag, $note) = @{$notesref->[$i]};
                }
                my $newtag = sprintf("%s%s_%03d", $section,
                    ($key ne '') ? "_$key" : '',
                    ($i * 5));
                # The rename tag needs to be guaranteed unique, but it also
                # needs to be the same length as $newtag, so just set the
                # high bits on all the characters.  It's easy to undo, and
                # because of the regexp in the config file reader, it's
                # guaranteed to not clash with any "natural" name.
                my $renametag = $newtag;
                $renametag =~ s/(.)/chr(ord(uc($1)) | 0x80)/goe;

                if (defined($oldtag)) {
                    $cfline = $result->{'cfidx_'.$oldtag};
                    $cfline = undef if ($cfline eq '');
                } else {
                    $renametag .= ":$cfline" if (defined($cfline));
                }

                # Fix up the tag (and maybe the line itself) in the stored
                # config file, and do _not_ create a backup.
                if (::update_stored_config($result, $oldtag, $renametag, $note, $updateline, 1)) {
                    push @newnotes, [ $newtag, $note ];
                    $cfline++ if (defined($cfline));
                } else {
                    ::Log(0, "ERROR: Edit of stored config file failed;\n        Could not change '$oldtag' to '$newtag' (1st pass).\n");
                }
            }

            # The final rename pass.
            @{$notesref} = ();
            foreach my $noteref (@newnotes) {
                my ($tag, $note) = @$noteref;
                my $renametag = $tag;
                $renametag =~ s/(.)/chr(ord(uc($1)) | 0x80)/goe;
                if (::update_stored_config($result, $renametag, $tag, $note, 0, !$backup)) {
                    push @{$notesref}, [ $tag, $note ];
                } else {
                    ::Log(0, "ERROR: Edit of stored config file failed;\n        Could not change temporary tag to '$tag' (2nd pass).\n");
                }
            }
        }
    }

}

# Convert a Perl data structure into (optionally compressed) JSON.
sub serialize {
    my ($r, $compress) = @_;

    my $text = eval { JSON::PP->new->canonical(1)->pretty(0)->encode($r) };
    if ($@ or !defined($text)) {
        undef $@;
        return undef;
    }
    my $comp = $compress ? compress_encode($text) : $text;
    return wantarray ? ($comp, $text) : $comp;
}

# Convert a string that SHOULD be JSON but might still be Data::Dumper output
# back into a Perl data structure.
sub deserialize {
    my ($text, $namespace, $strict) = @_;

    # Since none of the compression indicator characters we use are legal
    # BASE64, we can use those to figure out whether to decode_decompress() or not.
    my $uncomp = is_encoded($text) ? decode_decompress($text) : $text;

    # Now do the deserialization, trying JSON first (it's safest) and Perl
    # eval last.
    my $r = eval { JSON::PP->new->decode($uncomp) };
    if (defined($namespace) and ($@ or !defined($r))) {
        my $s = new_safe_compartment($namespace, $strict);
        $r = $s->reval($uncomp);
    }
    # Clear out $@ as the last eval may have left it dirty, if we tried to deserialize something that wasn't JSON
    # and also wasn't Perl.
    undef $@;
    return $r;
}

# Given some serialized data structure, convert it if it's not already JSON
sub reserialize {
    my ($text) = @_;

    my $tmp = ::deserialize($text);
    return ($text, $tmp) if defined($tmp);
    $tmp = ::deserialize($text, 'reserialize_cvt', 1);
    return (scalar(serialize($tmp, 1)), $tmp);
}

# Read a file and deserialize it
sub deserialize_file {
    my ($file, @search) = @_;

    @search = '.' unless @search;

    foreach my $dir (@search) {
        my $path = ::jp($dir, $file);
        if (-r $path) {
            my $ifh = new IO::File '<'.$path;
            my $t = ::deserialize(join('', <$ifh>), 'deserialize_file', 1);
            return $t;
        }
    }
    return undef;
}

sub compress_encode {
    # Compress and Base-64 encode the input string.  Returns the original
    # string, the compressed version, and the encoded version.  An undef in
    # a return slot indicates a failure of the operation.
    my ($input) = @_;
    my @tries = (['*', $input]);

    my $compressed = eval 'Compress::Zlib::compress($input, 9)';
    push @tries, [ '@', $compressed ] unless $@ or !defined($compressed);

    $compressed = memBzip($input);
    push @tries, [ '&', $compressed ] if defined($compressed);

    # Sort them in order of length, so as to use the shortest one
    @tries = sort { length($a->[1]) <=> length($b->[1]) } @tries;

    my $encoded = $tries[0]->[0].encode_base64($tries[0]->[1]);

    return wantarray ? ($input, $tries[0]->[1], $encoded) : $encoded;

}

sub is_encoded {
    my ($text) = @_;

    return ($text =~ /^\s*([\*\&\@])([A-Za-z0-9+\/=\012\015]*)$/os);
}

sub decode_decompress {
    # Base-64 decode and uncompress the input string.  Returns the original
    # string, the decoded version, and the decompressed version.  An undef in
    # a return slot indicates a failure of the operation.
    my ($input) = @_;

    return wantarray ? ('', '', '') : '' if $input eq '';

    my ($uncompressed, $decoded) = (undef, undef);
    my $copy = undef;
    my $type = '';
    if (($type, $copy) = is_encoded($input)) {
        $copy = $decoded = decode_base64($copy);
    } else {
        $decoded = undef;
        $copy = $input;
    }

    # Don't let eval failures elsewhere cause decompress to have a faux-fail (memBunzip in particular will set
    # $@ on failure, but does not clear it)
    undef $@;

    if ($type eq '*') {
        $uncompressed = $decoded;
    } elsif ($type eq '@') {
        $uncompressed = eval 'Compress::Zlib::uncompress($copy)';
    } elsif ($type eq '#') {
        $uncompressed = eval 'Compress::Zlib::memGunzip($copy)';
    } elsif ($type eq '&') {
        $uncompressed = memBunzip($copy);
    } else {
        # Try them all until one works
        $uncompressed = eval 'Compress::Zlib::uncompress($copy)';
        if (!defined($uncompressed) or $uncompressed eq '' or $@) {
            $uncompressed = memBunzip($copy);
        }
        if (!defined($uncompressed) or $uncompressed eq '' or $@) {
            $uncompressed = eval 'Compress::Zlib::memGunzip($copy)';
        }
    }
    if ($@) {
        Log(69, "Failure to decode/decompress '$input':\n$@\n".Carp::longmess()."\n");
        $uncompressed = undef if ($@);
    }

    return wantarray ? ($input, $decoded, $uncompressed) : $uncompressed;
}

sub memBzip {
    my ($data) = @_;

    # The last revision of this function that has support for interoperating
    # with Compress::Bzip2-based tools is in r6071.

    my $compressed;
    my $status = bzip2 \$data => \$compressed;
    if (!$status) {
        Log(71, "Compression failed: $Bzip2Error\n");
        return undef;
    }

    return $compressed;
}

sub memBunzip {
    my ($input) = @_;

    # In order to maintain compatibility with toolsets that generated
    # Compress::Bzip2-compatible compressed output, it's necessary to
    # strip the first 5 bytes before feeding the data to
    # IO::Uncompress::Bunzip2.  Compress::Bzip2 prepends a magic value
    # of 0xF0 and the length of the input data to the compressed data.

    # Break it down:
    my ($magic, $len, $compressed) = unpack 'CNa*', $input;
    $compressed = $input if $magic != 0xF0;

    # Decompress the data:
    my $data;
    my $status = bunzip2 \$compressed => \$data, 'Append' => 0, 'MultiStream' => 1, 'Transparent' => 0;
    if (!$status) {
        Log(71, "Decompression failed: $Bunzip2Error\n");
        return undef;
    }

    return $data;
}

sub basepeak_munge {
    my ($result, $bp_only, @benchmarks) = @_;

    return unless $result->{'basepeak'} == 1 || $result->{'basepeak'} == 2;

    # It's stupid to do base->peak substitution if there's no base to
    # substitute in!
    my $hasbase = 1 if grep { /^base$/ } @{$result->{'tunelist'}};

    if ($result->{'basepeak'} == 1) {
        $bp_only = 1;
        @benchmarks = sort keys %{$result->benchmarks};
    }

    if ($bp_only or $::lcsuite eq 'cpu2017') {
        if ($bp_only) {
            Log(10, "Doing base -> peak substitution for all benchmarks\n");
        } else {
            Log(10, "Doing base -> peak substitution for some benchmarks (per-benchmark basepeak)\n");
        }
        # Per run rules section 3.5, the base result is used for all
        # per-benchmark basepeak munging.
        for my $bench (@benchmarks) {
            my $benchref = $result->{'results'}->{$bench};
            # Make sure the data structures exist
            foreach my $tmptune ('base', 'peak') {
                if (::ref_type($benchref->{$tmptune}) ne 'HASH') {
                    $benchref->{$tmptune} = {'data' => [] };
                }
                foreach my $iterref (@{$benchref->{$tmptune}{'data'}}) {
                    $iterref->{'basepeak'} = 1;
                }
            }
            if ($hasbase) {
                @{$benchref->{'peak'}{'data'}} = @{$benchref->{'base'}{'data'}};
            }
        }
    } elsif (@benchmarks) {
        Log(10, "Doing lowest median substitution for some benchmarks (per-benchmark basepeak)\n");
        for my $bench (@benchmarks) {
            next unless exists($result->{'results'}->{$bench});
            Log(10, "  basepeak lowest median sub for $bench\n");
            my %tmpmedian = ();
            my $benchref = $result->{'results'}->{$bench};
            for my $tune (keys %{$benchref}) {
                my @tmpdata = ();
                for my $obj (@{$benchref->{$tune}{'data'}}) {
                    $obj->{'basepeak'} = 1;
                    next unless ($obj->valid eq 'S');
                    push (@tmpdata, $obj);
                }
                $tmpmedian{$tune} = median_ratio(0, @tmpdata);
            }
            my @sortres = sort { $tmpmedian{$a} <=> $tmpmedian{$b} } keys %tmpmedian;
            for (my $i = 1; $i < @sortres; $i++) {
                Log(89, "Setting $sortres[$i] to $sortres[0] for $bench\n");
                dupe_results($benchref->{$sortres[$i]}->{'data'},
                    $benchref->{$sortres[0]}->{'data'});
            }
        }
    }
}

sub dupe_results {
    my ($dest, $src) = @_;

    return unless (ref($dest) eq 'ARRAY' && ref($src) eq 'ARRAY');

    # Do a deep copy, except for the 'tune', 'ref', and 'refs' members
    for (my $i = 0; $i < @{$src}; $i++) {
        my $href = $src->[$i];
        for my $key (keys %{$href}) {
            next if ($key =~ /^(tune|ref|refs)$/o);
            $dest->[$i]->{$key} = $src->[$i]->{$key};
        }
    }
}

# SIDE EFFECT:  Sets the selected bit for the result if select is nonzero
sub median_ratio {
    my ($select, @objs) = @_;
    my $numobjs = @objs+0;
    return undef if $numobjs <= 0;
    my $power = ($objs[0]->accessor_nowarn('avg_power') > 0);
    if (Log(70)) {
        Log(70, "median_ratio(select=$select) for ".$objs[0]->benchmark.'='.$objs[0]->tune.'='.$objs[0]->label."\n");
        Log(70, "         ratios and runtimes:\n             ".join("\n             ", map { '[ '.$_->reported_time.' => '.$_->ratio.($power ? '; '.$_->energy_ratio.' kJ' : '').' ]' } @objs)."\n");
    }

    # Ascending sort by runtime and not ratio; for non 'ref' runs, ratio is
    # always '--'!
    @objs = sort { $a->reported_time <=> $b->reported_time } @objs;

    Log(70, "  sorted ratios and runtimes:\n             ".join("\n             ", map { '[ '.$_->reported_time.' => '.$_->ratio.($power ? '; '.$_->energy_ratio.' kJ' : '').' ]' } @objs)."\n");

    # Select the middle (truncated) run.  For even # of runs, this will always
    # be the middle+1, which will be the run with the next highest runtime,
    # which will be the lower median ratio.
    # See chapter 9 of Cormen, Thomas, et al. _Introduction to Algorithms,
    #   2nd Edtion_. Cambridge: MIT Press, 2001
    my $sel = int($numobjs / 2);
    Log(70, "  Selected run ".($sel + 1)." of $numobjs\n");

    # Set and unset the selected bits if necessary
    if ($select) {
        for(my $i = 0; $i < @objs; $i++) {
            $objs[$i]->selected(($i == $sel) ? 1 : 0);
        }
    }

    Log(70, "  Returning ratio = ".$objs[$sel]->ratio.($power ? " (energy_ratio = ".$objs[$sel]->energy_ratio.")" : '')."\n");
    return wantarray ? ($objs[$sel]->ratio, $objs[$sel]->accessor_nowarn('energy_ratio'), $objs[$sel]->dp) : $objs[$sel]->ratio;
}

sub round {
    my ($num, $dp, $mindp) = @_;

    if (defined($dp) && $dp >= 0) {
        $num = int(($num * (10 ** $dp)) + 0.5) / (10 ** $dp);
    }
    if (defined($mindp) && $mindp > 0) {
        $num =~ /\.(\d+?)0*$/;
        $dp = defined($1) ? length($1) : 0;
        $num = sprintf '%.*f', $mindp, $num if ($dp < $mindp);
    }
    return $num;
}

sub pluralize {
    my ($count, $word, @verb) = @_;

    my $rc = $count.' ';
    if (::ref_type($word) eq 'ARRAY') {
        $rc .= $word->[($count == 1) ? 0 : 1];
    } else {
        $rc .= $word;
        $rc .= 's' if ($count != 1);
    }
    $rc .= ' '.$verb[($count == 1) ? 0 : 1] if (@verb);
    return $rc;
}

sub assemble_cpu_description {
    my ($config) = @_;
    my $hw_ncpu = '';

    # Given these four fields:
    #  hw_ncpu  (n chips)
    #  hw_ncores (n cores)
    #  hw_nthreadspercore (n threads/core)
    # This routine assembles a nice text field.

    my $hw_nchips = firstof($config->accessor_nowarn('hw_nchips'));
    $hw_nchips = -1 if (!defined($hw_nchips) || $hw_nchips eq '--');

    my $hw_ncores = firstof($config->accessor_nowarn('hw_ncores'));
    $hw_ncores = -1 if (!defined($hw_ncores) || $hw_ncores eq '--');

    my $hw_nthreadspercore = firstof($config->accessor_nowarn('hw_nthreadspercore'));
    $hw_nthreadspercore = -1 if (!defined($hw_nthreadspercore) || $hw_nthreadspercore eq '--');

    $hw_ncpu  = ::pluralize($hw_ncores, 'core').', ';
    $hw_ncpu .= ::pluralize($hw_nchips, 'chip');
    if ($hw_nthreadspercore != 1) {
        $hw_ncpu .= ', '.::pluralize($hw_nthreadspercore, 'thread').'/core';
    }

    return $hw_ncpu;
}

sub generate_mpi_totals {
    my ($result, $config) = @_;
    foreach my $thing (qw( hw_total_nodes hw_total_chips hw_total_cores
        hw_total_threads hw_total_memory ) ) {
        $result->{$thing} = 0;
    }
    $result->{'system_class'} = 'Imaginary' unless defined($result->{'system_class'}) && $result->{'system_class'} ne '';

    # Generate node totals for everything
    if (exists($result->{'node'}) && (::ref_type($result->{'node'}) eq 'HASH')) {
        my @nodes = grep { $result->{'node'}->{$_}->{'purpose'} =~ /compute/i } keys %{$result->{'node'}};

        # Figure out what class of system is being benchmarked, if it hasn't
        # been set to something other than one of the defaults by the
        # benchmarker.
        if (!exists($result->{'system_class'}) ||
            $result->{'system_class'} eq 'Imaginary' ||
            $result->{'system_class'} eq '--') {
            if (@nodes == 1) {
                # One kind of node -- homogenous cluster or SMP?
                if ($result->{'node'}->{$nodes[0]}->{'count'} > 1) {
                    $result->{'system_class'} = 'Homogenous Cluster';
                } else {
                    $result->{'system_class'} = 'SMP';
                }
            } else {
                $result->{'system_class'} = 'Heterogenous Cluster';
            }
        }

        # ...and now on to the totals
        foreach my $system (@nodes) {
            if ((::ref_type($result->{'node'}->{$system}) ne 'HASH')) {
                ::Log(0, "\nERROR: Node \"$system\" does not have the proper kind of data structure\n");
                next;
            }
            my $nodeptr = $result->{'node'}->{$system};
            my $nodecnt = $nodeptr->{'count'};
            $result->{'hw_total_nodes'} += $nodecnt;
            $result->{'hw_total_chips'} += $nodecnt * $nodeptr->{'hw_nchips'};
            my $node_cores = 0;
            if (!exists($nodeptr->{'hw_ncoresperchip'}) &&
                exists($nodeptr->{'hw_nchips'}) && $nodeptr->{'hw_nchips'} > 0  &&
                exists($nodeptr->{'hw_ncores'}) && $nodeptr->{'hw_ncores'} > 0) {
                $nodeptr->{'hw_ncoresperchip'} = $nodeptr->{'hw_ncores'} / $nodeptr->{'hw_nchips'};
                $node_cores = $nodeptr->{'hw_ncores'};
            } elsif (!exists($nodeptr->{'hw_ncores'}) &&
                exists($nodeptr->{'hw_nchips'}) && $nodeptr->{'hw_nchips'} > 0  &&
                exists($nodeptr->{'hw_ncoresperchip'}) && $nodeptr->{'hw_ncoresperchip'} > 0) {
                $node_cores = $nodeptr->{'hw_nchips'} * $nodeptr->{'hw_ncoresperchip'};
                $nodeptr->{'hw_ncores'} = $node_cores;
            } else {
                $node_cores = $nodeptr->{'hw_ncores'};
            }
            $result->{'hw_total_cores'} += $nodecnt * $node_cores;
            $result->{'hw_total_threads'} += $nodecnt * $node_cores * $nodeptr->{'hw_nthreadspercore'};
            my $mem = join(' ', ::allof($nodeptr->{'hw_memory'}));
            $result->{'hw_total_memory'} += $nodecnt * ::decompose_memory($mem);
        }

        # Re-compose the memory size
        $result->{'hw_total_memory'} = ::recompose_memory($result->{'hw_total_memory'});
    }

    # Un-do some laziness
    $result->{'system_class'} =~ s/^Homo$/Homogenous/i;
    $result->{'system_class'} =~ s/^Hetero$/Heterogenous/i;

    # Make it look nice(?)
    $result->{'system_class'} = ucfirst($result->{'system_class'});

}

sub min_max_base_ranks {
    return min_max_base('ranks', @_);
}

sub min_max_base_threads {
    return min_max_base('threads', @_);
}

sub min_max_base {
    my ($what, $result) = @_;

    return undef unless defined($result) && (::ref_type($result) eq 'HASH');
    return undef unless exists($result->{'results'}) && (::ref_type($result->{'results'}) eq 'HASH');

    my @tunes = @{$::global_config->{'valid_tunes'}};
    my %base_min = map { $_ => '--' } @tunes;
    my %base_max = map { $_ => '--' } @tunes;

    foreach my $tune (@tunes) {
        foreach my $bench (sort keys %{$result->{'results'}}) {
            my $benchref = $result->{'results'}->{$bench};
            next unless (::ref_type($benchref) eq 'HASH') && exists($benchref->{$tune});
            my $tuneref = $result->{'results'}->{$bench}->{$tune};
            next unless (::ref_type($tuneref) eq 'HASH') && exists($tuneref->{'data'});
            for(my $i = 0; $i < @{$tuneref->{'data'}}; $i++) {
                next unless $tuneref->{'data'}->[$i]->{'selected'};
                next unless exists($tuneref->{'data'}->[$i]->{$what});
                $base_max{$tune} = $tuneref->{'data'}->[$i]->{$what} if ($base_max{$tune} eq '--' || $tuneref->{'data'}->[$i]->{$what} > $base_max{$tune});
                $base_min{$tune} = $tuneref->{'data'}->[$i]->{$what} if ($base_min{$tune} eq '--' || $tuneref->{'data'}->[$i]->{$what} < $base_min{$tune});
            }
        }
    }

    if ($base_min{'base'} ne '--' && $base_max{'base'} ne '--' &&
        $base_min{'base'} != $base_max{'base'}) {
        # What?  How can this be?
        Log(0, "ERROR: Minimum and maximum base $what do not match!\n");
        do_exit(1);
    }
    $result->{"base_$what"} = $base_min{'base'};
    $result->{"max_peak_$what"} = $base_max{'peak'};
    $result->{"min_peak_$what"} = $base_min{'peak'};
    $result->{"max_$what"} = $base_max{'base'};
    if ($base_max{'base'} eq '--' || ($base_max{'peak'} ne '--' && $base_max{'peak'} > $base_max{'base'})) {
        $result->{"max_$what"} - $base_max{'peak'};
    }
}

sub decompose_memory {
    my ($str) = @_;

    # Take a string that _should_ contain a memory size, normalize it to MB,
    # and return it as a number.
    my %mult = ( 'K'=> 1/1024, 'M'=> 1, 'G'=> 1024, 'T'=> 1024 * 1024 );
    if ($str =~ /([\d.]+)\s*(K|M|G|T|P)B/i) {
        my ($size, $unit) = ($1, $2);
        return ($size * $mult{$unit});
    } else {
        return 0;
    }
}

sub recompose_memory {
    my ($size) = @_;

    # Take a memory size (in MB), reduce it to a nice reasonable size, and
    # return it with units.
    my $units = 'M';
    my %nextunit = ( 'K'=>'M', 'M'=>'G', 'G'=>'T', 'T'=>'P', 'P'=>'E', 'E'=>'Z', 'Z'=>'Y' );
    my %prevunit = ( 'M'=>'K', 'G'=>'M', 'T'=>'G', 'P'=>'T', 'E'=>'P', 'Z'=>'E', 'Y'=>'Z' );
    while (($size > 1023) && (($size / 1024) == int($size / 1024))
        && exists($nextunit{$units})) {
        $units = $nextunit{$units};
        $size /= 1024;
    }
    while ($size > 0 && $size < 1024 && ($size < 1 || int($size) != $size)
        && exists($prevunit{$units})) {
        $size = int($size * 1024);
        $units = $prevunit{$units};
    }

    return "$size ${units}B";
}

sub make_path_re {
    my ($path) = @_;

    # Given a path, turn it into a regular expression where either kind of
    # slash matches, and where the match is not case-sensitive on Windows
    # or MacOS X (HFS+ _can_ be case-sensitive but in practice never is because
    # all Mac apps expect the filesystem to not be).
    my $flag = ($^O =~ /MSWin|Darwin/) ? 'i' : '';
    my @pathcomp = split(m#[\\/]#, $path, -1);
    my $pathre = join('[\\\\/]', map { length($_) ? '\Q'.$_.'\E' : '' } @pathcomp);
    my $rc = eval "qr#$pathre#$flag";
    if ($@) {
        # Oh, no... something went wrong and the regexp we constructed
        # couldn't be compiled.  Fall back to just making a regexp that
        # will only match the original path and hope that that's good
        # enough.
        ::Log(0, "WARNING: Could not construct path-separator-agnostic regular expression for '$path'\n");
        return eval "qr#\\Q$path\\E#$flag";
    }
    return $rc;
}

sub unrel_path {
    my ($path) = @_;

    # Given a path, strip out explicit references to parent directories:
    # /a/b/c/../../d/e => /a/d/e
    # Always returns an absolute path.
    if ($path !~ m#^[\\/]#) {
        $path = File::Spec->rel2abs($path);
    }
    $path = File::Spec->canonpath($path);
    my @components = split(/[\/\\]+/, $path);
    for(my $i = 1; $i < @components; $i++) {
        if ($components[$i] eq '..' && $i > 0) {
            # Get rid of it and the directory it would back up into
            splice @components, $i-1, 2;
            $i -= 2;
        }
    }

    return File::Spec->catdir(@components);
}

sub firstof {
    my ($thing) = @_;

    if (::ref_type($thing) eq 'ARRAY') {
        return $thing->[0];
    } else {
        return $thing;
    }
}


sub allof {
    my ($thing) = @_;

    if (::ref_type($thing) eq 'ARRAY') {
        return @{$thing};
    } else {
        return ($thing);
    }
}

# Sort multi-valued things (like notes) properly, even in the face of
# notes1 = foo
# notes002 = bar
# etc.
sub bytag ($$) {
    my ($a, $b) = @_;           # This is slower but works around the package
                                # variable problem.
    if ($a !~ /\d$/ || $b !~ /\d$/) {
        # Both need trailing numbers to get special attention
        return $a cmp $b;
    }
    my ($atxt, $anum) = ($a =~ /^(.*?)0*(\d+)$/);
    my ($btxt, $bnum) = ($b =~ /^(.*?)0*(\d+)$/);
    return $atxt cmp $btxt || ($anum+0) <=> ($bnum+0);
}

sub bytrailingnum ($$) {
    my ($a, $b) = @_;           # This is slower but works around the package
                                # variable problem.
    my ($aname, $anum, $bname, $bnum) = ('', 0, '', 0);
    ($aname, $anum) = $a =~ m/^(\S+?)([\d.]*)$/ if defined($a);
    ($bname, $bnum) = $b =~ m/^(\S+?)([\d.]*)$/ if defined($b);
    return $aname cmp $bname || ($anum+0) <=> ($bnum+0) || defined($anum) <=> defined($bnum);
}

# Like bytrailingnum, but the trailing number may not include a decimal point
sub bydirnum ($$) {
    my ($a, $b) = @_;           # This is slower but works around the package
                                # variable problem.
    my ($aname, $anum, $bname, $bnum) = ('', 0, '', 0);
    ($aname, $anum) = $a =~ m/^(\S+?)(\d*)$/ if defined($a);
    ($bname, $bnum) = $b =~ m/^(\S+?)(\d*)$/ if defined($b);
    return $aname cmp $bname || ($anum+0) <=> ($bnum+0) || defined($anum) <=> defined($bnum);
}

sub bytune {
    # Sort a list of tunings into the prescribed order.
    # Currently, we just ensure that base comes first and peak comes last.
    # Otherwise, it's lexical.
    return -1 if $a eq 'base';
    return 1 if $a eq 'peak';
    return $a cmp $b;
}

sub bylang($$) {
    # Sort a list of "language strings" (as seen in the reduced flags structure).
    # The idea is that the "mixed" languages some come last, or at least after
    # the "simple" language lists.
    my ($a, $b) = @_;
    my ($la, $lb) = (length($a), length($b));
    return $a cmp $b if ($la < 5 && $lb < 5);     # Single-language
    return $la <=> $lb;
}

sub lock_file {
    my ($fh, $filename) = @_;
    my $rc = undef;
    my $tries = 0;
    my $max_tries = 10;

    return (undef, 'badfh') unless defined($fh);

    my $cond = [ 'ok' ];
    while($tries < $max_tries && !(defined($rc) && $rc)) {
        eval '$rc = flock($fh, LOCK_EX);';
        $tries++;
        if ($@) {
            $cond = [ 'unimplemented', $@ ];
            last;
        }
        if ($! =~ /(?:not |un)implement/i) {
            $cond = [ 'unimplemented', $! ];
            last;
        }
        if ($rc) {
            return($rc, 'ok');
        } else {
            if ($tries < $max_tries) {
                my $tmptries = ($max_tries - $tries);
                $tmptries .= ($tmptries > 1) ? ' tries' : ' try';
                Log(170, "RETRYABLE ERROR: flock($filename, LOCK_EX) returned \"$!\"; $tmptries left\n");
            }
            sleep int(rand(5)) + 1;
        }
    }

    if ($cond->[0] eq 'unimplemented') {
        # Sigh.  Either the OS does not provide locking (unlikely), or the
        # filesystem being used doesn't support it (likely).
        # So try File::NFSLock. :/
        Log(170, "LOCK NOTICE: flock($fh, LOCK_EX) is unavailable; file-based locking will\n              be attempted\n");
        eval 'use File::NFSLock';
        if ($@) {
            if ($cond->[1] ne '') {
                Log(170, "LOCK ERROR: The File::NFSLock module could not be loaded:\n");
                Log(170, "-------------------------------\n$@\n-------------------------------\n");
                return (undef, @$cond);
            } else {
                return (undef, 'unimplemented', $@);
            }
        } else {
            my $lock = new File::NFSLock({
                    'file'               => $filename,
                    'lock_type'          => LOCK_EX,
                    'blocking_timeout'   => undef,
                    'stale_lock_timeout' => 300,
                });
            if (!defined($lock)) {
                return (undef, 'error', $File::NFSLock::errstr);
            }
            # Store it so that it can be unlocked later
            push @{$::locks{$fh}}, $lock;
            return(1, 'ok');
        }
    }

    my ($file, $line, $sub) = (caller(1))[1,2,3];
    $file = basename($file);
    Log(170, "LOCK ERROR: flock($filename, LOCK_EX) failed repeatedly; called from $sub ($file line $line)\n");

    return(undef, 'error', $!);
}

sub unlock_file {
    my ($fh) = @_;
    my $rc = undef;
    my $tries = 0;
    my $max_tries = 10;

    return (undef, 'badfh') unless defined($fh);

    $fh->flush();
    if (exists($::locks{$fh}) && (::ref_type($::locks{$fh}) eq 'ARRAY')) {
        # This was locked with File::NFSLock; no need to try flock
        foreach my $lock (@{$::locks{$fh}}) {
            $lock->unlock();
        }
        return(1, 'ok');
    }

    while($tries < $max_tries && !(defined($rc) && $rc)) {
        eval '$rc = flock($fh, LOCK_UN);';
        $tries++;
        return (undef, 'unimplemented', $@) if $@;
        return (undef, 'unimplemented', $!) if $! =~ /(?:not |un)implement/i;
        if ($rc) {
            return ($rc,   'ok');
        } else {
            if ($tries < $max_tries) {
                my $tmptries = ($max_tries - $tries);
                $tmptries .= ($tmptries > 1) ? ' tries' : ' try';
                Log(170, "RETRYABLE ERROR: flock(LOCK_UN) returned \"$!\"; $tmptries left\n");
            }
            sleep int(rand(5)) + 1;
        }
    }

    my ($file, $line, $sub) = (caller(1))[1,2,3];
    $file = basename($file);
    Log(170, "LOCK ERROR: flock(LOCK_UN) failed repeatedly; called from $sub ($file line $line)\n");

    return (undef, 'error', $!);
}

sub update_stored_config {
    my ($obj, $oldtag, $newtag, $text, $updateline, $no_backup) = @_;

    $no_backup = 0 unless defined($no_backup);

    # Make versions of the tags suitable for printing in error messages
    my $printold = '';
    if (defined($oldtag)) {
        $printold = $oldtag;
        $printold =~ s/(.)/chr(ord($1) & 0x7f)/goe;
        $printold .= '(+high bits)' if $printold ne $oldtag;
    }

    my $printnew = $newtag;
    $printnew =~ s/(.)/chr(ord($1) & 0x7f)/goe;
    $printnew .= '(+high bits)' if $printnew ne $newtag;

    ::Log(96, "update_stored_config($obj, oldtag='$printold', newtag='$printnew', text='$text', updateline=$updateline, no_backup=$no_backup)".Carp::longmess()."\n") if ::Log(96);

    # Fix up the $tag item in the array $obj->{'txtconfig'} (which should
    # be the text of a config file).  The index into the array is expected
    # to be found in cfidx_$oldtag, unless $oldtag is undef, in which case
    # it'll be added to the end of the config file, in a 'default:' section
    # which is automatically added.

    if (!exists $obj->{'txtconfig'}) {
        Log(0, "ERROR(update_stored_config): $obj does not contain a txtconfig member!\n");
        return 0;
    }
    if (ref($obj->{'txtconfig'}) ne 'ARRAY') {
        Log(0, "ERROR(update_stored_config): The txtconfig member in $obj is not an array!\n");
        return 0;
    }
    if (!defined($newtag) || $newtag eq '') {
        if (!defined($oldtag) || $oldtag eq '') {
            Log(0, "ERROR(update_stored_config): Both new and old tags are empty!\n");
            return 0;
        } else {
            $newtag = $oldtag;
            $printnew = $printold;
        }
    }
    if (!defined($text)) {
        # The line pointed to by $oldtag must be removed
        if (!defined($oldtag) || $oldtag eq '' ||
            !exists($obj->{'cfidx_'.$oldtag})) {
            Log(0, "ERROR(update_stored_config): Can't delete line '$printold'; index not found.\n");
            return 0;
        }

        # Do a rudimentary check to ensure that the line being deleted
        # actually contains the text of $oldtag.  This protects against
        # corruption of the cfidx list, which should never happen.
        if ($obj->{'txtconfig'}->[$obj->{'cfidx_'.$oldtag}] !~ /$oldtag/) {
            Log(0, "ERROR(update_stored_config): Won't delete line ".$obj->{'cfidx_'.$oldtag}."; line does not contain '$printold'.\n");
            # Get rid of the faulty index
            delete $obj->{'cfidx_'.$oldtag};
            return 0;
        }

        # Save a copy of the old config (maybe)
        if (!$no_backup) {
            @{$obj->{'orig_raw_config'}} = @{$obj->{'txtconfig'}} unless exists($obj->{'orig_raw_config'});
            $obj->{'orig_raw_good'} = 1;
        }

        # Delete the offending line
        splice(@{$obj->{'txtconfig'}}, $obj->{'cfidx_'.$oldtag}, 1);

        # Adjust the indices of lines that used to follow
        ::shift_indices($obj, $obj->{'cfidx_'.$oldtag}, -1);

        # Get rid of the old index
        delete $obj->{'cfidx_'.$oldtag};

        return 1;

    }

    if (!defined($oldtag)) {
        # This must be an insertion!
        my $idx = undef;
        if ($newtag =~ s/:(\d+)//) {
            $idx = $1;
        }
        if (exists($obj->{'cfidx_'.$newtag})) {
            Log(0, "ERROR(update_config_file): Cannot insert new line with same tag\n                            ($printnew) as existing line!\n");
            return 0;
        }

        # Save a copy of the old config (maybe)
        if (!$no_backup) {
            @{$obj->{'orig_raw_config'}} = @{$obj->{'txtconfig'}} unless exists($obj->{'orig_raw_config'});
            $obj->{'orig_raw_good'} = 1;
        }

        if (defined($idx)) {
            # There's a specific place to put it
            my $newtext = "$newtag =";
            if ($newtag =~ /$isnotes/) {
                # Leading whitespace for notes is preserved, so don't add any
                $newtext .= $text;
            } else {
                $newtext .= " $text";
            }
            splice @{$obj->{'txtconfig'}}, $idx, 0, $newtext;
            # Fix up all the indices that have just been bumped
            ::shift_indices($obj, $idx, 1);

            $obj->{'cfidx_'.$newtag} = $idx;
        } else {
            # Just put it in at the end
            if (!exists($obj->{'cfidx_tools_added_default_section'}) ||
                $obj->{'cfidx_tools_added_default_section'} <= 0) {
                push @{$obj->{'txtconfig'}},
                '',
                '# The following section was added automatically, and contains settings that',
                '# did not appear in the original configuration file, but were added to the',
                '# raw file after the run.',
                'default:';
                $obj->{'cfidx_tools_added_default_section'} = $#{$obj->{'txtconfig'}};
            }
            my $newtext = "$newtag =";
            if ($newtag =~ /$isnotes/o) {
                # Leading whitespace for notes is preserved, so don't add any
                $newtext .= $text;
            } else {
                $newtext .= " $text";
            }
            push @{$obj->{'txtconfig'}}, $newtext;
            $obj->{'cfidx_'.$newtag} = $#{$obj->{'txtconfig'}};
        }

        return 1;
    }

    # If it's not an insertion and not a deletion, it must be a change.  The
    # fun begins... now!
    if (!exists($obj->{'cfidx_'.$oldtag})) {
        Log(0, "ERROR(update_config_file): No index found for '$printold'; cannot change line!\n");
        return 0;
    }
    my $idx = $obj->{'cfidx_'.$oldtag};
    if (!defined($obj->{'txtconfig'}->[$idx])) {
        Log(0, "ERROR(update_config_file): No config file line found at index $idx!\n");
        return 0;
    }
    if (exists($obj->{'cfidx_'.$newtag}) &&
        $obj->{'cfidx_'.$newtag} != $obj->{'cfidx_'.$oldtag}) {
        Log(0, "ERROR(update_config_file): Cannot change \"$printold\" \@ $idx;\n                             \"$printnew\" already exists \@ ".$obj->{'cfidx_'.$newtag}."!\n");
        return 0;
    }

    # Save a copy of the old config (maybe)
    if (!$no_backup) {
        @{$obj->{'orig_raw_config'}} = @{$obj->{'txtconfig'}} unless exists($obj->{'orig_raw_config'});
        $obj->{'orig_raw_good'} = 1;
    }

    # Make things easier by expanding tabs
    $tabstop = 8;
    my $tmpline = expand($obj->{'txtconfig'}->[$idx]);
    my ($initial_whitespace, $found_tag, $post_tag_whitespace, $pre_text_whitespace, $found_text);
    if ($tmpline =~ /^(\s*)(\S+)(\s*)=(\s*)(.*)$/) {
        $initial_whitespace  = $1;
        $found_tag           = $2;
        $post_tag_whitespace = $3;
        $pre_text_whitespace = $4;
        $found_text          = $5;
    } else {
        Log(0, "ERROR(update_config_file): Config file line at $idx does not look like\n                            a variable setting!\n");
        return 0;
    }
    if ($found_tag ne $oldtag) {
        my $printfound = $found_tag;
        $printfound =~ s/(.)/chr(ord($1) & 0x7f)/goe;
        $printfound .= '(+high bits)' if $printfound ne $found_tag;
        Log(0, "ERROR(update_config_file): Config file line at $idx ($printfound) does not match $printold!\n");
        return 0;
    }
    # Adjust the length of the variable section, preserving indentation where
    # possible.
    my $origlen = length($found_tag);
    my $newlen = length($newtag);
    my $newline;
    if ($newlen == $origlen) {
        # Easy!  Just replace $found_tag with $newtag
        $newline = $initial_whitespace.$newtag.$post_tag_whitespace.'=';
    } elsif ($origlen > $newlen) {
        # Also easy! Just pad out $post_tag_whitespace
        $newline = $initial_whitespace.$newtag.$post_tag_whitespace.
        sprintf '%*s=', ($origlen - $newlen), ' ';
    } elsif ($origlen + length($post_tag_whitespace) > $newlen) {
        # Easy easy! Just remove some from $post_tag_whitespace
        $newline = $initial_whitespace.$newtag.
        sprintf '%*s=', (($origlen + length($post_tag_whitespace)) - $newlen), ' ';
    } else {
        # Okay, also not too hard; just make the total length the same (if
        # possible), and have no whitespace before the equals
        $newline = sprintf '%*s=', (length($initial_whitespace) + $origlen + length($post_tag_whitespace)), $newtag;
    }

    if ($updateline) {
        # Replace the text, preserving whitespace around the tag, the equals,
        # and (if the tag does not contain "notes") the beginning of the text.
        $pre_text_whitespace = '' if ($oldtag =~ /$isnotes/);
        $newline .= $pre_text_whitespace.$text;
    } else {
        $newline .= $pre_text_whitespace.$found_text;
    }
    $obj->{'txtconfig'}->[$idx] = $newline;
    delete $obj->{'cfidx_'.$oldtag};
    $obj->{'cfidx_'.$newtag} = $idx;
    return 1;
}

sub check_elem {
    my ($endtype, $start, @keys) = @_;
    my $curr = $start;
    my $lastkey = pop @keys;

    return 0 unless (::ref_type($start) eq 'HASH');

    # For a chained hash, check to see that each element exists and is a
    # HASH ref, except for the end, which must be of $endtype type.
    foreach my $key (@keys) {
        return 0 unless exists($start->{$key}) && (::ref_type($start->{$key}) eq 'HASH');
        $start = $start->{$key};
    }
    return 0 unless exists($start->{$lastkey});

    if (defined($endtype) && $endtype ne '') {
        return 0 unless (::ref_type($start->{$lastkey}) eq $endtype);
    }
    return 1;
}

sub deep_copy {
    my ($objref) = @_;

    # Well, I had written one, but this is better:
    return $objref if (ref($objref) eq '');
    my $tmpref;
    eval { local($SIG{__WARN__}) = sub { 1; }; $tmpref = dclone($objref) };
    if ($@ && ($@ !~ /Can.t store item CODE/ || !$Storable::forgive_me)) {
        Log(0, "Error during deep_copy:\n  $@\n");
    }
    return $tmpref;
}

sub read_file {
    my($name) = @_;
    my (@temp);
    my $fh = new IO::File "<$name";
    # IO::File will close the file when $fh goes out of scope
    return () if !defined $fh;
    return <$fh>;
}

sub escape_HTML {
    my ($str) = @_;

    $str =~ s/\&(?!#\d+;|#x[\da-fA-F]+;|[\da-zA-Z]+;)/\&amp;/g;
    $str =~ s/</&lt;/gso;
    $str =~ s/>/&gt;/gso;

    return $str;
}

sub find_benchmark {
    my ($config, $name) = @_;
    my @objs = map { $config->benchmarks->{$_} } keys %{$config->benchmarks};
    if ($name =~ /^(\d+)$/ || $name =~ /^(\d{1,3})\.(.*)/) {
        my ($benchnum, $benchname) = ($1, $2);
        for (@objs) {
            return $_ if ($_->num == $benchnum && (!defined($benchname) || $benchname eq '' || $_->name =~ m{^\Q$benchname\E}));
        }
    } else {
        my $matches = [];
        for (@objs) {
            return $_ if ($_->name eq $name || $_->benchmark eq $name);

            if ($_->name =~ m/^\Q$name\E/) {
                push @{$matches}, $_;
            }
        }

        if (@{$matches} == 1) {
            return $matches->[0];
        } elsif (@{$matches} == 0) {
            return undef;
        } else {
            return $matches;
        }
    }
    return undef;
}

sub new_safe_compartment {
    my ($ns, $strict) = @_;
    $strict = 0 unless defined($strict);

    my $s = new Safe $ns;
    if ($strict or istrue($main::global_config->safe_eval())) {
        $s->permit_only(
            # :base_core
            # specperl -e 'use Opcode qw(/./); print join("\n", opset_to_ops(opset(qw(:base_core))))."\n"'
            qw(
            null stub scalar pushmark wantarray const coreargs
            defined undef
            rv2sv sassign
            rv2av aassign aeach aelem aelemfast aelemfast_lex akeys aslice av2arylen avalues kvaslice
            rv2hv helem hslice each values keys exists delete kvhslice
            preinc i_preinc predec i_predec
            postinc i_postinc postdec i_postdec
            int hex oct abs pow
            multiply i_multiply divide i_divide
            modulo i_modulo add i_add subtract i_subtract
            left_shift right_shift bit_and bit_xor bit_or nbit_and nbit_or nbit_xor sbit_and sbit_or sbit_xor
            negate i_negate not complement ncomplement scomplement
            lt i_lt gt i_gt le i_le ge i_ge eq i_eq ne i_ne
            ncmp i_ncmp slt sgt sle sge seq sne scmp
            substr vec stringify study pos length index rindex
            ord chr ucfirst lcfirst uc lc fc quotemeta trans transr chop
            schop chomp schomp
            match split qr
            list lslice splice push pop shift unshift reverse
            cond_expr flip flop andassign orassign and or xor dor dorassign
            warn die lineseq nextstate scope enter leave
            rv2cv anoncode anonconst prototype
            entersub leavesub leavesublv return
            method method_named method_redir method_redir_super method_super
            leaveeval
            multideref
            ),

            # :base_mem
            # specperl -e 'use Opcode qw(/./); print join("\n", opset_to_ops(opset(":base_mem")))."\n"'
            qw(
            concat repeat join range
            anonlist anonhash
            ),

            # Not from any particular tag
            qw(
            rv2gv
            padany padsv padav padhv sprintf
            localtime gmtime
            ),
        );
    }
    return $s;
}

sub check_per_item_hash {
    my ($fieldsref, $storedhash, $bits) = @_;
    $bits = (defined($bits) && $bits >= 256) ? $bits : 256;
    my %storedhash = %{$storedhash};    # Make a scratch copy

    # Return values
    my $added = [];     # Fields added
    my $changed = [];   # Fields changed (including old and new values)
    my $removed = [];   # Fields removed

    my %genhash = ();
    my $rc = assemble_and_hash(\%genhash, $fieldsref, $bits);
    return undef unless defined($rc);

    foreach my $item (sort keys %genhash) {
        next if $item eq 'rawhash' || $item eq 'exthash';
        if (!exists($storedhash{$item})) {
            push @{$added}, $item;
            delete $storedhash{$item};
        } elsif ($storedhash{$item} ne $genhash{$item}) {
            push @{$changed}, [ $item, $storedhash{$item}, $genhash{$item} ];
            delete $storedhash{$item};
        } else {
            # It exists and it matches
            delete $storedhash{$item};
        }
    }
    foreach my $item (sort keys %storedhash) {
        push @{$removed}, $item;
    }

    return (@{$added} + @{$removed} + @{$changed}, $added, $changed, $removed);
}

# Given a hash of fields with values, generate an hash of
# field names to values/hashes (whichever is smaller).
# This can be used to check one extended per-item result
# file hashes, or can be inverted and serialized for output.
sub assemble_and_hash {
    my ($hash, $fieldsref, $bits) = @_;
    $bits = (defined($bits) && $bits >= 256) ? $bits : 256;

    my $ctx = Digest::SHA->new($bits);
    if (!defined($ctx)) {
        ::Log(0, "Error: Could not find get hash object for SHA-$bits\n");
        return undef;
    }

    foreach my $field (sort keys %{$fieldsref}) {
        my $tmpitem = join(' ', (map { s/\s*$//; $_ } grep { defined } @{$fieldsref->{$field}}));
        my $hashedval;
        if (length($tmpitem) < ($ctx->hashsize / 4)) {
            # Don't hash, just store
            $hashedval = $tmpitem;
        } else {
            $hashedval = $ctx->add($tmpitem)->hexdigest;
            $ctx->reset($bits);
        }
        if (exists($hash->{$field})) {
            if (ref($hash->{$field}) ne 'ARRAY') {
                $hash->{$field} = [ $hash->{$field}, $hashedval ];
            } else {
                push @{$hash->{$field}}, $hashedval;
            }
        } else {
            $hash->{$field} = $hashedval;
        }
    }
    return $hash;
}

# Given a hash of field -> [ lines ], put all the lines together and generate
# a hash of them.  Output is a hash of checksum -> [ fieldnames ]
sub generate_exthash {
    my ($fields, $bits) = @_;

    $bits = ($bits >= 256) ? $bits : 256;

    my %tmphash = ();
    my $inputlen = 0;
    my $inputlines = 0;
    foreach my $item (keys %{$fields}) {
        next if $item eq 'rawhash' || $item eq 'exthash'; # Shouldn't happen
        my $fieldtxt = join(' ', (map { s/\s*$//; $_ } grep { defined } @{$fields->{$item}}));
        $inputlen += length($fieldtxt) + (length("spec.${main::lcsuite}.${item}000: ") * (@{$fields->{$item}}+0));
        $inputlines += @{$fields->{$item}}+0;
        my $hashedval;
        if (length($fieldtxt) < ($bits / 4)) {
            $hashedval = $fieldtxt;
        } else {
            $hashedval = Digest::SHA->new($bits)->add($fieldtxt)->hexdigest;
        }
        push @{$tmphash{$hashedval}}, $item;
    }
    # To make manual comparison (when values are extracted using extract_misc)
    # possible, sort the lists
    foreach my $hashedval (keys %tmphash) {
        @{$tmphash{$hashedval}} = sort @{$tmphash{$hashedval}};
    }
    my ($tmpdump, $tmpdumpstr) = serialize(\%tmphash, 1);
    my @tmpdumplines = split(/\n/, $tmpdump);

    # Debug output
    if (::Log(89)) {
        ::Log(89, "input: $inputlen ($inputlines lines; ".((keys %{$fields})+0)." items; ".((keys %tmphash)+0)." unique hashes)\n");
        ::Log(89, "orig: ".length($tmpdumpstr)."\n");
        ::Log(89, "squeezed: ".length($tmpdump)."\n");
        my $finallines = @tmpdumplines + 0;
        my $finalsize = length($tmpdump) + (length("spec.${main::lcsuite}.exthash000: ") * $finallines);
        ::Log(89, "final: $finalsize ($finallines lines)\n");
        ::Log(89, sprintf "%.2f%% of size; %.2f%% of lines\n", $finalsize / $inputlen * 100, $finallines / $inputlines * 100);
        ::Log(89, Data::Dumper->Dump([\$tmpdump, \%tmphash],['tmpdump','tmphash'])."\n");
    }

    if (!defined($tmpdump)) {
        warn "Couldn't compress_encode data for exthash\n";
        return undef;
    } else {
        return split(/\n/, $tmpdump);
    }
}

# Given a compressed and encoded exthash blob from a result, unpack it,
# invert it so that it's back to (field => hash/value) format, and
# return it as well as the number of bits used for the hash.
sub unpack_exthash {
    my ($linesref) = @_;

    my $val = (ref($linesref) eq 'ARRAY') ? join("\n", @{$linesref}) : $linesref;

    my $bits = 0;
    my $newhash = undef;

    my $exthash = deserialize($val, 'unpack_exthash', 1);
    if (!defined($exthash) or ::reftype($exthash) ne 'HASH') {
        warn "Could not reconsititute list of extended hashes\n";
        return undef;
    }

    # Reverse the mappings
    $newhash = {};
    foreach my $hash (keys %{$exthash}) {
        foreach my $item (@{$exthash->{$hash}}) {
            $newhash->{$item} = $hash;
            $bits = length($hash) if length($hash) > $bits;
        }
    }
    $exthash = $newhash;
    $bits = ($bits < 64) ? 64 : $bits;  # In case NO hashes are in the exthash
    return ($exthash, $bits * 4);
}

# Given a meter label, produce the tag that should be used in the raw file
sub get_meter_tag {
    my ($name, @meters) = @_;

    if (::ref_type($meters[0]) eq 'HASH') {
        # List of meter objects, which will contain the tag
        my @list = grep { $_->{'name'} eq $name } @meters;
        if (@list && ::ref_type($list[0]) eq 'HASH') {
            return $list[0]->{'tag'};
        }

    } else {
        # List of tags; see if the supplied name (properly munged) matches and
        # if so, return it.  Otherwise just bail... what else can we do?
        $name =~ tr{A-Za-z0-9}{}cd;
        $name = lc($name);
        if (grep { $name eq $_ } @meters) {
            return $name;
        }
    }

    return undef;
}

# Given one or more channels of range data from PTD, make a string of it
sub range_string {
    my ($rangeref, $pos) = @_;

    return undef unless ref($rangeref) eq 'ARRAY';
    my $tmp = eval { [ grep { defined }  map { $_->[$pos] } @{$rangeref} ] };
    if (!defined($tmp) || ref($tmp) ne 'ARRAY' || $@ ne '') {
        ::Log(100, "WARNING: Couldn't extract range info from $rangeref at position $pos\n");
        return undef;
    }
    if (@{$tmp} == 1) {
        return $tmp->[0];
    } elsif (@{$tmp} > 1) {
        my $same = 1;
        foreach my $val (@{$tmp}) {
            return '['.join(',', @{$tmp}).']' if $tmp->[0] != $val;
        }
        return $tmp->[0];
    } else {
        return '';
    }
}

# Extract current and voltage range fields from a powersamples field.
# Main action is to put amp_range and volt_range fields into $result,
# but a side effect will be to return a hash of metertags and ranges
# used.
sub extract_ranges {
    my ($result, $samplelist, $prefix, @meters) = @_;

    my %rc = ();
    my $serialized;

    if (::ref_type($samplelist) ne 'ARRAY') {
        # rawformat will send strings in; try to turn them into an array ref
        ($serialized, $samplelist) = reserialize($samplelist);
        return undef if ::ref_type($samplelist) ne 'ARRAY';
    }
    $serialized = serialize($samplelist, 1) unless defined($serialized);

    foreach my $meterref (@{$samplelist}) {
        next unless ref($meterref) eq 'ARRAY';
        my $metertag = ::get_meter_tag($meterref->[0], @meters);
        my $meterstats = $meterref->[1];
        next unless ref($meterstats) eq 'HASH' && ref($meterstats->{'range'}) eq 'ARRAY';
        if (!defined($metertag)) {
            $metertag = 'UNKNOWN('.$meterref->[0].')';
            $metertag =~ s/:/ /g;
        }
        my $amp_range  = ::range_string($meterstats->{'range'}, 0);
        my $volt_range = ::range_string($meterstats->{'range'}, 1);
        $rc{$metertag} = {
            'amp'  => sprintf('%.1f', $amp_range),
            'volt' => sprintf('%.0f', $volt_range)
        };
        $amp_range  = $metertag.':'.$amp_range;
        $volt_range = $metertag.':'.$volt_range;

        my $amprangelist = $result->{$prefix.'amp_range'};
        $amprangelist = $result->{$prefix.'amp_range'} = [] unless ::ref_type($amprangelist) eq 'ARRAY';
        my $voltrangelist = $result->{$prefix.'volt_range'};
        $voltrangelist = $result->{$prefix.'volt_range'} = [] unless ::ref_type($voltrangelist) eq 'ARRAY';

        # Don't duplicate values
        push @{$amprangelist},  $amp_range  unless grep { $_ eq $amp_range  } @{$amprangelist};
        push @{$voltrangelist}, $volt_range unless grep { $_ eq $volt_range } @{$voltrangelist};
    }

    return ($serialized, %rc);
}

sub simple_subpart_fixup {
    # Given a list of fields and a list of tags, replicate the list of fields
    # for each tag, replacing '!' with the tag.
    my ($fields, @tags) = @_;

    # No tags == nothing to do
    return @{$fields} unless @tags > 0;
    # No variable fields == nothing to do
    return @{$fields} unless grep { $_->[0] =~ /!/ } @{$fields};

    my @rc = ();
    foreach my $tag (@tags) {
        foreach my $fieldref (@{$fields}) {
            my @tmp = @{$fieldref};
            $tmp[0] =~ s/!/$tag/;
            push @rc, [ @tmp ];
        }
    }

    return @rc;
}

sub fixup_subparts {
    my ($result, $syntax, $system) = @_;
    # Given a result object, a syntax table, and an item (node/interconnect
    # name), discover the number of sub-items and return a fixed-up syntax
    # table that will cause format_info to print them all.

    # Figure out where the groups of variable items are
    my @special_idx = ();
    my %special_items = ();
    my ($current_item, $current_idx) = (undef, undef);
    my @starting_indices = ();
    my $found_some = 0;
    for(my $i = 0; $i < @{$syntax}; $i++) {
        if ($syntax->[$i]->[0] =~ /^\Q${system}\E([^!]+)!(\S*)$/)  {
            my ($item, $subitem) = ($1, $2);
            if (defined($current_item) && defined($current_idx)
                && $current_item ne $item) {
                push @{$special_idx[$current_idx]}, $i - $current_idx;
                $current_item = $item;
                $current_idx = $i;
                push @starting_indices, $i;
            } elsif (!(defined($current_item) || defined($current_idx))) {
                $current_item = $item;
                $current_idx = $i;
                push @starting_indices, $i;
            }
            $special_idx[$i] = [ $subitem, $item, $i ];
            $special_items{$item}++;
            $found_some++;
        } elsif (defined($current_item) && defined($current_idx)) {
            push @{$special_idx[$current_idx]}, $i - $current_idx;
            ($current_item, $current_idx) = (undef, undef);
        }
    }
    if (defined($current_item) && defined($current_idx)) {
        push @{$special_idx[$current_idx]}, @{$syntax} - $current_idx;
    }
    return $syntax unless $found_some;

    # List the keys in $result just once
    my @keys = $result->list_keys;

    # Now get the list of special items that actually appear
    my %actual_items = ();
    foreach my $item (keys %special_items) {
        foreach my $instance (grep { /^\Q${system}${item}\E/ } @keys) {
            next unless $instance =~ /^\Q${system}${item}\E([a-zA-Z0-9]+)/;
            $actual_items{${item}.$1}++;
        }
    }
    # These will be processed in reverse order, so sort them appropriately
    my @actual_items = reverse sort keys %actual_items;

    if (@actual_items == 0) {
        # No actual items!  So they're missing... fake up accordingly
        @actual_items = reverse sort map { $_.'MISSING' } keys %special_items;
    }

    # Sort the list of block starts in reverse order; by inserting the
    # last items into the list first, the other indices won't get
    # screwed up.
    @starting_indices = reverse sort { $a <=> $b } @starting_indices;

    # Now make parallel copies of the syntax list, one for each actual item,
    # with '!' replaced by the item's name
    my %syntax_lists = ();
    foreach my $actual (@actual_items) {
        $syntax_lists{$actual} = [ ];
        for(my $i = 0; $i < @{$syntax}; $i++) {
            next unless defined($special_idx[$i]);
            my ($subitem, $item) = @{$special_idx[$i]};
            # Copy the syntax item somewhat deeply
            $syntax_lists{$actual}->[$i] = [ @{$syntax->[$i]} ];
            $syntax_lists{$actual}->[$i]->[0] = "$system$actual$subitem";
        }
    }

    # Make a mungeable copy of the syntax list
    my @syntax = @{$syntax};

    # Now go through all the variable blocks and splice them in to the final
    # syntax list.
    foreach my $idx (@starting_indices) {
        my ($subitem, $item, $start, $num) = @{$special_idx[$idx]};
        foreach my $actual (@actual_items) {
            splice @syntax, $start+$num, 0, @{$syntax_lists{$actual}}[$start..($start+$num-1)];
        }
        # Get rid of the marker lines
        splice @syntax, $start, $num;
    }

    return \@syntax;

}

sub power_info_munge {
    my ($r) = @_;

    # Just duplicate the necessary fields for each of the meters in $result
    @::power_info = map { [ $_, @{$::power_info{$_}} ] } sort grep { /^\d/ } keys %::power_info;
    foreach my $powerthing (sort grep { !/^\d/ } keys %::power_info) {
        next unless reftype($r->{'meterlist'}->{$powerthing}) eq 'ARRAY';
        foreach my $meter (@{$r->{'meterlist'}->{$powerthing}}) {
            $r->{'meters'}->{$powerthing}->{$meter} = [ ::simple_subpart_fixup($::power_info{$powerthing}, $meter) ];
        }
    }
}

sub mpi_info_munge {
    my ($r, $item, $system) = @_;

    # In order to avoid doing a LOT of hacking on info_format()
    # we'll make up a hardware/software list that has field names
    # fixed up for the current node or interconnect
    my (@hw_info, @sw_info);
    foreach my $inforef (@{$::mpi_info{$item}}) {
        if ($inforef->[2] =~ /hw/) {
            push @hw_info, [ "${item}_${system}_$inforef->[0]", @{$inforef}[1,2] ];
        }
        if ($inforef->[2] =~ /sw/) {
            push @sw_info, [ "${item}_${system}_$inforef->[0]", @{$inforef}[1,2] ];
        }
    }

    my $hw_info = ::fixup_subparts($r, \@hw_info, "${item}_${system}_");
    my $sw_info = ::fixup_subparts($r, \@sw_info, "${item}_${system}_");

return ($hw_info, $sw_info);
}

sub protect_notes_links {
    return munge_notes_links(1, @_);
}

sub unprotect_notes_links {
    return munge_notes_links(0, @_);
}

# Given a notes line, look for links like
# ATTACH <url> AS text
# ATTACH <url> AS [text text]
# LINK <url> AS text
# LINK <url> AS [text text]
# and prepare it for handling by line wrappers, etc.
sub munge_notes_links {
    my ($prot, $line, $replacements) = @_;

    $replacements = [] unless (::ref_type($replacements) eq 'ARRAY');
    if ($prot == 1) {
        # Protect it from the wrappers, etc.
        my $count = 0;
        while ($count < 100 &&
            $line =~ /((LINK|ATTACH)\s+(\S+)\s+AS\s+(\[[^]]+\]|\S+))/) {
            my ($section, $what, $url, $text) = ($1, $2, $3, $4);
            # Strip enclosing square brackets from $text
            $text =~ s/^\[(.*)\]$/$1/;
            my $repl = gen_notes_link_sym($section, $url, $text);
            if ($line !~ s/\Q$section\E/$repl/) {
                Log(0, "ERROR: Protection of \"$section\" in notes line failed\n");
                last;
            }
            $count++;
            push @{$replacements}, $repl;
        }
        return ($line, $replacements);
    } elsif ($prot == 0) {
        # Put the sections back
        foreach my $repl (@{$replacements}) {
            my $section = get_notes_link_section($repl);
            if (!defined($section)) {
                $repl =~ s/(.)/chr(ord($1) & 0x7f)/goe;
                Log(0, "ERROR: Replacement tag \"$repl\" not found when deprotecting notes line \"$line\"\n");

                next;
            }
            $line =~ s/\Q$repl\E/$section/; # Okay if it fails; might not be
            # in this line anyway.
        }
        return $line;
    }
}

sub gen_notes_link_sym {
    # Given the bits of a notes link (the full text, the URL, and the link text)
    # produce a token that can be subtituted into the original line which
    # will produce its presentation length (for the purposes of wrapping),
    # or which can be used to decompose the line for presentation.
    my ($section, $url, $text) = @_;

    if (exists($::sec_to_repl{$section})) {
        # Nothing to do
        return $::sec_to_repl{$section};
    }

    # Keep it relatively simple, but don't make it order n for new insertions
    # either...
    my $repl = length($text) x (length($text) / length(length($text)));
    $repl .= '_' x (length($text) % length($repl));
    my $testrepl;
    ($testrepl = $repl) =~ s/(.)/chr(ord($1) | 0x80)/goe;
    while (exists($::repl_to_sec{$testrepl})) {
        my $oldrepl = $repl;
        $repl++;
        $repl .= '_' x (length($text) % length($repl));
        if ($repl eq $oldrepl) {
            # Overflow!  Start from the beginning
            $repl = '0' x length($text);
        }
        ($testrepl = $repl) =~ s/(.)/chr(ord($1) | 0x80)/goe;
    }
    $repl =~ s/(.)/chr(ord($1) | 0x80)/goe;

    $::sec_to_repl{$section} = $repl;
    $::repl_to_sec{$repl} = {
        'url'     => $url,
        'text'    => $text,
        'section' => $section
    };
    return $repl;
}

sub get_notes_link_section {
    my ($repl) = @_;

    return undef unless exists($::repl_to_sec{$repl});
    return $::repl_to_sec{$repl}->{'section'};
}

# Look for "ATTACH <url> AS <text>" bits in notes, gather the files, rename
# them, fix up the URL in the notes line, and return it.
sub handle_ATTACH {
    my ($text, $basename, $written) = @_;
    $written = [] unless (::ref_type($written) eq 'ARRAY');
    my $rc = $text;
    my ($base, $dir, undef) = fileparse($basename);

    my $count = 0;
    while ($count < 40 && $text =~ /(ATTACH\s+(\S+)\s+AS\s+(\[[^]]+\]|\S+))/g) {
        my ($section, $url, $linktext) = ($1, $2, $3);
        $count++;

        # Check to see if the URL has our basename.  If so, check to see if
        # it's present and skip the fetch/rename cycle.  This can happen
        # on the initial run, when runcpu gathers the attachments and then
        # rawformat runs through them again.
        if ($url =~ /^\Q$base\E/) {
            next if (-f ::jp($dir, $url));
            # Otherwise, the file doesn't exist, so we'll let the code go
            # on and complain.
        }

        # Make sure it has an entry in sec_to_repl and repl_to_sec
        my $tag = ::gen_notes_link_sym($section, $url, $linktext);

        # Have we already seen and retrieved this URL?  If so, just point to
        # it.
        my $fname;
        if (exists($::url_to_file{$url})) {
            $fname = $::url_to_file{$url};
        } else {
            # Retrieve the URL and copy it to the supplied basename with a
            # proper extension.
            ::Log(1, "Retrieving attached file from $url\n");

            # If the URL is just a filename, and it doesn't exist in the
            # current directory, prepend the dirname of the current file
            # being formatted, if the file exists there.
            if ($url !~ m#/# && ! -r $url && -r jp($dir, $url)) {
                $url = jp($dir, $url);
            }

            my $res = ::get_url(\$ua, $url, undef, undef, undef);
            if (!$res->{'success'}) {
                $::repl_to_sec{$tag}->{'url'} = undef;
                ::Log(0, "\nERROR: Could not retrieve file attachment from \"$url\";\n");
                ::explain_http_error($res, 0);
                ::Log(0, "\n");
                next;
            }

            # What's in it?
            my $content = $res->{'content'};

            # Figure out what extension to give a file based on its MIME
            # content type.
            my $mime_type = $res->{'headers'}->{'content-type'};
            $mime_type =~ s/(\S+?)(?:,|\s+).*/$1/;
            my $ext;

            if (exists($::mime2ext{lc($mime_type)})) {
                $ext = '.'.$::mime2ext{lc($mime_type)};
            } elsif ( $mime_type =~ m#image/(.*)# ) {
                $ext = '.'.lc($1);
                $ext =~ s/jpeg/jpg/;
            } else {
                # What could it be?  Just leave it as-is, I guess...
                my $uri = URI->new($url);
                my @path_segs = $uri->path_segments;
                $ext = $path_segs[-1];
                $ext =~ s/^.*?(\.[^.]+)$/$1/;
            }
            # If the extension chosen is one that _might_ appear on any of our
            # other result outputs, prepend 'attached' to make it clear that
            # this is _not_ part of the result.
            my @formats = sort keys %{$::global_config->{'formats'}};
            my %extensions;
            if (@formats > 1) {
                # Rawformat always has the full list
                %extensions = map { '.'.$::global_config->{'formats'}->{$_}->{'extension'} => 1 } @formats;
            } else {
                # Runspec doesn't.  Not hardcoding this would require making
                # runcpu locate all the formats, which would require lots
                # more (technically) useless file duplication, so I decline.
                %extensions = map { '.'.$_ => 1 } (
                        qw(txt cfg csv flags.html html pdf ps rsf)
                        );
            }
            # And the HTML formatter may generate GIF files:
            $extensions{'.gif'} = 1;
            $ext = '.attached'.$ext if exists($extensions{$ext});

            # Choose a unique filename
            $fname = $basename.$ext;
            my $count = 0;
            while (-f $fname) {
                $count++;
                $fname = $basename.".$count".$ext;
            }

            # Write it out (finally!)
            my $ofh = new IO::File '>'.$fname;
            if (!defined($ofh)) {
                Log(0, "\nERROR: Could not open \"$fname\" for writing: $!\n");
                $::repl_to_sec{$tag}->{'url'} = undef;
                next;
            }
            binmode $$ofh, ':raw';
            $ofh->print($content);
            $ofh->close();
            push @{$written}, $fname;

            # Now strip off the directory part -- all these files should be in
            # the same place.
            # XXX This code will need some fixup for use at SPEC.
            $fname = basename($fname);
            $::repl_to_sec{$tag}->{'url'} = $fname;
            $::url_to_file{$url} = $fname;
        }

        # Now with filename in hand, rewrite the section, replacing the URL
        # with the filename
        if ($rc !~ s/\Q$section\E/ATTACH $fname AS $linktext/g) {
            ::Log(0, "\nERROR: Couldn't rewrite \"$url\" to \"$fname\" in notes line\n       \"$text\"\n");
        }
    }

    return $rc;
}

# Given a URL, file, or whatever, get the content and return an HTTP::Response
# object.
# The agent passed should be a scalar reference.
sub get_url {
    return do_url_request('GET', @_);
}

sub head_url {
    return do_url_request('HEAD', @_);
}

sub do_url_request {
    my ($method, $agent, $url, $timeout, $proxy, $callback) = @_;
    my $res = {};

    if ($url !~ m|^[^:]+://| or $url =~ m|^file:|) {
        # Bare path or file: URI; HTTP::Tiny neither needed nor wanted

        # Treatment of file: URIs is a little implementation-dependent, though
        # the IETF is working on it (see draft-ietf-appsawg-file-scheme).  The
        # CPU tools behave thusly:
        # - "file:" followed by a character other than "/" denotes a relative
        #   path.  The leading "file:" is stripped, the remainder of the path
        #   is canonicalized and made absolute before opening.
        # - "file:" followed by a single "/" is assumed to be an absolute
        #   path.  The leading "file:" is stripped and the path canonicalized
        #   before opening.
        # - "file://" is assumed to start a proper file: URI with a host part
        #   and an absolute path.  The initial "file://" along with everything
        #   up to the next "/" is stripped.  The host part of the URI may be
        #   empty or "localhost"; any other value will cause an error.  If no
        #   trouble with the host part, then the resulting absolute path is
        #   canonicalized before opening.
        my $path = $url;
        if ($path =~ s|^file://([^/]*)/|/|) {
            # Full file: URI
            if ($1 ne '' and $1 ne 'localhost') {
                ::Log(0, "\nERROR: The specified file: URI ($url) contains a non-empty host part: $1\n");
                $res = {
                    'success' => 0,
                    'status'  => 404,
                    'reason'  => "Non-empty host part: '$1'",
                };
            }
        } else {
            $path =~ s/^file://;
        }
        if (!defined($res->{'success'})) {
            $path = File::Spec->rel2abs($path) if ($path !~ m|^/|);
            $path = File::Spec->canonpath($path);
            $path = abs_path($path);        # Take care of . and .., etc.
            my $ifh = new IO::File '<'.$path;
            if (!defined($ifh)) {
                my $err = $!;
                ::Log(0, "\nERROR: The specified file ($path) from $url could not\n       be opened for reading: $err\n");
                $res = {
                    'success' => 0,
                    'status'  => 403,
                    'reason'  => $err,
                };
            } else {
                $ifh->binmode(':bytes');
                $res = {
                    'success' => 1,
                    'status'  => 200,
                    'reason'  => "OK; filename is $url",
                };
                if (defined($callback) and ref($callback) eq 'CODE') {
                    my $chunk;
                    while($ifh->read($chunk, 32768)) {
                        &{$callback}($chunk, $res);
                    }
                } else {
                    { local $/ = undef; $res->{'content'} = <$ifh> }
                }
            }
        }
    } else {
        $$agent = ::new_user_agent('proxy' => $proxy, 'timeout' => $timeout) unless defined($$agent);
        if (defined($$agent)) {
            if ($url !~ /^http:/) {
                Log(0, "\nERROR: Unsupported URL scheme; please use file: or http:.\n");
                Log(0, "The URL specified was $url\n");
                $res = {
                    'success' => 0,
                    'status'  => 405,
                    'reason'  => 'Method Not Allowed',
                };
            } else {
                $res = $$agent->request($method, $url, { 'data_callback' => $callback });
                if ($res->{'success'}) {
                    $res->{'reason'} = 'OK; filename is '.URI->new($url)->path;
                }
            }
        } else {
            # A URL was specified, but HTTP::Tiny is not available.
            # This should never happen.
            Log(0, "\nERROR: A URL was specified, but HTTP::Tiny is not available to retrieve it.\n");
            Log(0, "       Without HTTP::Tiny, only normal files can be specified for URLs\n");
            $res = {
                'success' => 0,
                'status'  => 503,
                'reason'  => 'HTTP::Tiny module not available',
            };
        }
    }

    return $res;
}

sub expand_all {
    my (@selection) = @_;
    my @replacements;

    # Convert 'all' to whatever it's supposed to be
    if ($::lcsuite eq 'cpu2017') {
        # 'all' really means ALL -- all benchmarks, all modes
        @replacements = (qw(
                            fprate
                            fpspeed
                            intrate
                            intspeed
                        ));
    } elsif ($::lcsuite eq 'mpi2007') {
        @replacements = (qw(medium large));
    } elsif ($::lcsuite eq 'omp2012') {
        @replacements = (qw(gross));
    }
    if (@replacements) {
        # This makes things nicer in several ways, but less general
        # Position is important, so we search for the index of 'all' so we can
        # use splice.
        for (my $i = 0; $i < @selection; $i++) {
            if ($selection[$i] =~ /^(\^)*(all|\Q${main::lcsuite}\E)\b/io) {
                my $not = $1;
                my $what = $2;
                my @tmp_replace = map { "${not}$_" } @replacements;
                splice @selection, $i, 1, @tmp_replace;
                Log(24, "'${not}${what}' replaced by ('".join("', '", @tmp_replace)."') at position $i of selection list\n");
            }
        }
    }

    return @selection;
}

sub get_tmp_directory {
    my ($config, $create, @extra) = @_;
    my $top = $config->top;
    if (check_output_root($config, $config->output_root, !$create)) {
        $top = $config->output_root;
    }

    my @subdirs = ();

    my $subdir = $config->expid;
    push @subdirs, $subdir if $subdir ne '';

    $subdir = $config->accessor_nowarn('lognum');
    if (defined($subdir) && $subdir ne '') {
        $subdir = $::suite.'.'.$subdir;
        push @subdirs, $subdir;
    }
    push @subdirs, @extra;

    # Protect against blocker files
    my $count = undef;
    my $madeit = 0;
    my $dir = '';
    my @trydirs = ('tmp', 'tmp.'.$::lcsuite, 'tmp.'.$::lcsuite.'.');
    DIR: foreach my $try (@trydirs) {
        if ($try eq 'tmp.'.$::lcsuite.'.') {
            $count++;
            $try .= $count;
            $count++;   # Get ready for the next one
            push @trydirs, 'tmp.'.$::lcsuite.'.'.$count;
        } elsif (defined($count) && $count < 10) {
            $count++;   # Get ready for the next one
            push @trydirs, 'tmp.'.$::lcsuite.'.'.$count;
        }
        $dir = $top;
        foreach my $tmpdir ($try, @subdirs) {
            my $trydir = jp($dir, $tmpdir);
            next DIR if (-e $trydir && ! -d $trydir);
            $dir = jp($dir, $tmpdir);
        }
        # At this point, $dir should point to a place that _might_ be a
        # directory, or might not exist.  Either is probably okay.
        if ($create) {
            my @created = ();
            eval {
                @created = mkpath($dir);
                if (!$@) {
                    # Touch a file in the directory to indicate that we are
                    # using it.  There's still a race where another runcpu
                    # could come along and remove it from under us, but it
                    # should shorten the window.
                    eval {
                        my ($tmpfh, $tmpfn) = tempfile('in_use_by_XXXX', DIR => $dir, SUFFIX => '_'.$$, UNLINK => 1);
                        $tmpfh->close(); # Windows complains otherwise
                    };
                }
            };
            if ($@) {
                Log(0, "ERROR: Could not create temp directory \"$dir\": $@\n");
                next DIR;
            }
        }
        $madeit = 1;
        last;
    }
    if ($madeit) {
        $::tmpdirs_seen{$dir}++;
        return $dir;
    } else {
        my $what = ($create) ? 'create ANY' : 'find ANY usable';
        Log(0, "ERROR: Could not $what temporary directory\n");
        my $from = (caller(1))[3];
        if ($from =~ /do_exit/) {
            # Avoid infinite loop
            return undef;
        } else {
            do_exit(1);
        }
    }
}

# Check to see if the supplied output root is from the correct suite and
# version.
sub check_output_root {
    my ($config, $dir, $nocreate) = @_;

    # If there's nothing to check, output_root isn't being used
    return 0 unless defined($dir) and $dir ne '';

    my $exiting = 0;
    my $level = 0;
    while($exiting == 0 and (my @caller_info = caller($level))) {
        $exiting++ if $caller_info[3] =~ /::do_exit$/;
        $level++;
    }
    if (! -d $dir) {
        if ($nocreate) {
            # If it doesn't exist, it can't be the wrong version
            return 1;
        } else {
            # Make it ours
            eval { mkpath($dir) };
            if ($@) {
                Log(0, "\nERROR: Could not create output_root directory: $@\n");
                $exiting ? return 1 : do_exit(1);
            }
        }
    }
    if (! -f jp($dir, 'version.txt')) {
        # Mark it as ours
        my $fh = new IO::File '>'.jp($dir, 'version.txt');
        if (!defined($fh)) {
            Log(0, "\nERROR: Could not create version file in output_root directory '$dir': $!\n");
            $exiting ? return 0 : do_exit(1);
        }
        $fh->print($::suite.' '.$::suite_version."\n");
        $fh->close();
    } else {
        # Check that it's ours
        my $fh = new IO::File '<'.jp($dir, 'version.txt');
        if (!defined($fh)) {
            Log(0, "\nERROR: Could not open version file in output_root directory '$dir' for reading: $!\n");
            $exiting ? return 0 : do_exit(1);
        }
        my $line = $fh->getline();
        $fh->close();
        $line =~ tr/\012\015//d;
        if ($line =~ /^(.+)\s+(\S+)$/) {
            my ($or_suite, $or_version, $suite, $version) = ($1, $2, $::suite);
            # YYY - version #
            $version = human_version($::suite_version);
            $or_version = human_version($or_version);
            $or_suite =~ s/^SPEC\s*//i;
            $suite =~ s/^SPEC\s*//i;
            if ($or_suite ne $suite or $or_version ne $version) {
                Log(0, "\nERROR: output_root version mismatch\n".
                    "         You are now using   SPEC $suite $version\n".
                    "         output_root is from SPEC $or_suite $or_version\n".
                    "   Please adjust the setting of 'output_root'\n");
                $exiting ? return 0 : do_exit(1);
            }
        } else {
            Log(0, "\nERROR: Version file in output_root directory '$dir' is corrupt.\n");
            Log(110, "       Expected '<suite> <version>'; got '$line'\n");
            $exiting ? return 0 : do_exit(1);
        }
    }

    # If we get here without exiting, then output_root is set and usable.
    return 1;
}

# Make a copy of a config object, overriding settings as necessary
sub copy_config {
    my ($baseconfig, $overrides) = @_;
    $overrides = { } unless defined($overrides) and ref($overrides) eq 'HASH';

    my $newconfig = new Spec::Config;
    # Copy everything so we can start fresh at will

    # Ask for Storable's indulgence, as the benchsets contain CODE refs
    my $old = $Storable::forgive_me;
    $Storable::forgive_me = 1;
    $newconfig = deep_copy($baseconfig);
    $Storable::forgive_me = $old;

    foreach my $override (sort keys %{$overrides}) {
        $newconfig->{$override} = $overrides->{$override};
    }

    # Copy the power analyzer and temperature meter lists; the socket object
    # is a GLOB, which Storable doesn't handle.
    foreach my $type ('power', 'temp') {
        next unless ref($baseconfig->{$type.'meterlist'}) eq 'ARRAY';
        for(my $i = 0; $i < @{$baseconfig->{$type.'meterlist'}}; $i++) {
            # Only copy the reference to the socket, as we still want the
            # response list to be empty
            $newconfig->{$type.'meterlist'}->[$i]->{'sock'} = $baseconfig->{$type.'meterlist'}->[$i]->{'sock'};
        }
    }

    # Fix up the config pointers for objects
    changeall_items($newconfig, 'config', undef, $newconfig);

    return $newconfig;
}

sub changeall_items {
    my ($container, $key, $oldval, $newval, $seen) = @_;
    $seen = {} unless ::ref_type($seen) eq 'HASH';

    return if $seen->{$container};
    $seen->{$container}++;

    my $what = ::ref_type($container);
    if ($what eq 'HASH') {
        if (exists($container->{$key}) and (!defined($oldval) or $container->{$key} eq $oldval)) {
            $container->{$key} = $newval;
        }
        foreach my $item (grep { $_ ne $key and ref($container->{$_}) ne '' } keys %{$container}) {
            changeall_items($container->{$item}, $key, $oldval, $newval, $seen);
        }
    } elsif ($what eq 'ARRAY') {
        for(my $i = 0; $i < @{$container}; $i++) {
            changeall_items($container->[$i], $key, $oldval, $newval, $seen) if ref($container->[$i]) ne '';
        }
    }
    return;
}

sub ref_type {
    my ($ref) = @_;

    return '' unless defined($ref);
    return '' unless defined(::reftype($ref));
    return ::reftype($ref);
}

sub copy_perms {
    my ($source, $target, $minmode) = @_;

    my $oldmode = stat($source);
    return unless defined($oldmode);
    $oldmode = $oldmode->mode | $minmode;
    chmod $oldmode, $target;
}

# Return the unique set of items
sub unique_elems {
    my (@items) = @_;

    # Fast, but messes up the order
    #return keys %{{map { $_ => 1 } @_}};

    # Slower, but preserves ordering
    my %seen = ();
    my @rc = ();
    foreach my $item (@items) {
        push @rc, $item unless $seen{$item};
        $seen{$item}++;
    }

    return @rc;

}

sub center {
    my ($text, $width) = @_;
    my $len = length $text;
    $width = 78 if !defined $width;
    $width = $len if $width < $len;
    ' ' x int(($width - length $text) / 2) . $text;
}

# Convert major.minor.subminor or a legacy kit number into a nice comparable
# real number (scalar context), or the component parts of one (list context).
# The second argument indicates how much of the original version should be
# included:
# 0 (default) => major, minor, subminor
# 1           => major, minor
# 2           => major
sub normalize_version($;$) {
    my ($str, $truncate) = @_;
    $truncate = 0 unless defined($truncate);
    my $format = (
        '%d.%03d%03d',
        '%d.%03d',
        '%d',
    )[$truncate];
    if (!defined($format) or $format eq '') {
        ::Log(0, "ERROR: normalize_version('$str', $truncate) called with truncate argument > 2\n");
        ::do_exit(1);
    }
    my @pieces = (0, 0, 0);
    if ($str !~ /\./) {
        # Legacy kit numbers.
        $pieces[1] = $str+0;
    }
    else {
        # Dotted decimal; explode it and turn it into a regular number
        @pieces = (split(/\./, $str), 0, 0, 0);
        for(my $i = 1; $i < min(3, @pieces+0); $i++) {
            if (length($pieces[$i]) > 3) {
                splice @pieces, $i, 1, ($pieces[$i] =~ /(.{1,3})/g);
            }
        }
        @pieces = map { $_ + 0 } @pieces[0..2];
    }
    splice @pieces, 3 - $truncate;
    $str = sprintf $format, @pieces;
    return wantarray ? @pieces : $str;
}

sub denormalize_version($) {
    my ($ver) = @_;
    if ($ver =~ s/^(\d+)\.//) {
        return ($1+0).'.'.join('.',map { $_+0 } grep { $_ ne '' } split(/(\d{3})/, $ver));
    } else {
        return $ver+0;
    }
}

sub canonical_version($;$) {
    return denormalize_version(normalize_version($_[0], $_[1]));
}

sub human_version($) {
    my ($ver) = @_;
    $ver = denormalize_version(normalize_version($ver, 0));
    return (is_release($ver) ? 'v' : 'kit ').$ver;
}

sub humanize {
    my ($qty, $unit, $base) = @_;
    $qty = int($qty);

    return "0 $unit\n" if $qty == 0;

    my ($suffix, $div) = ('B', 1000);
    if ($base == 2) {
        ($suffix, $div) = ('iB', 1024);
    }
    my %nextunit = ( 'B'=>'K', 'K'=>'M', 'M'=>'G', 'G'=>'T', 'T'=>'P' );
    $unit =~ s/^(.).*/$1/;

    # The 10 is arbitrary
    while (abs($qty) > ($div * 10)) {
        $unit = $nextunit{$unit};
        $qty = int($qty / $div);
    }
    $suffix = '' if $unit eq 'B';
    return "${qty} ${unit}$suffix";
}

sub is_release {
    my ($ver) = @_;
    my ($maj, $min, $submin) = normalize_version($ver);
    return ($maj >= 1 and $min <= 500 and $submin <= 500);
}

sub is_devel {
    return !is_release(@_);
}

sub get_suitehash {
    my ($path) = @_;

    my $ifh = new IO::File '<'.$path;
    my $ctx = ::get_hash_context(512);
    if (defined($ifh)) {
        # Read in the file, filter relevant lines, strip line endings, and add
        # them to the hash.
        while(defined(my $line = $ifh->getline())) {
            next unless $line =~ m# (?:benchspec|bin)/# or $line !~ m#/#;
            next if $line =~ m#(?:/Docs|\.txt$| bin/(?:unit_tests|scripts\.misc)/| bin/formats/\w+?.syntax$| c?shrc[^/]*$| install[^/]*$)#;
            $line =~ tr/\012\015//d;
            $ctx->add($line);
        }
        $ifh->close();
    }
    return defined($ctx) ? $ctx->hexdigest : 'NO_DIGEST';
}

sub floor {
    my ($temp) = @_;
    my $inttemp = int($temp);
    if ($temp != $inttemp) { #  This is a bad test.
        if ($temp > 0) {
            $temp = $inttemp;
        } else {
            $temp = $inttemp-1;
        }
    }
    return $temp;
}

sub explain_http_error {
    my ($res, $loglvl) = @_;

    if ($res->{'status'} eq '599'
            and $res->{'reason'} =~ /internal exception/i) {
        if ($res->{'content'} !~ /timeout/) {
            Log($loglvl, "got\n  ".$res->{'content'}."\n")
        } else {
            Log($loglvl, "request timed out\n");
        }
    } else {
        Log($loglvl, "got\n  ".$res->{'reason'}."\n");
    }
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab mouse= colorcolumn=120:
