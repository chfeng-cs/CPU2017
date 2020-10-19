
                      Nucleic Acid Builder (NAB)


INTRODUCTION

Nucleic Acid Builder (NAB) is a molecular modeling application that performs
the types of floating point intensive calculations that occur commonly in life
science computation.  The calculations range from relatively unstructured
"molecular dynamics" to relatively structured linear algebra.  The complete
version of NAB is distributed as part of AmberTools from the following URL:

	http://www.casegroup.rutgers.edu

The sources that make up the benchmark are only the subset of NAB (from
AmberTools version 10) that is required for typical life science calculations.
NAB is written entirely in C.  Only one main program is provided, nabmd.c, that
performs molecular dynamics simulation.

This NAB program may be executed in parallel using either OpenMP or MPI.  The
benchmark build process only supports OpenMP.  In order to compile for MPI
execution, it is necessary to modify the object.pm file to substitute the -DMPI
option for the -DOPENMP option.  This is not tested and is likely to cause the
benchmark to fail validation.


INSTALLATION (does not apply to the benchmark version)

Installation of NAB is simple:

	tar -xzf nab.tgz

	setenv NABHOME (the path to the nab directory)

	cd nab

	make all


EXECUTION UNDER OPENMP (does not apply to the benchmark version)

Initiate execution of the nabmd programs as follows:

	setenv OMP_NUM_THREADS (whatever number of threads you want)

	nabmd directory

where directory designates one of the directories discussed below.


INPUT DIRECTORIES

Several directories of input files are provided that describe molecules that
have differing number of atoms.  The number of atoms n is important because
mdgb molecular dynamics scale approximately as O(n**1.5).  Below are the number
of atoms that each input molecule comprises:

	hkrdenq - 124

	aminos - 327

	gcn4dna - 3227

	1am0 - 19030

	3j1n - 62072

Most of these input files were culled from the Brookhaven Protein Data Bank:

	http://www.rcsb.org

Even larger input files are available if necessary.


MORE DETAILS

Life science floating point calculations fall roughly into three groups:
linear algebra, fast Fourier transforms and other "unstructured" calculations
such as molecular dynamics.

The nabmd program performs less structured floating point calculations.  It
appears that for these types of calculations several threads may be required
to utilize the full capacity of one floating point unit.  In order to explore
this issue, it may be interesting to trace the egb() and nbond() functions of
the eff.c file.  These functions are called by the mme34() function of the eff.c
file, which function is in turn called by the md() function of the sff.c file.

The nabmd program will spend most of its time in the egb(), nbond() and nblist()
functions.  This observation arises from the fact that most of the computation
deals with "all to all" interatomic interactions, that is, each atom is potentially
affected by all other surrounding atoms.  The nblist() function creates, for each
atom, a "pair" list of atoms that affect that atom.  The egb() and nbond() functions
process, for each atom, the atoms that appear in that atom's pair list.

The nabmd program is compiled in 64 bit mode to match the capabilities of modern
CPUs, but it can just as well be compiled in 32 bit mode.


CONTROLLING THE COMPUTATION

By default, the nabmd program performs 1000 "time steps" or iterations of
molecular dynamics simulation.  To change the number of iterations, change the
3rd command-line argument.  The nabmd program prints summaries every 100 time
steps, as well as for the last step.  To disable this printing, change the ntpr
and ntpr_md variables in the source code from their default values of 100 to a
larger number such as 1000 or more.

The nabmd program calculates interatomic interactions using both the Generalized
Born solvation formula of the egb() function, as well as the "in vaccuo" formula
of the nbond() function.  The egb() function is used when the gb variable is set
to 1 in the nabmd.c file.  The nbond() function is used when the gb variable is
set to 0 in the nabmd.c file.

For MPI execution, a few scratch arrays are used for each MPI process. But for
OpenMP execution, all threads share one instance of each scratch array.  This
approach raises the possibility of the "false sharing" phenomenon wherein different
threads invalidate cache lines for one another.  In order to eliminate
false sharing, it is possible to set the blocksize variable in the nabmd.c
file.  The blocksize is defaulted to 8.  Blocksize should be set to the number of
double-precision floating point numbers that will fit in one cache line.  For
example, a cache line that comprises 64 bytes can hold 8 double-precision floating
point number, so the default value of blocksize (8) is appropriate for a 64-byte
cache.

The AmberTools User's Manual discusses many more variables that may be set via
the mm_options() function.  However, this function is the primary cause of lack
of portability of NAB.  Therefore, this function has been eliminated, and only
the gb, blocksize, ntpr and ntpr_md variables may be set in the nabmd.c file,
using an assignment statement instead of a call to the mm_options() function.
In order to permit another variable to be set in the nabmd.c file, that variable
must be declared "extern" in the nabmd.c file, and the "static" designation must
be removed from that variable in the sff.c file.
