#!/bin/sh

# Tests for specsha512sum
# Should do the roughly the same thing as the Perl-based tests from coreutils,
# but without the Perl.
# Also tests the SPEC "extended" format

# Some of the test vectors in test-specsum.in* taken from http://www.di-mgt.com.au/sha_testvectors.html

# $Id: test-specsha512sum.sh 3679 2015-11-20 19:16:20Z CloyceS $

. "${srcdir=.}/init.sh"; path_prepend_ ../src

if touch 'a
b'; then

  cat<<EOE > exp
\\cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e *a\\nb
EOE
  specsha512sum 'a
b' > out
  compare exp out || fail=1

  cat<<EOE > exp
\\cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e * 0000000000000000 a\\nb
EOE
  specsha512sum --extended 'a
b' > out
  compare exp out || fail=1
else
  echo "$0: Could not make newline-containing file name"
fi

for i in ../specsum-testdata/test-specsum.in*; do
  exp=$(basename $i | sed 's/specsum.in/specsha512sum.out/')
  specsha512sum $i > $exp || fail=1
  compare $(dirname $i)/$exp $exp || fail=1
  exp=$(basename $i | sed 's/specsum.in/specsha512sum.extout/')
  specsha512sum --extended $i > $exp || fail=1
  compare $(dirname $i)/$exp $exp || fail=1
done

for i in ../specsum-testdata/test-specsha512sum.in*; do
  exprc=$(basename $i | sed 's/^.*expect\([0-9]*\)\..*/\1/')
  exp=$(basename $i | sed 's/specsha512sum.in/specsha512sum.out/')
  inp=$(basename $i)
  tail -n+2 $i > $inp
  returns_ $exprc specsha512sum $(head -n 1 $i) $inp > $exp 2>&1 || fail=1
  compare $(dirname $i)/$exp $exp || fail=1
done

# Check the recursive functions
for i in '' --extended; do
  exp=../specsum-testdata/test-specsha512sum.recursive$i.out
  returns_ 0 specsha512sum --check --status $i $exp
  specsha512sum $i ../specsum-testdata | grep -v recursive | sort > $(basename $exp)
  compare $exp $(basename $exp) || fail=1
done

Exit $fail
