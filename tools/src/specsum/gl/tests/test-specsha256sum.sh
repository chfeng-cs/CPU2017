#!/bin/sh

# Tests for specsha256sum
# Should do the roughly the same thing as the Perl-based tests from coreutils,
# but without the Perl.
# Also tests the SPEC "extended" format

# Some of the test vectors in test-specsum.in* taken from http://www.di-mgt.com.au/sha_testvectors.html

# $Id: test-specsha256sum.sh 3679 2015-11-20 19:16:20Z CloyceS $

. "${srcdir=.}/init.sh"; path_prepend_ ../src

if touch 'a
b'; then

  cat<<EOE > exp
\\e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 *a\\nb
EOE
  specsha256sum 'a
b' > out
  compare exp out || fail=1

  cat<<EOE > exp
\\e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 * 0000000000000000 a\\nb
EOE
  specsha256sum --extended 'a
b' > out
  compare exp out || fail=1
else
  echo "$0: Could not make newline-containing file name"
fi

for i in ../specsum-testdata/test-specsum.in*; do
  exp=$(basename $i | sed 's/specsum.in/specsha256sum.out/')
  specsha256sum $i > $exp || fail=1
  compare $(dirname $i)/$exp $exp || fail=1
  exp=$(basename $i | sed 's/specsum.in/specsha256sum.extout/')
  specsha256sum --extended $i > $exp || fail=1
  compare $(dirname $i)/$exp $exp || fail=1
done

for i in ../specsum-testdata/test-specsha256sum.in*; do
  exprc=$(basename $i | sed 's/^.*expect\([0-9]*\)\..*/\1/')
  exp=$(basename $i | sed 's/specsha256sum.in/specsha256sum.out/')
  inp=$(basename $i)
  tail -n+2 $i > $inp
  returns_ $exprc specsha256sum $(head -n 1 $i) $inp > $exp 2>&1 || fail=1
  compare $(dirname $i)/$exp $exp || fail=1
done

# Check the recursive functions
for i in '' --extended; do
  exp=../specsum-testdata/test-specsha256sum.recursive$i.out
  returns_ 0 specsha256sum --check --status $i $exp
  specsha256sum $i ../specsum-testdata | grep -v recursive | sort > $(basename $exp)
  compare $exp $(basename $exp) || fail=1
done

Exit $fail
