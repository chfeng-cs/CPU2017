#
# vars_common.pl
#
# Copyright 1995-2019 Standard Performance Evaluation Corporation
#
# $Id: vars_common.pl 6366 2019-08-21 20:15:11Z CloyceS $

##############################################################################
# Initialize Variables
##############################################################################

use strict;
use Config;
use Cwd;
use Sys::Hostname;
use File::Spec::Functions qw(rel2abs);
require 'util_common.pl';

# Customize the name of the suite and the multipliers here
$::suitebase = 'CPU';
$::year = '2017';
$::release_year = 2017;   # Or just set to $::year
$::suite = $::suitebase.$::year;
$::current_version = '1.1.0'; # UPDATE - version: Adjust by hand
$::current_runcpu = 6247; # UPDATE - last changed revision for bin/harness/runcpu: Adjust by hand
$::treeowner = 'cloyce';    # Mostly for cleanuptree
$::treegroup = 'cpudevel';  # Mostly for cleanuptree
$::suite_version = 0;   # Just a placeholder.  MUST BE 0!

# lcsuite should match the name of at least one of your benchsets.  If not,
# be sure to edit expand_all in util_common.pl to do the right thing.
$::lcsuite = lc($::suite);

# Use these when constructing URLs
$::pub_url_base = 'https://www.spec.org/'.$::lcsuite;
$::docs_url_base = $::pub_url_base.'/Docs';
$::auto_url_base = 'http://www.spec.org/auto/'.$::lcsuite;
$::auto_docs_url_base = $::auto_url_base.'/Docs';
$::bench_url_base = $::auto_docs_url_base.'/benchmarks';

my $version = '$LastChangedRevision: 6366 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'vars_common.pl'} = $version;

# Ratio multipliers vs. reference machine
if ($::suite eq 'CPU2017') {
    $::speed_multiplier = 1;      # See osgcpu-14317
    $::rate_multiplier = 1;       # See osgcpu-14317
} else {
    $::speed_multiplier = 1;      # A reasonable default
    $::rate_multiplier = 1;       # A reasonable default
}

# Public location of benchmark and suite flag descriptions
$::spec_flags_base = "https://www.spec.org/auto/$::lcsuite/Docs/benchmarks/flags/";
$::spec_image_base = "https://www.spec.org/auto/$::lcsuite/images/";

# Config items that may not be changed by the user
$::nonvolatile_config = {
    'benchdir'                  => 'benchspec',         # benchmark base directory
    'bindir'                    => 'exe',               # subdirectory containing benchmark executables
    'builddir'                  => 'build',             # Where to do the builds
    'commanderrfile'            => 'speccmds.err',      # Name of command error file
    'commandfile'               => 'speccmds.cmd',      # Name of command file
    'commandoutfile'            => 'speccmds.out',      # Name of command output file
    'commandstdoutfile'         => 'speccmds.stdout',   # Name of command stdout file
    'compareerrfile'            => 'compare.err',       # Name of compare error file
    'comparefile'               => 'compare.cmd',       # Name of compare file
    'compareoutfile'            => 'compare.out',       # Name of compare output file
    'comparestdoutfile'         => 'compare.stdout',    # Name of compare stdout file
    'inputgenerrfile'           => 'inputgen.err',      # Name of input generation error file
    'inputgenfile'              => 'inputgen.cmd',      # Name of input generation file
    'inputgenoutfile'           => 'inputgen.out',      # Name of input generation output file
    'inputgenstdoutfile'        => 'inputgen.stdout',   # Name of input generation stdout file
    'configdir'                 => 'config',            # directory containing config files
    'comparedir'                => 'compare',           # subdir under datadir containing intermediate comparison input files
    'datadir'                   => 'data',              # directory containing input sets
    'default_size'              => 'ref',               # Default size or class of input
    'default_submit'            => '$command',          # Submit command to use when none is specified
    'dirprot'                   => 0777,                # default directory permissions mask
    'discard_power_samples'     => ($::lcsuite =~ /^(omp|accel)/) ? 1 : 0,         # Number of power samples to discard from each end before averaging
    'exehash_bits'              => 512256,              # Arg to get_hash_context (512256 => SHA-512/256)
    'exthash_bits'              => ($::lcsuite eq 'mpi2007') ? 0 : 256,      # Number of bits in hash algo for extended rawfile hash (none=0; MD5=128; SHA>=256)
    'flag_url_base'             => $::spec_flags_base,  # Base URL to use for flags files
    'inputdir'                  => 'input',             # subdir under datadir containing input files
    'log'                       => $::suite,            # base name of log files
    'max_average_uncertainty'   => 1,                   # Maximum avg. % uncertainty of all samples
    'max_hum_limit'             => 0,                   # Maximum allowed humidity in rel% (0 => no limit)
    'max_report_runs'           => ($::lcsuite eq 'cpu2017') ? 3 : ($::lcsuite =~ /^(omp|accel)/ ? 3 : 0), # Maximum number of runs to be valid (0 => no max)
    'max_unknown_uncertainty'   => 1,                   # % of samples allowed w/unknown uncertainty
    'meter_errors_default'      => 5.0,                 # Acceptable percentage of bad samples
    'min_report_runs'           => ($::lcsuite =~ /^(mpi2007|cpu2017)$/) ? 2 : 3, # Minimum number of runs to be valid
    'min_temp_limit'            => 20,                  # Minimum allowed temperature (0 => no limit)
    'orig_argv'                 => [ @ARGV ],           # Stash of ARGV as supplied by the user
    'orig_env'                  =>  { %ENV },           # Stash of original user environment
    'outputdir'                 => 'output',            # subdir under datadir containing reference output files
    'rawhash_bits'              => ($::lcsuite =~ /^(accel|cpu2017|omp)/) ? 256 : 128,        # Number of bits in hash algo for overall rawhash (MD5=128; SHA>=256)
    'reftime'                   => 'reftime',           # file containing reference times for workload
    'resultdir'                 => 'result',            # result directory
    'rundir'                    => 'run',               # subdirectory where runs happen
    'specdiff'                  => 'specdiff',          # Name of program in $SPEC/bin to use to compare results
    'makefile_template'         => 'Makefile.YYYtArGeTYYYspec', # Filename template for Makefile.spec
    'specrun'                   => 'specinvoke',        # Name of program in $SPEC/bin to use to run the benchmark
    'srcdir'                    => 'src',               # subdirectory containing source code
    'sysinfo_hash_bits'         => 256,
    'uncertainty_exception'     => 5,                   # % samples allowed to exceed max_average_uncertainty (this is hardcoded in PTD; we can't change it)
    'valid_actions'             => [ qw(
                                    buildsetup runsetup setup
                                    build only_run onlyrun
                                    run validate
                                    configpp
                                    clean realclean trash clobber scrub
                                    report
                                    makebundle usebundle
                                    ) ],
    'valid_tunes'               => [ qw(base peak) ],
    'worklist'                  => 'list',              # List of subdirectories under run or build directory
};

$::default_config = {
    'OS'                        => 'unix',              # OS type
    'absolutely_no_locking'     => 0,                   # Don't try to lock for run #
    'action'                    => 'validate',          # Default action
    'allow_label_override'      => 0,                   # Label with no settings okay?
    'backup_config'             => 1,                   # Whether to keep backup config file left over from updating exehash
    'basepeak'                  => 0,                   # Use base binary or run for peak measurements
    'calctol'                   => 1,                   # calculate tolerances?
    'check_version'             => 0,                   # Check suite version at SPEC? (Default for reportable only)
    'command_add_redirect'      => 0,                   # Should $command contain shell output redirection?
    'compile_error'             => 0,                   # were there problems compiling?
    'configfile'                => 'default.cfg',       # default configuration file name
    'copies'                    => 1,                   # default number of copies
    'current_range'             => undef,               # Current range for all measurements
    'delay'                     => 0,                   # Sleep a bit before and after each benchmark run?
    'deletebinaries'            => 0,                   # Delete existing binaries?
    'deletework'                => 0,                   # Delete existing working dirs?
    'device'                    => undef,               # Accelerator device setting
    'difflines'                 => 10,                  # default number of lines of specdiff differences printed
    'enable_monitor'            => 1,                   # Allow use of monitor_* hooks
    'endian'                    => $Config{'byteorder'},# Stash specperl's idea of the endianness of the SUT
    'env_vars'                  => 0,                   # Allow environment to be overriden by ENV_*?
    'expand_notes'              => 0,                   # do var expansion in notes?
    'expid'                     => '',                  # Optional subdirectory under which to put exe, run, build, result, etc.
    'label'                     => 'none',              # default label for executables, run dirs, build dirs
    'failflags'                 => 0,                   # Cause unknown or forbidden flags to abort formatting
    'fake'                      => 0,                   # Generate command output without changing anything?
    'feedback'                  => 1,                   # allow feedback directed optimization?
    'flagsurl'                  => '',                  # User flags file URL
    'force_monitor'             => 0,                   # Force monitor hooks to be used, even when they wouldn't normally be
    'http_proxy'                => '',                  # Optional HTTP proxy
    'http_timeout'              => 30,                  # How long to wait for HTTP responses
    'idle_current_range'        => undef,               # Current range for idle measurement
    'idledelay'                 => 10,                  # Delay (in s) before idle power measurement
    'idleduration'              => 60,                  # Length (in s) of idle power measurement
    'ignore_errors'             => 0,                   # Ignore most errors?
    'ignore_sigint'             =>  0,                  # Ignore SIGINT?
    'info_wrap_columns'         => 50,                  # Wrap non-notes at 50 columns by default
    # Number of iterations to run
    'iterations'                => $::nonvolatile_config->{'max_report_runs'} > 0 ? $::nonvolatile_config->{'max_report_runs'} : $::nonvolatile_config->{'min_report_runs'},
    'keeptmp'                   => 0,                   # Keep temporary files?
    'line_width'                => 0,                   # log line wrap width for screen output (0 => no wrapping)
    'link_input_files'          => 1,                   # Try to use hardlinks to have only one copy of input files
    'locking'                   => 1,                   # Try to lock files?
    'log_line_width'            => 0,                   # log line wrap width for log file output (0 => no wrapping)
    'log_timestamp'             => 0,                   # timestamp log lines?
    'mail_reports'              => 'all',               # Which reports to mail for mail "format"
    'mailcompress'              => 0,                   # Compress attachments in email report?
    'mailmethod'                => 'smtp',              # Use direct SMTP by default (instead of "qmail" or "sendmail")
    'mailport'                  => 25,                  # Network port to use for direct SMTP
    'mailserver'                => '127.0.0.1',         # Mail server IP address or hostname
    'mailto'                    => '',                  # Address at which to receive emailed reports
    'make'                      => 'specmake',          # Name of make executable (overridable for non-reportable runs in benchmark.pm)
    'make_no_clobber'           => 0,                   # Don't clean out build directory when building executables
    'makeflags'                 => '',                  # Extra flags for make (like -j)
    'mean_anyway'               => 0,                   # Calculate mean even if run is not valid?
    'meter_connect_timeout'     => 30,                  # How long to wait before giving up when connecting to PTD
    'meter_errors_percentage'   => $::nonvolatile_config->{'meter_errors_default'},
    'minimize_builddirs'        => 0,                   # Empty out build directories after successful build?
    'minimize_rundirs'          => 0,                   # Empty out run directories after successful run?
    'nc'                        => '',                  # format as non-compliant (contents is message)
    'nc_is_cd'                  => 0,                   # format as code defect (boolean)
    'nc_is_na'                  => 0,                   # format as not available (boolean)
    'no_input_handler'          => 'close',             # How specinvoke should handle stdin when none is specified
    'no_monitor'                => '',                  # Which workloads to exclude from monitoring
    'noratios'                  => 0,                   # Run even in the wrong mode?
    'note_preenv'               => 0,                   # Automatically turned on when needed
    'notes_wrap_columns'        => 0,                   # Automatically wrap notes at this column (0 => no wrapping)
    'notes_wrap_indent'         => '  ',                # When automatically wrapping notes, indent continuation 2 spaces
    'os_exe_ext'                => '',                  # Filename extension that denotes an executable
    'output_format'             => 'default',           # output format
    'output_root'               => '',                  # Root of alternate tree in which to build and run
    'parallel_test'             => 0,                   # Execute mandatory test/train runs in parallel?
    'parallel_test_submit'      => 0,                   # Submit commands to use for parallel test/train
    'parallel_test_workloads'   =>'',                   # Workload classes to parallelize (non-reportable runs only)
    'plain_train'               => ($::lcsuite eq 'cpu2017') ? 1 : 0,    # Allow use of submit for training runs?
    'platform'                  => undef,               # Accelerator platform setting
    'power'                     => 0,                   # Do power measurement?
    'preenv'                    => 1,                   # Honor preENV_* settings?
    'prefix'                    => '',                  # prefix to prepend to log file names
    'ranks'                     => -1,                  # Number of ranks (MPI only)
    'rawformat_opts'            => [],                  # options passed to rawformat from runcpu
    'rebuild'                   => 0,                   # Rebuild binaries even if they already exist?
    'reportable'                => 0,                   # Enforce reporting rules?
    'review'                    => 0,                   # Format for review?
    'run'                       => 'all',               # What benchmarks to run
    'runmode'                   => '',                  # rate/shrate/speed?
    'safe_eval'                 => 1,                   # Use very strict opcode mask for string expansion?
    'save_build_files'          => '',                  # Glob patterns of files to keep with executables
    'section_specifier_fatal'   => 1,                   # Is a typo in a section specifier fatal?
    'setprocgroup'              => 1,                   # Attempt to put runcpu and children in a separate process group?
    'setup_error'               => 0,                   # Were there problems during run setup?
    'sigint'                    => undef,               # Signal # of SIGINT
    'size'                      => $::nonvolatile_config->{'default_size'},
    'srcalt'                    => '',                  # approved source mods
    'stagger'                   => 10,                  # Stagger delay (ms) for the staggered homogenous rate
    'strict_rundir_verify'      => 1,                   # Make sure that the hashes of file in the rundir match the MANIFEST _and_ the original source file.
# CVT2DEV: 'strict_rundir_verify'      => 0,
    'sysinfo_program'           => 'specperl $[top]/bin/sysinfo',
    'sysinfo_program_hash'      => 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',  # SHA-256 for nothing
    'table'                     => 1,                   # Produce a table of results (only honored in text output)
    'teeout'                    => 0,                   # Run output through 'tee' so you can see it on the screen
    'threads'                   => -1,                  # Number of threads (OMP/CPU only)
    'train_single_thread'       => 0,                   # Restrict threads to 1 for feedback training runs?
    'train_with'                => 'train',             # Workload to use for training runs
    'tune'                      => 'base',              # default tuning level
    'uid'                       => $<,                  # User ID of the user running runcpu
    'unbuffer'                  => 1,                   # Unbuffer stdout if possible?
    'update'                    => 0,                   # Whether to run flags update
    'update_url'                => "http://www.spec.org/auto/$::lcsuite/updates/",
    'use_submit_for_compare'    => 0,                   # Should submit commands also be used for comparison runs?
    'use_submit_for_speed'      => ($::lcsuite =~ /^(accel|mpi2007|omp)/) ? 1 : 0, # Should submit commands be used even for non-rate runs?
    'verbose'                   => 5,                   # Default verbosity level
    'verify_binaries'           => 1,                   # check saved checksums?
    'voltage_range'             => undef,               # Voltage range for all measurements
};

# The config file parser will complain and abort if it sees any settings for
# fields marked as deprecated or obsolete.  I know that doesn't really match
# the behavior of "deprecated" as commonly accepted, but it's how we want
# it to work.
# These are only the generically undesireable fields.  Usually if a field
# is supplanted somehow (like sw_auto_parallel), it will be handled
# specially.
%::deprecated_config = (
    # Fields should only be deprecated between releases of a particular suite
);
%::obsolete_config = (
    'hw_fpu'            => 1,
    'PATHSEP'           => 1,
    'VENDOR'            => 1,
    'company_name'      => 1,
    'mach'              => 1,
    'machine_name'      => 1,
    'tester_name'       => 1,
    'rate'              => 1,
    'shrate'            => 1,
    'speed'             => 1,
    'noratios'          => 1,
    'max_active_compares' => 1,
    'ext'                      => 1,
    'allow_extension_override' => 1,
    'hw_cpu_mhz'        => 1,
    'hw_cpu_char'       => 1,
    'hw_ncoresperchip'  => 1,
);

%::mime2ext = (
    'image/x-coreldraw'             => 'cdr',
    'image/x-xpm'                   => 'xpm',
    'image/x-3ds'                   => '3ds',
    'image/x-portable-bitmap'       => 'xbm',
    'image/x-portable-greymap'      => 'xgm',
    'image/x-portable-pixmap'       => 'xpm',
    'image/x-niff'                  => 'niff',
    'image/tiff'                    => 'tiff',
    'image/unknown'                 => 'unknown',
    'image/gif'                     => 'gif',
    'image/jpeg'                    => 'jpg',
    'image/bmp'                     => 'bmp',
    'image/png'                     => 'png',
    'image/x-photoshop'             => 'psd',
    'image/x-djvu'                  => 'djvu',
    'image/x.djvu'                  => 'djvu',
    'application/excel'             => 'xls',
    'application/ichitaro4'         => 'jsw',
    'application/ichitaro5'         => 'jaw',
    'application/ichitaro6'         => 'jbw',
    'application/java'              => 'java',
    'application/java-archive'      => 'jar',
    'application/jar'               => 'jar',
    'application/mac-binhex40'      => 'hqx',
    'application/ms-tnef'           => 'tnef',
    'application/msaccess'          => 'mdb',
    'application/msword'            => 'doc',
    'application/octet-stream'      => 'unknown',
    'application/ogg'               => 'ogg',
    'application/pdf'               => 'pdf',
    'application/postscript'        => 'ps',
    'application/powerpoint'        => 'ppt',
    'application/vnd.rn-realmedia'  => 'ram',
    'application/x-123'             => '123',
    'application/x-arc'             => 'arc',
    'application/x-archive'         => 'arc',
    'application/x-arj'             => 'arj',
    'application/x-awk'             => 'awk',
    'application/x-bittorrent'      => 'torrent',
    'application/x-bzip2'           => 'bz2',
    'application/bzip2'             => 'bz2',
    'application/x-compress'        => 'Z',
    'application/compress'          => 'Z',
    'application/x-coredump'        => 'core',
    'application/x-cpio'            => 'cpio',
    'application/x-dbf'             => 'dbf',
    'application/x-dbm'             => 'dbm',
    'application/x-dbt'             => 'dbt',
    'application/x-debian-package'  => 'deb',
    'application/x-dosexec'         => 'exe',
    'application/x-dvi'             => 'dvi',
    'application/x-elc'             => 'elc',
    'application/x-executable'      => 'exe',
    'application/x-frame'           => 'fm',
    'application/x-gawk'            => 'awk',
    'application/x-gdbm'            => 'dbm',
    'application/x-gzip'            => 'gz',
    'application/gzip'              => 'gz',
    'application/x-iso9660'         => 'iso',
    'application/x-kdelnk'          => 'link',
    'application/x-lha'             => 'lha',
    'application/x-lharc'           => 'lha',
    'application/x-nawk'            => 'awk',
    'application/x-object'          => 'o',
    'application/x-perl'            => 'pl',
    'application/x-rar'             => 'rar',
    'application/x-realaudio'       => 'ra',
    'application/x-rpm'             => 'rpm',
    'application/x-sc'              => 'sc',
    'application/x-sharedlib'       => 'so',
    'application/x-shellscript'     => 'sh',
    'application/x-shockwave-flash' => 'swf',
    'application/x-stuffit'         => 'sit',
    'application/x-stuffitx'        => 'sit',
    'application/x-svr4-package'    => 'pkg',
    'application/x-tar'             => 'tar',
    'application/tar'               => 'tar',
    'application/x-tex-tfm'         => 'tfm',
    'application/x-zip'             => 'zip',
    'application/x-zip-compressed'  => 'zip',
    'application/zip'               => 'zip',
    'application/x-zoo'             => 'zoo',
    'text/plain'                    => 'txt',
    'text/html'                     => 'html',
);

# List of flags file filenames seen, and their source URLs
%::seen_flags_filenames = ();
%::seen_flags_files     = ();

sub initialize_variables {
    my ($config) = @_;

    for (keys %$::default_config) {
        $config->{$_} = $::default_config->{$_};
    }
    for (keys %$::nonvolatile_config) {
        $config->{$_} = $::nonvolatile_config->{$_};
    }

    $config->{'runcpu'} = join(' ', ($0, @ARGV));

    # If this is an invocation started by runcpu (as for preenv), strip out
    # command-line options that should not be presented to users for cut-n-
    # paste.
    if (any(sub { $_ eq '--from_runcpu' }, @ARGV)) {
        my $lastfield = '';
        $config->{'orig_argv'} = [ grep { if (m/^-{1,2}([^=[:space:]]+)/) { $lastfield = $1 } !exists($::runcpu_only_options{$1}) and !$::runcpu_only_options{$lastfield} } @{$config->{'orig_argv'}} ];
    }

    $config->{'hostname'} = hostname;

    my $name = '';
    $name = $ENV{'SPECUSER'}     if ($name eq '') && (exists $ENV{'SPECUSER'});
    $name = $ENV{'USER'}         if ($name eq '') && (exists $ENV{'USER'});
    $name = $ENV{'USERNAME'}     if ($name eq '') && (exists $ENV{'USERNAME'});
    $name = $ENV{'LOGNAME'}      if ($name eq '') && (exists $ENV{'LOGNAME'});
    $name = eval q/getlogin || getpwuid $config->{'uid'}/ if ($name eq '');
    $name = $config->{'uid'}     if ($name eq '');
    $name = 'default'            if ($name eq '');
    $config->{'username'} = $name;      # May be changed by command line

    # Check to see if OS was specified in environment
    $config->{'OS'} = lc($ENV{'OS'}) if exists($ENV{'OS'}) && ($ENV{'OS'} ne '');
    if ($config->{'OS'} =~ /^windows/) {
        $config->{'os_exe_ext'} = '.exe';
        $config->{'ignore_sigint'} = 1;
    }

    # See where the top of the SPEC tree is
    $config->{'top'} = $ENV{'SPEC'};
    $config->{'top'} = cwd if $ENV{'SPEC'} eq '' || ! -d $ENV{'SPEC'};
    $config->{'specrun'} = jp($config->top, $config->specrun);

    # Check to see if sigint is defined in the Config data
    {
        my @nums = split(" ", $Config{'sig_num'});
        my @names = split(" ", $Config{'sig_name'});
        while (@nums && @names) {
            my $num = shift @nums;
            my $name = shift @names;
            if ($name eq 'INT') {
                $config->{'sigint'} = $num;
                last;
            }
        }
    }

}

# For files where Subversion hasn't fixed up the %::tools_versions entry, assume it's in git and
# substitute the current short commit hash plus any modified notation as well.  If it's not git, just
# note that all the versions are UNKNOWN.
sub fixup_tools_versions {
    my (%toolvers) = @_;

    my %git_status;

    foreach my $file (grep { $toolvers{$_} =~ /\044Last/ } sort keys %toolvers) {
        my $path = find_inc($file);
        if (!defined($path)) {
            $toolvers{$file} = 'NOT_FOUND';
        } else {
            if (%git_status) {
                my @status;
                if (exists($git_status{$path})) {
                    push @status, $git_status{$path};
                }
                if (exists($git_status{'branch.oid'})) {
                    push @status, $git_status{'branch.head'}.'@'.$git_status{'branch.oid'};
                }
                push @status, $git_status{'__default'} unless @status;
                $toolvers{$file} = join('-', @status);
            } else {
                %git_status = (
                    '__default' => 'UNKNOWN',
                    read_git_status(dirname($path)),
                );

                # Go around again for this file.
                redo;
            }
        }
    }

    return %toolvers;
}

sub find_inc {
    my ($file) = @_;

    return $INC{$file} if -e $INC{$file};

    foreach my $dir (@INC, map { jp($_, 'formats') } @INC) {
        my $path = jp($dir, $file);
        return $path if -e $path;
    }
    return undef;
}

# Read current git tree status, including branch info, so that version info can be returned.
sub read_git_status {
    my ($path) = @_;
    my %rc = ();

    my %status_codes = (
        'M' => 'MODIFIED',
        'A' => 'ADDED',
        'D' => 'DELETED',
        'R' => 'RENAMED',
        'C' => 'COPIED',
        'U' => 'UPDATED+UNMERGED',
    );

    my @status = qx{cd '$path'; git status --porcelain=v2 --branch};

    # Output looks like
    # # branch.oid 1d71d5b6c36ef9d3a924034e2b3d3b5238616491
    # # branch.head master
    # 1 .M N... 100644 100644 100644 e7a6d5f83b79f59011720d1ad53c385e0acc02ae e7a6d5f83b79f59011720d1ad53c385e0acc02ae ../benchspec/CPU/intrate.bset
    # [...]

    while(defined(my $line = shift(@status))) {
        my @fields = split(/\s+/, $line);

        # # branch.head master
        if ($fields[0] eq '#') {
            $rc{$fields[1]} = $fields[2];
        }
        else {
            my $file = rel2abs(pop(@fields), $path);

            # [12] .M ...  ../benchspec/CPU/intrate.bset
            if ($fields[0] == 1 or $fields[0] == 2) {
                my %statuses = map { $status_codes{$_} => 1 } split(//, $fields[1]);
                my $status = join(',', sort grep { $_ ne '' } keys %statuses);
                $rc{$file} = $status;
                # Also get the original path for renamed/copied files, if it's not there already
                if ($fields[0] == 2) {
                    $file = rel2abs(pop(@fields), $path);
                    $rc{$file} = $status unless exists($rc{$file});
                }
            }
            elsif ($fields[0] eq 'u') {
                $rc{$file} = 'unmerged-'.$fields[1];
            }
            elsif ($fields[0] eq '?' and !exists($rc{$file})) {
                $rc{$file} = 'untracked';
            }
            elsif ($fields[0] eq '!' and !exists($rc{$file})) {
                $rc{$file} = 'ignored';
            }
        }
    }

    # Fix up the head commit to include the date (if we got the head commit)
    if (exists($rc{'branch.oid'})) {
        my $tmp = qx{cd '$path'; git log -n 1 --format='format:%h@%cI' $rc{'branch.oid'}};
        chomp($rc{'branch.oid'} = $tmp) if length($tmp) > 2;
    }

    return %rc;
}


sub finalize_config {
    my ($config, $cl_opts) = @_;
    # Command line options override config file options

    for ( keys %$cl_opts) {
        next if $_ eq 'ref' || $_ eq 'refs';
        $config->{$_} = $cl_opts->{$_};
    }

    # Make sure none of the unchangeble constants changed
    for ( keys %$::nonvolatile_config) {
        $config->{$_} = $::nonvolatile_config->{$_};
    }
}

sub suiteinfo {
    # Output suitable for Bourne shell eval
    print "suite='$::suite'\n";
    print "lcsuite='$::lcsuite'\n";
    print "suitebase='$::suitebase'\n";
    print "year='$::year'\n";
    print "release_year='$::release_year'\n";
    print "current_version='$::current_version'\n";
    print "current_runcpu='$::current_runcpu'\n";
    print "treeowner='$::treeowner'\n";
    print "treegroup='$::treegroup'\n";
    print "is_release='".(::is_release($::current_version) ? 1 : 0)."'\n";
}

1;

__END__

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab colorcolumn=120:
