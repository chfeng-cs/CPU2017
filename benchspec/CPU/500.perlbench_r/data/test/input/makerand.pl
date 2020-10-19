#
# Make a bunch of random numbers (around 1.9 million), and print some of them
# out. That's all.
#

srand(12091209);        # This is important

for (my $max = 4294967295; $max > 0; $max >>= 4) {
  my $i = 237528;
  while($i > 0) {
    $num = int(rand($max));
    $i--;
    next if ($i % 1000);
    print "$i ($max): $num\n";
  }
}
