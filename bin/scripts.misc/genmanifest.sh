#!/bin/sh
#
# genmanifest.sh - generate the top-level MANIFEST file
# No support is provided for this script.
#
# Copyright 1999-2016 Standard Performance Evaluation Corporation
#
# $Id: genmanifest.sh 5073 2016-12-02 14:04:01Z CloyceS $

if [ -z "$SPEC" ]; then
    echo "SPEC variable is not set!";
    exit 1;
fi

# Tweak this; it's a regexp that recognizes the name of the suite tarball
# that lives in install_archives
suitetarballre='/(mpi20\d+|cpu(20|v)\d+)(-.*)?\.(t[abx]z|tar\.[gbx]z2?)(\.(md5|sha\d+))?$'

# Don't tweak this
novc='( ( -name .svn -o -name .git ) -prune ) -o'

cd $SPEC
rm -f MANIFEST

if [ -f tools/tools_src.tar.xz -o -f tools/tools_src.tar.bz2 ]; then
  exclude_toolsrc="grep -v ^tools/src/"
else
  exclude_toolsrc=cat
fi

# Look in each benchmark's Docs directory for the file that cleanuptree
# copies to nnn.benchmark.html, and exclude it if found.
exclude_basedocs=cat
for i in benchspec/*/[0-9]*; do
  if [ -d $i/Docs ]; then
    _benchbase=$(basename $i | sed 's/^2[0-9][0-9]\.o//; s/^[0-9][0-9][0-9]\.//; s/_[rs]$//')
    if [ -f $i/Docs/${_benchbase}.html ]; then
      exclude_basedocs="$exclude_basedocs | egrep -v $i/Docs/${_benchbase}'\.(html|txt)'"
    fi
  fi
done

echo Generating sums for distribution files
find . $novc \( -type f ! -name MANIFEST.tmp -print \) | \
  sed 's#^\./##' | \
  egrep -v '^MANIFEST$' | \
  egrep -v '(\.ignoreme|\.cvsignore|\.DS_Store|\.gitignore)' | \
  egrep -v $suitetarballre | \
  egrep -v '^shrc\.bat$' | \
  egrep -v '^benchspec/common' | \
  egrep -v '^benchspec/[^/]*/[^/]*/(exe|run|build)/' | \
  egrep -v '^config/default\.cfg' | \
  egrep -v '^config/.*\.cfg\.' | \
  egrep -v '^result' | \
  egrep -v '^original\.src/(release_control|benchball)' | \
  egrep -v '^tools/src/buildtools.log/.*\.txt$' | \
  egrep -v '^tools/src/gnulib' | \
  $exclude_toolsrc | \
  eval "$exclude_basedocs" | \
  sort | \
  xargs specsha512sum --binary -e >> MANIFEST

ls -l MANIFEST
