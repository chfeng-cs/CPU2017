#!/bin/sh

# Tests for specmd5sum
# Should do the roughly the same thing as the Perl-based tests from coreutils,
# but without the Perl.
# Also tests the SPEC "extended" format

# Some of the test vectors in test-specsum.in* taken from http://www.di-mgt.com.au/sha_testvectors.html

# $Id: test-specmd5sum.sh 4445 2016-06-17 19:59:24Z CloyceS $

. "${srcdir=.}/init.sh"; path_prepend_ ../src

if touch 'a
b'; then

  cat<<EOE > exp
\\d41d8cd98f00b204e9800998ecf8427e *a\\nb
EOE
  specmd5sum 'a
b' > out
  compare exp out || fail=1

  cat<<EOE > exp
\\d41d8cd98f00b204e9800998ecf8427e * 0000000000000000 a\\nb
EOE
  specmd5sum --extended 'a
b' > out
  compare exp out || fail=1
else
  echo "$0: Could not make newline-containing file name"
fi

for i in ../specsum-testdata/test-specsum.in*; do
  exp=$(basename $i | sed 's/specsum.in/specmd5sum.out/')
  specmd5sum $i > $exp || fail=1
  compare $(dirname $i)/$exp $exp || fail=1
  exp=$(basename $i | sed 's/specsum.in/specmd5sum.extout/')
  specmd5sum --extended $i > $exp || fail=1
  compare $(dirname $i)/$exp $exp || fail=1
done

for i in ../specsum-testdata/test-specmd5sum.in*; do
  exprc=$(basename $i | sed 's/^.*expect\([0-9]*\)\..*/\1/')
  exp=$(basename $i | sed 's/specmd5sum.in/specmd5sum.out/')
  inp=$(basename $i)
  sed -ne '2,$p' $i > $inp
  returns_ $exprc specmd5sum $(head -n 1 $i) $inp > $exp 2>&1 || fail=1
  compare $(dirname $i)/$exp $exp || fail=1
done

# Check the recursive functions
for i in '' --extended; do
  exp=../specsum-testdata/test-specmd5sum.recursive$i.out
  returns_ 0 specmd5sum --check --status $i $exp
  specmd5sum $i ../specsum-testdata | grep -v recursive | sort > $(basename $exp)
  compare $exp $(basename $exp) || fail=1
done

Exit $fail
