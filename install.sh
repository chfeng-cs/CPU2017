#!/bin/sh

#
#  install.sh - installs the full benchmark tree or just the tools binaries
#  Copyright 1998-2019 by Standard Performance Evaluation Corporation
#
#  Authors:  Christopher Chan-Nui, Cloyce D. Spradling
#
# $Id: install.sh 6137 2019-04-10 03:19:22Z CloyceS $
#

SUITE=cpu2017
UCSUITE=CPU2017

if [ "x$TRIED" = x ]; then
    tput clear
    echo "SPEC $UCSUITE Installation"
fi

# install.sh requires a shell that understands $(...) instead of `...` and
# has getopts as a built-in function.  The former is pure POSIX and the latter
# is common in shells found in the mid-'90s and later.
# Ensure that we've got one such -- at least some common /bin/sh (as on Solaris 10)
# don't qualify.
shtest=`eval 'echo $(echo works)' 2>/dev/null`
if [ "$shtest" != "works" -o "0$OPTIND" = "0" ]; then
    if [ "x$TRIED" = x ]; then
        echo
        echo $0 requires a POSIXish shell... looking for one now
    fi
    for shdir in /usr/bin /bin; do
	for trysh in bash zsh ksh93 ksh88 ksh posix/sh; do
	    echo "$TRIED" | grep ":$shdir/${trysh}:" >/dev/null
	    if [ $? -ne 0 -a -x $shdir/$trysh ]; then
		if $shdir/$trysh -c 'echo $(echo usable && [ "0$OPTIND" = "0" ] || echo getopts)' 2>/dev/null | grep usable.getopts >/dev/null; then
		    echo ...trying $shdir/$trysh
		    TRIED="${TRIED}:$shdir/${trysh}:"
		    export TRIED
		    exec $shdir/$trysh $0 $*
		fi
	    fi
	done
    done

    # If we reach this point, all hope is lost
    echo
    echo "No usable shell found; installation aborted."
    echo
    exit 1
fi
echo

CURDIR=$(pwd)

if test -n "${ZSH_VERSION+set}"; then
    # ZSH has different (arguably, better) word splitting semantics than
    # bash/ksh.  See http://zsh.sourceforge.net/FAQ/zshfaq03.html for details.
    # In the interest of portability, we'll do it everyone else's way...
    setopt SH_WORD_SPLIT
    # Also, make glob failures non-fatal; this is necessary for tools
    # extraction.
    setopt NONOMATCH
fi

is_spec_dir() {
    [ "x$1" != "x" ] \
    && [ -d "$1/tools/bin"          ] \
    && [ -x "$1/bin/harness/runcpu" ]
}

uninstall_previous() {
    # UNinstall previously installed tools.  This might not get everything,
    # but it'll get everything that might not be overwritten by the next
    # installation.
    if [ "x$1" != "x" ]; then
        if [ -n "$2" -a -d $1/tools/bin/$2 -a -f $1/tools/bin/$2/tools-$2.tar.xz ]; then
            (cd "$1"; ./tools/bin/$2/specxz -dc tools/bin/$2/tools-$2.tar.xz | tools/bin/$2/spectar -tf - | grep bin/ | xargs rm -f)
        fi
        if [ -f "$1/TOOLS.sha512" ] && [ $(cat $1/TOOLS.sha512 | wc -l) -gt 10 ]; then
            (cd "$1"; awk '/bin\//{print $4}' TOOLS.sha512 | xargs rm -f)
        fi

        # At this point bin/lib should be empty, but just to be sure...
        rm -rf "$1/bin/lib"
        rm -f "$1/bin/packagename"
        rm -f "$1/SUMS.tools"
        rm -f "$1/TOOLS.sha512"
        # Clean up any cores that may have been left around
        rm -f "$1"/core*
    fi
}

check_manifest() {
    # Given a manifest file, a top dir, and an exclude pattern, verify the
    # contents of the files.
    manifest="$1"
    topdir="$2"
    exclude_pat="$3"
    if [ "x$manifest" = "x" ]; then
        errors="${errors}check_manifest: No manifest file specified
"
    elif [ ! -f $manifest ]; then
        errors="${errors}$manifest does not exist!
"
    elif [ "x$topdir" = "x" ]; then
        errors="${errors}check_manifest: No topdir specified
"
    elif [ ! -d $topdir ]; then
        errors="${errors}check_manifest: $topdir is not a directory!
"
    else
        echo
        echo "Checking the integrity of your source tree..."
        echo
        cat "$manifest" > "$topdir/MANIFEST.tmp.$$"

        # Filter out errors due to newly-rebuilt tools packages
        if [ -d "$topdir/tools/bin" -a ! -d "$topdir/tools/output" ]; then
          for i in $(cd "$topdir"; find tools/bin -name unbundled -print); do
            grep -v $(dirname "$i") "$topdir/MANIFEST.tmp.$$" > "$topdir/manifest.tmp.$$.1"
            cat "$topdir/manifest.tmp.$$.1" > "$topdir/MANIFEST.tmp.$$"
            rm -f "$topdir/manifest.tmp.$$.1"
          done
        else
          # This can happen when installing from ISO
          grep -v ' tools/bin/' "$topdir/MANIFEST.tmp.$$" > "$topdir/manifest.tmp.$$.1"
          cat "$topdir/manifest.tmp.$$.1" > "$topdir/MANIFEST.tmp.$$"
          rm -f "$topdir/manifest.tmp.$$.1"
        fi

        # Filter out names that were not unpacked
        for i in install_archives/ redistributable_sources/ $exclude_pat; do
          cat "$topdir/MANIFEST.tmp.$$" | grep -v " $i" > "$topdir/manifest.tmp.$$.1"
          cat "$topdir/manifest.tmp.$$.1" > "$topdir/MANIFEST.tmp.$$"
          rm -f "$topdir/manifest.tmp.$$.1"
        done

        # Don't do the grep -v ': OK' here because grep will exit successfully
        cat "$topdir/MANIFEST.tmp.$$" | grep -v '/ORIG$' | (cd "$topdir"; $SUMPROG -e -c - 2>&1) > "$topdir/manifest.check.$$"
        sumrc=$?
        rm -f "$topdir/MANIFEST.tmp.$$"
        cat "$topdir/manifest.check.$$" | grep -v ': OK$' > "$topdir/manifest.errors.$$"
        if [ $sumrc -ne 0 ]; then
            # Something made $SUMPROG unhappy
            if [ $(cat "$topdir/manifest.errors.$$" | wc -l) -le 0 ]; then
                # The reason wasn't reported, so say SOMETHING
                echo ERROR: $(basename $SUMPROG) exited with exit code $sumrc >> "$topdir/manifest.errors.$$"
            fi
        fi
        if grep ':' "$topdir/manifest.errors.$$"; then
            if [ -d "$topdir/tools/output" ]; then
              # The tools have just been built, so some failures are expected
              echo
              echo "Integrity check failed.  Some failures are to be expected after"
              echo "building the tools, as the build process modifies some files in the"
              echo "distribution."
            else
              # If we set errors, the install will stop before installing binaries
              errors="${errors}
"
            fi
        else
            echo "Checksums are all okay."
            echo
        fi
        rm -f "$topdir/manifest.check.$$" "$topdir/manifest.errors.$$"
    fi
}

mkdir_p() {
  if [ ! -d "$1" -a "x$1" != "x" -a "x$1" != "x/" -a "x$1" != "x." ]; then
    if [ ! -d $(dirname "$1") ]; then
      mkdir_p $(dirname "$1")
    fi
    if [ -d $(dirname "$1") ]; then
      # No point in trying if the previous failed
      try="$try
"$(mkdir "$1" 2>&1)
    fi
  fi
}

test_spectarget_candidate() {
    try=
    if echo "$SPECTARGET" | grep '[ 	]' >/dev/null; then
        echo
        echo ERROR: The destination path contains whitespace or escape characters.
        echo
        SPECTARGET=
        return
    fi
    mkdir_p $SPECTARGET
    if [ ! -d "$SPECTARGET" ]; then
        echo
        echo "Couldn't make $SPECTARGET; output from mkdir was"
        echo "$try"
        echo
        SPECTARGET=
    fi
    if [ -n "$SPECTARGET" ]; then
        if touch "$SPECTARGET/test.$$" 2> /dev/null; then
            rm "$SPECTARGET/test.$$"
        else
            echo
            echo "Can't create files in $SPECTARGET"
            echo
            SPECTARGET=
        fi
    fi
}

test_arch_tools() {
    _foundone=0
    if [ -x "$SPEC/tools/bin/$1/specxz" ]                        \
         && "$SPEC/tools/bin/$1/specxz" -h > /dev/null 2>&1      \
         && [ -x "$SPEC/tools/bin/$1/spectar" ]                  \
         && "$SPEC/tools/bin/$1/spectar" --help > /dev/null 2>&1 \
         && [ -x "$SPEC/tools/bin/$1/specsha512sum" ]            \
         && "$SPEC/tools/bin/$1/specsha512sum" --help > /dev/null 2>&1; then
        _foundone=1
    fi
    if [ $_foundone -eq 0 ]; then
        if [ -d "$SPEC/tools/bin/$1" ]; then
            error="${error}'$1' does not appear to be executable on this machine.
";
        else
            error="${error}Tools for '$1' do not exist.
";
        fi
        false
    else
        true
    fi
}

clear=$(tput clear)

# We want everything to be world readable
umask 022

# Variables to not inherit
SPEC_FORCE_INSTALL=
SPEC_IGNORE_SPEC=
SPECTARGET=
SELECTED_TOOLSET=0
arch=

# Parse the command-line arguments, if any
while getopts hfie:u:d:r opt; do
  case $opt in
    e)  SPEC_DONT_TELL="$SPEC_DONT_TELL,$OPTARG,"
      ;;
    u)  arch=$OPTARG
        SELECTED_TOOLSET=1
      ;;
    d)  SPECTARGET=$OPTARG
      ;;
    f)  SPEC_FORCE_INSTALL=1
      ;;
    i)  SPEC_IGNORE_SPEC=1
      ;;
    r)  SPEC_NO_RELOCATE=1
      ;;
    h | \?) cat<<EOU

Usage: $0 [-e toolset,...] [-d dest_dir] [-u toolset]
  -e toolset,...          List names of toolsets to _NOT_ use
  -u toolset              Specify the name of the toolset to use
  -d dest_dir             Specify the destination directory for installation
  -i                      Ignore current setting for \$SPEC (if any)
  -f                      Perform non-interactive installation if possible

EOU
        exit
      ;;
  esac
done
shift $(($OPTIND - 1))

# Set the locale, if it isn't already set and the user hasn't forbidden it
if [ -z "$SPEC_INSTALL_LOCALE_OK" ]; then
    if [ -z "$LC_ALL" -o -z "$LC_LANG" ]; then
        LC_ALL=C
        LC_LANG=C
        export LC_ALL LC_LANG
    fi
fi

# Set some flags for later
if [ "$VERBOSE" = 1 -o "$VERBOSE" = 'y' -o "$VERBOSE" = 'yes' ]; then
    SPEC_INSTALL_VERBOSE=-v
else
    SPEC_INSTALL_VERBOSE=
fi

# Find top of SPEC heirarchy
if [ -n "$SPEC" ] ; then
    if is_spec_dir "$SPEC" && [ -z "$SPEC_IGNORE_SPEC" ]; then
        if [ "$SPEC" != $(pwd) ]; then
            echo "The SPEC environment variable is already set to \"$SPEC\","
            echo "which does not match the current directory (\"$(pwd)\")."

            if [ -z "$SPEC_FORCE_INSTALL" ]; then
                echo "If you continue with the installation, the tools will be installed"
                echo "from \"$SPEC\" and possibly also into that directory."
                echo "Is this the desired behavior? (Please enter 'yes' or 'no') "
                read ans
                ans=$(echo $ans | tr YESNO yesno)
                if [ "$ans" = 1 -o "$ans" = 'y' -o "$ans" = 'yes' ]; then
                    true
                else
                    echo
                    echo "Okay, ignoring your environment setting of \$SPEC."
                    echo "Installation source and destination locations will be determined"
                    echo "automatically, and you will have a chance later to accept those choices or"
                    echo "abort the install."
                    echo
                    SPEC=
                fi
            else
                echo
                echo "Non-interactive installation specified; continuing with current value of \$SPEC."
                echo
            fi
        fi
    else
        SPEC=
    fi
fi
if [ -z "$SPEC" ]; then
    SPEC=$(pwd)
    while [ -n "$SPEC" ]; do
        if is_spec_dir "$SPEC"; then
            break;
        fi
        if [ "$SPEC" != "." ]; then
          # At least some vendors' /bin/sh doesn't like this substitution
          #SPEC=${SPEC%/*}
          # Everyone should still have sed
          SPEC=$(echo $SPEC | sed -e 's/\/[^\/]*$//')
        else
          SPEC=
        fi
    done
fi
if [ -z "$SPEC" ]; then
    SPEC=$(dirname "$0")
    while [ -n "$SPEC" ]; do
        if is_spec_dir "$SPEC"; then
            break;
        fi
        if [ "$SPEC" != "." ]; then
          # At least some vendors' /bin/sh doesn't like this substitution
          #SPEC=${SPEC%/*}
          # Everyone should still have sed
          SPEC=$(echo $SPEC | sed -e 's/\/[^\/]*$//')
        else
          SPEC=
        fi
    done
fi
if [ -z "$SPEC" ]; then
    echo
    echo "Can't find the top of your $UCSUITE tree!  Please change to the benchmark"
    echo "directory and run this program ($0) again!"
    exit 1
fi
echo "Top of the $UCSUITE tree is '$SPEC'"

if cd "$SPEC" ; then
    true
else
    echo
    echo "Huh?  Can't cd into $UCSUITE directory '$SPEC'"
    exit 1
fi

# Make sure that things on the CD/DVD can be executed, or the tools install
# will fail mysteriously.

if [ ! -f "$SPEC/bin/scripts.misc/exec_test" ]; then
  echo
  echo
  echo ERROR:
  echo The bin subdirectory of $SPEC is missing a file.
  echo Installation cannot proceed.
  echo
  exit 1
fi

exectest=$("$SPEC/bin/scripts.misc/exec_test" 2>/dev/null)

if [ $? -eq 0 ]; then
  if [ "$exectest" = "yes" ]; then
      CANEXEC=yes
  elif echo "$exectest" | grep yes >/dev/null 2>&1; then
      CANEXEC=yes
  else
      CANEXEC=maybe
  fi
else
  echo
  echo
  echo ERROR:
  echo Programs in $SPEC cannot be executed.
  echo 'Is this volume mounted with the "noexec" flag?'
  echo Tools installation will not be able to proceed until this is rectified.
  echo
  exit 1
fi

if [ "x$SPECTARGET" != "x" ]; then
    test_spectarget_candidate
fi

if [ -z "$SPECTARGET" ]; then
    if touch a 2> /dev/null; then
        rm a
        SPECTARGET=$SPEC
    fi
fi

if echo "$SPECTARGET" | grep '[ 	]' >/dev/null; then
    echo
    echo ERROR: The destination path contains whitespace.
    echo
    SPECTARGET=
fi

if [ -z "$SPEC_FORCE_INSTALL" ]; then
    while [ -z "$SPECTARGET" ]; do
        echo "Enter the directory you wish to install to (e.g. /usr/$SUITE)"
        read SPECTARGET
        if [ "x$SPECTARGET" = "x." ]; then
          SPECTARGET="$CURDIR"
          echo Attempting to install to $SPECTARGET
        fi
        test_spectarget_candidate
    done
elif [ -z "$SPECTARGET" ]; then
    echo
    echo Installation directory could not be automatically determined, and
    echo non-interactive installation was specified.  Aborting now.
    echo
    exit 1
fi

echo
echo "Installing FROM $SPEC"
echo "Installing TO $SPECTARGET"
echo
if [ -z "$SPEC_FORCE_INSTALL" ]; then
    echo "Is this correct? (Please enter 'yes' or 'no') "
    ans=
    read ans
    ans=$(echo $ans | tr YESNO yesno)
    while [ "$ans" != 1 -a "$ans" != 'y' -a "$ans" != 'yes' -a \
            "$ans" != 0 -a "$ans" != 'n' -a "$ans" != 'no' ]; do
      echo "Please enter 'yes' or 'no'"
      read ans
      ans=$(echo $ans | tr YESNO yesno)
    done
    if [ "$ans" = 0 -o "$ans" = 'n' -o "$ans" = 'no' ]; then
      echo "Installation aborted."
      echo
      echo "install.sh supports setting the destination directory directly."
      echo "Please run 'install.sh -h' for details."
      echo
      exit;
    fi
fi

# Clean up the installation if the user aborts
trap 'echo Attempting to remove tools installation...; uninstall_previous $SPECTARGET' 2 15

valid_archs=
archcount=0
if [ -z "$arch" ]; then
    mach=$(uname -m 2>/dev/null | sed 's/\./\\./g')
    os=$(uname -s 2>/dev/null | sed 's/\./\\./g')
    rev=$(uname -r 2>/dev/null | sed 's/\./\\./g')
    proc=$(uname -p 2>/dev/null | sed 's/\./\\./g')
    for order in $(cat $SPEC/tools/bin/*/order | sort -r -n); do
        tmparch=$(echo $order | sed 's/^[0-9]*://' | tr -d '\r\n')
        if [ -z "$tmparch" ]; then continue; fi
        if [ ! -d "$SPEC/tools/bin/$tmparch" ]; then
            echo
            echo
            echo "ERROR: The contents of one of the tools order files does not"
            echo "       match its associated toolset; tools/bin/$tmparch is"
            echo "       not a directory."
            echo
            echo
            exit 1
        fi
        tmparch=$(basename $tmparch | sed 's/\/$//')
        if [ -n "$mach" -a -n "$os" -a -f "$SPEC/tools/bin/$tmparch/excludearch" ] &&
             grep -i "$mach" "$SPEC/tools/bin/$tmparch/excludearch" >/dev/null 2>&1 ||
             grep -i "$os" "$SPEC/tools/bin/$tmparch/excludearch" >/dev/null 2>&1; then
            # The machine type or OS name was listed in excludearch;
            # don't try running binaries on this system
            true
        elif [ -n "$rev" -a -f "$SPEC/tools/bin/$tmparch/excluderev" ] &&
               grep -i "^$rev\$" "$SPEC/tools/bin/$tmparch/excluderev" >/dev/null 2>&1; then
            # The OS revision was listed in excluderev;
            # don't try running binaries on this system
            true
        elif [ -n "$proc" -a -f "$SPEC/tools/bin/$tmparch/excludeproc" ] &&
               grep -i "^$proc\$" "$SPEC/tools/bin/$tmparch/excludeproc" >/dev/null 2>&1; then
            # The processor architecture was listed in excludeproc;
            # don't try running binaries on this system
            true
        elif [ -n "$SPEC_DONT_TELL" ] &&
              echo $SPEC_DONT_TELL | grep -i ",$tmparch," >/dev/null 2>&1; then

            # The user wishes to not see this toolset.
            true
        elif test_arch_tools $tmparch; then
            if [ -n "$valid_archs" ]; then
              valid_archs="$tmparch $valid_archs"
            else
              valid_archs="$tmparch"
            fi
            archcount=$(($archcount + 1))
        fi
    done
fi

error=
if [ -n "$arch" ]; then
    test_arch_tools $arch
    if [ $? -ne 0 ]; then
        echo "$error"
        echo
        echo The specified toolset is not usable.  Aborting installation.
        exit 1
    else
        valid_archs=$arch
    fi
fi
if [ -z "$arch" -a -n "$valid_archs" ]; then
    if [ $archcount -gt 1 ]; then
      plural='s are'
    else
      plural=' is'
    fi
    echo
    echo "The following toolset$plural expected to work on your platform.  If the"
    echo "automatically installed one does not work, please re-run install.sh and"
    echo "exclude that toolset using the '-e' switch."
    echo
    echo "The toolset selected will not affect your benchmark scores."
    echo
    for i in $valid_archs; do
      descfile="$SPEC/tools/bin/$i/description"
      if [ -f "$descfile" ]; then
        printf "%-29s %s\n" $i "$(head -1 "$descfile")"
        if [ $(cat "$descfile" | wc -l) -gt 1 ]; then
          sed -ne '2,$p' "$descfile"
        fi
      else
        echo "$i"
      fi
      echo ""
    done
    echo "${error}"
fi

insterrors=
for arch in $valid_archs ""; do
  errors=
  archcount=$(($archcount - 1))

  if [ -n "$arch" ]; then
      echo
      echo "================================================================="
      echo "Attempting to install the $arch toolset..."
      echo
  fi

  # Set up the excludes for the installation.
  EXCLUDE=
  EXCLUDE_PAT=config/

  echo ""
  if [ -z "$arch" ]; then
      if [ -z "$valid_archs" ]; then
          # No previous messages
          echo "${clear}"
      else
          echo
      fi
      if [ "$CANEXEC" = "maybe" ]; then
          echo "No working toolsets could be found for this system.  This"
          echo "may be because programs cannot be executed from the install"
          echo "media, as when the \"noexec\" mount flag is used."
          echo "If that is the case, please re-mount the installation media"
          echo "with exec permission enabled and re-run install.sh."
          echo
          echo "Otherwise, if we really do not have working vendor-supplied binaries"
          echo "for this system, you may need to compile the tool binaries"
      elif [ "$SELECTED_TOOLSET" -eq 1 ]; then
          echo "The toolset you selected is not fully functional on this system."
          echo
          echo "Please select a different toolset or allow the installer to work"
          echo "through the list of candidates itself."
          echo
          echo "In the unlikely event that there is no working"
          echo "vendor-supplied toolset, you may need to build one"
      else
          if [ "x$insterrors" != "x" ]; then
              echo
              echo "Error running runcpu tests.  See the following file(s) for details about"
              echo "tests that failed, if no other toolset installs successfully:"
              for try in $insterrors; do
                echo "$try"
              done
              echo
          fi

          echo "We do not appear to have working vendor-supplied binaries for your"
          echo "architecture.  You will have to compile the tool binaries by"
      fi
      echo "yourself.  Please read the file"
      echo ""
      echo "    $SPEC/Docs/tools-build.html"
      echo ""
      echo "for instructions on how you might be able to build them."
      echo
      echo "Please only attempt this as a last resort."
      echo
      exit 1
  elif [ -z "$SPEC_INSTALL_TOOLS_SRC" ]; then
      EXCLUDE="$EXCLUDE --anchored --exclude=tools/src/"
      EXCLUDE_PAT="$EXCLUDE_PAT tools/src/"
  fi

  UNCOMPRESS="\"$SPEC/tools/bin/$arch/specxz\" -d"
  TAR="\"$SPEC/tools/bin/$arch/spectar\" $EXCLUDE"

  # Install things here
  # Here's a part where we try to unpack a tarball that lives in install_archives
  # on the installation media.  If it's not found, it's not necessarily fatal;
  # this situation could arise when running install.sh to install tools
  # binaries in a benchmark tree that has already been unpacked.
  errors=
  if [ "$SPEC" != "$SPECTARGET" -o ! -d "$SPEC/benchspec" -o ! -d "$SPEC/bin" ]; then
      if [ -n "$SPEC_USE_UNIFIED" -o ! -f "$SPEC/install_archives/release_control" ]; then
        SOC=
        for i in "$SPEC/install_archives/${SUITE}.tar.xz" "$SPEC/install_archives/${SUITE}.tar.xz\;1"; do
            if [ -f $i ]; then
                SOC=$i
                break
            fi
        done

        if [ -z "$SOC" ]; then
            errors="Can't find $SPEC/install_archives/${SUITE}.tar.xz file"
        elif [ -z "$errors" ]; then
            echo "Unpacking $UCSUITE archive..."
            if eval $UNCOMPRESS < "$SOC" | \
                  (cd "$SPECTARGET" ; eval $TAR $SPEC_INSTALL_VERBOSE -xf -) ; then
                true
                echo "Done unpacking $UCSUITE archive."
            else
                errors="Error extracting the $UCSUITE archive."
            fi
        fi
      else
        # Unpack the individual tarballs according to the release_control file
        cat "$SPEC/install_archives/release_control" | \
        while read file csize usize desc; do
          if [ -f "$SPEC/install_archives/benchball/$file" ]; then
              echo "Unpacking $desc ($usize MB)"
              if eval $UNCOMPRESS < "$SPEC/install_archives/benchball/$file" | \
                      (cd "$SPECTARGET" ; eval $TAR $SPEC_INSTALL_VERBOSE -xf -) ; then
                  true
              else
                  errors="${errors}Error unpacking the $file archive!
    "
              fi
          else
            errors="${errors}Benchmark archive $file could not be found!
  "
          fi
        done
      fi

      if [ -n "$errors" ]; then
          echo "$errors"
          echo
          echo "Installation of $arch failed; removing files written."
          rm -rf "$SPECTARGET"/*
          continue
      fi
  fi

  SUMPROG=
  for dir_ in "$SPEC/tools/bin/$arch" tools/bin/$arch bin; do
      if [ -x "$dir_/specsha512sum" ]; then
          SUMPROG="$dir_/specsha512sum"
          break
      fi
  done
  if [ -z "$SUMPROG" ]; then
      echo
      echo "No specsha512sum found; the $arch toolset is incomplete."
      echo
      continue
  elif [ -z "$SPEC_NOCHECK" ]; then
      if $SUMPROG -e >/dev/null 2>&1 </dev/null; then
          check_manifest "$SPEC/MANIFEST" "$SPECTARGET" "$EXCLUDE_PAT"
      else
          echo
          echo "specsha512sum from $arch does not support extended hashes."
          echo
          continue
      fi
  fi

  if [ -n "$errors" ]; then
      echo "$errors"
      # Errors at this point PROBABLY indicate that the unpacked distribution
      # is corrupt.  But if $SPECTARGET isn't $SPEC, it could be due to the
      # tools.  So only try another toolset if the current candidate was
      # responsible for unpacking the distribution.
      if [ "$SPECTARGET" = "$SPEC" -o $archcount -lt 0 ]; then
          echo "Unable to install."
          echo
          echo "Likely Reasons:"
          echo "- Your installation media has been damaged."
          echo "- You are trying to copy SPEC ${UCSUITE} trees from one place"
          echo "  to another using tools that damage files or do not preserve"
          echo "  file metadata."
          echo
          echo "Recovery:"
          echo "1. Create a new, empty directory to hold the installation."
          echo "2. Use the installer from the original media to install to that directory."
          echo
          uninstall_previous "$SPECTARGET"
          exit 1
      else
          echo
          echo "Installation of $arch aborted."
          echo
          rm -rf "$SPECTARGET"/*
          continue
      fi
  fi

  # Install binaries here
  rm -rf $SPECTARGET/bin/lib

  if [ -f "$SPECTARGET/TOOLS.sha512" ]; then
      echo "Removing previous tools installation"
      echo
      uninstall_previous "$SPECTARGET"
  fi

  echo "Unpacking binary tools for $arch..."
  echo
  TOOLS=
  if [ -f "$SPEC/tools/bin/$arch/tools-$arch.tar.xz" ]; then
    TOOLS="$SPEC/tools/bin/$arch/tools-$arch.tar.xz"
    UNCOMPRESS="\"$SPEC/tools/bin/$arch/specxz\" -dc"
  else
    # This should never happen
    echo
    echo "Compressed tools tar file for $arch is missing!"
    echo
    continue
  fi

  if eval $UNCOMPRESS < $(ls "$TOOLS") | \
          (cd "$SPECTARGET"; eval $TAR $SPEC_INSTALL_VERBOSE -xf -); then
      if [ -z "$SPEC_NOCHECK" ]; then
        echo "Checking the integrity of your binary tools..."
        echo
        # Don't do the grep -v ': OK' here because grep will exit successfully
        (cd "$SPECTARGET"; cat TOOLS.sha512 | grep -v '/ORIG$' | $SUMPROG -e -c - > manifest.check.$$ 2>&1)
        if [ $? != 0 ]; then
           cat "$SPECTARGET/manifest.check.$$" | grep -v ': OK$'
           echo
           errors="${errors}Binary tools integrity check failed.
"
        else
           echo "Checksums are all okay."
           echo
        fi
        rm -f "$SPECTARGET/manifest.check.$$"
      fi
      echo $arch > "$SPECTARGET/bin/packagename"
  else
      errors="${errors}Error extracting the tools binaries for '$arch'.
"
  fi

  if [ "x$errors" != "x" ]; then
      # Uninstall the tools that have just been unpacked (if possible)
      uninstall_previous "$SPECTARGET"
  else
      cd "$SPECTARGET"

      # shrc will add LD_LIBRARY_PATH if it is needed
      . ./shrc

      # Run the runcpu tests to make sure that everything is okay.
      testout=runcpu-test.${arch}.out
      echo "Testing the tools installation (this may take a minute)"
      echo
      if eval "runcpu --test=dots 3>&1 > $testout 2>&1"; then
          rm runcpu-test*.out
          insterrors=
          if [ -n "$SPEC_NOCHECK" ]; then
              $SPECTARGET/bin/specperl -ni -e '$l = $_; print; if (eof) { $l =~ tr/\012\015//d; $l =~ s/([0-9a-f]{13,})/"badb00".("0" x (length($1) - 13))."ca5cade"/eg; $l =~ s/ \S+$/ nocheck-install/; print $l."\r\n" }' $SPECTARGET/MANIFEST
          fi
      else
          errors="${errors}

Error running runcpu tests.  See $SPECTARGET/$testout for details,
if no other toolsets install successfully.

"
              insterrors="${insterrors}
$SPECTARGET/$testout
"
      fi
  fi

  if [ "x$errors" = "x" ]; then
      # This is a hack to make sure that the case of the directory is shown
      # properly even if it differs from that in $SPECTARGET.  Note that this
      # can only happen on systems with filesystems that are case-preserving
      # but not case-sensitive.  A regular (cd $SPECTARGET; pwd) will just reflect
      # the value in $SPECTARGET.
      FINAL_DEST=$(cd $(dirname $SPECTARGET); cd $(ls | grep -i "^$(basename $SPECTARGET)\$"); pwd)
      if ! echo "$FINAL_DEST" | grep -i $SPECTARGET >/dev/null; then
          # Something went wrong in the hack above; this value will always be
          # good enough.
          FINAL_DEST=$SPECTARGET
      fi
      echo
      echo "Installation successful.  Source the shrc or cshrc in"
      echo $FINAL_DEST
      echo "to set up your environment for the benchmark."
      echo
      break
  else
      echo "$errors"
      echo
      echo "Installation of $arch aborted."
      echo
      uninstall_previous "$SPECTARGET"
      continue
  fi
done

exit 0

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=sh syntax=sh shiftwidth=4 tabstop=8 expandtab nosmarttab:
