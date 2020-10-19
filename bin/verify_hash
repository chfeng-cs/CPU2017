#!/bin/sh
#
# Copyright 2008-2018 Standard Performance Evaluation Corporation
#
# $Id: sh_starter 5894 2018-04-13 22:53:49Z CloyceS $
#

# Avoid usage of $(...) to accomodate ancient Bourne shells on supported
# systems. (Solaris 10, I'm looking at you.)
_tool=`basename $0`

_bin=`dirname $0`
if [ "x$_bin" = x -o "$_bin" = . ]; then
    _bin=`pwd`
elif echo "$_bin" | grep -v '^/' > /dev/null 2>&1; then
    # Make the relative path absolute
    _bin=`(cd $_bin; pwd)`
fi

if [ ! -x "${_bin}/specperl" ]; then
    echo "specperl is not in ${_bin}; has the benchmark tree been installed?"
    exit 1
fi

_loc=
for _try in harness tools formatter; do
    if [ -f "${_bin}/${_try}/${_tool}" ]; then
        _loc=$_try
    fi
done
if [ "x$_loc" = x ]; then
    echo Could not locate $_tool under $_bin
    exit 1
elif [ "$_loc" = tools ]; then
    _lib=harness
else
    _lib=$_loc
fi

# Arrange for _bin to be in PATH, since the tools rely on it to find
# things like specmake, specinvoke, specdiff, etc.
if echo "${PATH}" | egrep -v "(^|:)${_bin}(:|$)" > /dev/null 2>&1; then
    PATH="${_bin}:$PATH"
    export PATH
fi

if [ "x$SPEC" = x ]; then
    # Also set SPEC, since it's easier to do it here than to patch all of the
    # things that might be expecting it to be set.
    SPEC=`(cd $_bin/..; pwd)`
    export SPEC
fi

exec specperl -I"${_bin}/common" -I"${_bin}/${_lib}" -I"${_bin}" -I"${_bin}/lib" "${_bin}/${_loc}/${_tool}" "$@"

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=sh syntax=sh shiftwidth=4 tabstop=8 expandtab nosmarttab:
