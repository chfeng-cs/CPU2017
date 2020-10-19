#
# flagutils_common.pl
#
# Copyright 2005-2019 Standard Performance Evaluation Corporation
#
# $Id: flagutils_common.pl 6213 2019-05-08 21:46:26Z CloyceS $

use strict;
use Safe;
use XML::SAX;
use CPUFlagsParser;
use File::Basename;
use File::Temp qw(tempdir tempfile);
use File::Path;
use IO::File;
use POSIX qw(:sys_wait_h);
use Digest::SHA;

require 'util_common.pl';

use vars qw($ua);

my %seen_ids = ();

my $version = '$LastChangedRevision: 6213 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'flagutils_common.pl'} = $version;

sub get_flags_file {
    my ($url, $source, $standalone, $timeout, $proxy, $suitever) = @_;
    my $isuser = ($source eq 'user');
    my $fname = undef;

    if (!defined($url) || $url eq '') {
        Log(0, "\nERROR(get_flags_file): Flags file URL is empty!\n");
        return(undef, undef, undef);
    }
    if ($url eq 'noflags') {
        return('', {}, undef);
    }
    if (exists($::seen_flags_files{$url})) {
        Log(0, "NOTICE(get_flags_file): Flags file URL '$url' has already been loaded and will not be loaded again.\n");
        return('', {}, undef);
    }

    $timeout ||= 30;

    my $flags = '';
    my $res = ::get_url(\$ua, $url, $timeout, $proxy, undef);
    my $flagsstring = '';
    if ($res->{'success'}) {
        $flagsstring = $res->{'content'};
        ($fname) = ($res->{'reason'} =~ /OK; filename is (.*)/);
        if ($url =~ /^file:/ and exists($::seen_flags_files{$fname})) {
            Log(0, "NOTICE(get_flags_file): Flags file URL '$url' has already been loaded from '$fname' and will not be loaded again.\n");
            return('', {}, undef);
        }
        $::seen_flags_files{$fname} = $url;
    } else {
        Log(0, "\nERROR: Specified flags URL ($url) could not be retrieved;\n");
        ::explain_http_error($res, 0);
        Log(0, "\n");
        return(undef, undef, undef);
    }

    # Make sure that the flags file is actually XML
    if ($flagsstring =~ /<flagsdescription>/) {
        $flags = join("\n", split(/(?:\n\r|\n|\r\n|\r)/, $flagsstring, -1));
        return ($flags, parse_flags($flags, $url, $source, $standalone, 'forbid' => ($isuser) ? [ 'mandatory' ] : [], 'suiteversion' => $suitever), $fname);
    } elsif ($flagsstring ne '') {
        Log(0, "\nERROR: A flags file was specified and read, but does not seem to contain\n");
        Log(0, "       valid flag description XML.  The file's content will be ignored.\n");
        return (undef, undef, undef);
    }
}

sub parse_flags {
    # Given hunks of XML, parse them into the structure that the rest
    # of the tools expect.
    #
    # Options:
    # forbid:   An array ref containing a list of classes not allowed to
    #           appear in the structure.
    # suiteversion:     The version of the suite used to generate the
    #                   result.  Used to determine the correct DTD to
    #                   use when validating the flags files.  The special
    #                   value 'select' will use whichever DTD is specified
    #                   by the file itself, or the latest if that can't be
    #                   determined.
    my ($flagsfiles, $url, $source, $standalone, %opts) = @_;

    $url = '' unless defined($url);

    # On the off chance that there are multiple discrete flags files in
    # the string, split them up.
    my @files = grep { $_ ne '' } split(/<\/flagsdescription>[\s\r\n]*/, $flagsfiles, -1);
    # Assume current version unless instructed otherwise
    my $suitever = $opts{'suiteversion'} || $::suite_version;

    my ($flagtext, $flaginfo) = ('', {});
    my $count = 0;
    foreach my $flags (@files) {
        $flags .= "</flagsdescription>\n";       # Eliminated by split earlier

        $flags = join("\n", split(/(?:\n\r|\n|\r\n|\r)/, $flags, -1));
        my $flagref = undef;
        my $flaghash = ::scalardigest($flags, 512);
        %seen_ids = ();     # Flag names need only be unique within a file
        $count++;

        my $flaghandler = new CPUFlagsParser;
        return undef unless defined($flaghandler);

        unless (defined($::website_formatter) && $::website_formatter) {
            # Use specrxp (if available) to strictly validate the contents of
            # the file.
            my $rxp_err = validate_xml($url, $count, $flags, $suitever);
            if (!defined($rxp_err)) {
                return undef;
            } elsif (   $rxp_err ne ''
                && $rxp_err ne 'no_rxp'
                && $rxp_err ne 'not_validated') {
                Log(0, "\nERROR: An error was encountered while parsing the flag description file\n");
                Log(0, "        at $url\n") if ($url ne '');
                if (@files > 1) {
                    Log(0, "        The error occured in file #$count; line numbers in the following\n");
                    Log(0, "        error output are relative to that file's opening \"<?xml>\" tag.\n");
                }
                Log(0, "   Output from the XML validator follows:\n\n-----------\n");
                Log(0, $rxp_err."\n-----------\n\n");
                return undef;
            }
        }

        my $flagparser = XML::SAX::ParserFactory->parser(
            Handler => $flaghandler
        );

        if (defined($flagparser)) {
            # Convert the XML into a hash
            eval { $flagparser->parse_string($flags); };
            if ($@) {
                my $err = $@;
                $err =~ s/at \S+flagutils.pl line \d+//gs;
                Log(0, "\nERROR: An error was encountered while parsing the flag description file\n");
                Log(0, "        at $url\n") if ($url ne '');
                Log(0, "       The error message returned by the XML parser was\n");
                Log(0, "$err\n");
                return undef;
            }
            $flagref = $flaghandler->get_flag_ref();
            if (::ref_type($flagref) ne 'HASH') {
                Log(0, "\nERROR: The XML parser did not return the expected data structure type.\n");
                undef $flagref;
            } else {
                # Add the hash of the flags to the data structure; it will
                # be used by the updater.
                $flagref->{'hash'} = $flaghash;

                # Make sure we haven't looked at this file already
                if (exists($::seen_flags_filenames{$source.$flagref->{'filename'}})) {
                    Log(0, "\nERROR: The flag file at '$url'\n");
                    Log(0, "        specifies a filename (\"".$flagref->{'filename'}."\")\n");
                    Log(0, "        which was also supplied by the flag file at '".$::seen_flags_filenames{$source.$flagref->{'filename'}}."'.\n");
                    Log(0, "        Flag files must have unique <filename> elements.\n");
                    do_exit(1);
                }
                $::seen_flags_filenames{$source.$flagref->{'filename'}} = $url;
                $::seen_flags_files{$url} = $flagref->{'filename'};

                # Check for forbidden classes (if any)
                if (exists($opts{'forbid'}) && (::ref_type($opts{'forbid'}) eq 'ARRAY') &&
                    @{$opts{'forbid'}}) {
                    # Grab all the flag classes from all the flags
                    my %seenclasses = map { $_->{'class'} => 1 } @{$flagref->{'flag'}};
                    my $found = 0;
                    foreach my $badclass (@{$opts{'forbid'}}) {
                        if (exists $seenclasses{$badclass}) {
                            Log(0, "\nERROR: The flag file at\n");
                            Log(0, "       $url\n");
                            Log(0, "     contains one or more flags in the class \"$badclass\", which is not\n");
                            Log(0, "     allowed.\n");
                            $found++;
                        }
                    }
                    do_exit(1) if $found;
                }

                # Check the flags for unknown attributes, etc.
                my $error = 0;
                my $flags = $flagref->{'flag'};
                foreach my $flag (@{$flags}) {
                    my $tmpname = $flag->{'name'};
                    if (!exists($flag->{'name'})) {
                        Log(0, "\nERROR: While parsing flags file");
                        Log(0, " at $url") if ($url ne '');
                        Log(0, ":\n");
                        if (exists($flag->{'regexp'})) {
                            Log(0, "       Flag with regular expression '".$flag->{'regexp'}."' has no name!\n");
                        } elsif (exists($flag->{'description'})) {
                            Log(0, "       Flag with description '".$flag->{'description'}."' has no name!\n");
                        } else {
                            Log(0, "       Flag with no name, regexp, or description found!\n");
                        }
                        $error++;
                    } else {
                        # If no example is supplied, copy the unmunged name to
                        # example and munge it as if it were a regexp (almost).
                        if (!exists($flag->{'example'})) {
                            $flag->{'example'} = $flag->{'name'};
                            if ($flag->{'example'} !~ s/^F-/-/i
                                    and $flag->{'class'} ne 'compiler') {
                                $flag->{'example'} = '-'.$flag->{'example'};
                            }
                            $flag->{'example'} =~ s/:/=/;
                        }

                        # Strip leading and trailing whitespace from the
                        # description, encode anything that might make an
                        # HTML validator unhappy (like ampersands), and surround
                        # it with <p>..</p> if it looks like there is _no_ markup
                        # present.
                        $flag->{'description'} =~ s/^\s+//s;
                        $flag->{'description'} =~ s/\s+$//s;
                        if ($flag->{'description'} !~ /[<>]/) {
                            $flag->{'description'} = "<p>\n".::escape_HTML($flag->{'description'})."\n</p>";
                        }

                        # If the XML has been validated, this error can't happen
                        if ($seen_ids{$flag->{'name'}}) {
                            Log(0, "\nERROR: While parsing flags file");
                            Log(0, " at $url") if ($url ne '');
                            Log(0, ":\n");
                            my $tmpcnt = $seen_ids{$flag->{'name'}};
                            Log(0, "       The flag name '$tmpname' is not unique! (".pluralize($tmpcnt + 1, 'occurrence').")\n");
                            Log(0, "       The post-conversion name is \"".$flag->{'name'}."\".\n");
                            Log(0, "       Perhaps they differ only in illegal characters?\n");
                            Log(0, "       (See section 3.1 of flag-description.html)\n");

                            $error++;
                        }
                        $seen_ids{$flag->{'name'}}++;
                    }
                    foreach my $inctype (qw(inc_flag inc_text)) {
                        if (exists($flag->{$inctype})
                            && (::ref_type($flag->{$inctype}) ne 'ARRAY')) {
                            Log(0, "\nERROR: While parsing flags file");
                            Log(0, " at $url") if ($url ne '');
                            Log(0, ":\n");
                            Log(0, "       Includes for flag named '".$flag->{'name'}."' is not an ARRAY\n");

                            $error++;
                        }
                    }

                    # If the flags file is valid, this error can not occur
                    if (exists($flag->{'inc_flag'}) && ::ref_type($flag->{'inc_flag'}) eq 'ARRAY') {
                        # Check that the referenced flags have descriptions
                        foreach my $incflagref (@{$flag->{'inc_flag'}}) {
                            if (::ref_type($incflagref) ne 'ARRAY') {
                                Log(0, "\nERROR: While parsing flags file");
                                Log(0, " at $url") if ($url ne '');
                                Log(0, ":\n");
                                Log(0, "       Flag included by name ($incflagref?) for flag named '".$flag->{'name'}."' is not an ARRAY\n");

                                $error++;
                                next;
                            }
                            my ($incflag, $flagtext) = @{$incflagref};
                            if (!exists($flagref->{'flagmap'}->{$incflag})) {
                                Log(0, "\nERROR: While parsing flags file");
                                Log(0, " at $url") if ($url ne '');
                                Log(0, ":\n");
                                Log(0, "       Flag \"$incflag\" referenced by '".$flag->{'name'}."' has no description!\n");

                                $error++;
                            }
                        }
                    }

                    # Make the default regexp, if necessary
                    if (!exists($flag->{'regexp'})) {
                        my $regexp = $tmpname;
                        # See flag-description.html#sect_3.3.1

                        # Step 1 (Fix up the initial portion)
                        if ($regexp !~ s/^F-/-/) {
                            # Step 2
                            if ($regexp !~ s/^f-/[-\/](?i)/) {
                                # Step 3
                                $regexp = '[-/]'.$regexp;
                            }
                        }

                        # Step 4a (Deal with the = problem)
                        $regexp =~ s/:/=/;

                        # Step 4b (add the args and match-value stuff)
                        if ($regexp !~ /=/) {
                            $regexp .= '(?:\([^\)]+\))?(?:=\S*)?';
                        }

                        # Step 5 (add the trailing delimiter)
                        # Use the more complex (but correct) lookahead.  "\b" is
                        # not used because of the case where this flag is a
                        # prefix of another _different_ flag where the first
                        # character after the prefix is a non-word character,
                        # as in "-falign-loops" and "-falign-loops-max-skip".
                        $regexp .= '(?=\s|$)';

                        # Step 6 (Ensure that it's not the tail end of
                        # another flag)
                        $regexp = '(?:^|(?<=\s))'.$regexp;

                        $flag->{'regexp'} = $regexp;
                        Log(95, "Created default regexp '$flag->{'regexp'}' for $flag->{'name'} in $url\n");
                    }

                    # Now that the regexp is guaranteed to exist, make sure that
                    # it's not nothing!
                    if ($flag->{'regexp'} eq '') {
                        Log(0, "\nERROR: While parsing flags file");
                        Log(0, " at $url") if ($url ne '');
                        Log(0, ":\n");
                        Log(0, "       Flag \"$tmpname\" has an empty regexp!\n");
                        $error++;
                    }

                    foreach my $req_attr (qw(class description)) {
                        if (!exists($flag->{$req_attr})) {
                            Log(0, "\nERROR: While parsing flags file");
                            Log(0, " at $url") if ($url ne '');
                            Log(0, ":\n");
                            Log(0, "       Flag named '".$flag->{'name'}."' has no $req_attr attribute!\n");
                            $error++;
                        } elsif ($flag->{$req_attr} eq '') {
                            Log(0, "\nERROR: While parsing flags file");
                            Log(0, " at $url") if ($url ne '');
                            Log(0, ":\n");
                            Log(0, "       Flag named '".$flag->{'name'}."' has an empty $req_attr attribute!\n");
                            $error++;
                        }
                    }

                    # Make sure that any compiler restrictions refer to actual
                    # defined compilers.
                    if (exists($flag->{'compilers'})) {
                        if ($flag->{'class'} eq 'compiler') {
                            Log(0, "\nERROR: While parsing flags file");
                            Log(0, " at $url") if ($url ne '');
                            Log(0, ":\n");
                            Log(0, "       The compiler flag named '".$flag->{'name'}."' has a 'compilers' attribute.\n");
                            Log(0, "       This will cause the flag to never match!\n");
                            Log(0, "       Flags in the 'compiler' class must not have compiler restrictions.\n");
                            $error++;
                        }

                        foreach my $compiler (split(/[,\s]+/, $flag->{'compilers'})) {
                            next if $compiler eq 'specpp';      # Implicit
                            if (!exists($flagref->{'flagmap'}->{$compiler})) {
                                Log(0, "\nERROR: While parsing flags file");
                                Log(0, " at $url") if ($url ne '');
                                Log(0, ":\n");
                                Log(0, "       Compiler restriction for \"".$flag->{'name'}."\" references\n");
                                Log(0, "         unknown compiler '$compiler'!\n");
                                $error++;
                            }
                            if (exists($flagref->{'flagmap'}->{$compiler}) &&
                                $flagref->{'flagmap'}->{$compiler}->{'class'} ne 'compiler') {
                                Log(0, "\nERROR: While parsing flags file");
                                Log(0, " at $url") if ($url ne '');
                                Log(0, ":\n");
                                Log(0, "       Compiler restriction for \"".$flag->{'name'}."\" references\n");
                                Log(0, "         flag '$compiler', which is not in the 'compiler' class!\n");
                                $error++;
                            }
                        }
                    }

                    my @unknown_attrs = grep { !/^(?:includes|addflag|name|regexp|description|class|compilers|precedence|example|ex_replacement|inc_flag|inc_text|display|parallel)$/o } keys %{$flag};
                    if (@unknown_attrs) {
                        Log(0, "\nWARNING: While parsing flags file");
                        Log(0, " at $url") if ($url ne '');
                        Log(0, ":\n");
                        Log(0, "         Flag named '".$flag->{'name'}."' has unknown attributes:\n");
                        Log(0, "             ".join(', ', @unknown_attrs)."\n");
                    }
                    # Add the origin of the flag, converting backslashes to slashes
                    $url =~ tr#\\#/#;
                    $flag->{'origin'} = [ $url, $source ];
                }

                # Fix up the filename, if present
                if (exists($flagref->{'filename'})) {
                    $flagref->{'filename'} = flag_filename_fixup($flagref->{'filename'});

                    # If it's empty, delete it.
                    if ($flagref->{'filename'} eq '') {
                        delete $flagref->{'filename'};
                    }
                }

                if ($error) {
                    undef $flagref;
                }

            }

            # Now that the hunk is parsed, merge it into what's come before
            if (defined($flagref)) {
                if (!merge_flags($flags, \$flagtext, $flagref, $flaginfo, $url)) {
                    Log(0, "\nERROR: Can't merge all flags files contained in\n       $url\n");
                    Log(0, "       The file's content will be ignored.\n");
                    return undef;
                }
            }
        }
    }

    return $flaginfo;
}

sub search_flags_byclass {
    my ($result, $class, $bench, $tune) = @_;

    return undef unless ::check_elem('HASH', $result, 'results');

    my @bench = (defined($bench) && $bench ne '') ? ($bench) : (keys %{$result->{'results'}});
    # Return true if there are any flags in $class in the result
    foreach my $bench (@bench) {
        next unless ::check_elem('HASH', $result, 'results', $bench);
        my @tunes = (defined($tune) && $tune ne '') ? ($tune) : (keys %{$result->{'results'}->{$bench}});
        foreach my $tune (@tunes) {
            next unless ::check_elem('HASH', $result, 'results', $bench, $tune, 'flags');
            if (exists($result->{'results'}->{$bench}->{$tune}->{'flags'}->{$class})) {
                ::Log(97, "Found \"$class\" flags for $bench:$tune\n");
                return 1;
            }
        }
    }
    return 0;
}

sub make_flag_id {
    my ($flag, $opttag, $text, $forceadd) = @_;
    return undef unless (::ref_type($flag) eq 'HASH');
    my $sum = '';
    if (!defined($text) || $text eq $flag->{'example'}) {
        # The default case should be no text
        $text = '';
    } else {
        $sum = ::scalardigest($text, 512);
    }
    my $origin = $flag->{'origin'}->[1];
    if ($origin eq 'user' || $origin eq 'suite' || $forceadd) {
        $opttag =~ tr/A-Za-z0-9:_/_/c;
        $origin .= "_$opttag" if defined($opttag) && $opttag ne '';
    }
    my $id = $origin.'_'.$flag->{'name'};
    $id .= "_$sum" if ($sum ne '');
    $id = "b$id" if $id !~ /^[A-Za-z:_]/;
    if (exists($flag->{'idcache'}) && (::ref_type($flag->{'idcache'}) eq 'HASH') &&
        exists($flag->{'idcache'}->{$text})) {
        # This is not for speed (otherwise it'd be farther up); it's for
        # consistency.  We'd use a sort of first-come-first-served approach to
        # handing out IDs, but that's dependent on the order in which the IDs
        # are requested, and they'll probably be different in each of the
        # formatters.
        return $flag->{'idcache'}->{$text.':'.$id};
    }
    $flag->{'idcache'}->{$text.':'.$id} = $id;
    return $id;
}

sub do_replacements {
    # Given a string and a list of values, replace $1, ... with the elements
    # of the list.  Backslash escapes are honored.
    my ($str, @repl) = @_;

    return $str unless defined($str) && $str ne '';

    $str =~ s/(?:\\(.)|(\$)\{?(\d+)\}?)/($2 eq '$') ? $repl[$3 - 1] : $1/eg;

    return $str;
}

sub merge_flags {
    my ($newtext, $oldtext, $newflags, $oldflags, $filename, $overwrite) = @_;
    $overwrite = 0 unless defined($overwrite);

    # Sometimes, as when using flags stored in a raw file, $filename is empty
    if (!defined($filename) || $filename eq '') {
        if ($newflags->{'filename'} ne '') {
            $filename = basename($newflags->{'filename'}, '.xml');
        } else {
            # Man, _this_ is arbitrary!
            my %seen_files = map { $_ => 1 } keys %{$oldflags->{'titles_by_file'}};
            $filename = $::suite.'_flags';
            if (exists($seen_files{$filename})) {
                my $count = 0;
                while (exists($seen_files{"${filename}.$count"})) {
                    $count++;
                }
                $filename = "${filename}.$count";
            }
        }
    }

    # Given a two sets of [text,flags], merge them together.  In cases where
    # there can be only one element (like filename), the first one wins.

    if (!defined($oldtext)  || $$oldtext eq '' ||
        !defined($oldflags)) {
        %{$oldflags} = %{$newflags};
        $$oldtext = $newtext;
        $oldflags->{'files_by_section'} = {};
        foreach my $item (qw(title filename style platform_settings
            submit_command sw_environment fdo_settings
            os_tuning virtual_machine firmware parts
            filelist),
            map { "header_$_" } keys %{$oldflags->{'header'}}) {
            $oldflags->{'files_by_section'}->{$item} = [ $filename ];
        }
        $oldflags->{'titles_by_file'}->{$filename} = $oldflags->{'title'};
        return 1;
    }

    # ***
    # First, the "hard" part (the data structure)
    # ***
    $oldflags->{'titles_by_file'}->{$filename} = $newflags->{'title'};
    push @{$oldflags->{'files_by_section'}->{'filelist'}}, $filename;

    # Deal with the title and filename (oldest gets to stay)
    foreach my $item (qw(title filename)) {
        if (!exists($oldflags->{$item}) || $oldflags->{$item} eq '') {
            $oldflags->{$item} = $newflags->{$item};
            $oldflags->{'files_by_section'}->{$item} = [ $filename ];
        }
    }

    # Append the various text strings
    foreach my $item (qw(style platform_settings submit_command
        sw_environment fdo_settings os_tuning
        virtual_machine firmware parts)) {
        if (exists($newflags->{$item}) && $newflags->{$item} ne '') {
            if (exists($oldflags->{$item})) {
                # Prepend header for current content, if necessary
                my $itemname = $item;
                $itemname =~ tr {_} { };
                if (@{$oldflags->{'files_by_section'}->{$item}} == 1) {
                    my $oldfile = $oldflags->{'files_by_section'}->{$item}->[0];
                    my $tmpstr = '';
                    if ($item eq 'style') {
                        # This is within <style>..</style>, so must be CSS-style
                        $tmpstr = "/* CSS section from $oldfile */\n";
                    } else {
                        # The current content came from one file, and was
                        # therefore not marked up.  That's about to change, so
                        # do the markup now.
                        $tmpstr = "<p>This result has been formatted using multiple flags files.\n   The \"$itemname\" from each of them appears next.</p>\n<hr />\n<h2>".ucfirst($itemname)." from $oldfile</h2>\n";
                        if ($oldflags->{'titles_by_file'}->{$oldfile} ne '') {
                            $tmpstr .= '<h4>'.$oldflags->{'titles_by_file'}->{$oldfile}."</h4>\n";
                        }
                    }
                    $oldflags->{$item} = $tmpstr.$oldflags->{$item};
                }
                if (@{$oldflags->{'files_by_section'}->{$item}} >= 1) {
                    if ($item eq 'style') {
                        # This is within <style>..</style>, so must be CSS-style
                        $oldflags->{$item} .= "/* CSS section from $filename */\n";
                    } else {
                        # Add the header for the next file, as there have been
                        # others before.
                        $oldflags->{$item} .= "<hr />\n<h2>".ucfirst($itemname)." from $filename</h2>\n";
                        if ($oldflags->{'titles_by_file'}->{$filename} ne '') {
                            $oldflags->{$item} .= '<h4>'.$oldflags->{'titles_by_file'}->{$filename}."</h4>\n";
                        }
                    }
                }
                $oldflags->{$item} .= $newflags->{$item};
                push @{$oldflags->{'files_by_section'}->{$item}}, $filename;
            } else {
                $oldflags->{$item} = $newflags->{$item};
                $oldflags->{'files_by_section'}->{$item} = [ $filename ];
            }
        }
    }

    # Deal with the headers
    foreach my $section (keys %{$newflags->{'header'}}) {
        if ($newflags->{'header'}->{$section} ne '') {
            if (exists($oldflags->{'header'}->{$section})) {
                # Prepend header for current content, if necessary
                my $itemname = $section.' header section';
                $itemname =~ s/^\s+//;
                if (@{$oldflags->{'files_by_section'}->{"header_$section"}} == 1) {
                    my $oldfile = $oldflags->{'files_by_section'}->{"header_$section"}->[0];
                    my $tmpstr = '';
                    # The current content came from one file, and was
                    # therefore not marked up.  That's about to change, so
                    # do the markup now.
                    $tmpstr = "<p>This result has been formatted using multiple flags files.\n   The \"$itemname\" from each of them appears next.</p>\n<hr />\n<h2>".ucfirst($itemname)." from $oldfile</h2>\n";
                    if ($oldflags->{'titles_by_file'}->{$oldfile} ne '') {
                        $tmpstr .= '<h4>'.$oldflags->{'titles_by_file'}->{$oldfile}."</h4>\n";
                    }
                    $oldflags->{'header'}->{$section} = $tmpstr.$oldflags->{'header'}->{$section};
                }
                if (@{$oldflags->{'files_by_section'}->{"header_$section"}} >= 1) {
                    # Add the header for the next file, as there have been
                    # others before.
                    $oldflags->{'header'}->{$section} .= "<hr />\n<h2>".ucfirst($itemname)." from $filename</h2>\n";
                    if ($oldflags->{'titles_by_file'}->{$filename} ne '') {
                        $oldflags->{'header'}->{$section} .= '<h4>'.$oldflags->{'titles_by_file'}->{$filename}."</h4>\n";
                    }
                }
                $oldflags->{'header'}->{$section} .= $newflags->{'header'}->{$section};
                push @{$oldflags->{'files_by_section'}->{'header_'.$section}}, $filename;
            } else {
                $oldflags->{'header'}->{$section} = $newflags->{'header'}->{$section};
                $oldflags->{'files_by_section'}->{'header_'.$section} = [ $filename ];
            }
        }
    }

    # Now for the flags.  Order is important, so go through the flags in the
    # 'flag' array.  Deep copy is not necessary.  Barf and return if a
    # name clash is found and $overwrite is not set.
    my $dupfound = 0;
    for my $flag (@{$newflags->{'flag'}}) {
        my $name = $flag->{'name'};
        if (exists($oldflags->{'flagmap'}->{$name})) {
            Log(0, "ERROR: Flag named '$name' in $filename clashes\n       with previously-read flag.\n");
            $dupfound++;
        }
    }
    if ($dupfound && !$overwrite) {
        Log(0, "ERROR: Found $dupfound duplicate flags in $filename\n");
        return 0;
    }
    # No dups found, so actually do the copy
    for my $flag (@{$newflags->{'flag'}}) {
        my $name = $flag->{'name'};
        push @{$oldflags->{'flag'}}, $flag;
        $oldflags->{'flagmap'}->{$name} = $flag;
    }

    # 'hash' will be handled after the text files are merged

    # ***
    # Second, the easy part (the text file)
    # ***

    # Since parse_flags and friends can now handle multiple flags files in
    # one stream, just append the new stuff to the old stuff:
    $$oldtext .= "\n".$newtext;

    $oldflags->{'hash'} = ::scalardigest($$oldtext, 512);

    return 1;
}

sub validate_xml {
    my ($url, $position, $flags, $suitever) = @_;

    # Run $flags through specrxp (if present), and return any errors

    # Figure out where the top is, so the path to the DTD can be fixed
    # on-the-fly (for avoiding network access)
    my $top;
    if (defined($::global_config) && (::ref_type($::global_config) eq 'HASH')) {
        $top = $::global_config->top;
    } else {
        # Must be running from flag_dump; just don't validate
        return 'not_validated';
    }

    my $dtd;
    if ($suitever eq 'select') {
        # Try to get the DTD filename from the flag text
        ($dtd) = ($flags =~ m#http://www.spec.org/dtd/(cpuflags\d.dtd)#);
        # Set it to the latest if it doesn't look right
        $dtd = 'cpuflags2.dtd' unless ($dtd =~ /^cpuflags/);
    } elsif ($::lcsuite eq 'mpi2007') {
        # Use the old DTD for MPI2007
        $dtd = 'cpuflags1.dtd';
    } else {
        $dtd = 'cpuflags2.dtd';
    }
    # Make it a full path
    my $dtd_path = ::jp($top, 'Docs', 'flags', $dtd);
    if (!-r $dtd_path) {
        Log(0, "\nERROR: The DTD used to validate flags files is not present.\n");
        Log(0, "       This file is normally found at \"$dtd\";\n");
        Log(0, "       Please make sure it is present before attempting to use a flags file\n");
        Log(0, "       again.\n");
        return undef;
    }
    $dtd_path = 'file://'.$dtd_path;
    if ($flags !~ m#http://www.spec.org/dtd/$dtd#) {
        $flags =~ m#http://www.spec.org/dtd/([^"]+)#;
        Log(0, "\n\nERROR: The DTD specified by the flags file at $url\n");
        Log(0, "       is not the same as the one used to validate flags files.\n");
        Log(0, "       The flags file specifies \"$1\";\n");
        Log(0, "       the correct DTD to use is \"$dtd\".\n");
        Log(0, "       Please correct the flags file before attempting to use it again.\n");
        return undef;
    }

    # Check to see if specrxp is present
    my $rxp = undef;
    foreach my $try (qw(specrxp specrxp.exe)) {
        if (-x ::jp($top, 'bin', $try)) {
            $rxp = ::jp($top, 'bin', $try);
            last;
        }
    }
    if (!defined($rxp)) {
        Log(0, "\nWARNING: Your toolset does not contain specrxp (or it is not executable);\n");
        Log(0, "       the flags file at $url\n");
        Log(0, "       will not be strictly validated.\n");
        Log(0, "Please get an updated toolset.\n\n");
        return 'no_rxp';
    }


    # Make a temporary directory to store the flags file in.  Doing bidir
    # pipes is a pain, and so I choose to capture the output.
    my $tempdir = ::get_tmp_directory($::global_config, 0);
    if (!(-d $tempdir && -w $tempdir)) {
        # I asked for it to not be created so that if it _couldn't_ be
        # created we could fall back
        eval { mkpath($tempdir) };
        if ($@ || !-w $tempdir) {
            # First choice failed (as it may in a read-only tree before the
            # config file is read).  $SPEC/config is guaranteed to be writable,
            # so use that.
            $tempdir = ::jp($top, 'config');
            eval "\$tempdir = tempdir( 'xmlcheck_XXXXX',
                                       DIR => \$tempdir,
                                       CLEANUP => 1 );";
            if ($@) {
                Log(0, "ERROR: A temporary directory could not be created under $tempdir\n");
                return undef;
            }
        }
    }

    # Write the file to be tested to a temporary file
    my ($fh, $fn) = tempfile( 'flags_XXXXX', DIR => $tempdir );
    if (!defined($fh)) {
        Log(0, "ERROR: A temporary file could not be opened for writing: $!\n");
        return undef;
    }

    # Fix up the DTD location to point to the local copy
    if ($^O =~ /MSWin/) {
        # Hide the drive letter spec
        $dtd_path =~ s#^file://([A-Z]:[\\/])#file:///$1#;
        # rxp doesn't like backslashes in paths
        $dtd_path =~ tr#\\#/#;
    }
    $flags =~ s#http://www.spec.org/dtd/cpuflags\d.dtd#$dtd_path#g;

    $fh->print($flags);
    $fh->close();

    if (!-r $fn) {
        Log(0, "ERROR: The temporary file just written has vanished!\n");
        return undef;
    }

    # Okay, finally run rxp
    if ($^O =~ /MSWin/) {
        # Hide the drive letter spec.  RXP doesn't remember the bad old days
        # of DOS drive letters, so it treats anything with letters followed by
        # a colon as a protocol specifier.
        $fn =~ s#^([A-Z]:\\)#file:///$1#;
        # Yep, backslashes again
        $fn =~ tr#\\#/#;
    }
    my $out = qx{$rxp -V -V -s $fn 2>&1};

    if ($?) {
        # Oops...an error!
        my ($rc, $sig) = (WEXITSTATUS($?), WTERMSIG($?));
        if ($out eq '') {
            # Not likely...
            $out  = "$rxp exited with return code $rc";
            $out .= " (signal $sig)" if ($sig);
            $out .= "\n";
        } else {
            # Fix up the temporary filenames
            $out =~ s# of file://\Q$fn\E##gs;
        }
    } else {
        $out = '';      # It should be this anyway, but just in case...
    }

    # Make sure there are no leavings
    $fn =~ s#^file:///##;  # Undo Windows damage above
    my $rc = unlink $fn;
    my $count = 5;
    while ($count >= 0 and (-e $fn)) {
        sleep 0.5;
        $rc = unlink $fn;
        $count--;
    }
    File::Temp::cleanup();      # Remove the temp files
    return $out;
}

sub one_match {
    my ($flag, $thing, $quiet) = @_;

    my $s = new Safe 'retmp';
    if ($^V ge v5.10.0) {
        $s->permit(qw(:load entereval sort print));
    } else {
        $s->deny_only('entereval'); # Deny eval-based regexp stuff
    }
    $s->share('utf8::SWASHNEW');
    ${$s->varglob('re')} = $flag->{'regexp'};
    ${$s->varglob('thing')} = $thing;

    my ($matched, $leftovers, @replacements) = $s->reval(q%
    #-----------------------------------------------------------------------------
        no re 'eval'; # The default, but just in case

        my $flag = undef;
        my @replacements = ();
        # This is the same thing as in flags_list in formatter/flagutils.pl.
        # If I could get it inlined, I would, because when I break it out into a
        # sub there's a noticeable performance degradation (in flags_list, not
        # here).
        if ($thing =~ s/($re)//) {
            no strict 'refs';
            $flag = $1;
            # Loop to add all captured groups
            # to the list of values to return
            for(my $i = 2; $i <= $#+; $i++) {
                push @replacements, ${$i};
            }
        }
        return ($flag, $thing, @replacements);
    #-----------------------------------------------------------------------------
    %);
    if ($@) {
        Log(0, "ERROR: While attempting to match $flag->{'name'} to \"$thing\";\n  the compartment returned:\n        $@\n\n");
        return ();
    }
    if (!$quiet) {
        if ($leftovers eq $thing) {
            Log(0, "WARNING: Failed match for $flag->{'name'} to \"$thing\".\n  It is possible that this is due to an incorrect flagtext attribute, or\n    the regular expression for $flag->{'name'} may need to be adjusted.\n\n");
            return ();
        } elsif ($leftovers !~ /^\s*$/) {
            Log(0, "WARNING: Incomplete match for $flag->{'name'} to \"$thing\";\n  the leftovers were \"$leftovers\"\n\n");
        }
        if ($thing !~ /^\Q$matched\E$/) {
            Log(0, "Notice: Text matched ($matched) is not contained in original\n  text ($thing).\n\n");
        }
    }
    return @replacements;
}

sub flag_filename_fixup {
    my ($filename) = @_;

    # Trim off unwanted extensions
    $filename =~ s/(?:\.(?:x|ht)ml)+$//i;

    # Remove apostrophes altogether (Cloyce's => Cloyces);
    # they look strange when converted to underscores
    $filename =~ s/\'//g;

    # Convert non-shell-friendly characters to underscores
    $filename =~ tr {a-zA-Z0-9._-} {_}c;

    # Try to get rid of date stamps and any preceeding
    # separators
    my $monthre = qr/(?:
                     jan(?:uary)?       |
                     feb(?:ruary|uary)? |
                     mar(?:ch)?         |
                     apr(?:il)?         |
                     may                |
                     june?              |
                     july?              |
                     aug(?:ust)?        |
                     sept?(?:ember)?    |
                     oct(?:ober)?       |
                     nov(?:ember)?      |
                     dec(?:ember)?
                     )/xi;
    my @datere = (
        qr/\d{4}[._-]?\d{2}[._-]?\d{2}/,  # 20070419
        qr/\d{2}[._-]?\d{2}[._-]?\d{2}/,  # 041907
        qr/\d{2}[._-]?$monthre[._-]?\d{4}/i,  # 19 Apr 2007
        qr/\d{2}[._-]?$monthre[._-]?\d{2}/i,  # 19 Apr 07
        qr/$monthre[._-]?\d{2}[._-]+\d{4}/, # Apr 19 2007
        qr/$monthre[._-]?\d{2}[._-]+\d{2}/, # Apr 19 07
        qr/file/i,  # Yes, we know it's a file
    );
    foreach my $re (@datere) {
        # Eliminate ones with a leading separator
        $filename =~ s/[._-]$re//g;
        # ...and ones with a trailing separator
        $filename =~ s/$re[._-]//g;
        # ...and ones without any separator
        $filename =~ s/$re//g;
    }

    # Now lose leading and trailing separators and underscores
    $filename =~ s/^[._-]+//;
    $filename =~ s/[._-]+$//;

    return $filename;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
