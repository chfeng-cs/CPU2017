# Thanks to Yary in http://www.perlmonks.org/?node_id=1114157 for the skeleton of this.
#
# $Id: EmptyButTrue.pm 4814 2016-09-01 20:54:01Z CloyceS $
#
package EmptyButTrue;
our $val;

use overload
  fallback => 'TRUE',
  '""' => sub { "" }, # Return empty string on stringification
  bool => sub { 1 },  # Return true in boolean context
  '0+' => sub { 1 },  # Return true in numeric context
  cmp  => sub { !ref $_[1] } # unequal to empty string, or any other string
  ;

bless $val=\$val;

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
