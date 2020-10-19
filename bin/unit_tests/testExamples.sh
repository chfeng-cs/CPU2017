#!/bin/bash
# Test whether Example-*cfg produce expected outputs, while
# avoiding any instances of "Unknown Flags"
#
# Usage:
#    Just run it.  Useful outputs are automatically captured.
#
# Env vars you can set:
#    KEEPTMP  0 - keep only failures (default)
#             1 - keep above plus limited stuff from successes
#             2 - keep everything, no matter how ugly or redundant
#
#    SKIP_USUAL_TESTS  Don't do the common 8 {int|fp}{rate|speed}{m32|m64}
#    SKIP_SPECIALS     Don't do extras for configs that have them
#    ANALYZE_ONLY      Just run the analysis stuff, using directory $ANALYZE_ONLY
#                      Implies SKIP_* and KEEPTMP=2
#    NAP               Sleep this many seconds between tests (default 3)
#
#  jhenning 1/2017

#------------------------------------------------------------------------------
# Globals

BASE0=$(basename $0)
few=10                          # number of errors worth spitting to screen
prefix=regressiontest           # copy Example-x.cfg to prefix-x.cfg before test
types_expected="cfg csv flags.html html pdf txt"  # which reports to look for
outroot=$SPEC/config/testing/   # output files go here with a datestamp

if [[ $(uname -s) == "Darwin" ]] ; then
   # treat my laptop gently: time between runcpu commands
   nap=${NAP:-10}
else
   # even on big systems, need a nap to avoid
   #  ERROR: The sysinfo_program produced no output!
   nap=${NAP:-3}
fi

errors=0
ignored=0
nconfig=0
ntests=0

# benchmark set for bmarks that lack Fortran
c_cpp='
        500.perlbench_r
        502.gcc_r
        505.mcf_r
        508.namd_r
        510.parest_r
        511.povray_r
        519.lbm_r
        520.omnetpp_r
        523.xalancbmk_r
        525.x264_r
        526.blender_r
        531.deepsjeng_r
        538.imagick_r
        541.leela_r
        544.nab_r
        557.xz_r
        600.perlbench_s
        602.gcc_s
        605.mcf_s
        619.lbm_s
        620.omnetpp_s
        623.xalancbmk_s
        625.x264_s
        631.deepsjeng_s
        638.imagick_s
        641.leela_s
        644.nab_s
        657.xz_s
        996.specrand_fs
        997.specrand_fr
        998.specrand_is
        999.specrand_ir
'

#------------------------------------------------------------------------------
# tiny bit of perl: too hard to express this in shell
baseFlagsNotGroupedByLanguage='
while (<>) {
   if (/^\s+Base O/) {
      $inbase = 1;
      next;
   } elsif (/^\s+(SPEC is a|Peak)/) {
      $inbase = 0;
      next;
   }
   next unless $inbase;
   if (/^\s*\d\d\d\.(\S+):/) {
      exit 1;
   }
}
exit 0;
'

#-----------------------------------------------------------------------------
function init_errs_file
{
   echo "writing to:"
   echo "   $testTop"
   if ! mkdir -p $testTop ; then
      echo Could not create $testTop
      exit 1
   fi
   if ! cd $testTop ; then
      echo Could not cd to $testTop
      exit 1
   fi
   touch $errs_file
   if [[ ! -e $errs_file ]] ; then
      echo Could not write to $testTop
      exit 1
   fi
}

#-----------------------------------------------------------------------------
# Most configs use a set of 8 tests, unless it is known not to support one of them.
function start_the_usuals
{
   for metric in intrate fprate intspeed fpspeed ; do
      for bits in 32 64 ; do
         for file in $list ; do
            if [[ $file =~ VisualStudio ]] ; then
               continue
            elif [[ $file =~ speed ]] && [[ $metric =~ rate ]] ; then
               continue
            elif [[ $file =~ rate ]] && [[ $metric =~ speed ]] ; then
               continue
            elif [[ $file =~ ic17 ]] && [[ $bits == 32 ]] ; then
               continue
            elif [[ $metric =~ speed ]] && [[ $bits == 32 ]] ; then
               continue
            fi
            config=$prefix-${file#Example-}
            outfile=$(basename $config .cfg).$metric.$bits.out
            cmd="$RUNCPU -S bits=$bits -c $config $metric "
            echo $cmd > $testTop/$outfile
            $cmd >> $testTop/$outfile  2>&1 &
            ntests=$(( ntests + 1 ))
            [[ $nap ]] && sleep $nap
         done
      done
   done
}

#-----------------------------------------------------------------------------
function start_special_cases
{
   #--------------
   # Visual Studio
   msvs=Example-VisualStudio.cfg
   if [[ ! -e $SPEC/config/$msvs ]] ; then
      # if the error is about STARTING tests, use tee to get word out early
      echo "ERROR - Could not find '$msvs', has its name changed?"  | tee -a $errs_file
      errors=$(( errors + 1 ))
   else
      cd $SPEC/config
      for version in 2015 2017 ; do
         config=$prefix-${msvs#Example-}
         config=$(basename $config .cfg)-$version.cfg
         cp $msvs $config
         for bits in 32 64 ; do
            cmd="runcpu --output_root=$testTop --fakereport -S bits=$bits -S VSVERSION=$version -c $config $c_cpp "
            outfile=$(basename $config .cfg).$bits.out
            echo $cmd > $testTop/$outfile
            $cmd >> $testTop/$outfile  2>&1 &
            ntests=$(( ntests + 1 ))
            [[ $nap ]] && sleep $nap
         done
      done
   fi
   #
   #--------------
   # Oracle Studio
   oStudio=Example-studio-solaris.cfg
   if [[ ! -e $SPEC/config/$oStudio ]] ; then
      # if the error is about STARTING tests, use tee to get word out early
      echo "ERROR - Could not find '$oStudio', has its name changed?" | tee -a $errs_file
      errors=$(( errors + 1 ))
   else
      cd $SPEC/config
      for chip in x86 sparc ; do
         config=${oStudio#Example-}
         config=$prefix-$(basename $config .cfg)-$chip.cfg
         cp $oStudio $config
         for lib in gnu2003 stlport4 stdcxx4 ; do
            # do not need _all_ possible combinations; just a sanity check
            metric="intrate"
            bits=64
            outfile=$(basename $config .cfg).$metric.$lib.$bits.out
            cmd="$RUNCPU -S bits=$bits -S lib=$lib =S chip=$chip -c $config $metric "
            echo $cmd > $testTop/$outfile
            $cmd >> $testTop/$outfile  2>&1 &
            ntests=$(( ntests + 1 ))
            [[ $nap ]] && sleep $nap
         done
      done
   fi
}

#------------------------------------------------------------------------------
function analyze_results
{
   if [[ ! -d $testTop/result ]] ; then
      echo ERROR: no result directory found!
      exit 1
   fi
   #----------------------
   # user screen output
   cd $testTop
   wrongbits="ERROR: This config file always uses 64 bits.  Please remove your"
   fail_build="'fail_build' set"
   for file in *out ; do
      keep_this_one="no"
      if grep -l "Neither config file" $file > /dev/null ; then
         echo ERROR: config file not found for $file >> $errs_file
         errors=$(( errors + 1 ))
         keep_this_one="yes"
         continue
      elif grep "$wrongbits" $file >/dev/null ; then
         # don't report expected errors
         ignored=$(( ignored + 1 ))
         continue
      else
         errlines=$(grep 'ERROR:' $file)
         if [[ $errlines ]] ; then
            filtered=$(echo "$errlines" | grep -v "$fail_build")
            if [[ $filtered ]] ; then
               echo "$filtered" >> $errs_file
               # hmmm, the count here is +1 for the file, but there could be many lines.
               # compare to other 'hmmm'
               errors=$(( errors + 1 ))
               keep_this_one="yes"
            else
               ignored=$(( ignored + 1 ))
               continue
            fi
         fi
      fi
   if [[ $keeptmp -eq 0 ]] && [[ $keep_this_one == "no" ]] ; then
      rm $file;
   fi
done

   #----------------------
   # result directory
   cd $testTop/result
   for log in C*log ; do
      keep_this_one="no"
      fstart=$(basename $log .log)
      runcpu=$(grep runcpu: $log)
      config_metric=${runcpu##* -c }       # drop all before the name of the config file
      config=${config_metric%% *}          # drop all after that name
      metric=${config_metric##* }          # maybe a metric, maybe just benchmark names
      if [[ "intrate intspeed fprate fpspeed" =~ $metric ]] ; then
         ismetric=yes
      else
         ismetric=
      fi
      config_shortname=${config#$prefix-}  # when reporting errors ok to be briefer
      config_shortname=$(basename $config_shortname .cfg)

      #
      # mumble.type produced?
      # (can't do this test if ANALYZE_ONLY because might have been cleaned)
      #
      missing=
      if [[ -z $ANALYZE_ONLY ]] ; then
         for type in $types_expected ; do
            if [[ $ismetric ]] ; then
               # Expect very specific files
               if [[ ! -e $fstart.$metric.$type ]] ; then
                  missing="$missing $type"
               fi
            else
               # Command had individual benchmarks. Match more liberally.
               if ! ls $fstart*$type > /dev/null 2>&1 ; then
                  missing="$missing $type"
               fi
            fi
         done
         if [[ $missing ]] ; then
            echo ERROR: $config_shortname $metric $log did not produce: $missing >> $errs_file
            errors=$(( errors + 1 ))      # usually just 1 root cause
            keep_this_one="yes"
         fi
      fi
      #
      # Bad things in the text report?
      #
      if ls $fstart*txt > /dev/null 2>&1 ; then
         unk=$(grep -l Unknown     $fstart*txt)      # Unknown flags?
         est=$(grep -l 'Est. SPEC' $fstart*txt)      # Estimated results?
         # Flags in wrong places?
         portInNonPort=$(grep -l 'Indicates portability flags found in non-portability variables' $fstart*txt)
         optInPort=$(grep -l 'Indicates optimization flags found in portability variables' $fstart*txt)
         if [[ $unk ]] ; then
            echo "ERROR: $config_shortname: Unknown flags in " $unk  >> $errs_file
            nfile=$(echo $unk | wc -w )
            errors=$(( errors + nfile ))
            # hmmm, the count here is +1 for every affected report
            # compare to other 'hmmm'
            keep_this_one="yes"
         fi
         if [[ $ismetric && $est ]] ; then
            echo "ERROR: $config_shortname: metric listed as 'Est.' in " $est  >> $errs_file
            nfile=$(echo $est | wc -w )
            errors=$(( errors + nfile ))
            keep_this_one="yes"
         fi
         if [[ $portInNonPort ]] ; then
            echo "ERROR: $config_shortname: misplaced portability flags in " $portInNonPort >> $errs_file
            nfile=$(echo $portInNonPort | wc -w )
            errors=$(( errors + nfile ))
            keep_this_one="yes"
         fi
         if [[ $optInPort ]] ; then
            echo "ERROR: $config_shortname: misplaced optimization flags in " $optInPort >> $errs_file
            nfile=$(echo $optInPort | wc -w )
            errors=$(( errors + nfile ))
            keep_this_one="yes"
         fi
         # Are flags consistent?
         for file in $fstart*txt ; do
            if ! perl -ne "$baseFlagsNotGroupedByLanguage" $file ; then
               echo "ERROR: $config_shortname: Base Flags not consistent in $file" >> $errs_file
               errors=$(( errors + 1 ))
               keep_this_one="yes"
            fi
         done
      fi
      #
      # clean as much as allowed
      #
      if [[ $keep_this_one == "no" ]] ; then
         if [[ $keeptmp -eq 0 ]] ; then
            rm -f $fstart*
         elif [[ $keeptmp -eq 1 ]] ; then
            for type in $types_expected; do
               if [[ $type != "txt" ]] ; then
                  rm -f $fstart*$type
               fi
            done
         fi
      fi
   done
}


#-----------------------------------------------------------------------------
# main code starts here

if [[ ! -d $SPEC/config ]] ; then
   echo "please define the SPEC env var"
   exit 1
fi

dateX2=$(date "+%Y-%m-%d-%H%M%S %s")
startTime=${dateX2% *}
startVsEpoch=${dateX2#* }

if [[ $ANALYZE_ONLY ]] ; then
   SKIP_USUAL_TESTS=yes
   SKIP_SPECIALS=yes
   KEEPTMP=2
   testTop=$ANALYZE_ONLY
   if [[ ! -d $testTop ]] ; then
      testTop=$outroot/$ANALYZE_ONLY
      if [[ ! -d $testTop ]] ; then
         echo "$BASE0 fatal: directory '$ANALYZE_ONLY' not found\n   nor ' testTop'\n"
         exit 1
      fi
   fi
else
   testTop=$outroot/examples-$startTime
   [[ -z $KEEPTMP ]] && keeptmp=0
   cd $SPEC/config
   list=${config_files:-$(ls Example*cfg)}
   for file in $list ; do
      config=$prefix-${file#Example-}
      cp $file $config
      nconfig=$(( nconfig + 1 ))
   done
fi

errs_file=$testTop/errors.summary.txt
if [[ -e $errs_file ]] ; then
   > $errs_file
fi

[[ -z $ANALYZE_ONLY ]] && init_errs_file

RUNCPU="runcpu --output_root=$testTop --fakereportable "

[[ -z $SKIP_USUAL_TESTS ]] && start_the_usuals
[[ -z $SKIP_SPECIALS ]]    && start_special_cases

wait
analyze_results

# cleanup config
if [[ $keeptmp -eq 0 ]] ; then
   cd $SPEC/config
   rm $prefix*.cfg*
elif [[ $keeptmp -eq 1 ]] ; then
   cd $SPEC/config
   rm $prefix*.cfg.2*
fi

#---------------------
# Summarize
#
dateX2=$(date "+%Y-%m-%d-%H%M%S %s")
EndTime=${dateX2% *}
endVsEpoch=${dateX2#* }
elapsed=$(( endVsEpoch - startVsEpoch ))
echo
echo $EndTime $0
echo Finished testing Example Configs using '--fakereport'/'--fakereportable'
printf "  %5d seconds elapsed time on %s \n" $elapsed $(hostname)
printf "  %5d config files tested\n"         $nconfig
printf "  %5d tests run\n"                   $ntests
printf "  %5d expected failures ignored\n"   $ignored
printf "  %5d errors found"                  $errors
if [[ $errors -eq 0 ]] ; then
   echo "!"
   [[ $keeptmp -eq 0 ]] && rm -r $outroot
   exit 0
else
   echo " -- For detail, see:"
   echo $testTop
   if [[ $errors -gt $few ]] ; then
      echo "Here are there first few errors.  There are more."
   fi
   sort $errs_file | perl -pe 's/^/   /;' | sort | uniq | head -$few
   exit $errors
fi

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=sh syntax=sh shiftwidth=4 tabstop=8 expandtab nosmarttab:
