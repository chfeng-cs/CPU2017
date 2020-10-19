#!/bin/sh

#
#  do_go.sh - the dirty guts of the CSH version of "go" and "ogo"
#  Copyright 2015-2016 Standard Performance Evaluation Corporation
#
#  Author: Cloyce D. Spradling
#
# $Id: do_go.sh 4940 2016-09-26 22:30:42Z CloyceS $
#

#
# It would be maximally safe and minimally convenient to actually write this
# in CSH; I think it's reasonable to expect that a system with CSH will also
# have a Bourne shell somewhere, and this allows us to recycle code from the
# real shrc.
#

if [ "$SPEC" = "" ]; then
    echo
    echo "The SPEC environment variable is not set\! Please source the cshrc and try again."
    echo
    exit
fi

_PPID=$1
shift
_CMD=$1
shift
UCSUITE=$1
shift

# go_usage() is stolen verbatim from shrc
go_usage() {
    ME=$1
    if [ "x$ME" = "xgo" -o "x$ME" = "xogo" ]; then
        if [ "x$ME" = "xgo" ]; then
            MYTOP='$SPEC'
        elif echo "$GO" | grep '^/' >/dev/null; then
            MYTOP='$GO'
        else
            MYTOP='$SPEC/$GO'
        fi
        echo "Usage: $ME <destination>"
        echo "Destinations:"
        echo " top              : $MYTOP"
        echo " docs             : \$SPEC/Docs"
        echo " config           : \$SPEC/config"
        echo " result           : $MYTOP/result"
        echo " <benchmark> [...]: $MYTOP/benchspec/CPU2017/<benchmark>"
        echo " benchmark can be abbreviated: e.g. '$ME perlbench'"
        echo "See utility.html#$ME for more information."
        echo
        echo "\$SPEC is currently set to \"$SPEC\""
        if [ "x$ME" = "xogo" ]; then
            echo "\$GO is currently set to \"$GO\""
        fi
        echo
    fi
}

# go() is stolen verbatim from shrc
go() {
    SHRC_NO_GO=1
    if [ "x$SPEC" != "x" ]; then
        if [ "x$1" = "x--help" -o "x$1" = "x-h" ]; then
            # Help time
            go_usage 'go'
        else
            do_go $SPEC $*
            echo pwd >> /tmp/.gogo.$_PPID
        fi
    else
        echo
        echo "The SPEC environment variable is not set! Please source the shrc and try again."
        echo
    fi
}

# check_output_root() is stolen verbatim from shrc
check_output_root() {
    if [ "x$GO" = "x" -o "x$GO" = "x$SPEC" ]; then
        # If $GO is empty or $SPEC, then there can't be a mismatch
        return 0;
    fi
    if echo "$GO" | grep '^/' >/dev/null; then
        _GO=$GO
    else
        _GO=`echo "$SPEC/$GO" | sed 's#//*#/#g'`
    fi
    if [ ! -d $_GO ]; then
        # If $GO isn't a directory, it can't be okay
        echo "Unable to locate directory named by GO ($GO)"
        return 1;
    fi
    if [ ! -f $_GO/version.txt ]; then
        # Check not possible; assume it's okay
        return 0
    fi
    if [ ! -r $_GO/version.txt ]; then
        # If the version.txt file can't be read, then it's unlikely that it
        # will be usable as an output_root.
        return 1
    fi
    _or_suite=$(  cat $_GO/version.txt | sed 's/^SPEC[ 	]*//; s/[ 	].*//')
    _or_version=$(cat $_GO/version.txt | sed -e 's/^.*[ 	]\([^ 	][^ 	]*\)$/\1/' -e 's/dev$//')
    _my_suite=$( echo $UCSUITE         | sed 's/^SPEC[ 	]*//; s/[ 	].*//')
    _my_version=$(cat $SPEC/version.txt)
    if [ "$_or_version" != "$_my_version" -o "$_or_suite" != "$_my_suite" ]; then
        echo "ERROR: GO directory ($_GO) version mismatch"
        echo "       GO   is from SPEC $_or_suite v$_or_version"
        echo "       SPEC is from SPEC $_my_suite v$_my_version"
        echo "       Please adjust your setting for the GO environment variable"
        return 1
    fi

    return 0
}

# ogo() is stolen verbatim from shrc
ogo() {
    SHRC_NO_GO=0
    TOP=$SPEC
    if [ "x$TOP" != "x" ]; then
        if [ "x$1" = "x--help" -o "x$1" = "x-h" ]; then
            # Help time
            go_usage 'ogo'
        else
            if check_output_root; then
                if [ "x$GO" != "x" ]; then
                    if echo "$GO" | grep '^/' >/dev/null; then
                        _GO=$GO
                    else
                        _GO=`echo "$SPEC/$GO" | sed 's#//*#/#g'`
                    fi
                    case "$1" in
                        top|"")
                            if [ "x$OGO_NO_WARN" = "x" ]; then
                                echo "Using value in GO for output_root: $_GO"
                            fi
                            TOP=$_GO                                          ;;
                        bin|config|doc|Doc|docs|Docs|int|fp|cpu|mpi|src|data) ;;
                        *)  case "$2" in
                                data|src|Spec) ;;
                                *)  if [ "x$OGO_NO_WARN" = "x" ]; then
                                        echo "Using value in GO for output_root: $GO"
                                    fi
                                    TOP=$_GO                                  ;;
                            esac                                              ;;
                    esac
                fi
                do_go $TOP $*
                echo pwd >> /tmp/.gogo.$_PPID
            fi
        fi
    else
        echo
        echo "The SPEC environment variable is not set! Please source the shrc and try again."
        echo
    fi
}

# do_go() was NOT stolen verbatim from shrc; it has been modified for use
# in do_go.sh
do_go() {
    ROOT=$1
    shift
    case "$1" in
        top|"")   echo cd \""$ROOT"\"                >> /tmp/.gogo.$_PPID
                       cd "$ROOT"
            ;;
        bin)      echo cd \""$ROOT"/bin\"            >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/bin
            ;;
        config)   echo cd \""$ROOT"/config\"         >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/config
            ;;
        doc)      echo cd \""$ROOT"/Docs\"           >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/Docs
            ;;
        Doc)      echo cd \""$ROOT"/Docs\"           >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/Docs
            ;;
        docs)     echo cd \""$ROOT"/Docs\"           >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/Docs
            ;;
        Docs)     echo cd \""$ROOT"/Docs\"           >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/Docs
            ;;
        result)   echo cd \""$ROOT"/result\"         >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/result
            ;;
        results)  echo cd \""$ROOT"/result\"         >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/result
            ;;
        int)      echo cd \""$ROOT"/benchspec/CPU*\" >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/benchspec/CPU*
            ;;
        fp)       echo cd \""$ROOT"/benchspec/CPU*\" >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/benchspec/CPU*
            ;;
        cpu)      echo cd \""$ROOT"/benchspec/CPU*\" >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/benchspec/CPU*
            ;;
        mpi)      echo cd \""$ROOT"/benchspec/MPI*\" >> /tmp/.gogo.$_PPID
                       cd "$ROOT"/benchspec/MPI*
            ;;
        src|build|run|data|exe|Spec)
            whichbench $ROOT
            if [ ! -z "$SPECTMP" -a "x$SPECTMP" != "x." ]; then
                echo cd \""$SPECTMP"\" >> /tmp/.gogo.$_PPID
                cd "$SPECTMP"
                if [ -d "$1" ]; then
                    echo cd \""$1"\" >> /tmp/.gogo.$_PPID
                    cd "$1"
                else
                    echo "No directory named \"$1\""
                    false
                fi
            elif [ ! -z "$2" -a -z "$DO_GO_NO_RECURSE" ]; then
                DO_GO_NO_RECURSE=1
                TMPDEST=$1
                TMPBENCH=$2
                shift 2
                do_go $ROOT $TMPBENCH $TMPDEST $*
            else
                echo Not in a benchmark tree
                false
            fi
            ;;
        *)  whichbench $ROOT $1
            if [ ! -z "$SPECTMP" ]; then
                echo cd \""$SPECTMP"\" >> /tmp/.gogo.$_PPID
                cd "$SPECTMP"
            else
                # No benchmark found; do not attempt to do subdirs
                shift $#
            fi
            ;;
    esac
    if [ $# -gt 1 ]; then
        shift
        for subdir in $*; do
            if [ -d "$subdir" ]; then
                echo cd \""$subdir"\" >> /tmp/.gogo.$_PPID
                cd "$subdir"
            else
                echo "No directory named \"$subdir\""
                false
            fi
            if [ $? -ne 0 ]; then
                break
            fi
        done
    fi
    DO_GO_NO_RECURSE=
}

# whichbench() is stolen verbatim from shrc
whichbench() {
    SPECTMP=
    TOP=$1
    BENCH=$2
    if [ $SHRC_NO_GO -eq 1 ]; then
        ME=go
    else
        ME=ogo
    fi
    if [ "x$BENCH" = "x" ]; then
        # No benchmark specified; try to figure out what the current one
        # (if any) is and Do The Right Thing.
        # For the purposes of this exercise, try all of $TOP, $GO, and
        # $SPEC.  It may be that the user is in an output root and wishes
        # to indirectly visit a subdirectory in the main tree (or vice-
        # versa).
        # But in any case, don't pay attention to GO unless the user is
        # using "ogo"
        if [ $SHRC_NO_GO -eq 1 ]; then
                GOGO=$SPEC
        else
            if echo "$GO" | grep '^/' >/dev/null; then
                GOGO=$GO
            else
                GOGO=`echo "$SPEC/$GO" | sed 's#//*#/#g'`
            fi
        fi
        for i in "$TOP" "$GOGO" "$SPEC"; do
            BENCH=`pwd | sed "s#$i//*benchspec/[^/][^/]*/##; s#/.*##;"`
            if [ "x$BENCH" != "x" ]; then
                break
            fi
        done
        if [ "x$BENCH" = "x" ]; then
            SPECTMP=.
            return
        fi
    fi
    for i in "$TOP"/benchspec/*/$BENCH* "$TOP"/benchspec/*/0$BENCH* \
        "$TOP"/benchspec/*/00$BENCH* "$TOP"/benchspec/*/*.$BENCH*
    do
        if [ -d "$i" ]
        then
            SPECTMP=$i
            return
        fi
    done
    echo "Can't resolve \"$BENCH\" into a benchmark name"
    echo
    echo "Try '$ME --help' for options"
    echo
}

if [ "$_CMD" = "go" ]; then
    go $*
elif [ "$_CMD" = "ogo" ]; then
    ogo $*
else
    echo Unknown action \"$_CMD\" specified
fi

# Uncomment to see what's going to happen
#cat /tmp/.gogo.$_PPID

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=sh syntax=sh shiftwidth=4 tabstop=8 expandtab nosmarttab:
