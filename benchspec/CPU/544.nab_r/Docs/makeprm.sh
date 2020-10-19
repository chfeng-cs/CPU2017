#!/bin/sh

# Attempt to make the PRM file for a molecule downloaded from the
# RCSB Protein Data Bank.
#
# No support is provided for this script
#
# $Id$

if [ "x$AMBERHOME" = "x" ]; then
  echo "AMBERHOME is not set; please source amber.sh or amber.csh in your"
  echo "AmberTools installation directory."
  exit 1
fi

if [ ! -x "$AMBERHOME/bin/nab" ] && ! nab | grep '^usage: nab' >/dev/null 2>&1; then
  echo "Can't find nab in $AMBERHOME/bin or in \$PATH"
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "Input file '$1' does not exist or is not a regular file"
  exit 1
fi

ORIG="$1"
if [ `basename "$ORIG" .bz2` != `basename "$ORIG"` ]; then
  INPUT=`basename "$ORIG" .bz2`
  cat "$ORIG" | bunzip2 > $INPUT
elif [ `basename "$ORIG" .gz` != `basename "$ORIG"` ]; then
  INPUT=`basename "$ORIG" .gz`
  cat "$ORIG" | gunzip > $INPUT
elif [ `basename "$ORIG" .Z` != `basename "$ORIG"` ]; then
  # Seriously?  compress?  It's the 21st century!
  INPUT=`basename "$ORIG" .Z`
  zcat "$ORIG" > $INPUT
else
  INPUT=`basename "$ORIG"`
  if [ `basename "$ORIG"` != "$ORIG" -a `dirname "$ORIG"` != "." ]; then
    cat "$ORIG" > $INPUT
  fi
  true
fi
if [ $? -ne 0 ]; then
  echo "Couldn't uncompress input file '$ORIG'"
  exit 1
fi

MOLECULE=`echo "$INPUT" | sed 's/^pdb//; s/\.ent$//; s/\.pdb$//;' | tr A-Z a-z`

mkdir -p $MOLECULE

cat > $MOLECULE/protprm.nab <<EONAB
/*
 * This simple program creates a file named "tprmtop" in the execution directory
 * and a file named by the command-line argument in the same directory as the
 * file that is specified by the command-line argument.  So for example, if the
 * command-line argument were ../1vw1/1vw1.pdb then a file named ../1vw1/1vw1.pdb.lpdb
 * would be created, obviously in the ../1vw1/ directory, and a file named "tprmtop"
 * would be created in the same directory from which this program were executed,
 * which would normally be the nab/utilities/ directory.
 *
 * If the .pdb file does not specify H atoms, as is the case for .pdb files from
 * the RCSB Protein Data Bank that have been created via X-ray crystallography,
 * then the .pdb.lpdb file will contain the H atoms that satisfy the valences of
 * the non-H atoms in the .pdb file.
 *
 * The "tprmtop" file is the parameter file that matches the .pdb.lpdb file.
 * Together, these two files specify a molecule in the manner that is required
 * by the nabmd program.  So, continuing with the example of the ../1vw1/1vw1.pdb
 * file, the ../1vw1/1vw1.pdb file should be renamed ../1vw1/1vw1.original.pdb,
 * the ../1vw1/1vw1.pdb.lpdb file should be renamed ../1vw1/1vw1.pdb, and the
 * "tprmtop" file should be renamed ../1vw1/1vw1.prm.  Then this molecule may
 * be specified by the nabmd program via the command-line argument 1vw1.
 *
 * Also, files named "tprmcrd", "tleap.out" and "leap.log" are created in the
 * execution directory; these files may be deleted.
 *
 * I couldn't figure out how to manipulate strings and rename or delete files
 * via the .nab source code, so the manual manipulation discussed above is required.
 *
 * Compile this file via "nab -o protprm protprm.nab" then execute it for the
 * 1vw1 example via "protprm ../1vw1/1vw1.pdb".
 *
 * Russ Brown March 15, 2014
 */

molecule m;

m = getpdb_prm( argv[2], "oldff/leaprc.ff99SB", "", 1 );
EONAB
if [ $? -ne 0 ]; then
  echo "Couldn't write NAB program into $MOLECULE"
  exit 1
fi

nab -o $MOLECULE/protprm $MOLECULE/protprm.nab
if [ $? -ne 0 ]; then
  echo "nab failed to build the conversion program"
  exit 1
fi

$MOLECULE/protprm "$INPUT"

# Now rename the files
if [ `dirname "$ORIG"` = $MOLECULE ]; then
  # The original file is in the output directory, so rename it
  mv "$ORIG" "$ORIG".original
fi
if [ "$ORIG" != "$INPUT" ]; then
  rm -f "$INPUT"
fi
mv `dirname "$INPUT"`/`basename $INPUT`.lpdb $MOLECULE/$MOLECULE.pdb
mv `dirname "$INPUT"`/tprmtop $MOLECULE/$MOLECULE.prm

# Clean up the nab leavings
rm -f tprmcrd tleap.out leap.log $MOLECULE/protprm*

# Done!
echo
echo
echo Output is in $MOLECULE
ls -l $MOLECULE/*

# Editor settings: (please leave this at the end of the file)
# vim:set filetype=sh syntax=sh shiftwidth=4 tabstop=8 expandtab nosmarttab
