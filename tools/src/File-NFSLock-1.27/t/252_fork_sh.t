# Shared Fork Test
#
# This tests the capabilities of fork after lock to
# ensure child retains shared lock even if parent releases it.
# This test uses ->fork() instead of ->newpid()

use strict;
use warnings;
use File::Temp qw(tempfile);

use Test::More;
use File::NFSLock;
use Fcntl qw(O_CREAT O_RDWR O_RDONLY O_TRUNC O_APPEND LOCK_EX LOCK_SH LOCK_NB);

$| = 1; # Buffer must be autoflushed because of fork() below.
if( $^O eq 'MSWin32' ) {
  plan skip_all => 'Tests fail on Win32 due to forking';
} else {
  plan tests => 6;
}

my $datafile = (tempfile 'XXXXXXXXXX')[1];

# Wipe lock file in case it exists
unlink ("$datafile$File::NFSLock::LOCK_EXTENSION");

# Create a blank file
sysopen ( my $fh, $datafile, O_CREAT | O_RDWR | O_TRUNC );
close ($fh);
ok (-e $datafile && !-s _);

{
  # Forced dummy scope
  my $lock1 = new File::NFSLock {
    file => $datafile,
    lock_type => LOCK_SH,
  };

  ok ($lock1);

  my $pid = $lock1->fork;
  if (!defined $pid) {
    die "fork failed!";
  } elsif (!$pid) {
    # Child process

    # Act busy for a while
    sleep 5;

    # Now release lock
    exit;
  } else {
    # Fork worked
    ok 1;

    # Leaving scope should release only the parent side
  }
}
# Lock is out of scope, but should
# still be acquired by the child.

# Try to get a non-blocking lock.
# Yes, it is the same process,
# but it should have been delegated
# to the child process.
# This lock should fail.
{
  # Forced dummy scope
  my $lock2 = new File::NFSLock {
    file => $datafile,
    lock_type => LOCK_EX|LOCK_NB,
  };

  ok (!$lock2);
}

# Wait for child to finish
ok(wait);

# Try again now that the child is done.
# This time it should work.
{
  # Forced dummy scope
  my $lock2 = new File::NFSLock {
    file => $datafile,
    lock_type => LOCK_EX|LOCK_NB,
  };

  ok($lock2);
}

# Wipe the temporary file
unlink $datafile;
